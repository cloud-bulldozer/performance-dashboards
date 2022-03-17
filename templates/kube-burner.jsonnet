local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local es = grafana.elasticsearch;

local worker_count = grafana.statPanel.new(
  title='Node count',
  datasource='$datasource1',
  justifyMode='center'
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "nodeRoles"',
    timeField='timestamp',
    metrics=[{
      field: 'coun',
      id: '1',
      meta: {},
      settings: {},
      type: 'count',
    }],
    bucketAggs=[
      {
        field: 'labels.role.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
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
          interval: '30s',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
).addThresholds([
  { color: 'green', value: null },
  { color: 'red', value: 80 },
]);


//Dashboard & Templates

grafana.dashboard.new(
  'Kube-burner report v2',
  description='',
  editable='true',
  time_from='now/y',
  time_to='now',
  timezone='utc',
)



// TODO: Second datasource and confirm that this one is working.

.addTemplate(
  grafana.template.datasource(
    'datasource1',
    'elasticsearch',
    'AWS Dev - ripsaw-kube-burner',
    label='Datasource'
  )
)
.addTemplate(
  grafana.template.custom(
    label='SDN type',
    name='sdn',
    current='All',
    query='openshift-sdn,openshift-ovn-kubernetes',
    multi=true,
    includeAll=true,
  )
)
.addTemplate(
  grafana.template.new(
    label='Job',
    multi=true,
    query='{"find": "terms", "field": "jobName.keyword"}',
    refresh=2,
    name='job',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='Job',
    multi=true,
    query='{"find": "terms", "field": "jobName.keyword"}',
    refresh=2,
    name='job',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='UUID',
    multi=false,
    query='{"find": "terms", "field": "uuid.keyword",  "query": "labels.namespace.keyword:  $sdn AND jobName.keyword: $job"}',
    refresh=2,
    name='uuid',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='Master nodes',
    multi=true,
    query='{ "find" : "terms", "field": "labels.node.keyword", "query": "metricName.keyword: nodeRoles AND labels.role.keyword: master AND uuid.keyword: $uuid"}',
    refresh=2,
    name='master',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='Worker nodes',
    multi=true,
    query='{ "find" : "terms", "field": "labels.node.keyword", "query": "metricName.keyword: nodeRoles AND labels.role.keyword: worker AND uuid.keyword: $uuid"}',
    refresh=2,
    name='worker',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='Infra nodes',
    multi=true,
    query='{ "find" : "terms", "field": "labels.node.keyword",  "query": "metricName.keyword: nodeRoles AND labels.role.keyword: infra AND uuid.keyword: $uuid"}',
    refresh=2,
    name='infra',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='Namespace',
    multi=true,
    query='{ "find" : "terms", "field": "labels.namespace.keyword", "query": "labels.namespace.keyword: /openshift-.*/ AND uuid.keyword: $uuid"}',
    refresh=2,
    name='namespace',
    includeAll=true,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.custom(
    label='Latency percentile',
    name='latencyPercentile',
    current='P99',
    query='P99, P95, P50',
    multi=false,
    includeAll=false,
  )
)

.addPanel(
  worker_count, { gridPos: { x: 0, y: 0, w: 4, h: 4 } }
)
