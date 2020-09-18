local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local es = grafana.elasticsearch;

//Panel definitions

local throughput_overtime = grafana.graphPanel.new(
  title='Throughput overtime - Phase = $phase : Operation = $operation',
  datasource='$datasource1',
  format='ops',
  linewidth=2
) {
  yaxes: [
    {
      format: 'ops',
      show: true,
    },
    {
      format: 'short',
      show: false,
    },
  ],
  fill: 2,
}.addTarget(
  es.target(
    query='(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user) AND (action.keyword=$operation)',
    timeField='timestamp',
    metrics=[{
      field: 'overall_rate',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'action.keyword',
        id: '4',
        settings: {
          min_doc_count: 1,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: 'auto',
          min_doc_count: 0,
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local phase_average_latency = grafana.graphPanel.new(
  title='Phase = $phase :: Latency - 90%tile Reported from YCSB',
  datasource='$datasource1',
  format='µs',
  linewidth=2,
  lines=false,
  points=true,
  nullPointMode='connected',
  pointradius=1
) {
  yaxes: [
    {
      format: 'µs',
      show: true,
    },
    {
      format: 'short',
      show: true,
    },
  ],
  fill: 2,
}.addTarget(
  es.target(
    query='(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user) AND (action.keyword=$operation)',
    timeField='timestamp',
    metrics=[{
      field: 'latency_90',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'action.keyword',
        id: '3',
        settings: {
          min_doc_count: 1,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: 'auto',
          min_doc_count: 0,
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local latency_95 = grafana.graphPanel.new(
  title='95th% Latency of each workload per YCSB Operation',
  datasource='$datasource2',
  format='µs',
  legend_show=false,
  linewidth=2,
  bars=true,
  lines=false,
  x_axis_mode='series',
  x_axis_values='total',
) {
  yaxes: [
    {
      format: 'µs',
      show: true,
    },
    {
      format: 'short',
      show: false,
    },
  ],
}.addTarget(
  es.target(
    query='(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user)',
    timeField='timestamp',
    metrics=[{
      field: 'data.$operation.95thPercentileLatency(us)',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'workload_type.keyword',
        id: '5',
        settings: {
          min_doc_count: 1,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: 'auto',
          min_doc_count: 0,
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local overall_workload_throughput = grafana.graphPanel.new(
  title='Overall Throughput per YCSB Workload',
  datasource='$datasource2',
  format='ops',
  legend_rightSide=true,
  legend_total=true,
  legend_alignAsTable=true,
  legend_values=true,
  linewidth=2,
  bars=true,
  lines=false,
  x_axis_mode='series',
  x_axis_values='total',
) {
  yaxes: [
    {
      format: 'ops',
      show: true,
    },
    {
      format: 'short',
      show: false,
    },
  ],
}.addTarget(
  es.target(
    query='(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user)',
    timeField='timestamp',
    metrics=[{
      field: 'data.OVERALL.Throughput(ops/sec)',
      id: '1',
      meta: {},
      settings: {},
      type: 'sum',
    }],
    bucketAggs=[
      {
        field: 'workload_type.keyword',
        id: '5',
        settings: {
          min_doc_count: 1,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: 'auto',
          min_doc_count: 0,
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local aggregate_operation_sum = grafana.tablePanel.new(
  title='Phase = $phase :: $operation - Count',
  datasource='$datasource2',
).addTarget(
  es.target(
    query='(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user)',
    timeField='timestamp',
    alias='$operation - Operations',
    metrics=[{
      field: 'data.$operation.Operations',
      id: '1',
      meta: {},
      settings: {},
      type: 'sum',
    }],
    bucketAggs=[
      {
        field: 'workload_type.keyword',
        id: '3',
        settings: {
          min_doc_count: 1,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
    ],
  )
);

//Dashboard & Templates

grafana.dashboard.new(
  'YCSB - Dashboard',
  description='',
  editable='true',
  time_from='now/y',
  time_to='now',
  timezone='utc',
)

.addTemplate(
  grafana.template.datasource(
    'datasource1',
    'elasticsearch',
    'Prod ES - ripsaw-ycsb-results',
    label='ycsb-results datasource'
  )
)

.addTemplate(
  grafana.template.datasource(
    'datasource2',
    'elasticsearch',
    'Prod ES - ripsaw-ycsb-summary',
    label='ycsb-summary datasource'
  )
)

.addTemplate(
  grafana.template.new(
    'uuid',
    '$datasource2',
    '{"find": "terms", "field": "uuid.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'user',
    '$datasource2',
    '{"find": "terms", "field": "user.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'phase',
    '$datasource2',
    '{"find": "terms", "field": "phase.keyword"}',
    refresh=2,
    current='run'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'operation',
    '$datasource2',
    '{"find": "fields", "field": "data.*.Operations"}',
    regex='/data.(.*).Operations/',
    refresh=2,
    current='READ'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addPanel(throughput_overtime, gridPos={ x: 0, y: 0, w: 12, h: 9 })
.addPanel(phase_average_latency, gridPos={ x: 12, y: 0, w: 12, h: 9 })
.addPanel(latency_95, gridPos={ x: 0, y: 9, w: 24, h: 6 })
.addPanel(overall_workload_throughput, gridPos={ x: 0, y: 15, w: 16, h: 10 })
.addPanel(aggregate_operation_sum, gridPos={ x: 16, y: 15, w: 8, h: 10 })
