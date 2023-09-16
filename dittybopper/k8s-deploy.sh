#!/usr/bin/env bash

set -e

function _usage {
  cat <<END

Deploys a mutable grafana pod with default dashboards for monitoring
system submetrics during workload/benchmark runs

Usage: $(basename "${0}") [-c <kubectl_cmd>] [-n <namespace>] [-p <grafana_pwd>]

       $(basename "${0}") [-i <dash_path>]

       $(basename "${0}") [-d] [-n <namespace>]

  -c <kubectl_cmd>  : The (c)ommand to use for k8s admin (defaults to 'kubectl' for now)

  -n <namespace>    : The (n)amespace in which to deploy the Grafana instance
                      (defaults to 'dittybopper')

  -p <grafana_pass> : The (p)assword to configure for the Grafana admin user
                      (defaults to 'admin')

  -i <dash_path>    : (I)mport dashboard from given path. Using this flag will
                      bypass the deployment process and only do the import to an
                      already-running Grafana pod. Can be a local path or a remote
                      URL beginning with http.

  -d                : (D)elete an existing deployment

  -h                : Help

END
}

# Set default template variables

export PROMETHEUS_USER=internal
export GRAFANA_ADMIN_PASSWORD=admin
export GRAFANA_URL="http://admin:${GRAFANA_ADMIN_PASSWORD}@localhost:3000"
export DASHBOARDS="k8s-performance.json"
export SYNCER_IMAGE=${SYNCER_IMAGE:-"quay.io/cloud-bulldozer/dittybopper-syncer:latest"} # Syncer image
export GRAFANA_IMAGE=${GRAFANA_IMAGE:-"quay.io/cloud-bulldozer/grafana:9.4.3"} # Syncer image


# Set defaults for command options
k8s_cmd='kubectl'
namespace='dittybopper'
grafana_default_pass=True

# Other vars
deploy_template="templates/k8s-dittybopper.yaml.template"

# Capture and act on command options
while getopts ":c:m:n:p:i:dh" opt; do
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
echo ""
echo -e "\033[32mGetting environment vars...\033[0m"
export PROMETHEUS_URL=http://$($k8s_cmd get endpoints -n prometheus prometheus-server -o jsonpath="{.subsets[0].addresses[0].ip}"):$($k8s_cmd get endpoints -n prometheus prometheus-server -o jsonpath="{.subsets[0].ports[0].port}")
echo "Prometheus URL is: ${PROMETHEUS_URL}"

function namespace() {
  # Create namespace
  $k8s_cmd "$1" namespace "$namespace"
}

function grafana() {
  envsubst < ${deploy_template} | $k8s_cmd "$1" -n "$namespace" -f -
  if [[ ! $delete ]]; then
    echo ""
    echo -e "\033[32mWaiting for dittybopper deployment to be available...\033[0m"
    $k8s_cmd wait --for=condition=available -n $namespace deployment/dittybopper --timeout=60s
  fi
}

function dash_import(){
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
    echo "{\"dashboard\": ${dashboard}, \"overwrite\": true}" | \
    curl -Ss -XPOST -H "Content-Type: application/json" -H "Accept: application/json" -d@- \
    "http://admin:${GRAFANA_ADMIN_PASSWORD}@127.0.0.1:3000/api/dashboards/db" -o /dev/null
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
  $k8s_cmd -n $namespace port-forward service/dittybopper 3000 &
  # Ugly, but need to slow things down when opening the port-forward
  sleep 5
  dash_import
  echo "You can access the Grafana instance at http://127.0.0.1:3000"
fi
