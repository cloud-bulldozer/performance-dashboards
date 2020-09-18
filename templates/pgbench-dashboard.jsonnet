local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local es = grafana.elasticsearch;

local tps_report = grafana.graphPanel.new(
  title='TPS Report',
  datasource='$datasource1',
  format='ops',
  transparent=true,
  legend_show=false,
  linewidth=2
) {
  yaxes: [
    {
      format: 'ops',
      min: '0',
      show: true,
    },
    {
      format: 'short',
      show: 'false',
    },
  ],
}.addTarget(
  es.target(
    query='(user = $user) AND (uuid = $uuid)',
    timeField='timestamp',
    metrics=[{
      field: 'tps',
      id: '1',
      meta: {},
      pipelineAgg: 'select metric',
      pipelineVariables: [
        {
          name: 'var1',
          pipelineAgg: 'select metric',
        },
      ],
      settings: {},
      type: 'sum',
    }],
    bucketAggs=[{
      field: 'timestamp',
      id: '2',
      settings: {
        interval: 'auto',
        min_doc_count: 0,
        trimEdges: 0,
      },
      type: 'date_histogram',
    }],
  )
);

local latency_report = grafana.graphPanel.new(
  title='Latency Report',
  datasource='$datasource1',
  format='ms',
  transparent=true,
  legend_show=true,
)
                       {
  type: 'heatmap',
  yaxes: [],
  yAxis: {
    format: 'ms',
    show: true,
  },
}.addTarget(
  es.target(
    query='(uuid.keyword=$uuid) AND (user.keyword=$user)',
    timeField='timestamp',
    metrics=[{
      field: 'latency_ms',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[{
      field: 'timestamp',
      id: '2',
      settings: {
        interval: 'auto',
        min_doc_count: 0,
        trimEdges: 0,
      },
      type: 'date_histogram',
    }],
  )
);

local avg_tps = grafana.graphPanel.new(
  title='Overall Average TPS Per Run',
  datasource='$datasource2',
  format='ops',
  bars=true,
  lines=false,
  transparent=true,
  legend_show=true,
  legend_min=true,
  legend_max=true,
  legend_avg=true,
  legend_alignAsTable=true,
  legend_values=true,
  show_xaxis=false,
  x_axis_mode='series',
  x_axis_values='avg',
) {
  yaxes: [
    {
      format: 'ops',
      min: '0',
      show: true,
    },
    {
      format: 'short',
      show: 'false',
    },
  ],
}.addTarget(
  es.target(
    query='(uuid.keyword=$uuid) AND (user.keyword=$user)',
    timeField='timestamp',
    metrics=[{
      field: 'tps_incl_con_est',
      id: '1',
      meta: {},
      pipelineAgg: 'select metric',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'description.keyword',
        id: '6',
        settings: {
          min_doc_count: 1,
          order: 'asc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '4',
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

local results = grafana.tablePanel.new(
  title='Result Summary',
  datasource='$datasource1',
  transparent=true,
  styles=[
    {
      pattern: 'Average latency_ms',
      alias: 'Avg latency',
      align: 'auto',
      type: 'number',
      decimals: '2',
    },
    {
      pattern: 'Average tps',
      alias: 'Avg TPS',
      align: 'auto',
      type: 'number',
      decimals: '2',
    },
  ],
).addTarget(
  es.target(
    query='(uuid.keyword=$uuid) AND (user.keyword=$user)',
    timeField='timestamp',
    bucketAggs=[
      {
        field: 'user.keyword',
        id: '1',
        settings: {
          min_doc_count: 1,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
    ],

    metrics=[
      {
        field: 'latency_ms',
        id: '4',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'tps',
        id: '20',
        meta: {},
        settings: {},
        type: 'avg',
      },
    ],
  )
);

grafana.dashboard.new(
  'Pgbench - Dashboard',
  description='',
  editable='true',
  timezone='utc',
  time_from='now/y',
  time_to='now'
)

.addTemplate(
  grafana.template.datasource(
    'datasource1',
    'elasticsearch',
    'bull-pgbench',
    label='pgbench-results datasource'
  )
)

.addTemplate(
  grafana.template.datasource(
    'datasource2',
    'elasticsearch',
    'bull-pgbench-summary',
    label='pgbench-summary datasource'
  )
)

.addTemplate(
  grafana.template.new(
    'uuid',
    '$datasource1',
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
    '$datasource1',
    '{"find": "terms", "field": "user.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addAnnotation(
  grafana.annotation.datasource(
    'Run Start Time',
    '$datasource2',
    iconColor='#5794F2'
  ) {
    enable: true,
    type: 'tags',
    timeField: 'run_start_timestamp',
    textField: 'user',
    tagsField: 'description',
  }
)


.addAnnotation(
  grafana.annotation.datasource(
    'Sample Start Time',
    '$datasource2',
    iconColor='#B877D9'
  ) {
    enable: false,
    type: 'tags',
    timeField: 'sample_start_timestamp',
    textField: 'user',
    tagsField: 'description',
  }
)

.addPanel(tps_report, gridPos={ x: 0, y: 0, w: 12, h: 9 })
.addPanel(latency_report, gridPos={ x: 0, y: 9, w: 12, h: 9 })
.addPanel(avg_tps, gridPos={ x: 12, y: 0, w: 12, h: 9 })
.addPanel(results, gridPos={ x: 12, y: 9, w: 12, h: 9 })
