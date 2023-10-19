local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
  averagePodLatency: {
    query(): 
        elasticsearch.withAlias("{{field}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
          + elasticsearch.bucketAggs.DateHistogram.withId("5")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(1)
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("podReadyLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("4")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("schedulingLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("3")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("initializedLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("2")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("containersReadyLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: podLatencyMeasurement')
        + elasticsearch.withTimeField('timestamp')
  },
  podLatenciesSummary: {
    query(): 
        elasticsearch.withAlias("$latencyPercentile {{term quantileName.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("quantileName.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Max.withField("$latencyPercentile")
         + elasticsearch.metrics.MetricAggregationWithSettings.Max.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Max.withType('max'),
        ])
        + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: podLatencyQuantilesMeasurement')
        + elasticsearch.withTimeField('timestamp')
  },
  podConditionsLatency: {
    query():
        elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField("namespace.keyword")
          + elasticsearch.bucketAggs.Terms.withId("7")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("100"),
        elasticsearch.bucketAggs.Terms.withField("nodeName.keyword")
          + elasticsearch.bucketAggs.Terms.withId("6")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("100"),
        elasticsearch.bucketAggs.Terms.withField("podName.keyword")
          + elasticsearch.bucketAggs.Terms.withId("5")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("100"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("schedulingLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("4")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("initializedLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("3")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("containersReadyLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("2")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("podReadyLatency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: podLatencyMeasurement')
        + elasticsearch.withQueryType('randomWalk')
        + elasticsearch.withTimeField('timestamp')
  },
  top10ContainerRuntimeNetworkSetupLatency: {
    query(): 
        elasticsearch.withAlias("{{labels.node.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.node.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: containerNetworkSetupLatency')
        + elasticsearch.withTimeField('timestamp')
  },
  schedulingThroughput: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: schedulingThroughput')
        + elasticsearch.withTimeField('timestamp')
  },
  mastersCPUUtilization: {
    queries(): [
        elasticsearch.withAlias("{{labels.instance.keyword}}")
        + elasticsearch.withHide(false)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.instance.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.settings.withScript("_value * 100")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"nodeCPU-Masters\" AND NOT labels.mode.keyword: idle AND NOT labels.mode.keyword: steal")
        + elasticsearch.withTimeField('timestamp'),
        elasticsearch.withAlias("Aggregated")
        + elasticsearch.withHide(false)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.settings.withScript("_value * 100")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: nodeCPU-Masters AND NOT labels.mode.keyword: idle AND NOT labels.mode.keyword: steal")
        + elasticsearch.withTimeField('timestamp')
    ]
  },
  mastersMemoryUtilization: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withHide(false)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.instance.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
        self.base("Utilization {{labels.instance.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: nodeMemoryUtilization-Masters"),
        self.base("Total {{labels.instance.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: nodeMemoryTotal-Masters"),
        elasticsearch.withAlias("Aggregated utilization")
        + elasticsearch.withHide(false)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: nodeMemoryUtilization-Masters")
        + elasticsearch.withTimeField('timestamp')
    ]
  },
  nodeStatusSummary: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.condition.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"nodeStatus\"")
        + elasticsearch.withTimeField('timestamp')
  },
  podStatusSummary: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.phase.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"podStatusCount\"")
        + elasticsearch.withTimeField('timestamp')
  },
  kubeApiServerUsage: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("5")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.namespace.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerCPU\" AND labels.container.keyword: kube-apiserver"),
        self.base("Rss {{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerMemory\" AND labels.container.keyword: kube-apiserver"),
        self.base("Rss {{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerMemory-Masters\" AND labels.container.keyword: kube-apiserver"),
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerCPU-Masters\" AND labels.container.keyword: kube-apiserver"),
    ]
  },
  averageKubeApiServerUsage: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto'),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
        self.base("Avg CPU kube-apiserver", "uuid.keyword: $uuid AND metricName: \"containerCPU\" AND labels.container.keyword: kube-apiserver"),
        self.base("Avg Rss kube-apiserver", "uuid.keyword: $uuid AND metricName: \"containerMemory\" AND labels.container.keyword: kube-apiserver"),
    ]
  },
  activeKubeControllerManagerUsage: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("5")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("1"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.namespace.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerCPU\" AND labels.container.keyword: kube-controller-manager"),
        self.base("Rss {{labels.namespace.keyword}}-{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerMemory\" AND labels.container.keyword: kube-controller-manager"),
        self.base("{{labels.namespace.keyword}}-{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerCPU-Masters\" AND labels.container.keyword: kube-controller-manager"),
        self.base("Rss {{labels.namespace.keyword}}-{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: \"containerMemory-Masters\" AND labels.container.keyword: kube-controller-manager"),
    ]
  },
  kubeSchedulerUsage: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("5")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.namespace.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \"containerCPU\" AND labels.container.keyword: kube-scheduler"),
        self.base("Rss {{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \"containerMemory\" AND labels.container.keyword: kube-scheduler"),
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \"containerCPU-Masters\" AND labels.container.keyword: kube-scheduler"),
        self.base("Rss {{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \"containerMemory-Masters\" AND labels.container.keyword: kube-scheduler"),
    ]
  },
  nodeCount: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.role.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.Count.withId("1")
         + elasticsearch.metrics.Count.withType('count'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName: \"nodeRoles\"")
        + elasticsearch.withTimeField('timestamp')
  },
  aggregatesCount: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
        self.base("Namespaces", "uuid.keyword: $uuid AND metricName: \"namespaceCount\" AND labels.phase: \"Active\""),
        self.base("Services", "uuid.keyword: $uuid AND metricName: \"serviceCount\""),
        self.base("Deployments", "uuid.keyword: $uuid AND metricName: \"deploymentCount\""),
        self.base("Secrets", "uuid.keyword: $uuid AND metricName.keyword: \"secretCount\""),
        self.base("ConfigMaps", "uuid.keyword: $uuid AND metricName.keyword: \"configmapCount\""),
    ]
  },
  openshiftVersion: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.RawData.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize("500")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"etcdVersion\"")
        + elasticsearch.withTimeField('timestamp')
  },
  jobSummary: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withHide(false)
        + elasticsearch.withBucketAggs([])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.RawData.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize("500")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: jobSummary")
        + elasticsearch.withTimeField('timestamp')
  },
  clusterMetadata: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withHide(false)
        + elasticsearch.withBucketAggs([])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.RawData.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize("500")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: clusterMetadata")
        + elasticsearch.withTimeField('timestamp')
  },
  alerts: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.RawData.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize("500")
         + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: alert")
        + elasticsearch.withTimeField('timestamp')
  },
  ovnKubeMasterPodStats: {
      base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(metric): [
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.pod.keyword: /ovnkube-master.*/"),
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.pod.keyword: /ovnkube-control-plane.*/"),
    ]
  },
  ovnKubeMasterStats: {
      base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(metric): [
        self.base("{{labels.pod.keyword}}-{{labels.container.keyword}}", "uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.pod.keyword: /ovnkube-master.*/"),
        self.base("{{labels.pod.keyword}}-{{labels.container.keyword}}", "uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.pod.keyword: /ovnkube-control-plane.*/"),
    ]
  },
  ovnKubeNodePodStats: {
      base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("5"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(metric): [
        self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.namespace.keyword: \"openshift-ovn-kubernetes\" AND labels.pod.keyword: /ovnkube-node.*/"),
        elasticsearch.withAlias('Aggregated')
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.namespace.keyword: \"openshift-ovn-kubernetes\" AND labels.pod.keyword: /ovnkube-node.*/")
        + elasticsearch.withTimeField('timestamp'),        
    ]
  },
  ovnControllerStats: {
    query(metric): 
        elasticsearch.withAlias("{{labels.pod.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("5"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.namespace.keyword: \"openshift-ovn-kubernetes\"  AND labels.pod.keyword: /ovnkube-node.*/ AND labels.container.keyword: \"ovn-controller\"")
        + elasticsearch.withTimeField('timestamp')
  },
  aggregatedOVNKubeMasterStats: {
      base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(metric): [
      self.base("", "uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.pod.keyword: /ovnkube-master.*/"),
      self.base("","uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.pod.keyword: /ovnkube-control-plane.*/"),
    ],
  },
  aggregatedOVNKubeNodeStats: {
    query(metric): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.namespace.keyword: \"openshift-ovn-kubernetes\"  AND labels.pod.keyword: /ovnkube-node.*/")
        + elasticsearch.withTimeField('timestamp')
  },
  etcd99thLatencies: {
    query(metric): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \""+ metric +"\"")
        + elasticsearch.withTimeField('timestamp')
  },
  etcdLeaderChanges: {
    query(): 
        elasticsearch.withAlias("Etcd leader changes")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: etcdLeaderChangesRate")
        + elasticsearch.withTimeField('timestamp')
  },
  etcd99thNetworkPeerRT: {
    query(): 
        elasticsearch.withAlias("{{labels.pod.keyword}} to {{labels.To.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.Terms.withField("labels.To.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: 99thEtcdRoundTripTimeSeconds")
        + elasticsearch.withTimeField('timestamp')
  },
  etcdResourceUtilization: {
      base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
      self.base("Rss {{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: containerMemory* AND labels.container.keyword: etcd"),
      self.base("{{labels.pod.keyword}}", "uuid.keyword: $uuid AND metricName.keyword: containerCPU* AND labels.container.keyword: etcd"),
    ],
  },
  readOnlyAPILatencyResource: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.verb.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(0)
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.Terms.withField("labels.resource.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: readOnlyAPICallsLatency AND labels.scope.keyword: resource")
        + elasticsearch.withTimeField('timestamp')
  },
  readOnlyAPILatencyNamespace: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.verb.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(0)
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: readOnlyAPICallsLatency AND labels.scope.keyword: namespace")
        + elasticsearch.withTimeField('timestamp')
  },
  readOnlyAPILatencyCluster: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.verb.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(0)
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: readOnlyAPICallsLatency AND labels.scope.keyword: cluster")
        + elasticsearch.withTimeField('timestamp')
  },
  readOnlyAPILatencyMutating: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.verb.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(0)
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: mutatingAPICallsLatency")
        + elasticsearch.withTimeField('timestamp')
  },
  serviceSyncLatency: {
    query(): 
        elasticsearch.withAlias("Latency")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: serviceSyncLatency")
        + elasticsearch.withTimeField('timestamp')
  },
  apiRequestRate: {
    query(): 
        elasticsearch.withAlias("{{labels.verb.keyword}} {{labels.resource.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.resource.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.verb.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: APIRequestRate")
        + elasticsearch.withTimeField('timestamp')
  },
  top5KubeletProcessByCpuUsage: {
    queries(): [
        elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.node.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("5"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: kubeletCPU")
        + elasticsearch.withTimeField('timestamp'),
       elasticsearch.withAlias("Average across workers")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: kubeletCPU")
        + elasticsearch.withTimeField('timestamp'),
    ],
  },
  top5CrioProcessByCpuUsage: {
    queries(): [
        elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.node.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("5"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: crioCPU")
        + elasticsearch.withTimeField('timestamp'),
       elasticsearch.withAlias("Average across workers")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: crioCPU")
        + elasticsearch.withTimeField('timestamp'),
    ],
  },
  top5KubeletRSSByMemoryUsage: {
    queries(): [
       elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.node.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("5"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: kubeletMemory")
        + elasticsearch.withTimeField('timestamp'),
       elasticsearch.withAlias("Average across workers")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: kubeletMemory")
        + elasticsearch.withTimeField('timestamp'),
    ],
  },
  top5CrioRSSByMemoryUsage: {
    queries(): [
        elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.node.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("5"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: crioMemory")
        + elasticsearch.withTimeField('timestamp'),
       elasticsearch.withAlias("Average across workers")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: crioMemory")
        + elasticsearch.withTimeField('timestamp'),
    ],
  },
  mastersContainerStats: {
    query(metric): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto'),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.node.keyword: $master")
        + elasticsearch.withTimeField('timestamp')
  },
  masterCPU: {
    query(): 
        elasticsearch.withAlias("{{labels.mode.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.mode.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withSettings({
            "script": {
              "inline": "_value*100"
            }
          })
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"nodeCPU-Masters\" AND labels.instance.keyword: $master")
        + elasticsearch.withTimeField('timestamp')
  },
  masterMemory: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
      self.base("Utilization", "uuid.keyword: $uuid AND metricName.keyword: \"nodeMemoryUtilization-Masters\" AND labels.instance.keyword: $master"),
    ],
  },
  workersContainerStats: {
    query(metric): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto'),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: "+ metric +" AND labels.node.keyword: $worker")
        + elasticsearch.withTimeField('timestamp')
  },
  workerCPU: {
    query(): 
        elasticsearch.withAlias("{{labels.mode.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.mode.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withSettings({
            "script": {
              "inline": "_value*100"
            }
          })
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"nodeCPU-Workers\" AND labels.instance.keyword: \"$worker\"")
        + elasticsearch.withTimeField('timestamp')
  },
  workerMemory: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
      self.base("Utilization", "uuid.keyword: $uuid AND metricName.keyword: \"nodeMemoryUtilization-Workers\" AND labels.instance.keyword: $worker"),
    ],
  },
  infraContainerStats: {
    queries(metric): [
        elasticsearch.withAlias("{{labels.pod.keyword}}: {{labels.container.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName: \""+ metric +"\" AND labels.node.keyword: \"$infra\" AND labels.namespace.keyword: $namespace")
        + elasticsearch.withTimeField('timestamp'),
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.Terms.withField("labels.container.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto'),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: "+ metric +"-Infra AND labels.node.keyword: $infra")
        + elasticsearch.withTimeField('timestamp'),
    ],
  },
  infraCPU: {
    query(): 
        elasticsearch.withAlias("{{labels.mode.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.mode.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withSettings({
            "script": {
              "inline": "_value*100"
            }
          })
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"nodeCPU-Infra\" AND labels.instance.keyword: $infra")
        + elasticsearch.withTimeField('timestamp')
  },
  infraMemory: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
      self.base("available", "uuid.keyword: $uuid AND metricName.keyword: \"nodeMemoryAvailable-Infra\" AND labels.instance.keyword: $infra"),
      self.base("Total", "uuid.keyword: $uuid AND metricName.keyword: \"nodeMemoryTotal-Infra\" AND labels.instance.keyword: $infra"),
    ],
  },
  aggWorkerNodeCpuUsage: {
    query(): 
        elasticsearch.withAlias("{{labels.mode.keyword}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.mode.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withSettings({
            "script": {
              "inline": "_value*100"
            }
          })
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: \"nodeCPU-AggregatedWorkers\"")
        + elasticsearch.withTimeField('timestamp')
  },
  aggWorkerNodeMemory: {
    base(alias, query):
        elasticsearch.withAlias(alias)
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('30s')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery(query)
        + elasticsearch.withTimeField('timestamp'),
    queries(): [
      self.base("Available", "uuid.keyword: $uuid AND metricName.keyword: \"nodeMemoryAvailable-AggregatedWorkers\""),
    ],
  },
  aggWorkerNodeContainerCpuUsage: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1'),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: containerCPU-AggregatedWorkers")
        + elasticsearch.withTimeField('timestamp')
  },
  aggWorkerNodeContainerMemoryUsage: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("labels.pod.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount("1")
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
          + elasticsearch.bucketAggs.DateHistogram.withId("2")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto'),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("value")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery("uuid.keyword: $uuid AND metricName.keyword: containerMemory-AggregatedWorkers")
        + elasticsearch.withTimeField('timestamp')
  },
}