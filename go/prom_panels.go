package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"github.com/grafana/grafana-foundation-sdk/go/stat"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

func promDatasourceRef() common.DataSourceRef {
	return common.DataSourceRef{
		Type: cog.ToPtr("prometheus"),
		Uid:  cog.ToPtr("${Datasource}"),
	}
}

func promQuery(expr, legend string) *prometheus.DataqueryBuilder {
	return prometheus.NewDataqueryBuilder().
		Expr(expr).
		LegendFormat(legend).
		Format(prometheus.PromQueryFormatTimeSeries).
		IntervalFactor(2)
}

func intervalOption(val string) dashboard.VariableOption {
	return dashboard.VariableOption{
		Text:  dashboard.StringOrArrayOfString{String: &val},
		Value: dashboard.StringOrArrayOfString{String: &val},
	}
}

// Panel type: generic - base timeseries with tooltip multi/desc, legend table mode
func genericTimeSeries(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	p := timeseries.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		Span(span).Height(height).
		SpanNulls(boolPtr(false)).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeTable),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

// Panel type: genericLegend - extends generic with calcs [mean, min, max], sortBy Max desc, placement bottom
func genericLegendTimeSeries(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	p := timeseries.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		Span(span).Height(height).
		SpanNulls(boolPtr(false)).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeTable).
			Calcs([]string{"mean", "min", "max"}).
			SortBy("Max").
			SortDesc(true).
			Placement(common.LegendPlacementBottom),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

// Panel type: genericLegendCounter - extends generic with calcs [first, min, max, last], sortBy Max desc, placement bottom
func genericLegendCounterTimeSeries(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	p := timeseries.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		Span(span).Height(height).
		SpanNulls(boolPtr(false)).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			DisplayMode(common.LegendDisplayModeTable).
			Calcs([]string{"first", "min", "max", "last"}).
			SortBy("Max").
			SortDesc(true).
			Placement(common.LegendPlacementBottom),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

// Panel type: genericLegendCounterSumRightHand - extends genericLegendCounter with override for 'sum' series on right axis
func genericLegendCounterSumRightHandTimeSeries(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	p := genericLegendCounterTimeSeries(title, unit, span, height, targets...)
	return p.OverrideByRegexp("sum", []dashboard.DynamicConfigValue{
		{Id: "custom.axisPlacement", Value: "right"},
		{Id: "custom.axisLabel", Value: "sum"},
	})
}

// Stat panel
func genericStat(title string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *stat.PanelBuilder {
	p := stat.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Span(span).Height(height).
		ReduceOptions(common.NewReduceDataOptionsBuilder().
			Calcs([]string{"last"}),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}
