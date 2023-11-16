local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local elasticsearch = g.query.elasticsearch;

{
    avgRPSAll: {
        query():
            elasticsearch.withAlias("{{ocpMajorVersion.keyword}}")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("ocpMajorVersion.keyword")
                + elasticsearch.bucketAggs.Terms.withId("8")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('asc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1') 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("9")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("total_avg_rps")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
                // + elasticsearch.metrics.ExtendedStats.withMeta()
            ])
            + elasticsearch.withQuery("uuid.keyword: $all_uuids AND config.termination.keyword: $termination AND ocpMajorVersion.keyword: $ocpMajorVersion")
            + elasticsearch.withTimeField('timestamp')


    },
    avgRPS: {
        query():
            elasticsearch.withAlias("{{ocpMajorVersion.keyword}}")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("ocpMajorVersion.keyword")
                + elasticsearch.bucketAggs.Terms.withId("8")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('asc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1') 
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("9")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("total_avg_rps")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination AND ocpMajorVersion.keyword: $ocpMajorVersion")
            + elasticsearch.withTimeField('timestamp')


    },

    avgTime: {
        query():
            elasticsearch.withAlias("{{ocpMajorVersion.keyword}}")
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("ocpMajorVersion.keyword")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('asc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1') ,
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("8")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount(0)
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),
            ])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("$latency_metric")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg')

            ])
            + elasticsearch.withQuery("uuid.keyword: $all_uuids AND config.termination.keyword: $termination AND ocpMajorVersion.keyword: $ocpMajorVersion")
            + elasticsearch.withTimeField('timestamp')

    },

    workloadSummary: {
        query():
            elasticsearch.withAlias("")
            + elasticsearch.withBucketAggs([])
            + elasticsearch.withHide(false)
            + elasticsearch.withMetrics([
               elasticsearch.metrics.MetricAggregationWithSettings.RawData.withId("1")
                + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType("raw_data")

            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid")
            + elasticsearch.withTimeField('timestamp')

    },

    trendRPS: {
        query():
            elasticsearch.withAlias("{{$compare_by}}")
            + elasticsearch.withHide(false)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("$compare_by")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
                + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("8")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges(0),

            ])
            + elasticsearch.withMetrics([
            elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("total_avg_rps")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
            // + elasticsearch.metrics.MetricAggregationWithSettings.Average.settings.withScript("_value * 100")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')



    },

    latencyTrend: {
        query():
            elasticsearch.withAlias("{{$compare_by}}")
            + elasticsearch.withHide(false)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("$compare_by")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
                + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("8")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("0")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),

            ])
            + elasticsearch.withMetrics([
            elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("$latency_metric")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')
    },

    terminationRPS: {
        query():
            elasticsearch.withAlias("")
            
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("$compare_by")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
                + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("8")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("0")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),

            ])
            + elasticsearch.withMetrics([
            elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("total_avg_rps")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')

    },

    latencyTermination: {
        query():
            elasticsearch.withAlias("")
            + elasticsearch.withHide(false)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("$compare_by")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
                + elasticsearch.bucketAggs.Terms.settings.withSize("0"),
                elasticsearch.bucketAggs.DateHistogram.withField("timestamp")
                + elasticsearch.bucketAggs.DateHistogram.withId("8")
                + elasticsearch.bucketAggs.DateHistogram.withType('date_histogram')
                + elasticsearch.bucketAggs.DateHistogram.settings.withInterval('auto')
                + elasticsearch.bucketAggs.DateHistogram.settings.withMinDocCount("1")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTimeZone("utc")
                + elasticsearch.bucketAggs.DateHistogram.settings.withTrimEdges("0"),

            ])
            + elasticsearch.withMetrics([
            elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("$latency_metric")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("1")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')

    },

    qualityRPS: {
        query():
            elasticsearch.withAlias("")
            + elasticsearch.withHide(false)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("$compare_by")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
            ])
            + elasticsearch.withMetrics([
            elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withField("total_avg_rps")
            + elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withMeta(
                {
                "std_deviation": true,
                "std_deviation_bounds_lower": false,
                "std_deviation_bounds_upper": false
                })
            + elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withId("1")
            + elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withType('extended_stats'),

            elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("total_avg_rps")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("8")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')

    },

    dataQuality: {
        query():
            elasticsearch.withAlias("")
            + elasticsearch.withHide(false)
            + elasticsearch.withBucketAggs([
                elasticsearch.bucketAggs.Terms.withField("$compare_by")
                + elasticsearch.bucketAggs.Terms.withId("7")
                + elasticsearch.bucketAggs.Terms.withType('terms')
                + elasticsearch.bucketAggs.Terms.settings.withOrder('desc')
                + elasticsearch.bucketAggs.Terms.settings.withOrderBy('_term')
                + elasticsearch.bucketAggs.Terms.settings.withMinDocCount('1')
                + elasticsearch.bucketAggs.Terms.settings.withSize("10"),
            ])
            + elasticsearch.withMetrics([
            elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withField("$latency_metric")
            + elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withMeta(
                {
                "std_deviation": true,
                "std_deviation_bounds_lower": false,
                "std_deviation_bounds_upper": false
                })
            + elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withId("1")
            + elasticsearch.metrics.MetricAggregationWithSettings.ExtendedStats.withType('extended_stats'),

            elasticsearch.metrics.MetricAggregationWithSettings.Average.withField("$latency_metric")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withId("8")
            + elasticsearch.metrics.MetricAggregationWithSettings.Average.withType('avg'),
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')



    },

    rawData: {
        query():
            elasticsearch.withAlias("")
            + elasticsearch.withBucketAggs([])
            + elasticsearch.withMetrics([
                elasticsearch.metrics.MetricAggregationWithSettings.RawData.withId("1")
                +elasticsearch.metrics.MetricAggregationWithSettings.RawData.settings.withSize("500")
                + elasticsearch.metrics.MetricAggregationWithSettings.RawData.withType('raw_data'),

                
            ])
            + elasticsearch.withQuery("uuid.keyword: $uuid AND config.termination.keyword: $termination")
            + elasticsearch.withTimeField('timestamp')
    }

    


}