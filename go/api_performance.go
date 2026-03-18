package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

func buildAPIPerformanceDashboard() *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("API Performance Dashboard").
		Description("Dashboard for Api-performance-overview\n").
		Tags([]string{"Api-performance"}).
		Time("now-1h", "now").
		Timezone("utc").
		Refresh("30s").
		Readonly().
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").
			Type("prometheus").
			Regex("").
			Label("Datasource"),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("apiserver").
			Label("apiserver").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(apiserver_request_duration_seconds_bucket, apiserver)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("instance").
			Label("instance").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(apiserver_request_total, instance)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("resource").
			Label("resource").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(apiserver_request_duration_seconds_bucket, resource)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("code").
			Label("code").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(code)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("verb").
			Label("verb").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(verb)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("flow_schema").
			Label("flow-schema").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(flow_schema)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("priority_level").
			Label("priority-level").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(priority_level)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewIntervalVariableBuilder("interval").
			Label("interval").
			Values(dashboard.StringOrMap{String: cog.ToPtr("1m,5m")}).
			Auto(true).
			StepCount(30).
			MinInterval("10s").
			Current(intervalOption("1m")).
			Options([]dashboard.VariableOption{
				intervalOption("1m"),
				intervalOption("5m"),
			}),
		).
		WithPanel(apiLegendRight("request duration - 99th quantile", "s",
			dashboard.GridPos{X: 0, Y: 0, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",subresource!="log",verb=~"$verb",verb!~"WATCH|WATCHLIST|PROXY"}[$interval])) by(verb,le))`, "{{verb}}"),
		)).
		WithPanel(apiLegendRight("request rate - by instance", "short",
			dashboard.GridPos{X: 12, Y: 0, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",code=~"$code",verb=~"$verb"}[$interval])) by(instance)`, "{{instance}}"),
		)).
		WithPanel(apiLegendRight("request duration - 99th quantile - by resource", "s",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",subresource!="log",verb=~"$verb",verb!~"WATCH|WATCHLIST|PROXY"}[$interval])) by(resource,le))`, "{{resource}}"),
		)).
		WithPanel(apiLegendRight("request rate - by resource", "short",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",code=~"$code",verb=~"$verb"}[$interval])) by(resource)`, "{{resource}}"),
		)).
		WithPanel(apiLegendBottom("request duration - read vs write", "s",
			dashboard.GridPos{X: 0, Y: 16, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"LIST|GET"}[$interval])) by(le))`, "read"),
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[$interval])) by(le))`, "write"),
		)).
		WithPanel(apiLegendBottom("request rate - read vs write", "short",
			dashboard.GridPos{X: 12, Y: 16, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"LIST|GET"}[$interval]))`, "read"),
			promQuery(`sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[$interval]))`, "write"),
		)).
		WithPanel(apiLegendBottom("requests dropped rate", "short",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_request_terminations_total{instance=~"$instance"}[$interval])) by (verb)`, ""),
		)).
		WithPanel(apiLegendBottom("requests terminated rate", "short",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_request_terminations_total{instance=~"$instance",resource=~"$resource",code=~"$code"}[$interval])) by(component)`, ""),
		)).
		WithPanel(apiLegendRight("requests status rate", "short",
			dashboard.GridPos{X: 0, Y: 32, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"$verb",code=~"$code"}[$interval])) by(code)`, "{{code}}"),
		)).
		WithPanel(apiLegendRight("long running requests", "short",
			dashboard.GridPos{X: 12, Y: 32, W: 12, H: 8},
			promQuery(`sum(apiserver_longrunning_requests{instance=~"$instance",resource=~"$resource",verb=~"$verb"}) by(instance)`, "{{instance}}"),
		)).
		WithPanel(apiLegendRight("request in flight", "short",
			dashboard.GridPos{X: 0, Y: 40, W: 12, H: 8},
			promQuery(`sum(apiserver_current_inflight_requests{instance=~"$instance"}) by (instance,request_kind)`, "{{request_kind}}-{{instance}}"),
		)).
		WithPanel(apiLegendRight("response size - 99th quantile", "bytes",
			dashboard.GridPos{X: 12, Y: 40, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_response_sizes_bucket{instance=~"$instance",resource=~"$resource",verb=~"$verb"}[$interval])) by(instance,le))`, "{{instance}}"),
		)).
		WithPanel(apiLegendRight("p&f - request queue length", "short",
			dashboard.GridPos{X: 0, Y: 48, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_queue_length_after_enqueue_bucket{instance=~"$instance",flow_schema=~"$flow_schema",priority_level=~"$priority_level"}[$interval])) by(flow_schema, priority_level, le))`, "{{flow_schema}}:{{priority_level}}"),
		)).
		WithPanel(apiWaitDuration("p&f - request wait duration - 99th quantile", "s",
			dashboard.GridPos{X: 12, Y: 48, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_wait_duration_seconds_bucket{instance=~"$instance",flow_schema=~"$flow_schema",priority_level=~"$priority_level"}[5m])) by(flow_schema, priority_level, le))`, "{{flow_schema}}:{{priority_level}}"),
		)).
		WithPanel(apiLegendRight("p&f - request dispatch rate", "short",
			dashboard.GridPos{X: 0, Y: 64, W: 12, H: 8},
			promQuery(`sum(rate(apiserver_flowcontrol_dispatched_requests_total{instance=~"$instance",flow_schema=~"$flow_schema",priority_level=~"$priority_level"}[$interval])) by(flow_schema,priority_level)`, "{{flow_schema}}:{{priority_level}}"),
		)).
		WithPanel(apiLegendRight("p&f - request execution duration", "s",
			dashboard.GridPos{X: 12, Y: 64, W: 12, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_execution_seconds_bucket{instance=~"$instance",flow_schema=~"$flow_schema",priority_level=~"$priority_level"}[$interval])) by(flow_schema, priority_level, le))`, "{{flow_schema}}:{{priority_level}}"),
		)).
		WithPanel(apiLegendRight("p&f - pending in queue", "short",
			dashboard.GridPos{X: 0, Y: 72, W: 12, H: 8},
			promQuery(`sum(apiserver_flowcontrol_current_inqueue_requests{instance=~"$instance",flow_schema=~"$flow_schema",priority_level=~"$priority_level"}) by (flow_schema,priority_level)`, "{{flow_schema}}:{{priority_level}}"),
		)).
		WithPanel(apiLegendRight("p&f - concurrency limit by kube-apiserver", "short",
			dashboard.GridPos{X: 12, Y: 72, W: 12, H: 8},
			promQuery(`sum(apiserver_flowcontrol_request_concurrency_in_use{instance=~".*:6443",priority_level=~"$priority_level"}) by (instance,flow_schema)`, "{{instance}}:{{flow_schema}}"),
		))
}

