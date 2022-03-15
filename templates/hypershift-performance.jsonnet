local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local stat = grafana.statPanel;

// Panel definitions

// Hypershift Hosted Cluster Components

local genericGraphLegendPanel(title, format) = grafana.graphPanel.new(
  title=title,
  datasource='$datasource',
  format=format,
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  nullPointMode='null as zero',
  sort='decreasing',
);

local hostedControlPlaneCPU = genericGraphLegendPanel('Hosted Control Plane CPU', 'none').addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_cpu_usage_seconds{namespace=~"$namespace",app=~"etcd.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
).addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_cpu_usage_seconds{namespace=~"$namespace",app=~".*kube.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
).addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_cpu_usage_seconds{namespace=~"$namespace",app=~"cluster.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
).addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_cpu_usage_seconds{namespace=~"$namespace",app=~"openshift.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
);

local hostedControlPlaneMemory = genericGraphLegendPanel('Hosted Control Plane Memory', 'bytes').addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_memory_usage{namespace=~"$namespace",app=~"etcd.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
).addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_memory_usage{namespace=~"$namespace",app=~".*kube.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
).addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_memory_usage{namespace=~"$namespace",app=~"cluster.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
).addTarget(
  prometheus.target(
    'topk(10,hypershift:controlplane:component_memory_usage{namespace=~"$namespace",app=~"openshift.*"})',
    legendFormat='hyper - {{namespace}} - {{app}}',
  )
);

// Overall Status

local num_hosted_cluster = stat.new(
  title='Number of HostedCluster',
  datasource='$datasource',
  graphMode='none',
  reducerFunction='max',
).addTarget(
  prometheus.target(
    'count(kube_namespace_labels{namespace=~"clusters-.*"})',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local m_ocp_version = stat.new(
  title='Management OCP Version',
  datasource='$datasource',
  textMode='name',
  graphMode='none',
).addTarget(
  prometheus.target(
    'cluster_version{type="completed",version!="",namespace="openshift-cluster-version"}',
    legendFormat='{{version}}',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local ocp_version = stat.new(
  title='HostedCluster OCP Version',
  datasource='$datasource',
  textMode='name',
  graphMode='none',
).addTarget(
  prometheus.target(
    'cluster_version{type="completed",version!="",namespace=~"$namespace"}',
    legendFormat='{{version}}',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local infrastructure = stat.new(
  title='Cloud Infrastructure',
  datasource='$datasource',
  textMode='name',
  graphMode='none',
).addTarget(
  prometheus.target(
    'cluster_infrastructure_provider{namespace=~"$namespace"}',
    legendFormat='{{type}}',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local region = stat.new(
  title='Cloud Region',
  datasource='$datasource',
  textMode='name',
  graphMode='none',
).addTarget(
  prometheus.target(
    'cluster_infrastructure_provider{namespace=~"$namespace"}',
    legendFormat='{{region}}',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local m_infrastructure = stat.new(
  title='Management Cloud Infrastructure',
  datasource='$datasource',
  textMode='name',
  graphMode='none',
).addTarget(
  prometheus.target(
    'cluster_infrastructure_provider{namespace="openshift-kube-apiserver-operator"}',
    legendFormat='{{type}}',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local m_region = stat.new(
  title='Management Cloud Region',
  datasource='$datasource',
  textMode='name',
  graphMode='none',
).addTarget(
  prometheus.target(
    'cluster_infrastructure_provider{namespace="openshift-kube-apiserver-operator"}',
    legendFormat='{{region}}',
  )
).addThresholds([
  { color: 'green', value: null },
]);

local top10ContMem = genericGraphLegendPanel('Top 10 container RSS', 'bytes').addTarget(
  prometheus.target(
    'topk(10, container_memory_rss{namespace=~"clusters-.*",container!="POD",name!=""})',
    legendFormat='{{ namespace }} - {{ name }}',
  )
);

local top10ContCPU = genericGraphLegendPanel('Top 10 container CPU', 'percent').addTarget(
  prometheus.target(
    'topk(10,irate(container_cpu_usage_seconds_total{namespace=~"clusters-.*",container!="POD",name!=""}[1m])*100)',
    legendFormat='{{ namespace }} - {{ name }}',
  )
);

// ETCD metrics

local fs_writes = grafana.graphPanel.new(
  title='Etcd container disk writes',
  datasource='$datasource',
  format='Bps',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'rate(container_fs_writes_bytes_total{namespace=~"$namespace",container="etcd",device!~".+dm.+"}[2m])',
    legendFormat='{{namespace}} - {{ pod }}: {{ device }}',
  )
);

local ptp = grafana.graphPanel.new(
  title='p99 peer to peer latency',
  datasource='$datasource',
  format='s',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{namespace=~"$namespace"}[2m]))',
    legendFormat='{{namespace}} - {{pod}}',
  )
);

local disk_wal_sync_duration = grafana.graphPanel.new(
  title='Disk WAL Sync Duration',
  datasource='$datasource',
  format='s',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(irate(etcd_disk_wal_fsync_duration_seconds_bucket{namespace=~"$namespace"}[2m])) by (namespace, pod, le))',
    legendFormat='{{namespace}} - {{pod}} WAL fsync',
  )
);

local disk_backend_sync_duration = grafana.graphPanel.new(
  title='Disk Backend Sync Duration',
  datasource='$datasource',
  format='s',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(irate(etcd_disk_backend_commit_duration_seconds_bucket{namespace=~"$namespace"}[2m])) by (namespace, pod, le))',
    legendFormat='{{namespace}} - {{pod}} DB fsync',
  )
);

local db_size = grafana.graphPanel.new(
  title='DB Size',
  datasource='$datasource',
  format='bytes',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'etcd_mvcc_db_total_size_in_bytes{namespace=~"$namespace"}',
    legendFormat='{{namespace}} - {{pod}} DB physical size'
  )
).addTarget(
  prometheus.target(
    'etcd_mvcc_db_total_size_in_use_in_bytes{namespace=~"$namespace"}',
    legendFormat='{{namespace}} - {{pod}} DB logical size',
  )
);


local cpu_usage = grafana.graphPanel.new(
  title='CPU usage',
  datasource='$datasource',
  format='percent',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'sum(irate(container_cpu_usage_seconds_total{namespace=~"$namespace", container="etcd"}[2m])) by (namespace, pod) * 100',
    legendFormat='{{namespace}} - {{ pod }}',
  )
);

local mem_usage = grafana.graphPanel.new(
  title='Memory usage',
  datasource='$datasource',
  format='bytes',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'sum(avg_over_time(container_memory_working_set_bytes{container="",pod!="", namespace=~"$namespace"}[2m])) BY (pod, namespace)',
    legendFormat='{{namespace}} - {{ pod }}',
  )
);

local network_traffic = grafana.graphPanel.new(
  title='Container network traffic',
  datasource='$datasource',
  format='Bps',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'sum(rate(container_network_receive_bytes_total{ container="etcd", namespace=~"$namespace"}[2m])) BY (namespace, pod)',
    legendFormat='rx {{namespace}} - {{ pod }}'
  )
).addTarget(
  prometheus.target(
    'sum(rate(container_network_transmit_bytes_total{ container="etcd", namespace=~"$namespace"}[2m])) BY (namespace, pod)',
    legendFormat='tx {{namespace}} - {{ pod }}',
  )
);


