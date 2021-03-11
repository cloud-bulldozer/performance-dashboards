local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

// Panel definitions

// First sections
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
    'rate(container_fs_writes_bytes_total{container="etcd",device!~".+dm.+"}[2m])',
    legendFormat='{{ pod }}: {{ device }}',
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
    'histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket[2m]))',
    legendFormat='{{pod}}',
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
    'histogram_quantile(0.99, sum(irate(etcd_disk_wal_fsync_duration_seconds_bucket[2m])) by (pod, le))',
    legendFormat='{{pod}} WAL fsync',
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
    'histogram_quantile(0.99, sum(irate(etcd_disk_backend_commit_duration_seconds_bucket[2m])) by (pod, le))',
    legendFormat='{{pod}} DB fsync',
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
    'etcd_mvcc_db_total_size_in_bytes',
    legendFormat='{{pod}} DB physical size'
  )
).addTarget(
  prometheus.target(
    'etcd_mvcc_db_total_size_in_use_in_bytes',
    legendFormat='{{pod}} DB logical size',
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
    'sum(irate(container_cpu_usage_seconds_total{namespace="openshift-etcd", container="etcd"}[2m])) by (pod) * 100',
    legendFormat='{{ pod }}',
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
    'sum(avg_over_time(container_memory_working_set_bytes{container="",pod!="", namespace=~"openshift-etcd.*"}[2m])) BY (pod, namespace)',
    legendFormat='{{ pod }}',
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
    'sum(rate(container_network_receive_bytes_total{ container="etcd", namespace=~"openshift-etcd.*"}[2m])) BY (namespace, pod)',
    legendFormat='rx {{ pod }}'
  )
).addTarget(
  prometheus.target(
    'sum(rate(container_network_transmit_bytes_total{ container="etcd", namespace=~"openshift-etcd.*"}[2m])) BY (namespace, pod)',
    legendFormat='tx {{ pod }}',
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
    'rate(etcd_network_client_grpc_received_bytes_total[2m])',
    legendFormat='rx {{pod}}'
  )
).addTarget(
  prometheus.target(
    'rate(etcd_network_client_grpc_sent_bytes_total[2m])',
    legendFormat='tx {{pod}}',
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
    'rate(etcd_network_peer_received_bytes_total[2m])',
    legendFormat='rx {{pod}} Peer Traffic'
  )
).addTarget(
  prometheus.target(
    'rate(etcd_network_peer_sent_bytes_total[2m])',
    legendFormat='tx {{pod}} Peer Traffic',
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
  format='s',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum[2m]))',
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
    '(etcd_mvcc_db_total_size_in_bytes{} / etcd_server_quota_backend_bytes{})*100',
    legendFormat='{{pod}}',
  )
);

local db_capacity_left = grafana.graphPanel.new(
  title='DB Left capacity (with fragmented space)',
  datasource='$datasource',
  format='bytes',
).addTarget(
  prometheus.target(
    'etcd_server_quota_backend_bytes{} - etcd_mvcc_db_total_size_in_bytes{}',
    legendFormat='{{pod}}',
  )
);

local db_size_limit = grafana.graphPanel.new(
  title='DB Size Limit (Backend-bytes)',
  datasource='$datasource',
  format='bytes'
).addTarget(
  prometheus.target(
    'etcd_server_quota_backend_bytes{}',
    legendFormat='{{ pod }} Quota Bytes',
  )
);

// Proposals, leaders, and keys section

local keys = grafana.graphPanel.new(
  title='Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_keys_total{pod=~"$pod"}',
    legendFormat='{{ pod }} Num keys',
  )
);

local compacted_keys = grafana.graphPanel.new(
  title='Compacted Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_db_compaction_keys_total{pod=~"$pod"}',
    legendFormat='{{ pod  }} keys compacted',
  )
);

local heartbeat_failures = grafana.graphPanel.new(
  title='Heartbeat Failures',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_server_heartbeat_send_failures_total{pod=~"$pod"}',
    legendFormat='{{ pod }} heartbeat  failures',
  )
).addTarget(
  prometheus.target(
    'etcd_server_health_failures{pod=~"$pod"}',
    legendFormat='{{ pod }} health failures',
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
    'rate(etcd_debugging_mvcc_put_total{pod=~"$pod"}[2m])',
    legendFormat='{{ pod }} puts/s',
  )
).addTarget(
  prometheus.target(
    'rate(etcd_debugging_mvcc_delete_total{pod=~"$pod"}[2m])',
    legendFormat='{{ pod }} deletes/s',
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
    'delta(etcd_server_slow_apply_total{pod=~"$pod"}[2m])',
    legendFormat='{{ pod }} slow applies',
  )
).addTarget(
  prometheus.target(
    'delta(etcd_server_slow_read_indexes_total{pod=~"$pod"}[2m])',
    legendFormat='{{ pod }} slow read indexes',
  )
);

local raft_proposals = grafana.graphPanel.new(
  title='Raft Proposals',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_failed_total[2m]))',
    legendFormat='Proposal Failure Rate',
  )
).addTarget(
  prometheus.target(
    'sum(etcd_server_proposals_pending)',
    legendFormat='Proposal Pending Total',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_committed_total[2m]))',
    legendFormat='Proposal Commit Rate',
  )
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_proposals_applied_total[2m]))',
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

local num_leader_changes = grafana.graphPanel.new(
  title='Number of leader changes seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(etcd_server_leader_changes_seen_total[2m]))',
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
    'pod',
    '$datasource',
    'label_values({job="etcd"}, pod)',
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
      disk_wal_sync_duration { gridPos: { x: 0, y: 8, w: 12, h: 8 } },
      disk_backend_sync_duration { gridPos: { x: 12, y: 8, w: 12, h: 8 } },
      fs_writes { gridPos: { x: 0, y: 16, w: 12, h: 8 } },
      db_size { gridPos: { x: 12, y: 16, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='Network Usage', collapse=true).addPanels(
    [
      network_traffic { gridPos: { x: 0, y: 1, w: 12, h: 8 } },
      ptp { gridPos: { x: 12, y: 1, w: 12, h: 8 } },
      peer_traffic { gridPos: { x: 0, y: 8, w: 12, h: 8 } },
      grpc_traffic { gridPos: { x: 12, y: 8, w: 12, h: 8 } },
      active_streams { gridPos: { x: 0, y: 16, w: 12, h: 8 } },
      snapshot_duration { gridPos: { x: 12, y: 16, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 1, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='DB Info per Member', collapse=true).addPanels(
    [
      percent_db_used { gridPos: { x: 0, y: 8, w: 8, h: 8 } },
      db_capacity_left { gridPos: { x: 8, y: 8, w: 8, h: 8 } },
      db_size_limit { gridPos: { x: 16, y: 8, w: 8, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 2, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='General Info', collapse=true).addPanels(
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
