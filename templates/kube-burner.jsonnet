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


local metric_count_panel = grafana.statPanel.new(
  datasource='$datasource1',
  justifyMode='center',
  title=null
).addTarget(
  // Namespaces count
  es.target(
    query='uuid.keyword: $uuid AND metricName: "namespaceCount" AND labels.phase: "Active"',
    alias='Namespaces',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
).addTarget(
  // Services count
  es.target(
    query='uuid.keyword: $uuid AND metricName: "serviceCount"',
    alias='Services',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
).addTarget(
  // Deployments count
  es.target(
    query='uuid.keyword: $uuid AND metricName: "deploymentCount"',
    alias='Services',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
).addTarget(
  // Secrets count
  es.target(
    query='uuid.keyword: $uuid AND metricName: "secretCount"',
    alias='Services',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
).addTarget(
  // ConfigMap count
  es.target(
    query='uuid.keyword: $uuid AND metricName: "configmapCount"',
    alias='ConfigMaps',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      meta: {},
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
).addThresholds([
  { color: 'green', value: null },
  { color: 'red', value: 80 },
]);

local openshift_version_panel = grafana.statPanel.new(
  title='OpenShift version',
  datasource='$datasource1',
  justifyMode='center',
  reducerFunction='lastNotNull',
  fields='/^labels\\.version$/'
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "clusterVersion"',
    timeField='timestamp',
    metrics=[{
      id: '1',
      settings: {
        size: '500',
      },
      type: 'raw_data',
    }],
  )
);

local etcd_version_panel = grafana.statPanel.new(
  title='Etcd version',
  datasource='$datasource1',
  justifyMode='center',
  reducerFunction='lastNotNull',
  fields='labels.cluster_version'
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "etcdVersion"',
    timeField='timestamp',
    metrics=[{
      id: '1',
      settings: {
        size: '500',
      },
      type: 'raw_data',
    }],
  )
);


// Next line

local job_summary_panel = grafana.tablePanel.new(
  title='Job Summary',
  datasource='$datasource1',


).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "jobSummary"',
    timeField='timestamp',
    metrics=[{
      id: '1',
      settings: {
        size: '500',
      },
      type: 'raw_data',
    }],
  )
).addTransformation(
  grafana.transformation.new('organize', options={
    excludeByName: {
      _id: true,
      _index: true,
      _type: true,
      highlight: true,
      'jobConfig.cleanup': true,
      'jobConfig.errorOnVerify': true,
      'jobConfig.jobIterationDelay': true,
      'jobConfig.jobIterations': false,
      'jobConfig.jobPause': true,
      'jobConfig.maxWaitTimeout': true,
      'jobConfig.namespace': true,
      'jobConfig.namespaced': true,
      'jobConfig.namespacedIterations': false,
      'jobConfig.objects': true,
      'jobConfig.preLoadPeriod': true,
      'jobConfig.verifyObjects': true,
      'jobConfig.waitFor': true,
      'jobConfig.waitForDeletion': true,
      'jobConfig.waitWhenFinished': true,
      metricName: true,
      sort: true,
      timestamp: true,
      uuid: false,
    },
    indexByName: {
      _id: 1,
      _index: 2,
      _type: 3,
      elapsedTime: 8,
      'jobConfig.burst': 7,
      'jobConfig.cleanup': 12,
      'jobConfig.errorOnVerify': 13,
      'jobConfig.jobIterationDelay': 14,
      'jobConfig.jobIterations': 9,
      'jobConfig.jobPause': 15,
      'jobConfig.jobType': 10,
      'jobConfig.maxWaitTimeout': 16,
      'jobConfig.name': 5,
      'jobConfig.namespace': 17,
      'jobConfig.namespacedIterations': 18,
      'jobConfig.objects': 19,
      'jobConfig.podWait': 11,
      'jobConfig.qps': 6,
      'jobConfig.verifyObjects': 20,
      'jobConfig.waitFor': 21,
      'jobConfig.waitForDeletion': 22,
      'jobConfig.waitWhenFinished': 23,
      metricName: 24,
      timestamp: 0,
      uuid: 4,
    },
    renameByName: {
      _type: '',
      elapsedTime: 'Elapsed time',
      'jobConfig.burst': 'Burst',
      'jobConfig.cleanup': '',
      'jobConfig.errorOnVerify': 'errorOnVerify',
      'jobConfig.jobIterationDelay': 'jobIterationDelay',
      'jobConfig.jobIterations': 'Iterations',
      'jobConfig.jobPause': 'jobPause',
      'jobConfig.jobType': 'Job Type',
      'jobConfig.maxWaitTimeout': 'maxWaitTImeout',
      'jobConfig.name': 'Name',
      'jobConfig.namespace': 'namespacePrefix',
      'jobConfig.namespaced': '',
      'jobConfig.namespacedIterations': 'Namespaced iterations',
      'jobConfig.objects': '',
      'jobConfig.podWait': 'podWait',
      'jobConfig.preLoadImages': 'Preload Images',
      'jobConfig.preLoadPeriod': '',
      'jobConfig.qps': 'QPS',
      'jobConfig.verifyObjects': '',
      metricName: '',
      timestamp: '',
      uuid: 'UUID',
    },
  })
);

// First row: Cluster status
local masters_cpu = grafana.graphPanel.new(
  title='Masters CPU utilization',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_avg=true,
  legend_max=true,
  percentage=true,
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeCPU-Masters" AND NOT labels.mode.keyword: idle AND NOT labels.mode.keyword: steal',
    timeField='timestamp',
    alias='{{labels.instance.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {
        script: '_value * 100',
      },
      type: 'sum',
    }],
    bucketAggs=[
      {
        field: 'labels.instance.keyword',
        fake: true,
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);

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
  worker_count, { x: 0, y: 0, w: 4, h: 4 }
)
.addPanel(
  metric_count_panel, { x: 4, y: 0, w: 12, h: 4 }
)
.addPanel(
  openshift_version_panel, { x: 16, y: 0, w: 4, h: 4 },
)
.addPanel(
  etcd_version_panel, { x: 20, y: 0, w: 2, h: 4 }
)
.addPanel(
  job_summary_panel, { x: 0, y: 4, h: 3, w: 24 },
)
.addPanel(
  grafana.row.new(title='Cluster status', collapse=true).addPanels(
    [
      masters_cpu { gridPos: { x: 0, y: 8, w: 12, h: 9 } },
      // { gridPos: { x: , y: 8, w: , h: 9 } },
      // { gridPos: { x: , y: 8, w: , h: 9 } },
    ]
  ), { x: 0, y: 8, w: 24, h: 1 }
)