local grpc_traffic = grafana.graphPanel.new(
  title='gRPC network traffic',
  datasource='$datasource',
  format='Bps',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'rate(etcd_network_client_grpc_received_bytes_total{namespace=~"$namespace"}[2m])',
    legendFormat='rx {{namespace}} - {{pod}}'
  )
).addTarget(
  prometheus.target(
    'rate(etcd_network_client_grpc_sent_bytes_total{namespace=~"$namespace"}[2m])',
    legendFormat='tx {{namespace}} - {{pod}}',
  )
);

local peer_traffic = grafana.graphPanel.new(
  title='Peer network traffic',
  datasource='$datasource',
  format='Bps',
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  sort='decreasing',
  nullPointMode='null as zero',
).addTarget(
  prometheus.target(
    'rate(etcd_network_peer_received_bytes_total{namespace=~"$namespace"}[2m])',
    legendFormat='rx {{namespace}} - {{pod}} Peer Traffic'
  )
).addTarget(
  prometheus.target(
    'rate(etcd_network_peer_sent_bytes_total{namespace=~"$namespace"}[2m])',
    legendFormat='tx {{namespace}} - {{pod}} Peer Traffic',
  )
);


local active_streams = grafana.graphPanel.new(
  title='Active Streams',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(grpc_server_started_total{namespace=~"$namespace",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace=~"$namespace",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"})',
    legendFormat='{{namespace}} - Watch Streams',
  )
).addTarget(
  prometheus.target(
    'sum(grpc_server_started_total{namespace=~"$namespace",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace=~"$namespace",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"})',
    legendFormat='{{namespace}} - Lease Streams',
  )
);

local snapshot_duration = grafana.graphPanel.new(
  title='Snapshot duration',
  datasource='$datasource',
  format='s',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum{namespace=~"$namespace"}[2m]))',
    legendFormat='the total latency distributions of save called by snapshot',
  )
);

