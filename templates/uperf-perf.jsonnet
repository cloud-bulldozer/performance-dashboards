local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local es = grafana.elasticsearch;


// Panels
local throughput = grafana.graphPanel.new(
  title='UPerf Performance : Throughput per-second',
  datasource='$datasource',
  format='bps',
  legend_max=true,
  legend_avg=true,
  legend_alignAsTable=true,
  legend_values=true,
  transparent=true,
) {
  yaxes: [
    {
      format: 'bps',
      show: 'true',
    },
    {
      format: 'pps',
      show: 'false',
    },
  ],
}.addTarget(
  es.target(
    query='uuid: $uuid AND cluster_name: $cluster_name AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND num_threads: $threads',
    timeField='uperf_ts',
    metrics=[{
      field: 'norm_byte',
      id: '1',
      inlineScript: '_value * 8',
      meta: {},
      settings: {
        script: {
          inline: '_value * 8',
        },
      },
      transparent: true,
      type: 'sum',
    }],
    bucketAggs=[{
      field: 'uperf_ts',
      id: '2',
      settings: {
        interval: 'auto',
        min_doc_count: 0,
        trimEdges: null,
      },
      type: 'date_histogram',
    }],
  )
);

local operations = grafana.graphPanel.new(
  title='UPerf Performance : Operations per-second',
  datasource='$datasource',
  format='pps',
  legend_max=true,
  legend_avg=true,
  legend_alignAsTable=true,
  legend_values=true,
  transparent=true,
) {
  yaxes: [
    {
      format: 'pps',
      show: 'true',
    },
    {
      format: 'pps',
      show: 'false',
    },
  ],
}.addTarget(
  es.target(
    query='uuid: $uuid AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND num_threads: $threads',
    timeField='uperf_ts',
    metrics=[{
      field: 'norm_ops',
      id: '1',
      meta: {},
      settings: {},
      type: 'sum',
    }],
    bucketAggs=[{
      field: 'uperf_ts',
      id: '2',
      settings: {
        interval: 'auto',
        min_doc_count: 0,
        trimEdges: null,
      },
      transparent: true,
      type: 'date_histogram',
    }],
  )
);


local results = grafana.tablePanel.new(
  title='UPerf Result Summary',
  datasource='$datasource',
  transparent=true,
  styles=[
    {
      pattern: 'message_size',
      type: 'string',
      unit: 'Bps',
    },
    {
      decimals: '2',
      pattern: 'Average norm_byte',
      type: 'number',
      unit: 'bps',
    },
    {
      decimals: '0',
      pattern: 'Average norm_ops',
      type: 'number',
      unit: 'none',
    },
    {
      decimals: '2',
      pattern: 'Average norm_ltcy',
      type: 'number',
      unit: 'µs',
    },
    {
      alias: 'Sample count',
      decimals: '2',
      pattern: 'Count',
      type: 'number',
      unit: 'short',
    },
  ],
).addTarget(
  es.target(
    query='uuid: $uuid AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND NOT norm_ops:0',
    timeField='uperf_ts',
    bucketAggs=[
      {
        fake: true,
        field: 'test_type.keyword',
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
        fake: true,
        field: 'protocol.keyword',
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
        fake: true,
        field: 'num_threads',
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
        field: 'message_size',
        id: '2',
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
        field: 'norm_byte',
        id: '1',
        inlineScript: '_value * 8',
        meta: {},
        settings: {
          script: {
            inline: '_value * 8',
          },
        },
        type: 'avg',
      },
      {
        field: 'norm_ops',
        id: '6',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'norm_ltcy',
        id: '7',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'select field',
        id: '8',
        type: 'count',
      },
    ],
  )
);


//Dashboard + Templates

grafana.dashboard.new(
  'Public - UPerf Results',
  description='',
  tags=['network', 'performance'],
  timezone='utc',
  time_from='now-1h',
  editable='true',
)

.addTemplate(
  grafana.template.datasource(
    'datasource',
    'elasticsearch',
    'bull-uperf',
    label='uperf-results datasource',
    regex='/(.*uperf.*)/',
  )
)

.addTemplate(
  grafana.template.new(
    'uuid',
    '$datasource',
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
    'cluster_name',
    '$datasource',
    '{"find": "terms", "field": "cluster_name.keyword"}',
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
    '$datasource',
    '{"find": "terms", "field": "user.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'iteration',
    '$datasource',
    '{"find": "terms", "field": "iteration"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'server',
    '$datasource',
    '{"find": "terms", "field": "remote_ip.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'test_type',
    '$datasource',
    '{"find": "terms", "field": "test_type.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'protocol',
    '$datasource',
    '{"find": "terms", "field": "protocol.keyword"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'message_size',
    '$datasource',
    '{"find": "terms", "field": "message_size"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'threads',
    '$datasource',
    '{"find": "terms", "field": "num_threads"}',
    refresh=2,
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addPanel(throughput, gridPos={ x: 0, y: 0, w: 12, h: 9 })
.addPanel(operations, gridPos={ x: 12, y: 0, w: 12, h: 9 })
.addPanel(results, gridPos={ x: 0, y: 20, w: 24, h: 18 })
