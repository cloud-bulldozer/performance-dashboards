local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
    throughput: {
       query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("uperf_ts")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(null),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("norm_byte")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum')
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.settings.script.withInline('_value * 8')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND cluster_name: $cluster_name AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND num_threads: $threads')
            + elasticsearch.withTimeField('uperf_ts')
    },

    operations: {
        query():
            elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.DateHistogram.withField("uperf_ts")
                + elasticsearch.bucketAggs.DateHistogram.withId("2")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(null),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Sum.withField("norm_ops")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Sum.withType('sum')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND num_threads: $threads')
            + elasticsearch.withTimeField('uperf_ts')
    },

    results: {
        query():
        elasticsearch.withAlias(null)
            + elasticsearch.withBucketAggs([
                 elasticsearch.bucketAggs.Terms.withField("test_type.keyword")
                + elasticsearch.bucketAggs.Terms.withId("3")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                 elasticsearch.bucketAggs.Terms.withField("protocol.keyword")
                + elasticsearch.bucketAggs.Terms.withId("4")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.Terms.withField("num_threads")
                + elasticsearch.bucketAggs.Terms.withId("5")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.Terms.withField("message_size")
                + elasticsearch.bucketAggs.Terms.withId("2")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount(1) 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),

            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("norm_byte")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.settings.script.withInline('_value * 8'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("norm_ops")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("6")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.settings.script.withInline('_value * 8'),

                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("norm_ltcy")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("7")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),

                elasticsearch.metrics.MetricAggregationWithSettings.UniqueCount.withType('count')
                + elasticsearch.metrics.MetricAggregationWithSettings.UniqueCount.withId('8')
                + elasticsearch.metrics.MetricAggregationWithSettings.UniqueCount.withField('select field')
            ])
            + elasticsearch.withQuery('uuid: $uuid AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND NOT norm_ops:0')
            + elasticsearch.withTimeField('uperf_ts')
        }
}