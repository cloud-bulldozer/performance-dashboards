package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/elasticsearch"
	"github.com/grafana/grafana-foundation-sdk/go/table"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

func buildVegetaDashboard() *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("Vegeta Results").
		Description("Dashboard for Ingress Performance\n").
		Tags([]string{""}).
		Time("now-24h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().
			RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"}),
		).
		Refresh("").
		Readonly().
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").
			Type("elasticsearch").
			Regex("/(.*vegeta.*)/").
			Label("vegeta-results datasource"),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("uuid").
			Label("UUID").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "uuid.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("hostname").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "hostname.keyword"}`)}).
			Datasource(esDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("targets").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`{"find": "terms", "field": "targets.keyword"}`)}).
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
		WithPanel(vegetaTimeSeries(
			"RPS (rate of sent requests per second)", "reqps",
			dashboard.GridPos{X: 0, Y: 0, W: 12, H: 9},
			vegetaESAvgQuery("rps", "1"),
		)).
		WithPanel(vegetaTimeSeries(
			"Throughput (rate of successful requests per second)", "reqps",
			dashboard.GridPos{X: 12, Y: 0, W: 12, H: 9},
			vegetaESAvgQuery("throughput", "1"),
		)).
		WithPanel(vegetaTimeSeries(
			"Request Latency (observed over given interval)", "µs",
			dashboard.GridPos{X: 0, Y: 12, W: 12, H: 9},
			vegetaESAvgQuery("req_latency", "1"),
			vegetaESAvgQuery("p99_latency", "1"),
		)).
		WithPanel(vegetaResultSummaryTable())
}

const vegetaLuceneQuery = `uuid: $uuid AND hostname: $hostname AND iteration: $iteration AND targets: "$targets"`

func vegetaESAvgQuery(field, metricID string) *elasticsearch.DataqueryBuilder {
	return elasticsearch.NewDataqueryBuilder().
		Query(vegetaLuceneQuery).
		TimeField("timestamp").
		BucketAggs([]elasticsearch.BucketAggregation{
			dateHistogramBucketAgg("timestamp", "2"),
		}).
		Metrics([]elasticsearch.MetricAggregation{
			avgMetric(field, metricID),
		})
}

func vegetaTimeSeries(title, unit string, gridPos dashboard.GridPos, targets ...*elasticsearch.DataqueryBuilder) *timeseries.PanelBuilder {
	p := timeseries.NewPanelBuilder().
		Title(title).
		Datasource(esDatasourceRef()).
		Unit(unit).
		GridPos(gridPos).
		Transparent(true).
		SpanNulls(boolPtr(true)).
		ShowPoints(common.VisibilityModeNever).
		LineWidth(1).
		FillOpacity(20).
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
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

func vegetaResultSummaryTable() *table.PanelBuilder {
	return table.NewPanelBuilder().
		Title("Vegeta Result Summary").
		Datasource(esDatasourceRef()).
		GridPos(dashboard.GridPos{X: 0, Y: 24, W: 24, H: 9}).
		Transparent(true).
		ShowHeader(true).
		ColorScheme(dashboard.NewFieldColorBuilder().
			Mode(dashboard.FieldColorModeIdThresholds),
		).
		WithTarget(
			elasticsearch.NewDataqueryBuilder().
				Query(vegetaLuceneQuery).
				TimeField("timestamp").
				BucketAggs([]elasticsearch.BucketAggregation{
					termsBucketAgg("uuid.keyword", "2"),
					termsBucketAgg("targets.keyword", "1"),
				}).
				Metrics([]elasticsearch.MetricAggregation{
					avgMetric("rps", "3"),
					avgMetric("throughput", "4"),
					avgMetric("p99_latency", "5"),
					avgMetric("req_latency", "6"),
					avgMetric("bytes_in", "7"),
					avgMetric("bytes_out", "8"),
				}),
		).
		WithTransformation(dashboard.DataTransformerConfig{
			Id: "seriesToColumns",
			Options: map[string]any{
				"reducers": []any{},
			},
		}).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average rps"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "reqps"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average throughput"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "reqps"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average p99_latency"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "µs"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average req_latency"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "µs"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average bytes_in"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "bps"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		).
		WithOverride(
			dashboard.MatcherConfig{Id: "byName", Options: "Average bytes_out"},
			[]dashboard.DynamicConfigValue{
				{Id: "unit", Value: "bps"},
				{Id: "decimals", Value: "2"},
				{Id: "custom.align", Value: nil},
			},
		)
}
