local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
    rps: {
       query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(null),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("rps")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND hostname: $hostname AND iteration: $iteration AND targets: "$targets"')
            + elasticsearch.withTimeField('timestamp')
    },

    throughput: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(null),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("throughput")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND hostname: $hostname AND iteration: $iteration AND targets: "$targets"')
            + elasticsearch.withTimeField('timestamp')
    },

    latency: {
        query():
        [
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(null),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("req_latency")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND hostname: $hostname AND iteration: $iteration AND targets: "$targets"')
            + elasticsearch.withTimeField('timestamp'),

            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(null),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("p99_latency")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND hostname: $hostname AND iteration: $iteration AND targets: "$targets"')
            + elasticsearch.withTimeField('timestamp')

        ]
    },

    results: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                 elasticsearch.bucketAggs.Terms.withField("uuid.keyword")
                + elasticsearch.bucketAggs.Terms.withId("2")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                 elasticsearch.bucketAggs.Terms.withField("targets.keyword")
                + elasticsearch.bucketAggs.Terms.withId("1")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10")
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("rps")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("3")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("throughput")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("4")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("p99_latency")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("5")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("req_latency")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("6")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("bytes_in")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("7")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("bytes_out")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("8")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND hostname: $hostname AND iteration: $iteration AND targets: "$targets"')
            + elasticsearch.withTimeField('timestamp')
    }
}