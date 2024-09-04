local variables = import './variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local elasticsearch = g.query.elasticsearch;

{

  platformOverview: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize('500')
        + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: jobSummary')
      + elasticsearch.withTimeField('timestamp'),
  },

  jobSummary: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize('500')
        + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: jobSummary')
      + elasticsearch.withTimeField('timestamp'),
  },

  nodeCPUusage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('1')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: cpu-$node_roles')
      + elasticsearch.withTimeField('timestamp'),
  },

  maximumCPUusage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('1')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-cpu-$node_roles')
      + elasticsearch.withTimeField('timestamp'),
  },

  masterMemoryUsage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('1')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: memory-$node_roles')
      + elasticsearch.withTimeField('timestamp'),
  },

  maximumAggregatedMemory: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('1')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-memory-sum-$node_roles')
      + elasticsearch.withTimeField('timestamp'),
  },

  maxClusterCPUusageRatio: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-cpu-cluster-usage-ratio')
      + elasticsearch.withTimeField('timestamp'),
  },

  maxClusterMemoryUsageratio: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-memory-cluster-usage-ratio')
      + elasticsearch.withTimeField('timestamp'),
  },

  P99PodReadyLatency: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('6')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('7')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('P99')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: podLatencyQuantilesMeasurement AND quantileName.keyword: Ready')
      + elasticsearch.withTimeField('timestamp'),
  },

  P99ServiceReadyLatency: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('6')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('7')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('P99')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: svcLatencyQuantilesMeasurement AND quantileName.keyword: Ready')
      + elasticsearch.withTimeField('timestamp'),
  },

  ovnKubeMasterPodStats: {
    base(alias, query):
      elasticsearch.withAlias(alias)
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('labels.pod.keyword')
        + elasticsearch.bucketAggs.Terms.withId('3')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('0'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('2')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('10s')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
      ])
      + elasticsearch.withQuery(query)
      + elasticsearch.withTimeField('timestamp'),
    queries(metric): [
      self.base('{{labels.pod.keyword}}', 'uuid.keyword: $uuid AND metricName: "' + metric + '" AND labels.pod.keyword: /ovnkube-master.*/'),
      self.base('{{labels.pod.keyword}}', 'uuid.keyword: $uuid AND metricName: "' + metric + '" AND labels.pod.keyword: /ovnkube-control-plane.*/'),
    ],
  },
  // OVNkube control plane container stats
  ovnKubeMasterContainerStats: {
    base(alias, query):
      elasticsearch.withAlias(alias)
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('labels.container.keyword')
        + elasticsearch.bucketAggs.Terms.withId('3')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('0'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('2')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('10s')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum'),
      ])
      + elasticsearch.withQuery(query)
      + elasticsearch.withTimeField('timestamp'),
    queries(metric): [
      self.base('{{labels.container.keyword}}', 'uuid.keyword: $uuid AND metricName: "' + metric + '"  labels.container.keyword: /ovnkube-master.*/'),
      self.base('{{labels.container.keyword}}', 'uuid.keyword: $uuid AND metricName: "' + metric + '"  labels.container: /ovnkube-control-plane.*/'),
    ],
  },

  ReadOnlyAPIRequestP99LatencyResourceScoped: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: avg-ro-apicalls-latency AND labels.scope.keyword: resource')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxReadOnlyAPIrequestP99ResourceScoped: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-ro-apicalls-latency AND labels.scope.keyword: resource')
      + elasticsearch.withTimeField('timestamp'),
  },

  ReadonlyAPIrequestP99LatencyNamespaceScoped: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: avg-ro-apicalls-latency AND labels.scope.keyword: namespace')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxReadOnlyAPIrequestP99LatencyNamespaceScoped: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-ro-apicalls-latency AND labels.scope.keyword: namespace')
      + elasticsearch.withTimeField('timestamp'),
  },

  ReadOnlyAPIrequestP99LatencyClusterScoped: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: avg-ro-apicalls-latency AND labels.scope.keyword: cluster')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxReadonlyAPIrequestP99LatencyClusterScoped: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-ro-apicalls-latency AND labels.scope.keyword: cluster')
      + elasticsearch.withTimeField('timestamp'),
  },

  MutatingAPIrequestP99Latency: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: avg-mutating-apicalls-latency')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxMutatingAPIrequestP99Latency: {
    query():
      elasticsearch.withAlias('Memory')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-mutating-apicalls-latency')
      + elasticsearch.withTimeField('timestamp'),
  },

  etcd99thWALfsync: {
    query():
      elasticsearch.withAlias('{{labels.pod.keyword}}')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: 99thEtcdDiskWalFsync')
      + elasticsearch.withTimeField('timestamp'),
  },

  Max99thWALfsync: {
    query():
      elasticsearch.withAlias('{{labels.pod.keyword}}')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-99thEtcdDiskWalFsync')
      + elasticsearch.withTimeField('timestamp'),
  },

  etcd99Roundtrip: {
    query():
      elasticsearch.withAlias('{{labels.pod.keyword}}')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: 99thEtcdRoundTripTime')
      + elasticsearch.withTimeField('timestamp'),
  },

  Max99Roundtrip: {
    query():
      elasticsearch.withAlias('{{labels.pod.keyword}}')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-99thEtcdRoundTripTime')
      + elasticsearch.withTimeField('timestamp'),
  },

  etcd99BackendIandO: {
    query():
      elasticsearch.withAlias('{{labels.pod.keyword}}')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: 99thEtcdDiskBackendCommit')
      + elasticsearch.withTimeField('timestamp'),
  },

  Max99thBackendIandO: {
    query():
      elasticsearch.withAlias('{{labels.pod.keyword}}')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-99thEtcdDiskBackendCommit')
      + elasticsearch.withTimeField('timestamp'),
  },

  etcdCPUusage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: cpu-etcd')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxetcdCPUusage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-cpu-etcd')
      + elasticsearch.withTimeField('timestamp'),
  },

  etcdRSSusage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: memory-etcd')
      + elasticsearch.withTimeField('timestamp'),
  },

  etcdMaxRSSusage: {
    query():
      elasticsearch.withAlias('')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('5')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
        elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
        + elasticsearch.bucketAggs.DateHistogram.withId('3')
        + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
        + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
        + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount('0')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone('utc')
        + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: memory-etcd')
      + elasticsearch.withTimeField('timestamp'),
  },

  AvgRSSUsageComponet: {
    query():
      elasticsearch.withAlias('RSS')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: memory-${component:raw}')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxAggregatedRSSUsageComponent: {
    query():
      elasticsearch.withAlias('RSS')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-memory-sum-${component:raw}')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxRSSUsageComponent: {
    query():
      elasticsearch.withAlias('RSS')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-memory-${component:raw}')
      + elasticsearch.withTimeField('timestamp'),
  },
  AvgCPUUsageComponent: {
    query():
      elasticsearch.withAlias('RSS')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: cpu-${component:raw}')
      + elasticsearch.withTimeField('timestamp'),
  },

  MaxCPUUsageComponent: {
    query():
      elasticsearch.withAlias('RSS')
      + elasticsearch.withBucketAggs([
        elasticsearch.bucketAggs.Terms.withField('$compare_by.keyword')
        + elasticsearch.bucketAggs.Terms.withId('2')
        + elasticsearch.bucketAggs.Terms.withType('terms')
        + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
        + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
        + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
        + elasticsearch.bucketAggs.Terms.settings.withSize('10'),
      ])
      + elasticsearch.withMetrics([
        elasticsearch.metrics.MetricAggregationWithSettings.Average.withField('value')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId('1')
        + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
      ])
      + elasticsearch.withQuery('uuid.keyword: $uuid AND metricName.keyword: max-cpu-${component:raw}')
      + elasticsearch.withTimeField('timestamp'),
  },
}
