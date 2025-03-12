local variables = import './variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local generateTimeSeriesQuery(query, legend) = [
  local prometheusQuery = g.query.prometheus;
  prometheusQuery.new('$' + variables.Datasource.name, query)
  + prometheusQuery.withFormat('time_series')
  + prometheusQuery.withIntervalFactor(2)
  + prometheusQuery.withLegendFormat(legend),
];

{
  CPUUsage: {
    query():
      generateTimeSeriesQuery('sum(irate(container_cpu_usage_seconds_total{namespace="openshift-etcd", container="etcd",pod=~"$etcd_pod"}[2m])) by (pod) * 100', '{{ pod }}'),
  },

  memoryUsage: {
    query():
      generateTimeSeriesQuery('sum(avg_over_time(container_memory_working_set_bytes{container="",pod!="", namespace=~"openshift-etcd.*",pod=~"$etcd_pod"}[2m])) BY (pod, namespace)', '{{ pod }}'),
  },

  compactionDurationSum: {
    query():
      generateTimeSeriesQuery('delta(etcd_debugging_mvcc_db_compaction_total_duration_milliseconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[1m:30s])/2', 'rate compact sum {{instance}} ')
      + generateTimeSeriesQuery('etcd_debugging_mvcc_db_compaction_total_duration_milliseconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}', 'compact sum {{instance}} '),
  },

  defragDurationSum: {
    query():
      generateTimeSeriesQuery('delta(etcd_disk_backend_defrag_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[1m:30s])/2', 'rate defrag sum {{instance}} ')
      + generateTimeSeriesQuery('etcd_disk_backend_defrag_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}', 'defrag sum {{instance}} '),
  },

  nodeVmstatPgmajfault: {
    query():
      generateTimeSeriesQuery('rate(node_vmstat_pgmajfault[2m])* on (instance) group_left label_replace(kube_node_role{role="control-plane"},"instance","$1","node","(.*)")', 'rate pgmajfault {{instance}} ')
      + generateTimeSeriesQuery('node_vmstat_pgmajfault * on (instance) group_left label_replace(kube_node_role{role="control-plane"},"instance","$1","node","(.*)")', 'pgmajfault {{instance}} '),
  },

  diskWalSyncDuration: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(etcd_disk_wal_fsync_duration_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[5m])) by (pod, le))', '{{pod}} WAL fsync'),
  },

  diskWalSyncDurationSum: {
    query():
      generateTimeSeriesQuery('irate(etcd_disk_wal_fsync_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '2m irate WAL sum {{instance}} ')
      + generateTimeSeriesQuery('etcd_disk_wal_fsync_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}', 'WAL sum {{instance}} '),
  },

  diskWalSyncDurationCount: {
    query():
      generateTimeSeriesQuery('irate(etcd_disk_wal_fsync_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '2m irate WAL count {{instance}} ')
      + generateTimeSeriesQuery('etcd_disk_wal_fsync_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}', 'WAL count {{instance}} '),
  },

  diskBackendCommitDuration: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(etcd_disk_backend_commit_duration_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[5m])) by (pod, le))', '{{pod}} DB fsync'),
  },

  diskBackendCommitDurationSum: {
    query():
      generateTimeSeriesQuery('irate(etcd_disk_backend_commit_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '2m irate WAL sum {{instance}} ')
      + generateTimeSeriesQuery('etcd_disk_backend_commit_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}', 'WAL sum {{instance}} '),
  },

  diskBackendCommitDurationCount: {
    query():
      generateTimeSeriesQuery('irate(etcd_disk_backend_commit_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '2m irate WAL count {{instance}} ')
      + generateTimeSeriesQuery('etcd_disk_backend_commit_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}', 'WAL count {{instance}} '),
  },

  etcdContainerDiskWrites: {
    query():
      generateTimeSeriesQuery('rate(container_fs_writes_bytes_total{namespace="openshift-etcd",device!~".+dm.+"}[2m])', '{{ pod }}: {{ device }}'),
  },

  dbSize: {
    query():
      generateTimeSeriesQuery('etcd_mvcc_db_total_size_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{pod}} DB physical size')
      + generateTimeSeriesQuery('etcd_mvcc_db_total_size_in_use_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{pod}} DB logical size'),
  },

  containerNetworkTraffic: {
    query():
      generateTimeSeriesQuery('sum(rate(container_network_receive_bytes_total{ namespace=~"openshift-etcd.*"}[2m])) BY (namespace, pod)', 'rx {{ pod }}')
      + generateTimeSeriesQuery('sum(rate(container_network_transmit_bytes_total{ namespace=~"openshift-etcd.*"}[2m])) BY (namespace, pod)', 'tx {{ pod }}'),
  },

  p99PeerToPeerLatency: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m]))', '{{pod}}'),
  },

  peerNetworkTraffic: {
    query():
      generateTimeSeriesQuery('rate(etcd_network_peer_received_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', 'rx {{pod}} Peer Traffic')
      + generateTimeSeriesQuery('rate(etcd_network_peer_sent_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', 'tx {{pod}} Peer Traffic'),
  },

  gRPCNetworkTraffic: {
    query():
      generateTimeSeriesQuery('rate(etcd_network_client_grpc_received_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', 'rx {{pod}}')
      + generateTimeSeriesQuery('rate(etcd_network_client_grpc_sent_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', 'tx {{pod}}'),
  },

  activeStreams: {
    query():
      generateTimeSeriesQuery('sum(grpc_server_started_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"})', 'Watch Streams')
      + generateTimeSeriesQuery('sum(grpc_server_started_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"})', 'Lease Streams'),
  },

  snapshotDuration: {
    query():
      generateTimeSeriesQuery('sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum{namespace="openshift-etcd"}[2m]))', 'the total latency distributions of save called by snapshot'),
  },

  dbSpaceUsed: {
    query():
      generateTimeSeriesQuery('(etcd_mvcc_db_total_size_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"} / etcd_server_quota_backend_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"})*100', '{{pod}}'),
  },

  dbLeftCapacity: {
    query():
      generateTimeSeriesQuery('etcd_server_quota_backend_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"} - etcd_mvcc_db_total_size_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{pod}}'),
  },

  dbSizeLimit: {
    query():
      generateTimeSeriesQuery('etcd_server_quota_backend_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{ pod }} Quota Bytes'),
  },

  raftProposals: {
    query():
      generateTimeSeriesQuery('sum(rate(etcd_server_proposals_failed_total{namespace="openshift-etcd"}[2m]))', 'Proposal Failure Rate')
      + generateTimeSeriesQuery('sum(etcd_server_proposals_pending{namespace="openshift-etcd"})', 'Proposal Pending Total')
      + generateTimeSeriesQuery('sum(rate(etcd_server_proposals_committed_total{namespace="openshift-etcd"}[2m]))', 'Proposal Commit Rate')
      + generateTimeSeriesQuery('sum(rate(etcd_server_proposals_applied_total{namespace="openshift-etcd"}[2m]))', 'Proposal Apply Rate'),
  },

  numberOfLeaderChangesSeen: {
    query():
      generateTimeSeriesQuery('sum(rate(etcd_server_leader_changes_seen_total{namespace="openshift-etcd"}[2m]))', ''),
  },

  etcdHasALeader: {
    query():
      generateTimeSeriesQuery('max(etcd_server_has_leader{namespace="openshift-etcd"})', ''),
  },

  totalNumberOfProposalsSeen: {
    query():
      generateTimeSeriesQuery('max(etcd_server_proposals_committed_total{namespace="openshift-etcd"})', ''),
  },

  keys: {
    query():
      generateTimeSeriesQuery('etcd_debugging_mvcc_keys_total{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{ pod }} Num keys'),
  },

  leaderElectionsPerDay: {
    query():
      generateTimeSeriesQuery('changes(etcd_server_leader_changes_seen_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[1d])', '{{instance}} Total Leader Elections Per Day'),
  },

  slowOperations: {
    query():
      generateTimeSeriesQuery('delta(etcd_server_slow_apply_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '{{ pod }} slow applies')
      + generateTimeSeriesQuery('delta(etcd_server_slow_read_indexes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '{{ pod }} slow read indexes'),
  },

  keyOperations: {
    query():
      generateTimeSeriesQuery('rate(etcd_mvcc_put_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '{{ pod }} puts/s')
      + generateTimeSeriesQuery('rate(etcd_mvcc_delete_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])', '{{ pod }} deletes/s'),
  },

  heartBeatFailure: {
    query():
      generateTimeSeriesQuery('etcd_server_heartbeat_send_failures_total{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{ pod }} heartbeat failures')
      + generateTimeSeriesQuery('etcd_server_health_failures{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{ pod }} health failures'),
  },

  compactedKeys: {
    query():
      generateTimeSeriesQuery('etcd_debugging_mvcc_db_compaction_keys_total{namespace="openshift-etcd",pod=~"$etcd_pod"}', '{{ pod  }} keys compacted'),
  },
}
