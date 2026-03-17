package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/elasticsearch"
	"github.com/grafana/grafana-foundation-sdk/go/table"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

func buildUperfDashboard() *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("Public - UPerf Results dashboard").
		Tags([]string{"network", "performance"}).
		Time("now-1h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().
			RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"}),
		).
		Refresh("").
		Readonly().
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").
			Type("elasticsearch").
			Regex("/(.*uperf.*)/").
			Label("uperf-results datasource"),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("uuid").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "uuid.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("cluster_name").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "cluster_name.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("user").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "user.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("iteration").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "iteration"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("server").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "remote_ip.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("test_type").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "test_type.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("protocol").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "protocol.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("message_size").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "message_size"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("threads").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "num_threads"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithPanel(uperfTimeSeries(
			"UPerf Performance : Throughput per-second", "bps",
			dashboard.GridPos{X: 0, Y: 0, W: 12, H: 9},
			uperfThroughputQuery(),
		)).
		WithPanel(uperfTimeSeries(
			"UPerf Performance : Operations per-second", "pps",
			dashboard.GridPos{X: 12, Y: 0, W: 12, H: 9},
			uperfOperationsQuery(),
		)).
		WithPanel(uperfResultSummaryTable())
}

const uperfThroughputLuceneQuery = `uuid: $uuid AND cluster_name: $cluster_name AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND num_threads: $threads`
const uperfOperationsLuceneQuery = `uuid: $uuid AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND num_threads: $threads`
const uperfResultsLuceneQuery = `uuid: $uuid AND user: $user AND  iteration: $iteration AND remote_ip: $server AND message_size: $message_size AND test_type: $test_type AND protocol: $protocol AND NOT norm_ops:0`

func uperfThroughputQuery() *elasticsearch.DataqueryBuilder {
	return elasticsearch.NewDataqueryBuilder().
		Query(uperfThroughputLuceneQuery).
		TimeField("uperf_ts").
		BucketAggs([]elasticsearch.BucketAggregation{
			dateHistogramBucketAgg("uperf_ts", "2"),
		}).
		Metrics([]elasticsearch.MetricAggregation{
			sumMetricWithScript("norm_byte", "1", "_value * 8"),
		})
}

func uperfOperationsQuery() *elasticsearch.DataqueryBuilder {
	return elasticsearch.NewDataqueryBuilder().
		Query(uperfOperationsLuceneQuery).
		TimeField("uperf_ts").
		BucketAggs([]elasticsearch.BucketAggregation{
			dateHistogramBucketAgg("uperf_ts", "2"),
		}).
		Metrics([]elasticsearch.MetricAggregation{
			sumMetric("norm_ops", "1"),
		})
}

func uperfTimeSeries(title, unit string, gridPos dashboard.GridPos, target *elasticsearch.DataqueryBuilder) *timeseries.PanelBuilder {
	return timeseries.NewPanelBuilder().
		Title(title).
		Datasource(esDatasourceRef()).
		Unit(unit).
		GridPos(gridPos).
		Transparent(true).
		SpanNulls(common.BoolOrFloat64{Bool: cog.ToPtr(true)}).
		ShowPoints(common.VisibilityModeNever).
		LineWidth(1).
		FillOpacity(10).
		PointSize(5).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeTable).
			Placement(common.LegendPlacementBottom).
			Calcs([]string{"mean", "max"}),
		).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderNone),
		).
		WithTarget(target)
}

func uperfResultSummaryTable() *table.PanelBuilder {
	return table.NewPanelBuilder().
		Title("UPerf Result Summary").
		Datasource(esDatasourceRef()).
		GridPos(dashboard.GridPos{X: 0, Y: 20, W: 24, H: 18}).
		Transparent(true).
		ShowHeader(true).
		ColorScheme(dashboard.NewFieldColorBuilder().
			Mode(dashboard.FieldColorModeIdThresholds),
		).
		WithTarget(
			elasticsearch.NewDataqueryBuilder().
				Query(uperfResultsLuceneQuery).
				TimeField("uperf_ts").
				BucketAggs([]elasticsearch.BucketAggregation{
					termsBucketAgg("test_type.keyword", "3"),
					termsBucketAgg("protocol.keyword", "4"),
					termsBucketAgg("num_threads", "5"),
					termsBucketAgg("message_size", "2"),
				}).
				Metrics([]elasticsearch.MetricAggregation{
					avgMetricWithScript("norm_byte", "1", "_value * 8"),
					avgMetric("norm_ops", "6"),
					avgMetric("norm_ltcy", "7"),
					countMetric("8"),
				}),
		).
		WithTransformation(dashboard.DataTransformerConfig{
			Id: "seriesToColumns",
			Options: map[string]any{
				"reducers": []any{},
			},
		}).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "message_size"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: ""},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average norm_byte"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "bps"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average norm_ops"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "none"},
				{Id: "decimals", Value: "0"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average norm_ltcy"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "µs"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Count"},
			[]dashboard.DynamicConfigValue{
				{Id: "displayName", Value: "Sample count"},
				{Id: "unit", Value: "short"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		)
}