func apiBase(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	p := timeseries.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		GridPos(gridPos).
		DrawStyle(common.GraphDrawStyleLine).
		LineInterpolation(common.LineInterpolationLinear).
		BarAlignment(common.BarAlignmentCenter).
		LineWidth(1).
		FillOpacity(10).
		GradientMode(common.GraphGradientModeNone).
		SpanNulls(boolPtr(false)).
		PointSize(5).
		ShowPoints(common.VisibilityModeNever).
		Stacking(common.NewStackingConfigBuilder().
			Group("A").
			Mode(common.StackingModeNone),
		).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			SortBy("Max").
			SortDesc(true),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

func apiLegendRight(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return apiBase(title, unit, gridPos, targets...).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeTable).
			Placement(common.LegendPlacementRight).
			Calcs([]string{"max"}).
			SortBy("Max").
			SortDesc(true),
		)
}

func apiLegendBottom(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return apiBase(title, unit, gridPos, targets...).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeList).
			Placement(common.LegendPlacementBottom).
			SortBy("Max").
			SortDesc(true),
		)
}

func apiWaitDuration(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return apiLegendRight(title, unit, gridPos, targets...).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeTable).
			Placement(common.LegendPlacementRight).
			Calcs([]string{"mean", "max", "lastNotNull"}).
			SortBy("Max").
			SortDesc(true),
		)
}
