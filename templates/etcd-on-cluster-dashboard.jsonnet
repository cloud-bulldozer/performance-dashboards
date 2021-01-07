local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

// Panel definitions

// First sections
local fs_writes = grafana.graphPanel.new(
  title='container_fs_writes_total',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(container_fs_writes_total[5m])) by (container_name,device)',
    legendFormat='',
  )
);

local ptp = grafana.graphPanel.new(
  title='p99 peer to peer',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket[5m]))',
    legendFormat='',
  )
);

local disk_sync_duration = grafana.graphPanel.new(
  title='Disk Sync Duration',
  datasource='$datasource',
  staircase=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(etcd_disk_wal_fsync_duration_seconds_bucket[5m])) by (instance, le))',
    legendFormat='{{instance}} WAL fsync',
    format='time_series'
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(etcd_disk_backend_commit_duration_seconds_bucket[5m])) by (instance, le))',
    legendFormat='{{instance}} DB fsync',
    format='time_series'
  )
);

local snapshot_taken = grafana.graphPanel.new(
  title='Snapshot taken',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'grpc_server_started_total{grpc_service="etcdserverpb.Maintenance", grpc_method="Snapshot"}',
    legendFormat='',
  )
);


local db_size = grafana.graphPanel.new(
  title='DB Size',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_db_total_size_in_bytes',
    legendFormat='{{instance}} DB Size',
  )
);


local cpu_usage = grafana.graphPanel.new(
  title='CPU usage',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(avg_over_time(pod:container_cpu_usage:sum{container="",pod!="", namespace=~"openshift-etcd.*"}[5m])) BY (pod, namespace)',
    legendFormat='-> {{ pod }}',
  )
);

local mem_usage = grafana.graphPanel.new(
  title='Memory usage',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(avg_over_time(container_memory_working_set_bytes{container="",pod!="", namespace=~"openshift-etcd.*"}[5m])) BY (pod, namespace)',
    legendFormat='-> {{ pod }}',
  )
);

local traffic_in = grafana.graphPanel.new(
  title='Traffic in bytes total',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(container_network_receive_bytes_total{ container="POD", pod!= "", namespace=~"openshift-etcd.*"}[5m])) BY (namespace, pod)',
    legendFormat='-> {{ pod }}',
  )
);

local traffic_out = grafana.graphPanel.new(
  title='Traffic out bytes total',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(container_network_transmit_bytes_total{ container="POD", pod!= "", namespace=~"openshift-etcd.*"}[5m])) BY (namespace, pod)',
    legendFormat='-> {{ pod }}',
  )
);

local client_traffic_in = grafana.graphPanel.new(
  title='Client traffic in',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'rate(etcd_network_client_grpc_received_bytes_total[5m])',
    legendFormat='{{instance}} Client Traffic In',
  )
);

local client_traffic_out = grafana.graphPanel.new(
  title='Client traffic out',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'rate(etcd_network_client_grpc_sent_bytes_total[5m])',
    legendFormat='{{instance}} Client Traffic Out',
  )
);

local peer_traffic_in = grafana.graphPanel.new(
  title='Peer traffic in',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_network_peer_received_bytes_total[5m])) by (instance)',
    legendFormat='{{instance}} Peer Traffic In',
  )
);

local peer_traffic_out = grafana.graphPanel.new(
  title='Peer traffic out',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_network_peer_sent_bytes_total[5m])) by (instance)',
    legendFormat='{{instance}} Peer Traffic Out',
  )
);

local disk_opeations_latency = grafana.graphPanel.new(
  title='Disk Operations Latency',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_disk_wal_fsync_duration_seconds_sum[5m]))',
    legendFormat='The latency distributions of fsync called by wal',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_disk_backend_commit_duration_seconds_sum[5m]))',
    legendFormat='The latency distributions of commit called by backend',
  )
);

local network_sent_and_received = grafana.graphPanel.new(
  title='Network',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_network_client_grpc_received_bytes_total[5m]))',
    legendFormat='The total number of bytes received by grpc clients',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_network_client_grpc_sent_bytes_total[5m]))',
    legendFormat='The total number of bytes sent to grpc clients',
  )
);

