local variables = import './variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local prometheus = g.query.prometheus;

{
  m_infrastructure: {
    query():
      prometheus.withExpr('cluster_infrastructure_provider{namespace="openshift-kube-apiserver-operator"}')
      + prometheus.withInstant(true)
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{type}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

  },

  m_region: {
    query():
      prometheus.withExpr('cluster_infrastructure_provider{namespace="openshift-kube-apiserver-operator"}')
      + prometheus.withInstant(true)
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{region}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  m_ocp_version: {
    query():
      prometheus.withExpr('cluster_version{type="completed",version!="",namespace="openshift-cluster-version"}')
      + prometheus.withInstant(true)
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{version}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  num_hosted_cluster: {
    query():
      prometheus.withExpr('count(kube_namespace_labels{namespace=~"^ocm-.*"})')
      + prometheus.withInstant(true)
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  current_namespace_count: {
    query():
      prometheus.withExpr('sum(kube_namespace_status_phase) by (phase)')
      + prometheus.withInstant(true)
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ phase }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  current_node_count: {
    query():
      [
        prometheus.withExpr('sum(kube_node_info{})')
        + prometheus.withInstant(true)
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Number of nodes')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('sum(kube_node_status_condition{status="true"}) by (condition) > 0')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Node: {{ condition }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('sum(kube_node_role{}) by (role)')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Role: {{ role }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  current_pod_count: {
    query():
      prometheus.withExpr('sum(kube_pod_status_phase{}) by (phase) > 0')
      + prometheus.withInstant(true)
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ phase}} Pods')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContCPUHosted: {
    query():
      prometheus.withExpr('topk(10,irate(container_cpu_usage_seconds_total{namespace=~"^ocm-.*",container!="POD",name!=""}[2m])*100)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ namespace }} - {{ name }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContMemHosted: {
    query():
      prometheus.withExpr('topk(10, container_memory_rss{namespace=~"^ocm-.*",container!="POD",name!=""})')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ namespace }} - {{ name }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContCPUManagement: {
    query():
      prometheus.withExpr('topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[2m])*100)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ namespace }} - {{ name }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContMemManagement: {
    query():
      prometheus.withExpr('topk(10, container_memory_rss{namespace!="",container!="POD",name!=""})')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ namespace }} - {{ name }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContCPUOBOManagement: {
    query():
      prometheus.withExpr('topk(10,irate(container_cpu_usage_seconds_total{namespace="openshift-observability-operator",container!="POD",name!=""}[2m])*100)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ pod }}/{{ container }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContMemOBOManagement: {
    query():
      prometheus.withExpr('topk(10, container_memory_rss{namespace="openshift-observability-operator",container!="POD",name!=""})')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ pod }}/{{ container }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContCPUHypershiftManagement: {
    query():
      prometheus.withExpr('topk(10,irate(container_cpu_usage_seconds_total{namespace="hypershift",container!="POD",name!=""}[2m])*100)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ pod }}/{{ container }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  top10ContMemHypershiftManagement: {
    query():
      prometheus.withExpr('topk(10, container_memory_rss{namespace="hypershift",container!="POD",name!=""})')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ pod }}/{{ container }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  dynaactivegateMem: {
    query():
      prometheus.withExpr('sum(container_memory_rss{namespace=~"dynatrace",pod=~".*-activegate-.*",container!=""}) by (node, namespace, pod)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ node }}: {{ namespace }} : {{ pod }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  dynaactivegateCPU: {
    query():
      prometheus.withExpr('sum(irate(container_cpu_usage_seconds_total{namespace=~"dynatrace", pod=~".*-activegate-.*", container!~"POD|"}[2m])*100) by (node, namespace, pod)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ node }}: {{ namespace }} : {{ pod }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  opentelemetryCPU: {
    query():
      prometheus.withExpr('sum(irate(container_cpu_usage_seconds_total{namespace=~"dynatrace", pod=~"opentelemetry-.*", container!~"POD|"}[2m])*100) by (node, namespace, pod)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ node }}: {{ namespace }} : {{ pod }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  opentelemetryMem: {
    query():
      prometheus.withExpr('sum(container_memory_rss{namespace=~"dynatrace",pod=~"opentelemetry-.*",container!=""}) by (node, namespace, pod)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ node }}: {{ namespace }} : {{ pod }}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  nodeCount: {
    query():
      [
        prometheus.withExpr('sum(kube_node_info{})')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Number of nodes')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
        prometheus.withExpr('sum(kube_node_status_condition{status="true"}) by (node,condition) > 0')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{node}}: {{ condition }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  current_machine_set_replica_count: {
    query():
      [
        prometheus.withExpr('mapi_machine_set_status_replicas{name=~".*worker.*"}')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Replicas: {{ name }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('mapi_machine_set_status_replicas_available{name=~".*worker.*"}')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Available: {{ name }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('mapi_machine_set_status_replicas_ready{name=~".*worker.*"}')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('Ready: {{ name }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  nsCount: {
    query():
      prometheus.withExpr('sum(kube_namespace_status_phase) by (phase) > 0')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{ phase }} namespaces')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  podCount: {
    query():
      prometheus.withExpr('sum(kube_pod_status_phase{}) by (phase)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{phase}} pods')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  clusterOperatorsInformation: {
    query():
      prometheus.withExpr('cluster_operator_conditions{name!="",reason!=""}')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{name}} - {{reason}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  clusterOperatorsDegraded: {
    query():
      prometheus.withExpr('cluster_operator_conditions{condition="Degraded",name!="",reason!=""}')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{name}} - {{reason}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  FailedPods: {
    query():
      [
        prometheus.withExpr('kube_pod_status_phase{phase="Failed"}')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}}/{{ pod }}:{{ phase }}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
        prometheus.withExpr('count(kube_pod_status_phase{phase="Failed"})')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{phase}} pods')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  alerts: {
    query():
      prometheus.withExpr('topk(10,sum(ALERTS{severity!="none"}) by (alertname, severity))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{severity}}: {{alertname}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_disk_wal_sync_duration: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(irate(etcd_disk_wal_fsync_duration_seconds_bucket{namespace=~"openshift-etcd"}[2m])) by (namespace, pod, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{namespace}} - {{pod}} WAL fsync')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_disk_backend_sync_duration: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(irate(etcd_disk_backend_commit_duration_seconds_bucket{namespace=~"openshift-etcd"}[2m])) by (namespace, pod, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{namespace}} - {{pod}} DB fsync')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },
  mgmt_percent_db_used: {
    query():
      prometheus.withExpr('(etcd_mvcc_db_total_size_in_bytes{namespace=~"openshift-etcd"} / etcd_server_quota_backend_bytes{namespace=~"openshift-etcd"})*100')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{namespace}} - {{pod}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_db_capacity_left: {
    query():
      prometheus.withExpr('etcd_server_quota_backend_bytes{namespace=~"openshift-etcd"} - etcd_mvcc_db_total_size_in_bytes{namespace=~"openshift-etcd"}')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{namespace}} - {{pod}}')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_db_size_limit: {
    query():
      prometheus.withExpr('etcd_server_quota_backend_bytes{namespace=~"openshift-etcd"}')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{namespace}} - {{ pod }} Quota Bytes')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_db_size: {
    query():
      [
        prometheus.withExpr('etcd_mvcc_db_total_size_in_bytes{namespace=~"openshift-etcd"}')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - {{pod}} DB physical size')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('etcd_mvcc_db_total_size_in_use_in_bytes{namespace=~"openshift-etcd"}')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - {{pod}} DB logical size')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_grpc_traffic: {
    query():
      [
        prometheus.withExpr('rate(etcd_network_client_grpc_received_bytes_total{namespace=~"openshift-etcd"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('rx {{namespace}} - {{pod}}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('rate(etcd_network_client_grpc_sent_bytes_total{namespace=~"openshift-etcd"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('tx {{namespace}} - {{pod}}')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_active_streams: {
    query():
      [
        prometheus.withExpr('sum(grpc_server_started_total{namespace=~"openshift-etcd",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace=~"openshift-etcd",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"})')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - Watch Streams')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('sum(grpc_server_started_total{namespace=~"openshift-etcd",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace=~"openshift-etcd",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"})')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - Lease Streams')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_snapshot_duration: {
    query():
      prometheus.withExpr('sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum{namespace=~"openshift-etcd"}[2m]))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('the total latency distributions of save called by snapshot')
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_raft_proposals: {
    query():
      [
        prometheus.withExpr('sum(rate(etcd_server_proposals_failed_total{namespace=~"openshift-etcd"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - Proposal Failure Rate')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('sum(etcd_server_proposals_pending{namespace=~"openshift-etcd"})')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - Proposal Pending Total')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('sum(rate(etcd_server_proposals_committed_total{namespace=~"openshift-etcd"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - Proposal Commit Rate')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('sum(rate(etcd_server_proposals_applied_total{namespace=~"openshift-etcd"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('{{namespace}} - Proposal Apply Rate')
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_num_leader_changes: {
    query():
      prometheus.withExpr('sum(rate(etcd_server_leader_changes_seen_total{namespace=~"openshift-etcd"}[2m]))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_etcd_has_leader: {
    query():
      prometheus.withExpr('max(etcd_server_has_leader{namespace=~"openshift-etcd"})')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_num_failed_proposals: {
    query():
      prometheus.withExpr('max(etcd_server_proposals_committed_total{namespace=~"openshift-etcd"})')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_leader_elections_per_day: {
    query():
      prometheus.withExpr('changes(etcd_server_leader_changes_seen_total{namespace=~"openshift-etcd"}[1d])')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{instance}} Total Leader Elections Per Day')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_keys: {
    query():
      prometheus.withExpr('etcd_debugging_mvcc_keys_total{namespace=~"openshift-etcd"}')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{ pod }} Num keys')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  mgmt_slow_operations: {
    query():
      [
        prometheus.withExpr('delta(etcd_server_slow_apply_total{namespace=~"openshift-etcd"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} slow applies')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('delta(etcd_server_slow_read_indexes_total{namespace=~"openshift-etcd"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} slow read indexes')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_key_operations: {
    query():
      [
        prometheus.withExpr('rate(etcd_mvcc_put_total{namespace=~"openshift-etcd"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} puts/s')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('rate(etcd_mvcc_delete_total{namespace=~"openshift-etcd"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} deletes/s')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_heartbeat_failures: {
    query():
      [
        prometheus.withExpr('etcd_server_heartbeat_send_failures_total{namespace=~"openshift-etcd"}')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} heartbeat  failures')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),

        prometheus.withExpr('etcd_server_health_failures{namespace=~"openshift-etcd"}')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} health failures')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  mgmt_compacted_keys: {
    query():
      [
        prometheus.withExpr('etcd_debugging_mvcc_db_compaction_keys_total{namespace=~"openshift-etcd"}')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod  }} keys compacted')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
      ],
  },

  nodeCPU: {
    query():
      prometheus.withExpr('sum by (instance, mode)(irate(node_cpu_seconds_total{job=~".*"}[2m])) * 100 and on (instance) label_replace(cluster:nodes_roles{label_hypershift_openshift_io_cluster=~"$namespace"}, "instance", "$1", "node", "(.+)")')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{instance}} - {{mode}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  nodeMemory: {
    query():
      prometheus.withExpr('node_memory_Active_bytes and on (instance) label_replace(cluster:nodes_roles{label_hypershift_openshift_io_cluster=~"$namespace"}, "instance", "$1", "node", "(.+)")')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{instance}} - Active')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  suricataCPU: {
    query():
      prometheus.withExpr('sum(irate(container_cpu_usage_seconds_total{namespace=~"openshift-suricata",container!="POD",name!=""}[2m])*100) by (node) and on (node) label_replace(cluster:nodes_roles{label_hypershift_openshift_io_cluster=~"$namespace"}, "node", "$1", "node", "(.+)")')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{node}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  suricataMemory: {
    query():
      prometheus.withExpr('sum(container_memory_rss{namespace=~"openshift-suricata",container!="POD",name!=""}) by (node) and on (node) label_replace(cluster:nodes_roles{label_hypershift_openshift_io_cluster=~"$namespace"}, "node", "$1", "node", "(.+)")')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{node}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  dynaoneagentCPU: {
    query():
      prometheus.withExpr('sum(irate(container_cpu_usage_seconds_total{namespace=~"dynatrace", pod=~".*-oneagent-.*", container!~"POD|"}[2m])*100) by (node, namespace, pod)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{ node }}: {{ namespace }} : {{ pod }}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  dynaoneagentMem: {
    query():
      prometheus.withExpr('sum(container_memory_rss{namespace=~"dynatrace",pod=~".*-oneagent-.*",container!=""}) by (node, namespace, pod)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{ node }}: {{ namespace }} : {{ pod }}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  infrastructure: {
    query():
      prometheus.withExpr('cluster_infrastructure_provider{namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withLegendFormat('{{type}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  region: {
    query():
      prometheus.withExpr('cluster_infrastructure_provider{namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withLegendFormat('{{region}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  ocp_version: {
    query():
      prometheus.withExpr('cluster_version{type="completed",version!="",namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withLegendFormat('{{version}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  hostedControlPlaneCPU: {
    query():
      prometheus.withExpr('cluster_version{type="completed",version!="",namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{version}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  hostedControlPlaneMemory: {
    query():
      prometheus.withExpr('topk(10, container_memory_rss{namespace=~"$namespace",container!="POD",name!=""})')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{pod}}/{{container}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('PF55DCC5EC58ABF5A'),
  },

  request_duration_99th_quantile: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[2m])) by(verb,le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{verb}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  request_rate_by_instance: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",code=~"$code",verb=~"$verb"}[2m])) by(instance)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{instance}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  request_duration_99th_quantile_by_resource: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[2m])) by(resource, namespace, verb, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{verb}}:{{resource}}/{{namespace}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  request_rate_by_resource: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",code=~"$code",verb=~"$verb"}[2m])) by(resource)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{resource}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  request_duration_read_write: {
    query():
      [
        prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",verb=~"LIST|GET"}[2m])) by(le))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('read')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[2m])) by(le))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('write')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  request_rate_read_write: {
    query():
      [
        prometheus.withExpr('sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",verb=~"LIST|GET"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('read')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('write')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  requests_dropped_rate: {
    query():
      prometheus.withExpr('sum(rate(apiserver_dropped_requests_total{namespace=~"$namespace"}[2m])) by (requestKind)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  requests_terminated_rate: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_terminations_total{namespace=~"$namespace",resource=~"$resource",code=~"$code"}[2m])) by(component)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  requests_status_rate: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",verb=~"$verb",code=~"$code"}[2m])) by(code)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{code}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  long_running_requests: {
    query():
      prometheus.withExpr('sum(apiserver_longrunning_gauge{namespace=~"$namespace",resource=~"$resource",verb=~"$verb"}) by(instance)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{instance}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  request_in_flight: {
    query():
      prometheus.withExpr('sum(apiserver_current_inflight_requests{namespace=~"$namespace"}) by (instance,requestKind)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{requestKind}}-{{instance}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_requests_rejected: {
    query():
      prometheus.withExpr('sum(rate(apiserver_flowcontrol_rejected_requests_total{namespace=~"$namespace"}[2m])) by (reason)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  response_size_99th_quartile: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_response_sizes_bucket{namespace=~"$namespace",resource=~"$resource",verb=~"$verb"}[2m])) by(instance,le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{instance}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_request_queue_length: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_queue_length_after_enqueue_bucket{namespace=~"$namespace"}[2m])) by(flowSchema, priorityLevel, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_request_wait_duration_99th_quartile: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_wait_duration_seconds_bucket{namespace=~"$namespace"}[2m])) by(flowSchema, priorityLevel, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_request_execution_duration: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_execution_seconds_bucket{namespace=~"$namespace"}[2m])) by(flowSchema, priorityLevel, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_request_dispatch_rate: {
    query():
      prometheus.withExpr('sum(rate(apiserver_flowcontrol_dispatched_requests_total{namespace=~"$namespace"}[2m])) by(flowSchema,priorityLevel)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_concurrency_limit: {
    query():
      prometheus.withExpr('sum(apiserver_flowcontrol_request_concurrency_limit{namespace=~"$namespace"}) by (priorityLevel)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{priorityLevel}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  pf_pending_in_queue: {
    query():
      prometheus.withExpr('sum(apiserver_flowcontrol_current_inqueue_requests{namespace=~"$namespace"}) by (flowSchema,priorityLevel)')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  disk_wal_sync_duration: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(irate(etcd_disk_wal_fsync_duration_seconds_bucket{namespace=~"$namespace"}[2m])) by (namespace, pod, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{pod}} WAL fsync')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  disk_backend_sync_duration: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(irate(etcd_disk_backend_commit_duration_seconds_bucket{namespace=~"$namespace"}[2m])) by (namespace, pod, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{pod}} DB fsync')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  percent_db_used: {
    query():
      prometheus.withExpr('(etcd_mvcc_db_total_size_in_bytes{namespace=~"$namespace"} / etcd_server_quota_backend_bytes{namespace=~"$namespace"})*100')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{pod}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  db_capacity_left: {
    query():
      prometheus.withExpr('etcd_server_quota_backend_bytes{namespace=~"$namespace"} - etcd_mvcc_db_total_size_in_bytes{namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{pod}}')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },


  db_size_limit: {
    query():
      prometheus.withExpr('etcd_server_quota_backend_bytes{namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{ pod }} Quota Bytes')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  db_size: {
    query():
      [
        prometheus.withExpr('etcd_mvcc_db_total_size_in_bytes{namespace=~"$namespace"}')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{pod}} DB physical size')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('etcd_mvcc_db_total_size_in_use_in_bytes{namespace=~"$namespace"}')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{pod}} DB logical size')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  grpc_traffic: {
    query():
      [
        prometheus.withExpr('rate(etcd_network_client_grpc_received_bytes_total{namespace=~"$namespace"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('rx {{namespace}} - {{pod}}')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('rate(etcd_network_client_grpc_sent_bytes_total{namespace=~"$namespace"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('tx {{namespace}} - {{pod}}')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  active_streams: {
    query():
      [
        prometheus.withExpr('sum(grpc_server_started_total{namespace=~"$namespace",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace=~"$namespace",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"})')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - Watch Streams')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('sum(grpc_server_started_total{namespace=~"$namespace",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace=~"$namespace",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"})')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - Lease Streams')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  snapshot_duration: {
    query():
      prometheus.withExpr('sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum{namespace=~"$namespace"}[2m]))')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('the total latency distributions of save called by snapshot')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  raft_proposals: {
    query():
      [
        prometheus.withExpr('sum(rate(etcd_server_proposals_failed_total{namespace=~"openshift-etcd"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - Proposal Failure Rate')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('sum(etcd_server_proposals_pending{namespace=~"$namespace"})')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - Proposal Pending Total')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('sum(rate(etcd_server_proposals_committed_total{namespace=~"$namespace"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - Proposal Commit Rate')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('sum(rate(etcd_server_proposals_applied_total{namespace=~"$namespace"}[2m]))')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - Proposal Apply Rate')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

      ],
  },

  num_leader_changes: {
    query():
      prometheus.withExpr('sum(rate(etcd_server_leader_changes_seen_total{namespace=~"$namespace"}[2m]))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  etcd_has_leader: {
    query():
      prometheus.withExpr('max(etcd_server_has_leader{namespace=~"$namespace"})')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  num_failed_proposals: {
    query():
      prometheus.withExpr('max(etcd_server_proposals_committed_total{namespace=~"$namespace"})')
      + prometheus.withFormat('time_series')
      + prometheus.withInstant(true)
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  leader_elections_per_day: {
    query():
      prometheus.withExpr('changes(etcd_server_leader_changes_seen_total{namespace=~"$namespace"}[1d])')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{instance}} Total Leader Elections Per Day')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  keys: {
    query():
      prometheus.withExpr('etcd_debugging_mvcc_keys_total{namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{ pod }} Num keys')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

  slow_operations: {
    query():
      [
        prometheus.withExpr('delta(etcd_server_slow_apply_total{namespace=~"$namespace"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} slow applies')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('delta(etcd_server_slow_read_indexes_total{namespace=~"$namespace"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} slow read indexes')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  key_operations: {
    query():
      [
        prometheus.withExpr('rate(etcd_mvcc_put_total{namespace=~"$namespace"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} puts/s')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('rate(etcd_mvcc_delete_total{namespace=~"$namespace"}[2m])')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} deletes/s')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  heartbeat_failures: {
    query():
      [
        prometheus.withExpr('etcd_server_heartbeat_send_failures_total{namespace=~"$namespace"}')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} heartbeat  failures')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),

        prometheus.withExpr('etcd_server_health_failures{namespace=~"$namespace')
        + prometheus.withFormat('time_series')
        + prometheus.withLegendFormat('{{namespace}} - {{ pod }} health failures')
        + prometheus.withIntervalFactor(2)
        + prometheus.withDatasource('P1BA917A37525EDF3'),
      ],
  },

  compacted_keys: {
    query():
      prometheus.withExpr('etcd_debugging_mvcc_db_compaction_keys_total{namespace=~"$namespace"}')
      + prometheus.withFormat('time_series')
      + prometheus.withLegendFormat('{{namespace}} - {{ pod  }} keys compacted')
      + prometheus.withIntervalFactor(2)
      + prometheus.withDatasource('P1BA917A37525EDF3'),
  },

}