//DB Info per Member

local percent_db_used = grafana.graphPanel.new(
  title='% DB Space Used',
  datasource='$datasource',
  format='percent',
).addTarget(
  prometheus.target(
    '(etcd_mvcc_db_total_size_in_bytes{namespace=~"$namespace"} / etcd_server_quota_backend_bytes{namespace=~"$namespace"})*100',
    legendFormat='{{namespace}} - {{pod}}',
  )
);

local db_capacity_left = grafana.graphPanel.new(
  title='DB Left capacity (with fragmented space)',
  datasource='$datasource',
  format='bytes',
).addTarget(
  prometheus.target(
    'etcd_server_quota_backend_bytes{namespace=~"$namespace"} - etcd_mvcc_db_total_size_in_bytes{namespace=~"$namespace"}',
    legendFormat='{{namespace}} - {{pod}}',
  )
);

local db_size_limit = grafana.graphPanel.new(
  title='DB Size Limit (Backend-bytes)',
  datasource='$datasource',
  format='bytes'
).addTarget(
  prometheus.target(
    'etcd_server_quota_backend_bytes{namespace=~"$namespace"}',
    legendFormat='{{namespace}} - {{ pod }} Quota Bytes',
  )
);

// Proposals, leaders, and keys section

local keys = grafana.graphPanel.new(
  title='Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_keys_total{namespace=~"$namespace",pod=~"$pod"}',
    legendFormat='{{namespace}} - {{ pod }} Num keys',
  )
);

local compacted_keys = grafana.graphPanel.new(
  title='Compacted Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_db_compaction_keys_total{namespace=~"$namespace",pod=~"$pod"}',
    legendFormat='{{namespace}} - {{ pod  }} keys compacted',
  )
);

local heartbeat_failures = grafana.graphPanel.new(
  title='Heartbeat Failures',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_server_heartbeat_send_failures_total{namespace=~"$namespace",pod=~"$pod"}',
    legendFormat='{{namespace}} - {{ pod }} heartbeat  failures',
  )
).addTarget(
  prometheus.target(
    'etcd_server_health_failures{namespace=~"$namespace",pod=~"$pod"}',
    legendFormat='{{namespace}} - {{ pod }} health failures',
  )
);


local key_operations = grafana.graphPanel.new(
  title='Key Operations',
  datasource='$datasource',
  format='ops',
) {
  yaxes: [
    {
      format: 'ops',
      show: 'true',
    },
    {
      format: 'short',
      show: 'false',
    },
  ],
}.addTarget(
  prometheus.target(
    'rate(etcd_debugging_mvcc_put_total{namespace=~"$namespace",pod=~"$pod"}[2m])',
    legendFormat='{{namespace}} - {{ pod }} puts/s',
  )
).addTarget(
  prometheus.target(
    'rate(etcd_debugging_mvcc_delete_total{namespace=~"$namespace",pod=~"$pod"}[2m])',
    legendFormat='{{namespace}} - {{ pod }} deletes/s',
  )
);

local slow_operations = grafana.graphPanel.new(
  title='Slow Operations',
  datasource='$datasource',
  format='ops',
) {
  yaxes: [
    {
      format: 'ops',
      show: 'true',
    },
    {
      format: 'short',
      show: 'false',
    },
  ],
}.addTarget(
  prometheus.target(
    'delta(etcd_server_slow_apply_total{namespace=~"$namespace",pod=~"$pod"}[2m])',
    legendFormat='{{namespace}} - {{ pod }} slow applies',
  )
).addTarget(
  prometheus.target(
    'delta(etcd_server_slow_read_indexes_total{namespace=~"$namespace",pod=~"$pod"}[2m])',
    legendFormat='{{namespace}} - {{ pod }} slow read indexes',
  )
);