local rpc_rate = grafana.graphPanel.new(
  title='RPC Rate',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(grpc_server_started_total{grpc_type="unary"}[5m]))',
    legendFormat='RPC Rate',
  )
).addTarget(
  prometheus.target(
    'sum(rate(grpc_server_handled_total{grpc_type="unary",grpc_code!="OK"}[5m]))',
    legendFormat='RPC Failed Rate',
  )
);

local active_streams = grafana.graphPanel.new(
  title='Active Streams',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(grpc_server_started_total{grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"})',
    legendFormat='Watch Streams',
  )
).addTarget(
  prometheus.target(
    'sum(grpc_server_started_total{grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"})',
    legendFormat='Lease Streams',
  )
);

local snapshot_duration = grafana.graphPanel.new(
  title='Snapshot duration',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum[5m]))',
    legendFormat='the total latency distributions of save called by snapshot',
  )
);

//DB Info per Member

local percent_db_used = grafana.singlestat.new(
  title='% DB Space Used $pod',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    '(etcd_mvcc_db_total_size_in_bytes{pod=~"$pod",job=~"$cluster"} / etcd_server_quota_backend_bytes{pod=~"$pod",job=~"$cluster"})*100',
  )
);

local db_capacity_left = grafana.singlestat.new(
  title='DB Left capacity (with fragmented space) $pod',
  datasource='$datasource',
  format='bytes',
).addTarget(
  prometheus.target(
    'etcd_server_quota_backend_bytes{pod=~"$pod",job=~"$cluster"} - etcd_mvcc_db_total_size_in_bytes{pod=~"$pod",job=~"$cluster"}',
    legendFormat='Backend bytes - DB Size',
  )
);

local db_size_limit = grafana.singlestat.new(
  title='DB Size Limit (Backend-bytes) $pod',
  datasource='$datasource',
  format='bytes'
).addTarget(
  prometheus.target(
    'etcd_server_quota_backend_bytes{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} Quota Bytes',
  )
);

// Proposals, leaders, and keys section

local keys = grafana.graphPanel.new(
  title='Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_keys_total{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} Num keys',
  )
);

local compacted_keys = grafana.graphPanel.new(
  title='Compacted Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_db_compaction_keys_total{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod  }} keys compacted',
  )
);

local heartbeat_failures = grafana.graphPanel.new(
  title='Heartbeat Failures',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_server_heartbeat_send_failures_total{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} heartbeat  failures',
  )
).addTarget(
  prometheus.target(
    'etcd_server_health_failures{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} health failures',
  )
);

local total_number_of_failed_proposals = grafana.singlestat.new(
  title='The total number of failed proposals seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'max(etcd_server_leader_changes_seen_total{pod=~"$pod",job=~"$cluster"})',
  )
);

local key_operations = grafana.graphPanel.new(
  title='Key Operations',
  datasource='$datasource',
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
    'rate(etcd_debugging_mvcc_put_total{pod=~"$pod",job=~"$cluster"}[5m])',
    legendFormat='{{ pod }} puts/s',
  )
).addTarget(
  prometheus.target(
    'rate(etcd_debugging_mvcc_delete_total{pod=~"$pod",job=~"$cluster"}[5m])',
    legendFormat='{{ pod }} deletes/s',
  )
);

local slow_operations = grafana.graphPanel.new(
  title='Slow Operations',
  datasource='$datasource',
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
    'etcd_server_slow_apply_total{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} slow applies',
  )
).addTarget(
  prometheus.target(
    'etcd_server_slow_read_indexes_total{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} slow read indexes',
  )
);

local raft_proposals = grafana.graphPanel.new(
  title='Raft Proposals',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_failed_total[5m]))',
    legendFormat='Proposal Failure Rate',
  )
).addTarget(
  prometheus.target(
    'sum(etcd_server_proposals_pending)',
    legendFormat='Proposal Pending Total',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_committed_total[5m]))',
    legendFormat='Proposal Commit Rate',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_applied_total[5m]))',
    legendFormat='Proposal Apply Rate',
  )
);

local leader_elections_per_day = grafana.graphPanel.new(
  title='Leader Elections Per Day',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'changes(etcd_server_leader_changes_seen_total[1d])',
    legendFormat='{{instance}} Total Leader Elections Per Day',
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
    'max(etcd_server_has_leader)',
  )
);

local num_leader_changes = grafana.singlestat.new(
  title='Number of leader changes seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'max(etcd_server_leader_changes_seen_total)',
  )
);

local num_failed_proposals = grafana.singlestat.new(
  title='Total number of failed proposals seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'max(etcd_server_proposals_committed_total)',
  )
);


