local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

//Panel definitions

//Status

local info = grafana.tablePanel.new(
  title='Info',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'process_resident_memory_bytes{pod=~"$pod",job=~"$cluster"}',
    format='table',
    instant=true,
  )
).addTarget(
  prometheus.target(
    '(etcd_mvcc_db_total_size_in_bytes{pod=~"$pod",job=~"$cluster"} / etcd_server_quota_backend_bytes{pod=~"$pod",job=~"$cluster"})*100',
    format='table',
    instant=true,
  )
).addTarget(
  prometheus.target(
    'sum(etcd_debugging_mvcc_keys_total{pod=~"$pod",job=~"$cluster"}) by (instance)',
    format='table',
    instant=true,
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(etcd_disk_wal_fsync_duration_seconds_bucket{pod=~"$pod",job=~"$cluster"}[5m])) by (instance, le))',
    format='table',
    instant=true,
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(etcd_disk_backend_commit_duration_seconds_bucket{pod=~"$pod",job=~"$cluster"}[5m])) by (instance, le))',
    format='table',
    instant=true,
  )
).addTarget(
  prometheus.target(
    'sum(etcd_server_is_leader{pod=~"$pod",job=~"$cluster"}) by (instance)',
    format='table',
    instant=true,
  )
).addTarget(
  prometheus.target(
    'sum(etcd_debugging_mvcc_db_compaction_keys_total{pod=~"$pod",job=~"$cluster"}) by (instance)',
    format='table',
    instant=true,
  )
);

local etcd_members = grafana.singlestat.new(
  title='Etcd Members',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(etcd_server_id{job="etcd"})',
    legendFormat='members'
  )
);

local etcd_has_leader = grafana.singlestat.new(
  title='Etcd has a leader?',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'max(etcd_server_has_leader{pod=~"$pod",job=~"$cluster"})',
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
//General Info

local keys = grafana.graphPanel.new(
  title='Keys',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'etcd_debugging_mvcc_keys_total{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} Num keys',
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

local number_of_leader_changes = grafana.singlestat.new(
  title='The number of leader changes seen',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'max(etcd_server_leader_changes_seen_total{pod=~"$pod",job=~"$cluster"})',
  )
);

local memory = grafana.graphPanel.new(
  title='Memory',
  datasource='$datasource',
) {
  yaxes: [
    {
      format: 'bytes',
      show: 'true',
    },
    {
      format: 'short',
      show: 'false',
    },
  ],
}.addTarget(
  prometheus.target(
    'process_resident_memory_bytes{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} Resident Memory',
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

local db_size = grafana.graphPanel.new(
  title='DB Size',
  datasource='$datasource',
) {
  yaxes: [
    {
      format: 'bytes',
      show: 'true',
    },
    {
      format: 'short',
      show: 'false',
    },
  ],
}.addTarget(
  prometheus.target(
    'etcd_mvcc_db_total_size_in_bytes{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} DB Size',
  )
).addTarget(
  prometheus.target(
    'etcd_mvcc_db_total_size_in_use_in_bytes{pod=~"$pod",job=~"$cluster"}',
    legendFormat='{{ pod }} Used bytes',
  )
);

//Dashboard + Templates

grafana.dashboard.new(
  'etcd-cluster-info',
  description='Etcd Dashboard from Prometheus for clusters running etcd as Kubernetes Pods',
  timezone='utc',
  time_from='now-1h',
  editable='true',
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
  grafana.row.new(title='Status', collapse=true).addPanels(
    [
      info { gridPos: { x: 0, y: 1, w: 12, h: 6 } },
      etcd_members { gridPos: { x: 12, y: 1, w: 12, h: 3 } },
      etcd_has_leader { gridPos: { x: 12, y: 4, w: 12, h: 3 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='DB Info per Member', collapse=true).addPanels(
    [
      percent_db_used { gridPos: { x: 0, y: 8, w: 8, h: 6 } },
      db_capacity_left { gridPos: { x: 8, y: 8, w: 8, h: 6 } },
      db_size_limit { gridPos: { x: 16, y: 8, w: 8, h: 6 } },
    ]
  ), { gridPos: { x: 0, y: 7, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='General Info', collapse=true).addPanels(
    [
      keys { gridPos: { x: 0, y: 26, w: 12, h: 8 } },
      heartbeat_failures { gridPos: { x: 12, y: 26, w: 9, h: 6 } },
      total_number_of_failed_proposals { gridPos: { x: 21, y: 26, w: 3, h: 6 } },
      key_operations { gridPos: { x: 0, y: 34, w: 12, h: 8 } },
      slow_operations { gridPos: { x: 12, y: 32, w: 6, h: 7 } },
      number_of_leader_changes { gridPos: { x: 18, y: 32, w: 6, h: 7 } },
      memory { gridPos: { x: 0, y: 42, w: 12, h: 8 } },
      compacted_keys { gridPos: { x: 12, y: 39, w: 12, h: 7 } },
      db_size { gridPos: { x: 12, y: 46, w: 12, h: 8 } },
    ]
  ), { gridPos: { x: 0, y: 25, w: 24, h: 1 } }
)
