package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/elasticsearch"
)

func boolPtr(v bool) common.BoolOrFloat64 {
	return common.BoolOrFloat64{Bool: cog.ToPtr(v)}
}

func esDatasourceRef() common.DataSourceRef {
	return common.DataSourceRef{
		Type: cog.ToPtr("elasticsearch"),
		Uid:  cog.ToPtr("${Datasource}"),
	}
}

func dateHistogramBucketAgg(timeField, id string) elasticsearch.BucketAggregation {
	dh, _ := elasticsearch.NewDateHistogramBuilder().
		Field(timeField).
		Id(id).
		Settings(elasticsearch.NewElasticsearchDateHistogramSettingsBuilder().
			Interval("auto").
			MinDocCount("0").
			TimeZone("utc"),
		).
		Build()
	return elasticsearch.BucketAggregation{DateHistogram: &dh}
}

func termsBucketAgg(field, id string) elasticsearch.BucketAggregation {
	t, _ := elasticsearch.NewTermsBuilder().
		Field(field).
		Id(id).
		Settings(elasticsearch.NewElasticsearchTermsSettingsBuilder().
			Order(elasticsearch.TermsOrderDesc).
			OrderBy("_term").
			MinDocCount("1").
			Size("10"),
		).
		Build()
	return elasticsearch.BucketAggregation{Terms: &t}
}

func avgMetric(field, id string) elasticsearch.MetricAggregation {
	avg, _ := elasticsearch.NewAverageBuilder().
		Field(field).
		Id(id).
		Build()
	return elasticsearch.MetricAggregation{Average: &avg}
}

func avgMetricWithScript(field, id, script string) elasticsearch.MetricAggregation {
	avg, _ := elasticsearch.NewAverageBuilder().
		Field(field).
		Id(id).
		Settings(elasticsearch.NewElasticsearchAverageSettingsBuilder().
			Script(elasticsearch.InlineScript{
				ElasticsearchInlineScript: &elasticsearch.ElasticsearchInlineScript{
					Inline: cog.ToPtr(script),
				},
			}),
		).
		Build()
	return elasticsearch.MetricAggregation{Average: &avg}
}

func sumMetric(field, id string) elasticsearch.MetricAggregation {
	s, _ := elasticsearch.NewSumBuilder().
		Field(field).
		Id(id).
		Build()
	return elasticsearch.MetricAggregation{Sum: &s}
}

func sumMetricWithScript(field, id, script string) elasticsearch.MetricAggregation {
	s, _ := elasticsearch.NewSumBuilder().
		Field(field).
		Id(id).
		Settings(elasticsearch.NewElasticsearchSumSettingsBuilder().
			Script(elasticsearch.InlineScript{
				ElasticsearchInlineScript: &elasticsearch.ElasticsearchInlineScript{
					Inline: cog.ToPtr(script),
				},
			}),
		).
		Build()
	return elasticsearch.MetricAggregation{Sum: &s}
}

func countMetric(id string) elasticsearch.MetricAggregation {
	c, _ := elasticsearch.NewCountBuilder().
		Id(id).
		Build()
	return elasticsearch.MetricAggregation{Count: &c}
}
