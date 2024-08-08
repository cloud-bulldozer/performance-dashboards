local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
    throughput_overtime: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("action.keyword")
                + elasticsearch.bucketAggs.Terms.withId("4")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("3")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("overall_rate")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user) AND (action.keyword=$operation)')
            + elasticsearch.withTimeField('timestamp')
    },

    phase_average_latency: {
        query():
            elasticsearch.withAlias("{{ocpMajorVersion.keyword}}")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("action.keyword")
                + elasticsearch.bucketAggs.Terms.withId("3")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("latency_90")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user) AND (action.keyword=$operation)')
            + elasticsearch.withTimeField('timestamp')
    },

    latency_95: {
        query():
            elasticsearch.withAlias("{{ocpMajorVersion.keyword}}")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("workload_type.keyword")
                + elasticsearch.bucketAggs.Terms.withId("5")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("3")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("data.$operation.95thPercentileLatency(us)")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user)')
            + elasticsearch.withTimeField('timestamp')
    },

    overall_workload_throughput: {
        query():
            elasticsearch.withAlias("{{ocpMajorVersion.keyword}}")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("workload_type.keyword")
                + elasticsearch.bucketAggs.Terms.withId("5")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("3")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("data.OVERALL.Throughput(ops/sec)")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum')
            ])
            + elasticsearch.withQuery('(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user)')
            + elasticsearch.withTimeField('timestamp')
    },

    aggregate_operation_sum: {
        query():
            elasticsearch.withAlias("$operation - Operations")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("workload_type.keyword")
                + elasticsearch.bucketAggs.Terms.withId("3")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("data.$operation.Operations")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum')
            ])
            + elasticsearch.withQuery('(uuid.keyword = $uuid) AND (phase.keyword = $phase) AND (user.keyword=$user)')
            + elasticsearch.withTimeField('timestamp')
    }
}