#!/usr/bin/env bash

set -e

function _usage {
  cat <<END

Deploys a mutable grafana pod with default dashboards for monitoring
system submetrics during workload/benchmark runs

Usage: $(basename "${0}") [-c <kubectl_cmd>] [-n <namespace>] [-p <grafana_pwd>]

       $(basename "${0}") [-i <dash_path>]

       $(basename "${0}") [-d] [-n <namespace>]

  -c <kubectl_cmd>  : The (c)ommand to use for k8s admin (defaults to 'oc' for now)

  -n <namespace>    : The (n)amespace in which to deploy the Grafana instance
                      (defaults to 'dittybopper')

  -p <grafana_pass> : The (p)assword to configure for the Grafana admin user
                      (defaults to 'admin')

  -i <dash_path>    : (I)mport dashboard from given path. Using this flag will
                      bypass the deployment process and only do the import to an
                      already-running Grafana pod. Can be a local path or a remote
                      URL beginning with http.

  -t <template_path>: Use custom dittybopper template from local path, default will be templates/dittybopper.yaml.template

  -d                : (D)elete an existing deployment

  -h                : Help

END
}

# Set default template variables
export PROMETHEUS_USER=internal
export GRAFANA_ADMIN_PASSWORD=admin
export GRAFANA_URL="http://admin:${GRAFANA_ADMIN_PASSWORD}@localhost:3000"
export SYNCER_IMAGE=${SYNCER_IMAGE:-"quay.io/cloud-bulldozer/dittybopper-syncer:latest"} # Syncer image
export GRAFANA_IMAGE=${GRAFANA_IMAGE:-"quay.io/cloud-bulldozer/grafana:9.4.3"} # Syncer image

# Set defaults for command options
k8s_cmd='oc'
namespace='dittybopper'
namespace_file="$(dirname $(realpath ${BASH_SOURCE[0]}))/templates/dittybopper_ns.yaml.template"
grafana_default_pass=True

# Capture and act on command options
while getopts ":c:m:n:p:i:t:dh" opt; do
  case ${opt} in
    c)
      k8s_cmd=${OPTARG}
      ;;
    n)
      namespace="${OPTARG}"
      ;;
    p)
      export GRAFANA_ADMIN_PASSWORD=${OPTARG}
      grafana_default_pass=False
      ;;
    i)
      dash_import+=(${OPTARG})
      ;;
    t)
      template=${OPTARG}
    ;;
    d)
      delete=True
      ;;
    h)
      _usage
      exit 1
      ;;
    \?)
      echo -e "\033[32mERROR: Invalid option -${OPTARG}\033[0m" >&2
      _usage
      exit 1
      ;;
    :)
      echo -e "\033[32mERROR: Option -${OPTARG} requires an argument.\033[0m" >&2
      _usage
      exit 1
      ;;
  esac
done


if [[ ! -z ${template} ]]; then
  deploy_template=${template}
else
  deploy_template="$(dirname $(realpath ${BASH_SOURCE[0]}))/templates/dittybopper.yaml.template"
fi


echo "${dash_import[@]}"
echo -e "\033[32m
    ____  _ __  __        __
   / __ \(_) /_/ /___  __/ /_  ____  ____  ____  ___  _____
  / / / / / __/ __/ / / / __ \/ __ \/ __ \/ __ \/ _ \/ ___/
 / /_/ / / /_/ /_/ /_/ / /_/ / /_/ / /_/ / /_/ /  __/ /
/_____/_/\__/\__/\__, /_.___/\____/ .___/ .___/\___/_/
                /____/           /_/   /_/

