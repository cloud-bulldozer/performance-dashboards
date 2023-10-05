local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
  all: {
    query(): 
        elasticsearch.withAlias("cluster={{metadata.clusterName.keyword}} platform={{metadata.platform.keyword}} acrossAZ={{acrossAZ}} streams={{parallelism}} version={{metadata.ocpVersion.keyword}} hostNetwork={{hostNetwork}} mtu={{metadata.mtu}}")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("messageSize")
          + elasticsearch.bucketAggs.Terms.withId("2")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("parallelism")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("metadata.platform.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("profile.keyword")
          + elasticsearch.bucketAggs.Terms.withId("5")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("driver.keyword")
          + elasticsearch.bucketAggs.Terms.withId("6")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("metadata.ocpVersion.keyword")
          + elasticsearch.bucketAggs.Terms.withId("8")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("hostNetwork")
          + elasticsearch.bucketAggs.Terms.withId("9")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("acrossAZ")
          + elasticsearch.bucketAggs.Terms.withId("10")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("metadata.clusterName.keyword")
          + elasticsearch.bucketAggs.Terms.withId("11")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.Terms.withField("metadata.mtu")
          + elasticsearch.bucketAggs.Terms.withId("12")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
          elasticsearch.bucketAggs.DateHistogram.withField('timestamp')
          + elasticsearch.bucketAggs.DateHistogram.withId("7")
          + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
          + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
          + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("0")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
          + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("throughput")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
        ])
        + elasticsearch.withQuery('uuid: $uuid AND parallelism: $parallelism AND profile: $profile AND messageSize: $messageSize AND driver.keyword: $driver AND hostNetwork: $hostNetwork AND acrossAZ: false AND service: $service')
        + elasticsearch.withTimeField('timestamp')
  },
  parallelismAll: {
    query(): 
        elasticsearch.withAlias("")
        + elasticsearch.withBucketAggs([
          elasticsearch.bucketAggs.Terms.withField("uuid.keyword")
          + elasticsearch.bucketAggs.Terms.withId("3")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("profile.keyword")
          + elasticsearch.bucketAggs.Terms.withId("4")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("messageSize")
          + elasticsearch.bucketAggs.Terms.withId("5")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('1')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("tputMetric.keyword")
          + elasticsearch.bucketAggs.Terms.withId("6")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("metadata.platform.keyword")
          + elasticsearch.bucketAggs.Terms.withId("7")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("service")
          + elasticsearch.bucketAggs.Terms.withId("8")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
          elasticsearch.bucketAggs.Terms.withField("ltcyMetric.keyword")
          + elasticsearch.bucketAggs.Terms.withId("9")
          + elasticsearch.bucketAggs.Terms.withType('terms')
          + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
          + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
          + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
          + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
        ])
        + elasticsearch.withMetrics([
         elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("throughput")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
         + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
         elasticsearch.metrics.MetricAggregationWithSettings.Percentiles.withField("latency")
         + elasticsearch.metrics.MetricAggregationWithSettings.Percentiles.withId("10")
         + elasticsearch.metrics.MetricAggregationWithSettings.Percentiles.withType('percentiles')
         + elasticsearch.metrics.MetricAggregationWithSettings.Percentiles.withSettings({
                "percents": [
                  "95"
                ]
              }),
        ])
        + elasticsearch.withQuery('uuid: $uuid AND parallelism: $parallelism AND profile: $profile AND messageSize: $messageSize AND driver.keyword: $driver AND metadata.platform: $platform')
        + elasticsearch.withTimeField('timestamp')
  },
}