// Creating the dashboard from the panels described above.

grafana.dashboard.new(
  'etcd-cluster-info',
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
    'cluster',
    '$datasource',
    'label_values(job)',
    regex='/.*etcd.*/',
    refresh=1,
  ) {
    type: 'query',
    multi: true,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'pod',
    '$datasource',
    'label_values({job="$cluster"}, pod)',
    refresh=1,
  ) {
    type: 'query',
    multi: false,
    includeAll: false,
  }
)

.addTemplate(
  grafana.template.new(
    'instance',
    '$datasource',
    'label_values({job="$cluster"}, instance)',
    refresh=1,
  ) {
    type: 'query',
    multi: true,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'namespace',
    '$datasource',
    'label_values({job="$cluster"}, namespace)',
    current='openshift-etcd',
    refresh=1,
  ) {
    type: 'query',
    multi: true,
    includeAll: false,
  }
)

.addTemplate(
  grafana.template.new(
    'pod_ip',
    '$datasource',
    'label_values(kube_pod_info{pod="$pod" }, pod_ip)',
    refresh=1,
  ) {
    type: 'query',
    multi: false,
    includeAll: false,
  }
)

.addPanel(
  grafana.row.new(title='General Resource Usage', collapse=true).addPanels(
    [
      cpu_usage { gridPos: { x: 0, y: 1, w: 12, h: 8 } },
      mem_usage { gridPos: { x: 12, y: 1, w: 12, h: 8 } },
      disk_sync_duration { gridPos: { x: 0, y: 8, w: 12, h: 8 } },
      fs_writes { gridPos: { x: 12, y: 8, w: 12, h: 8 } },
      db_size { gridPos: { x: 0, y: 16, w: 12, h: 8 } },
      snapshot_taken { gridPos: { x: 12, y: 16, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='Network Usage', collapse=true).addPanels(
    [
      network_sent_and_received { gridPos: { x: 0, y: 1, w: 12, h: 8 } },
      ptp { gridPos: { x: 12, y: 1, w: 12, h: 8 } },
      traffic_in { gridPos: { x: 0, y: 8, w: 12, h: 8 } },
      traffic_out { gridPos: { x: 12, y: 8, w: 12, h: 8 } },
      client_traffic_in { gridPos: { x: 0, y: 15, w: 6, h: 8 } },
      client_traffic_out { gridPos: { x: 6, y: 15, w: 6, h: 8 } },
      peer_traffic_in { gridPos: { x: 12, y: 15, w: 6, h: 8 } },
      peer_traffic_out { gridPos: { x: 18, y: 15, w: 6, h: 8 } },
      rpc_rate { gridPos: { x: 0, y: 23, w: 8, h: 8 } },
      active_streams { gridPos: { x: 8, y: 23, w: 8, h: 8 } },
      snapshot_duration { gridPos: { x: 16, y: 23, w: 8, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 1, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='DB Info per Member', collapse=true).addPanels(
    [
      percent_db_used { gridPos: { x: 0, y: 8, w: 8, h: 4 } },
      db_capacity_left { gridPos: { x: 8, y: 8, w: 8, h: 4 } },
      db_size_limit { gridPos: { x: 16, y: 8, w: 8, h: 4 } },
    ]
  ), { gridPos: { x: 0, y: 2, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='General Info', collapse=true).addPanels(
    [
      raft_proposals { gridPos: { x: 0, y: 1, w: 12, h: 8 } },
      leader_elections_per_day { gridPos: { x: 12, y: 1, w: 12, h: 8 } },
      etcd_has_leader { gridPos: { x: 0, y: 8, w: 6, h: 4 } },
      num_leader_changes { gridPos: { x: 6, y: 8, w: 6, h: 4 } },
      num_failed_proposals { gridPos: { x: 0, y: 12, w: 12, h: 4 } },
      keys { gridPos: { x: 12, y: 12, w: 12, h: 8 } },
      slow_operations { gridPos: { x: 0, y: 20, w: 12, h: 8 } },
      key_operations { gridPos: { x: 12, y: 20, w: 12, h: 8 } },
      heartbeat_failures { gridPos: { x: 0, y: 28, w: 12, h: 8 } },
      compacted_keys { gridPos: { x: 12, y: 28, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 3, w: 24, h: 1 } }
)