local raft_proposals = grafana.graphPanel.new(
  title='Raft Proposals',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_failed_total{namespace=~"$namespace"}[2m]))',
    legendFormat='{{namespace}} - Proposal Failure Rate',
  )
).addTarget(
  prometheus.target(
    'sum(etcd_server_proposals_pending{namespace=~"$namespace"})',
    legendFormat='{{namespace}} - Proposal Pending Total',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_committed_total{namespace=~"$namespace"}[2m]))',
    legendFormat='{{namespace}} - Proposal Commit Rate',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_applied_total{namespace=~"$namespace"}[2m]))',
    legendFormat='{{namespace}} - Proposal Apply Rate',
  )
);

local leader_elections_per_day = grafana.graphPanel.new(
  title='Leader Elections Per Day',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'changes(etcd_server_leader_changes_seen_total{namespace=~"$namespace"}[1d])',
    legendFormat='{{namespace}} - {{instance}} Total Leader Elections Per Day',
  )
);

local etcd_has_leader = grafana.singlestat.new(
  title='Etcd has a leader?',
  datasource='$datasource',
  valueMaps=[
    {
      op: '=',
      text: 'YES',
      value: '1',
    },
    {
      op: '=',
      text: 'NO',
      value: '0',
    },
  ]
).addTarget(
  prometheus.target(
    'max(etcd_server_has_leader{namespace=~"$namespace"})',
  )
);

local num_leader_changes = grafana.graphPanel.new(
  title='Number of leader changes seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_leader_changes_seen_total{namespace=~"$namespace"}[2m]))',
  )
);

local num_failed_proposals = grafana.singlestat.new(
  title='Total number of failed proposals seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'max(etcd_server_proposals_committed_total{namespace=~"$namespace"})',
  )
);

// API metrics

local request_duration_99th_quantile = grafana.graphPanel.new(
  title='request duration - 99th quantile',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[1m])) by(verb,le))',
    legendFormat='{{verb}}',
  )
);

local request_rate_by_instance = grafana.graphPanel.new(
  title='request rate - by instance',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",code=~"$code",verb=~"$verb"}[1m])) by(instance)',
    legendFormat='{{instance}}',
  )
);

local request_duration_99th_quantile_by_resource = grafana.graphPanel.new(
  title='request duration - 99th quantile - by resource',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[1m])) by(resource,le))',
    legendFormat='{{resource}}',
  )
);

local request_rate_by_resource = grafana.graphPanel.new(
  title='request duration - 99th quantile',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",code=~"$code",verb=~"$verb"}[1m])) by(resource)',
    legendFormat='{{resource}}',
  )
);

local request_duration_read_write = grafana.graphPanel.new(
  title='request duration - read vs write',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",verb=~"LIST|GET"}[1m])) by(le))',
    legendFormat='read',
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{namespace=~"$namespace",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[1m])) by(le))',
    legendFormat='write',
  )
);


local request_rate_read_write = grafana.graphPanel.new(
  title='request rate - read vs write',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",verb=~"LIST|GET"}[1m]))',
    legendFormat='read',
  )
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[1m]))',
    legendFormat='write',
  )
);


local requests_dropped_rate = grafana.graphPanel.new(
  title='requests dropped rate',
  datasource='$datasource',
  description='Number of requests dropped with "Try again later" response',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_dropped_requests_total{namespace=~"$namespace"}[1m])) by (requestKind)',
  )
);


local requests_terminated_rate = grafana.graphPanel.new(
  title='requests terminated rate',
  datasource='$datasource',
  description='Number of requests which apiserver terminated in self-defense',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_terminations_total{namespace=~"$namespace",resource=~"$resource",code=~"$code"}[1m])) by(component)',
  )
);

local requests_status_rate = grafana.graphPanel.new(
  title='requests status rate',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{namespace=~"$namespace",resource=~"$resource",verb=~"$verb",code=~"$code"}[1m])) by(code)',
    legendFormat='{{code}}'
  )
);

local long_running_requests = grafana.graphPanel.new(
  title='long running requests',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(apiserver_longrunning_gauge{namespace=~"$namespace",resource=~"$resource",verb=~"$verb"}) by(instance)',
    legendFormat='{{instance}}'
  )
);

local request_in_flight = grafana.graphPanel.new(
  title='requests in flight',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(apiserver_current_inflight_requests{namespace=~"$namespace"}) by (instance,requestKind)',
    legendFormat='{{requestKind}}-{{instance}}',
  )
);

local pf_requests_rejected = grafana.graphPanel.new(
  title='p&f - requests rejected',
  datasource='$datasource',
  description='Number of requests rejected by API Priority and Fairness system',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_flowcontrol_rejected_requests_total{namespace=~"$namespace"}[1m])) by (reason)',
  )
);

