local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
    tps_report: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("tps")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum')
                + elasticsearch.metrics.MetricAggregationWithSettings.CumulativeSum.withPipelineAgg('select metric')
                + elasticsearch.metrics.MetricAggregationWithSettings.BucketScript.pipelineVariables.withName('var1')
                + elasticsearch.metrics.MetricAggregationWithSettings.BucketScript.pipelineVariables.withPipelineAgg('select metric')
            ])
            + elasticsearch.withQuery('(user = $user) AND (uuid = $uuid)')
            + elasticsearch.withTimeField('timestamp')
    },

    avg_tps: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                 elasticsearch.bucketAggs.Terms.withField("description.keyword")
                + elasticsearch.bucketAggs.Terms.withId("6")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('asc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("4")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0)
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("tps_incl_con_est")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
                + elasticsearch.metrics.MetricAggregationWithSettings.CumulativeSum.withPipelineAgg('select metric')
            ])
            + elasticsearch.withQuery('(uuid.keyword=$uuid) AND (user.keyword=$user)')
            + elasticsearch.withTimeField('timestamp'),
    },

    latency_report: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0)
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("latency_ms")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('(uuid.keyword=$uuid) AND (user.keyword=$user)')
            + elasticsearch.withTimeField('timestamp'),
    },

    results: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                 elasticsearch.bucketAggs.Terms.withField("user.keyword")
                + elasticsearch.bucketAggs.Terms.withId("1")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("latency_ms")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("4")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("tps")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("20")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')

            ])
            + elasticsearch.withQuery('(uuid.keyword=$uuid) AND (user.keyword=$user)')
            + elasticsearch.withTimeField('timestamp'),
    }
}