\033[0m"
echo "Using k8s command: $k8s_cmd"
echo "Using namespace: $namespace"
if [[ ${grafana_default_pass} ]]; then
  echo "Using default grafana password: ${GRAFANA_ADMIN_PASSWORD}"
else
  echo "Using custom grafana password."
fi


# Get environment values
#FIXME: This is OCP-Specific; needs updating to support k8s
echo ""
echo -e "\033[32mGetting environment vars...\033[0m"
export PROMETHEUS_URL="https://$($k8s_cmd get routes -n openshift-monitoring prometheus-k8s -o jsonpath="{.spec.host}")"
export PROMETHEUS_BEARER=$($k8s_cmd create token -n openshift-monitoring prometheus-k8s --duration 240h || $k8s_cmd sa get-token -n openshift-monitoring prometheus-k8s || $k8s_cmd sa new-token -n openshift-monitoring prometheus-k8s)
echo "Prometheus URL is: ${PROMETHEUS_URL}"
if [[ -n ${PROMETHEUS_BEARER} ]]; then
  echo "Prometheus bearer token collected."
else
  echo "ERROR: Prometheus bearer token is not collected."
  exit 1
fi

# Identify Hypershift Management Cluster
if [ $($k8s_cmd get crd hostedclusters.hypershift.openshift.io 2>/dev/null | wc -l) -ne 0 ] ; then
  echo "Detected Hypershift Management Cluster"
  export HYPERSHIFT_MANAGEMENT_CLUSTER="yes"
  export OBO_URL="http://hypershift-monitoring-stack-prometheus.openshift-observability-operator.svc.cluster.local:9090"
fi

function namespace() {
  # Create namespace
  $k8s_cmd "$1" -f "$namespace_file"
}

function grafana() {
  envsubst < ${deploy_template} | $k8s_cmd "$1" -n "$namespace" -f -
  if [[ ! $delete ]]; then
    echo ""
    echo -e "\033[32mWaiting for dittybopper deployment to be available...\033[0m"
    if $k8s_cmd wait --for=condition=available -n $namespace deployment/dittybopper --timeout=60s; then
      return 0
    else
      $k8s_cmd get pods -n $namespace
      $k8s_cmd get deploy -n $namespace
      $k8s_cmd logs -l app=dittybopper --max-log-requests=100 -n $namespace --all-containers=true
      exit 1
    fi
  fi
}

function dash_import(){
  sleep 5
  echo -e "\033[32mImporting dashboards...\033[0m"
  for dash in ${dash_import[@]}; do
    if [[ $dash =~ ^http ]]; then
      echo "Fetching remote dashboard $dash"
      dashfile="/tmp/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)"
      curl -sS $dash -o $dashfile
    else
      echo "Using local dashboard ${dash}"
      dashfile=$dash
    fi
    dashboard=$(cat ${dashfile})
    dashboard_request="{\"dashboard\": ${dashboard}, \"overwrite\": true}"
    response_code=$(curl -Ss -w "%{http_code}" -X POST -H "Content-Type: application/json" -H "Accept: application/json" -d "${dashboard_request}" \
    "http://admin:${GRAFANA_ADMIN_PASSWORD}@${dittybopper_route}/api/dashboards/db" -o /tmp/resp.txt)
    if [[ $response_code != "200" ]]; then
      echo ""
      echo -e "\033[31mFailed to import dashboard ${dash}\033[0m"
      cat  /tmp/resp.txt
      echo ""
      echo -e "\033[31mYou can find the above output in /tmp/resp.txt\033[0m"
      exit 1
    else
      echo -e "\033[32mImported dashboard ${dash}\033[0m"
    fi
  done
}

if [[ $delete ]]; then
  echo ""
  echo -e "\033[32mDeleting Grafana...\033[0m"
  grafana "delete"
  echo ""
  echo -e "\033[32mDeleting namespace...\033[0m"
  namespace "delete"
  echo ""
  echo -e "\033[32mDeployment deleted!\033[0m"
else
  echo ""
  echo -e "\033[32mCreating namespace...\033[0m"
  # delete the namespace if it already exists to make sure the latest version of the dashboards are deployed and also to support the case where user wants to redeploy dittybopper without having to delete the namespace manually
  if [[ $($k8s_cmd get namespaces | grep -w $namespace) ]]; then
    echo "Looks like the namespace $namespace already exists, deleting it"
    namespace "delete"
  fi
  namespace "create"
  echo ""
  echo -e "\033[32mDeploying Grafana...\033[0m"
  grafana "apply"
  echo ""
  dittybopper_route=$($k8s_cmd -n $namespace get route dittybopper  -o jsonpath="{.spec.host}")
  [[ ! -z ${dash_import} ]] && dash_import
  echo "You can access the Grafana instance at http://${dittybopper_route}"
fi