local response_size_99th_quartile = grafana.graphPanel.new(
  title='response size - 99th quantile',
  datasource='$datasource',
  description='Response size distribution in bytes for each group, version, verb, resource, subresource, scope and component',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_response_sizes_bucket{namespace=~"$namespace",resource=~"$resource",verb=~"$verb"}[1m])) by(instance,le))',
    legendFormat='{{instance}}',
  )
);

local pf_request_queue_length = grafana.graphPanel.new(
  title='p&f - request queue length',
  datasource='$datasource',
  description='Length of queue in the API Priority and Fairness system, as seen by each request after it is enqueued',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_queue_length_after_enqueue_bucket{namespace=~"$namespace"}[1m])) by(flowSchema, priorityLevel, le))',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_request_wait_duration_99th_quartile = grafana.graphPanel.new(
  title='p&f - request wait duration - 99th quantile',
  datasource='$datasource',
  description='Length of time a request spent waiting in its queue',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_wait_duration_seconds_bucket{namespace=~"$namespace"}[1m])) by(flowSchema, priorityLevel, le))',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_request_execution_duration = grafana.graphPanel.new(
  title='p&f - request execution duration',
  datasource='$datasource',
  description='Duration of request execution in the API Priority and Fairness system',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_execution_seconds_bucket{namespace=~"$namespace"}[1m])) by(flowSchema, priorityLevel, le))',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_request_dispatch_rate = grafana.graphPanel.new(
  title='p&f - request dispatch rate',
  datasource='$datasource',
  description='Number of requests released by API Priority and Fairness system for service',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_flowcontrol_dispatched_requests_total{namespace=~"$namespace"}[1m])) by(flowSchema,priorityLevel)',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_concurrency_limit = grafana.graphPanel.new(
  title='p&f - concurrency limit by priority level',
  datasource='$datasource',
  description='Shared concurrency limit in the API Priority and Fairness system',
).addTarget(
  prometheus.target(
    'sum(apiserver_flowcontrol_request_concurrency_limit{namespace=~"$namespace"}) by (priorityLevel)',
    legendFormat='{{priorityLevel}}'
  )
);

local pf_pending_in_queue = grafana.graphPanel.new(
  title='p&f - pending in queue',
  datasource='$datasource',
  description='Number of requests currently pending in queues of the API Priority and Fairness system',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(apiserver_flowcontrol_current_inqueue_requests{namespace=~"$namespace"}) by (flowSchema,priorityLevel)',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);


// Creating the dashboard from the panels described above.

grafana.dashboard.new(
  'Hypershift Performance',
  description='',
  timezone='utc',
  time_from='now-1h',
  editable='true'
)

.addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    '',
    label='datasource'
  )
)

.addTemplate(
  grafana.template.new(
    'namespace',
    '$datasource',
    'label_values(kube_pod_info, namespace)',
    '',
    regex='/(clusters-.*|.*hosted.*)/',
    refresh=2,
  ) {
    label: 'Namespace',
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'pod',
    '$datasource',
    'label_values({pod=~"etcd.*", namespace="$namespace"}, pod)',
    refresh=1,
  ) {
    type: 'query',
    multi: false,
    includeAll: false,
  }
)

