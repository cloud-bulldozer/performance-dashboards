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
// TODO: Convert to new table format once jsonnet supports it.
// That would fix the text wrapping problem.
local job_summary_panel = grafana.tablePanel.new(
  title='Job Summary',
  datasource='$datasource1',
  styles=[
    {
      pattern: 'uuid',
      alias: 'UUID',
      type: 'string',
    },
    {
      pattern: 'jobConfig.name',
      alias: 'Name',
      type: 'string',
    },
    {
      pattern: 'jobConfig.qps',
      alias: 'QPS',
      type: 'number',
    },
    {
      pattern: 'jobConfig.burst',
      alias: 'Burst',
      type: 'number',
    },
    {
      pattern: 'elapsedTime',
      alias: 'Elapsed time',
      type: 'number',
      unit: 's',
    },
    {
      pattern: 'jobConfig.jobIterations',
      alias: 'Iterations',
      type: 'number',
    },
    {
      pattern: 'jobConfig.jobType',
      alias: 'Job Type',
      type: 'string',
    },
    {
      pattern: 'jobConfig.podWait',
      alias: 'podWait',
      type: 'boolean',
    },
    {
      pattern: 'jobConfig.namespacedIterations',
      alias: 'Namespaced iterations',
      type: 'boolean',
    },
    {
      pattern: 'jobConfig.preLoadImages',
      alias: 'Preload Images',
      type: 'boolean',
    },
    {
      pattern: '_id',
      alias: '_id',
      type: 'hidden',
    },
    {
      pattern: '_index',
      alias: '_index',
      type: 'hidden',
    },
    {
      pattern: '_type',
      alias: '_type',
      type: 'hidden',
    },
    {
      pattern: 'highlight',
      alias: 'highlight',
      type: 'hidden',
    },
    {
      pattern: '_type',
      alias: '_type',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.cleanup',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.errorOnVerify',
      alias: 'errorOnVerify',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.jobIterationDelay',
      alias: 'jobIterationDelay',
      type: 'hidden',
      unit: 's',
    },
    {
      pattern: 'jobConfig.jobPause',
      alias: 'jobPause',
      type: 'hidden',
      unit: 's',
    },
    {
      pattern: 'jobConfig.maxWaitTimeout',
      alias: 'maxWaitTimeout',
      type: 'hidden',
      unit: 's',
    },
    {
      pattern: 'jobConfig.namespace',
      alias: 'namespacePrefix',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.namespaced',
      alias: 'jobConfig.namespaced',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.objects',
      alias: 'jobConfig.objects',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.preLoadPeriod',
      alias: 'jobConfig.preLoadPeriod',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.verifyObjects',
      alias: 'jobConfig.verifyObjects',
      type: 'hidden',
    },
    {
      pattern: 'metricName',
      alias: 'metricName',
      type: 'hidden',
    },
    {
      pattern: 'timestamp',
      alias: 'timestamp',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.waitFor',
      alias: 'jobConfig.waitFor',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.waitForDeletion',
      alias: 'jobConfig.waitForDeletion',
      type: 'hidden',
    },
    {
      pattern: 'jobConfig.waitWhenFinished',
      alias: 'jobConfig.waitWhenFinished',
      type: 'hidden',
    },
    {
      pattern: 'sort',
      alias: 'sort',
      type: 'hidden',
    },
  ]
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
  legend_values=true,
  format='percent',
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

local masters_memory = grafana.graphPanel.new(
  title='Masters Memory utilization',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_avg=true,
  legend_max=true,
  legend_values=true,
  format='bytes'
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryAvailable-Masters"',
    timeField='timestamp',
    alias='Available {{labels.instance.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
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

local node_status_summary = grafana.graphPanel.new(
  title='Node Status Summary',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_current=true,
  legend_values=true,
  legend_rightSide=true,
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeStatus"',
    timeField='timestamp',
    alias='{{labels.condition.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'labels.condition.keyword',
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
);


local pod_status_summary = grafana.graphPanel.new(
  title='Pod Status Summary',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_current=true,
  legend_values=true,
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "podStatusCount"',
    timeField='timestamp',
    alias='{{labels.phase.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'labels.phase.keyword',
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
);

local kube_api_cpu = grafana.graphPanel.new(
  title='Kube-apiserver CPU',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                     .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.container.keyword: kube-apiserver',
    timeField='timestamp',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
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
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                     .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU-Masters" AND labels.container.keyword: kube-apiserver',
    timeField='timestamp',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
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
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                     .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.container.keyword: kube-apiserver',
    timeField='timestamp',
    alias='Avg CPU {{labels.container.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);
// TODO: When the feature is added to grafannet, style the average differently.


local kube_api_memory = grafana.graphPanel.new(
  title='Kube-apiserver Memory',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                        .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.container.keyword: kube-apiserver',
    timeField='timestamp',
    alias='Rss {{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
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
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory-Masters" AND labels.container.keyword: kube-apiserver',
    timeField='timestamp',
    alias='Rss {{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
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
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                        .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.container.keyword: kube-apiserver',
    timeField='timestamp',
    alias='Avg Rss {{labels.container.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);
// TODO: When the feature is added to grafannet, style the average differently.


local active_controller_manager_cpu = grafana.graphPanel.new(
  title='Active Kube-controller-manager CPU',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.container.keyword: kube-controller-manager',
    timeField='timestamp',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '1',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU-Masters" AND labels.container.keyword: kube-controller-manager',
    timeField='timestamp',
    alias='{{labels.container.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '1',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);


local active_controller_manager_memory = grafana.graphPanel.new(
  title='Active Kube-controller-manager memory',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                                         .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.container.keyword: kube-controller-manager',
    timeField='timestamp',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '1',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                                         .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory-Masters" AND labels.container.keyword: kube-controller-manager',
    timeField='timestamp',
    alias='{{labels.container.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '1',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        fake: true,
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);


local kube_scheduler_cpu = grafana.graphPanel.new(
  title='Kube-scheduler CPU',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                           .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.container.keyword: kube-scheduler',
    timeField='timestamp',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                           .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU-Masters" AND labels.container.keyword: kube-scheduler',
    timeField='timestamp',
    alias='{{labels.container.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);


local kube_scheduler_memory = grafana.graphPanel.new(
  title='Kube-scheduler memory',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                              .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.container.keyword: kube-scheduler',
    timeField='timestamp',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
)
                              .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory-Masters" AND labels.container.keyword: kube-scheduler',
    timeField='timestamp',
    alias='Rss {{labels.container.keyword}}',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);


local hypershift_controlplane_cpu = grafana.graphPanel.new(
  title='Hypershift Controlplane CPU Usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                                    .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU-Controlplane"',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '20',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '20',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '4',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          timeZone: 'utc',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);


local hypershift_controlplane_memory = grafana.graphPanel.new(
  title='Hypershift Controlplane RSS memory Usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                                       .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory-Controlplane"',
    timeField='timestamp',
    metrics=[{
      field: 'value',
      id: '1',
      settings: {},
      type: 'avg',
    }],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '20',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '20',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '4',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          timeZone: 'utc',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);

// Pod latencies section
local average_pod_latency = grafana.graphPanel.new(
  title='Average pod latency',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_min=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='ms',
)
                            .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: podLatencyMeasurement',
    timeField='timestamp',
    alias='{{field}}',
    metrics=[
      {
        field: 'podReadyLatency',
        id: '1',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'schedulingLatency',
        id: '3',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'initializedLatency',
        id: '4',
        meta: {},
        settings: {},
        type: 'avg',
      },
    ],
    bucketAggs=[
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

local pod_latencies_summary = grafana.statPanel.new(
  datasource='$datasource1',
  justifyMode='center',
  title='Pod latencies summary $latencyPercentile',
  unit='ms',
  colorMode='value',  // Note: There isn't currently a way to set the color palette.
).addTarget(
  // Namespaces count
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: podLatencyQuantilesMeasurement',
    alias='$latencyPercentile {{term quantileName.keyword}}',
    timeField='timestamp',
    metrics=[{
      field: '$latencyPercentile',
      id: '1',
      meta: {},
      settings: {},
      type: 'max',
    }],
    bucketAggs=[
      {
        fake: true,
        field: 'quantileName.keyword',
        id: '5',
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
          min_doc_count: '0',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);

local pod_conditions_latency = grafana.tablePanel.new(
  title='Pod conditions latency',
  datasource='$datasource1',
  transform='table',
  styles=[
    {
      pattern: 'Average containersReadyLatency',
      alias: 'ContainersReady',
      type: 'number',
      unit: 'ms',
    },
    {
      pattern: 'Average initializedLatency',
      alias: 'Initialized',
      type: 'number',
      unit: 'ms',
    },
    {
      pattern: 'Average podReadyLatency',
      alias: 'Ready',
      type: 'number',
      unit: 'ms',
    },
    {
      pattern: 'Average schedulingLatency',
      alias: 'Scheduling',
      type: 'number',
      unit: 'ms',
    },
    {
      pattern: 'namespace.keyword',
      alias: 'Namespace',
      type: 'string',
    },
    {
      pattern: 'podName.keyword',
      alias: 'Pod',
      type: 'string',
    },
    {
      pattern: 'nodeName.keyword',
      alias: 'Node',
      type: 'string',
    },
  ],
).addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: podLatencyMeasurement',
    timeField='timestamp',
    metrics=[
      {
        field: 'schedulingLatency',
        id: '1',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'initializedLatency',
        id: '3',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'containersReadyLatency',
        id: '4',
        meta: {},
        settings: {},
        type: 'avg',
      },
      {
        field: 'podReadyLatency',
        id: '5',
        meta: {},
        settings: {},
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'namespace.keyword',
        id: '6',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '5',
          size: '100',
        },
        type: 'terms',
      },
      {
        fake: true,
        field: 'nodeName.keyword',
        id: '7',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '100',
        },
        type: 'terms',
      },
      {
        field: 'podName.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '5',
          size: '100',
        },
        type: 'terms',
      },
    ],
  )
);

local setup_latency = grafana.graphPanel.new(
  title='Top 10 Container runtime network setup latency',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='µs',
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: containerNetworkSetupLatency',
    timeField='timestamp',
    alias='{{labels.node.keyword}}',
    metrics=[
      {
        field: 'value',
        id: '1',
        meta: {},
        settings: {},
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.node.keyword',
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
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local scheduling_throughput = grafana.graphPanel.new(
  title='Scheduling throughput',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='reqps',
)
                              .addTarget(
  es.target(
    query='uuid: $uuid AND metricName.keyword: schedulingThroughput',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        meta: {},
        settings: {},
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

// OVN section
local ovnkube_master_cpu = grafana.graphPanel.new(
  title='ovnkube-master CPU usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                           .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.namespace.keyword: "openshift-ovn-kubernetes"  AND labels.pod.keyword: /ovnkube-master.*/',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          timeZone: 'utc',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);


local ovnkube_master_memory = grafana.graphPanel.new(
  title='ovnkube-master Memory usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                              .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.namespace.keyword: "openshift-ovn-kubernetes"  AND labels.pod.keyword: /ovnkube-master.*/',
    timeField='timestamp',
    alias='{{labels.pod.keyword}}',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'sum',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          timeZone: 'utc',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);

local ovnkube_controller_cpu = grafana.graphPanel.new(
  title='ovn-controller CPU usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                               .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.namespace.keyword: "openshift-ovn-kubernetes"  AND labels.pod.keyword: /ovnkube-node.*/ AND labels.container.keyword: "ovn-controller"',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          timeZone: 'utc',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);


local ovnkube_controller_memory = grafana.graphPanel.new(
  title='ovn-controller Memory usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                                  .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.namespace.keyword: "openshift-ovn-kubernetes"  AND labels.pod.keyword: /ovnkube-node.*/ AND labels.container.keyword: "ovn-controller"',
    timeField='timestamp',
    alias='{{labels.pod.keyword}}',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'sum',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        id: '2',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'timestamp',
        id: '3',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          timeZone: 'utc',
          trimEdges: '0',
        },
        type: 'date_histogram',
      },
    ],
  )
);


// ETCD section
local etcd_fsync_latency = grafana.graphPanel.new(
  title='etcd 99th disk WAL fsync latency',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                           .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "99thEtcdDiskWalFsyncDurationSeconds"',
    timeField='timestamp',
    alias='{{labels.pod.keyword}}',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
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
);

local etcd_commit_latency = grafana.graphPanel.new(
  title='etcd 99th disk backend commit latency',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                            .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "99thEtcdDiskBackendCommitDurationSeconds"',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
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
);


local etcd_leader_changes = grafana.graphPanel.new(
  title='Etcd leader changes',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  min=0,
  format='s',
)
                            .addTarget(
  es.target(
    query='uuid: $uuid AND metricName.keyword: etcdLeaderChangesRate',
    alias='Etcd leader changes',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '1',
        settings: {
          interval: '30s',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);


local etcd_peer_roundtrip_time = grafana.graphPanel.new(
  title='Etcd 99th network peer roundtrip time',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                                 .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: 99thEtcdRoundTripTimeSeconds',
    alias='{{labels.pod.keyword}} to {{labels.To.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.pod.keyword',
        fake: true,
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        fake: true,
        field: 'labels.To.keyword',
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
);

local etcd_cpu = grafana.graphPanel.new(
  title='Etcd CPU utilization',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                 .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.container.keyword: etcd',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        fake: true,
        field: 'labels.container.keyword',
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);


local etcd_memory = grafana.graphPanel.new(
  title='Etcd memory utilization',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                    .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.container.keyword: etcd',
    alias='{{labels.namespace.keyword}}-{{labels.pod.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        fake: true,
        field: 'labels.container.keyword',
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.namespace.keyword',
        id: '5',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

// API an Kubeproxy section

local api_latency_read_only_resource = grafana.graphPanel.new(
  title='Read Only API request P99 latency - resource scoped',
  datasource='$datasource1',
  legend_alignAsTable=true,
  format='s',
)
                                       .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: readOnlyAPICallsLatency AND labels.scope.keyword: resource',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.verb.keyword',
        id: '3',
        settings: {
          min_doc_count: 0,
          order: 'desc',
          orderBy: '_term',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'labels.resource.keyword',
        id: '4',
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
);

local api_latency_read_only_namespace = grafana.graphPanel.new(
  title='Read Only API request P99 latency - namespace scoped',
  datasource='$datasource1',
  legend_alignAsTable=true,
  format='s',
)
                                        .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: readOnlyAPICallsLatency AND labels.scope.keyword: namespace',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.verb.keyword',
        id: '3',
        settings: {
          min_doc_count: 0,
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
);

local api_latency_read_only_cluster = grafana.graphPanel.new(
  title='Read Only API request P99 latency - cluster scoped',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: readOnlyAPICallsLatency AND labels.scope.keyword: cluster',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.verb.keyword',
        id: '3',
        settings: {
          min_doc_count: 0,
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
);

local api_latency_mutating = grafana.graphPanel.new(
  title='Mutating API request P99 latency',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                             .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: mutatingAPICallsLatency',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.verb.keyword',
        id: '3',
        settings: {
          min_doc_count: 0,
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
);


local api_request_rate = grafana.graphPanel.new(
  title='API request rate',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                         .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: APIRequestRate',
    alias='{{labels.verb.keyword}} {{labels.resource.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.resource.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '_term',
          size: '0',
        },
        type: 'terms',
      },
      {
        fake: true,
        field: 'labels.verb.keyword',
        id: '3',
        settings: {
          min_doc_count: 0,
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
);


local service_sync_latency = grafana.graphPanel.new(
  title='Service sync latency',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='s',
)
                             .addTarget(
  es.target(
    query='uuid: $uuid AND metricName.keyword: kubeproxyP99ProgrammingLatency',
    alias='Latency',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.instance.keyword',
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
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
)
                             .addTarget(
  es.target(
    query='uuid: $uuid AND metricName.keyword: serviceSyncLatency',
    alias='Latency',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

// Cluster Kubelet & CRI-O section
local kubelet_process_cpu = grafana.graphPanel.new(
  title='Kubelet process CPU usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                            .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: kubeletCPU',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.node.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local kubelet_process_memory = grafana.graphPanel.new(
  title='Kubelet process RSS memory usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                               .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: kubeletMemory',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.node.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local cri_o_process_cpu = grafana.graphPanel.new(
  title='CRI-O process CPU usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                          .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: crioCPU',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.node.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);


local cri_o_process_memory = grafana.graphPanel.new(
  title='CRI-O RSS memory usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_values=true,
  format='percent',
)
                             .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: crioMemory',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'labels.node.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

// Master Node section

local container_cpu_master = grafana.graphPanel.new(
  title='Container CPU usage $master',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  format='percent',
)
                             .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.node.keyword: $master AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}} {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local container_memory_master = grafana.graphPanel.new(
  title='Container RSS memory $master',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                                .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.node.keyword: $master AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}} {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local cpu_master = grafana.graphPanel.new(
  title='CPU $master',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_min=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                   .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeCPU-Masters" AND labels.instance.keyword: $master',
    alias='{{labels.mode.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
        settings: {
          script: {
            inline: '_value*100',
          },
        },
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.mode.keyword',
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
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local memory_master = grafana.graphPanel.new(
  title='Memory $master',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryAvailable-Masters" AND labels.instance.keyword: $master',
    alias='Available',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryTotal-Masters" AND labels.instance.keyword: $master',
    alias='Total',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryUtilization-Masters" AND labels.instance.keyword: $master',
    alias='Utilization',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
);

// Worker Node section

local container_cpu_worker = grafana.graphPanel.new(
  title='Container CPU usage $worker',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  format='percent',
)
                             .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.node.keyword: $worker AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}} {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local container_memory_worker = grafana.graphPanel.new(
  title='Container RSS memory $worker',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                                .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.node.keyword: $worker AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}} {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local cpu_worker = grafana.graphPanel.new(
  title='CPU $worker',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_min=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                   .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeCPU-Workers" AND labels.instance.keyword: $worker',
    alias='{{labels.mode.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
        settings: {
          script: {
            inline: '_value*100',
          },
        },
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.mode.keyword',
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
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local memory_worker = grafana.graphPanel.new(
  title='Memory $worker',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryAvailable-Workers" AND labels.instance.keyword: $worker',
    alias='Available',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryTotal-Workers" AND labels.instance.keyword: $worker',
    alias='Total',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
)
                      .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryUtilization-Workers" AND labels.instance.keyword: $worker',
    alias='Utilization',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
);


// Infra Node section

local container_cpu_infra = grafana.graphPanel.new(
  title='Container CPU usage $infra',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  format='percent',
)
                            .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerCPU" AND labels.node.keyword: $infra AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}} {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local container_memory_infra = grafana.graphPanel.new(
  title='Container RSS memory $infra',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                               .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName: "containerMemory" AND labels.node.keyword: $infra AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}} {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
        id: '4',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
        },
        type: 'terms',
      },
      {
        field: 'labels.container.keyword',
        fake: true,
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '0',
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
);

local cpu_infra = grafana.graphPanel.new(
  title='CPU $infra',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_min=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                  .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeCPU-Infra" AND labels.instance.keyword: $infra',
    alias='{{labels.mode.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
        settings: {
          script: {
            inline: '_value*100',
          },
        },
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.mode.keyword',
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
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local memory_infra = grafana.graphPanel.new(
  title='Memory $infra',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                     .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryAvailable-Infra" AND labels.instance.keyword: $infra',
    alias='Available',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
)
                     .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryTotal-Infra" AND labels.instance.keyword: $infra',
    alias='Total',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
)
                     .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryUtilization-Infra" AND labels.instance.keyword: $infra',
    alias='Utilization',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
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
);

// Aggregated worker node usage section
local agg_avg_cpu = grafana.graphPanel.new(
  title='Avg CPU usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                    .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeCPU-AggregatedWorkers"',
    alias='{{labels.mode.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
        settings: {
          script: {
            inline: '_value*100',
          },
        },
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.mode.keyword',
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
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local agg_avg_mem = grafana.graphPanel.new(
  title='Avg Memory',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_rightSide=true,
  legend_max=true,
  legend_values=true,
  format='bytes',
)
                    .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryAvailable-AggregatedWorkers"',
    alias='Available',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
)
                    .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "nodeMemoryTotal-AggregatedWorkers"',
    alias='Total',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        field: 'timestamp',
        id: '2',
        settings: {
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);


local agg_container_cpu = grafana.graphPanel.new(
  title='Container CPU usage',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='percent',
)
                          .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "containerCPU-AggregatedWorkers" AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}}: {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.container.keyword',
        id: '3',
        settings: {
          min_doc_count: '1',
          order: 'desc',
          orderBy: '1',
          size: '10',
        },
        type: 'terms',
      },
      {
        field: 'labels.pod.keyword',
        id: '4',
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
          interval: 'auto',
          min_doc_count: '1',
          trimEdges: 0,
        },
        type: 'date_histogram',
      },
    ],
  )
);

local agg_container_mem = grafana.graphPanel.new(
  title='Container memory RSS',
  datasource='$datasource1',
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_values=true,
  format='bytes',
)
                          .addTarget(
  es.target(
    query='uuid.keyword: $uuid AND metricName.keyword: "containerMemory-AggregatedWorkers" AND labels.namespace.keyword: $namespace',
    alias='{{labels.pod.keyword}}: {{labels.container.keyword}}',
    timeField='timestamp',
    metrics=[
      {
        field: 'value',
        id: '1',
        type: 'avg',
      },
    ],
    bucketAggs=[
      {
        fake: true,
        field: 'labels.pod.keyword',
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
        fake: true,
        field: 'labels.container.keyword',
        id: '3',
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
          trimEdges: 0,
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
  grafana.template.new(
    label='Platform',
    name='platform',
    current='All',
    query='{"find": "terms", "field": "platform.keyword"}',
    refresh=2,
    multi=true,
    includeAll=true,
    datasource='$datasource1',
  )
)
.addTemplate(
  grafana.template.new(
    label='SDN type',
    name='sdn',
    current='All',
    query='{"find": "terms", "field": "sdn_type.keyword"}',
    refresh=2,
    multi=true,
    includeAll=true,
    datasource='$datasource1',
  )
)
.addTemplate(
  grafana.template.new(
    label='Workload',
    multi=true,
    query='{"find": "terms", "field": "workload.keyword", "query": "platform.keyword: $platform AND sdn_type.keyword: $sdn"}',
    refresh=1,
    name='workload',
    includeAll=false,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='Worker count',
    multi=true,
    query='{"find": "terms", "field": "worker_nodes_count", "query": "platform.keyword: $platform AND sdn_type.keyword: $sdn AND workload.keyword: $workload"}',
    refresh=1,
    name='worker_count',
    includeAll=true,
    datasource='$datasource1'
  )
)
.addTemplate(
  grafana.template.new(
    label='UUID',
    multi=false,
    query='{"find": "terms", "field": "uuid.keyword", "query": "platform.keyword: $platform AND sdn_type.keyword: $sdn AND workload.keyword: $workload AND worker_nodes_count: $worker_count"}',
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
  openshift_version_panel, { x: 16, y: 0, w: 6, h: 4 },
)
.addPanel(
  etcd_version_panel, { x: 22, y: 0, w: 2, h: 4 }
)
.addPanel(
  job_summary_panel, { x: 0, y: 4, h: 3, w: 24 },
)
.addPanel(
  grafana.row.new(title='Cluster status', collapse=true).addPanels(
    [
      masters_cpu { gridPos: { x: 0, y: 8, w: 12, h: 9 } },
      masters_memory { gridPos: { x: 12, y: 8, w: 12, h: 9 } },
      node_status_summary { gridPos: { x: 0, y: 17, w: 12, h: 8 } },
      pod_status_summary { gridPos: { x: 12, y: 17, w: 12, h: 8 } },
      kube_api_cpu { gridPos: { x: 0, y: 25, w: 12, h: 9 } },
      kube_api_memory { gridPos: { x: 12, y: 25, w: 12, h: 9 } },
      active_controller_manager_cpu { gridPos: { x: 0, y: 34, w: 12, h: 9 } },
      active_controller_manager_memory { gridPos: { x: 12, y: 34, w: 12, h: 9 } },
      kube_scheduler_cpu { gridPos: { x: 0, y: 43, w: 12, h: 9 } },
      kube_scheduler_memory { gridPos: { x: 12, y: 43, w: 12, h: 9 } },
      hypershift_controlplane_cpu { gridPos: { x: 0, y: 52, w: 12, h: 9 } },
      hypershift_controlplane_memory { gridPos: { x: 12, y: 52, w: 12, h: 9 } },
    ]
  ), { x: 0, y: 7, w: 24, h: 1 }
)
.addPanel(
  // Panels below for uncollapsed row.
  grafana.row.new(title='Pod latency stats', collapse=false), { x: 0, y: 8, w: 24, h: 1 }
)
.addPanels(
  [
    average_pod_latency { gridPos: { x: 0, y: 9, w: 12, h: 8 } },
    pod_latencies_summary { gridPos: { x: 12, y: 9, w: 12, h: 8 } },
    pod_conditions_latency { gridPos: { x: 0, y: 17, w: 24, h: 10 } },
    setup_latency { gridPos: { x: 0, y: 27, w: 12, h: 9 } },
    scheduling_throughput { gridPos: { x: 12, y: 27, w: 12, h: 9 } },
  ]
)
.addPanel(
  grafana.row.new(title='OVNKubernetes', collapse=true).addPanels(
    [
      ovnkube_master_cpu { gridPos: { x: 0, y: 80, w: 12, h: 8 } },
      ovnkube_master_memory { gridPos: { x: 12, y: 80, w: 12, h: 8 } },
      ovnkube_controller_cpu { gridPos: { x: 0, y: 88, w: 12, h: 8 } },
      ovnkube_controller_memory { gridPos: { x: 12, y: 88, w: 12, h: 8 } },
    ]
  ), { x: 0, y: 36, w: 24, h: 1 }
)
.addPanel(
  grafana.row.new(title='etcd', collapse=false), { x: 0, y: 37, w: 24, h: 1 }
)
.addPanels(
  [
    etcd_fsync_latency { gridPos: { x: 0, y: 38, w: 12, h: 9 } },
    etcd_commit_latency { gridPos: { x: 12, y: 38, w: 12, h: 9 } },
    etcd_leader_changes { gridPos: { x: 0, y: 47, w: 12, h: 9 } },
    etcd_peer_roundtrip_time { gridPos: { x: 12, y: 47, w: 12, h: 9 } },
    etcd_cpu { gridPos: { x: 0, y: 56, w: 12, h: 9 } },
    etcd_memory { gridPos: { x: 12, y: 56, w: 12, h: 9 } },
  ],
)
.addPanel(
  grafana.row.new(title='API and Kubeproxy', collapse=false), { x: 0, y: 65, w: 24, h: 1 }
)
.addPanels(
  [
    api_latency_read_only_resource { gridPos: { x: 0, y: 66, w: 12, h: 9 } },
    api_latency_read_only_namespace { gridPos: { x: 12, y: 66, w: 12, h: 9 } },
    api_latency_read_only_cluster { gridPos: { x: 0, y: 75, w: 12, h: 9 } },
    api_latency_mutating { gridPos: { x: 12, y: 75, w: 12, h: 9 } },
    api_request_rate { gridPos: { x: 0, y: 84, w: 12, h: 9 } },
    service_sync_latency { gridPos: { x: 12, y: 84, w: 12, h: 9 } },
  ],
)

.addPanel(
  grafana.row.new(title='API and Kubeproxy', collapse=false), { x: 0, y: 93, w: 24, h: 1 }
)
.addPanels(
  [
    kubelet_process_cpu { gridPos: { x: 0, y: 94, w: 12, h: 8 } },
    kubelet_process_memory { gridPos: { x: 12, y: 94, w: 12, h: 8 } },
    cri_o_process_cpu { gridPos: { x: 0, y: 103, w: 12, h: 8 } },
    cri_o_process_memory { gridPos: { x: 12, y: 103, w: 12, h: 8 } },
  ],
)

.addPanel(
  grafana.row.new(title='Master: $master', collapse=true, repeat='$master').addPanels(
    [
      container_cpu_master { gridPos: { x: 0, y: 112, w: 12, h: 9 } },
      container_memory_master { gridPos: { x: 12, y: 112, w: 12, h: 9 } },
      cpu_master { gridPos: { x: 0, y: 121, w: 12, h: 9 } },
      memory_master { gridPos: { x: 12, y: 121, w: 12, h: 9 } },
    ]
  ), { x: 0, y: 111, w: 24, h: 1 }
)

.addPanel(
  grafana.row.new(title='Worker: $worker', collapse=true, repeat='$worker').addPanels(
    [
      container_cpu_worker { gridPos: { x: 0, y: 112, w: 12, h: 9 } },
      container_memory_worker { gridPos: { x: 12, y: 112, w: 12, h: 9 } },
      cpu_worker { gridPos: { x: 0, y: 121, w: 12, h: 9 } },
      memory_worker { gridPos: { x: 12, y: 121, w: 12, h: 9 } },
    ]
  ), { x: 0, y: 111, w: 24, h: 1 }
)

.addPanel(
  grafana.row.new(title='Infra: $infra', collapse=true, repeat='$infra').addPanels(
    [
      container_cpu_infra { gridPos: { x: 0, y: 131, w: 12, h: 9 } },
      container_memory_infra { gridPos: { x: 12, y: 131, w: 12, h: 9 } },
      cpu_infra { gridPos: { x: 0, y: 140, w: 12, h: 9 } },
      memory_infra { gridPos: { x: 12, y: 140, w: 12, h: 9 } },
    ]
  ), { x: 0, y: 130, w: 24, h: 1 }
)

.addPanel(
  grafana.row.new(title='Aggregated worker nodes usage (only in aggregated metrics profile)', collapse=true).addPanels(
    [
      agg_avg_cpu { gridPos: { x: 0, y: 150, w: 12, h: 9 } },
      agg_avg_mem { gridPos: { x: 12, y: 150, w: 12, h: 9 } },
      agg_container_cpu { gridPos: { x: 0, y: 159, w: 12, h: 9 } },
      agg_container_mem { gridPos: { x: 12, y: 159, w: 12, h: 9 } },
    ]
  ), { x: 0, y: 149, w: 24, h: 1 }
)