.addTemplate(
  grafana.template.new(
    'resource',
    '$datasource',
    'label_values(apiserver_request_duration_seconds_bucket, resource)',
    refresh='time',
    label='resource'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'code',
    '$datasource',
    'label_values(code)',
    refresh='time',
    label='code',
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'verb',
    '$datasource',
    'label_values(verb)',
    refresh='time',
    label='verb',
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addPanel(grafana.row.new(title='Overall stats', collapse=true).addPanels(
  [
    m_infrastructure { gridPos: { x: 0, y: 0, w: 6, h: 4 } },
    m_region { gridPos: { x: 6, y: 0, w: 6, h: 4 } },
    m_ocp_version { gridPos: { x: 12, y: 0, w: 6, h: 4 } },
    num_hosted_cluster { gridPos: { x: 18, y: 0, w: 6, h: 4 } },
    top10ContCPU { gridPos: { x: 0, y: 4, w: 12, h: 8 } },
    top10ContMem { gridPos: { x: 12, y: 4, w: 12, h: 8 } },
  ],
), { gridPos: { x: 0, y: 4, w: 24, h: 1 } })

.addPanel(grafana.row.new(title='HostedControlPlane stats - $namespace', collapse=true, repeat='namespace').addPanels(
  [
    infrastructure { gridPos: { x: 0, y: 0, w: 8, h: 4 } },
    region { gridPos: { x: 8, y: 0, w: 8, h: 4 } },
    ocp_version { gridPos: { x: 16, y: 0, w: 8, h: 4 } },
    hostedControlPlaneCPU { gridPos: { x: 0, y: 12, w: 12, h: 8 } },
    hostedControlPlaneMemory { gridPos: { x: 12, y: 12, w: 12, h: 8 } },
    request_duration_99th_quantile { gridPos: { x: 0, y: 20, w: 6, h: 8 } },
    request_rate_by_instance { gridPos: { x: 6, y: 20, w: 6, h: 8 } },
    request_duration_99th_quantile_by_resource { gridPos: { x: 12, y: 20, w: 6, h: 8 } },
    request_rate_by_resource { gridPos: { x: 18, y: 20, w: 6, h: 8 } },
    request_duration_read_write { gridPos: { x: 0, y: 30, w: 6, h: 8 } },
    request_rate_read_write { gridPos: { x: 6, y: 30, w: 6, h: 8 } },
    requests_dropped_rate { gridPos: { x: 12, y: 30, w: 6, h: 8 } },
    requests_terminated_rate { gridPos: { x: 18, y: 30, w: 6, h: 8 } },
    requests_status_rate { gridPos: { x: 0, y: 40, w: 6, h: 8 } },
    long_running_requests { gridPos: { x: 6, y: 40, w: 6, h: 8 } },
    request_in_flight { gridPos: { x: 12, y: 40, w: 6, h: 8 } },
    pf_requests_rejected { gridPos: { x: 18, y: 40, w: 6, h: 8 } },
    response_size_99th_quartile { gridPos: { x: 0, y: 50, w: 6, h: 8 } },
    pf_request_queue_length { gridPos: { x: 6, y: 50, w: 6, h: 8 } },
    pf_request_wait_duration_99th_quartile { gridPos: { x: 12, y: 50, w: 6, h: 8 } },
    pf_request_execution_duration { gridPos: { x: 18, y: 50, w: 6, h: 8 } },
    pf_request_dispatch_rate { gridPos: { x: 0, y: 60, w: 6, h: 8 } },
    pf_concurrency_limit { gridPos: { x: 6, y: 60, w: 6, h: 8 } },
    pf_pending_in_queue { gridPos: { x: 12, y: 60, w: 6, h: 8 } },
  ],
), { gridPos: { x: 0, y: 4, w: 24, h: 1 } })

.addPanel(
  grafana.row.new(title='ETCD General Resource Usage', collapse=true).addPanels(
    [
      disk_wal_sync_duration { gridPos: { x: 0, y: 2, w: 12, h: 8 } },
      disk_backend_sync_duration { gridPos: { x: 12, y: 2, w: 12, h: 8 } },
      percent_db_used { gridPos: { x: 0, y: 10, w: 8, h: 8 } },
      db_capacity_left { gridPos: { x: 8, y: 10, w: 8, h: 8 } },
      db_size_limit { gridPos: { x: 16, y: 10, w: 8, h: 8 } },
      db_size { gridPos: { x: 0, y: 18, w: 12, h: 8 } },
      grpc_traffic { gridPos: { x: 12, y: 18, w: 12, h: 8 } },
      active_streams { gridPos: { x: 0, y: 26, w: 12, h: 8 } },
      snapshot_duration { gridPos: { x: 12, y: 26, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='ETCD General Info', collapse=true).addPanels(
    [
      raft_proposals { gridPos: { x: 0, y: 1, w: 12, h: 8 } },
      num_leader_changes { gridPos: { x: 12, y: 1, w: 12, h: 8 } },
      etcd_has_leader { gridPos: { x: 0, y: 8, w: 6, h: 2 } },
      num_failed_proposals { gridPos: { x: 6, y: 8, w: 6, h: 2 } },
      leader_elections_per_day { gridPos: { x: 0, y: 12, w: 12, h: 6 } },
      keys { gridPos: { x: 12, y: 12, w: 12, h: 8 } },
      slow_operations { gridPos: { x: 0, y: 20, w: 12, h: 8 } },
      key_operations { gridPos: { x: 12, y: 20, w: 12, h: 8 } },
      heartbeat_failures { gridPos: { x: 0, y: 28, w: 12, h: 8 } },
      compacted_keys { gridPos: { x: 12, y: 28, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 3, w: 24, h: 1 } }
)
