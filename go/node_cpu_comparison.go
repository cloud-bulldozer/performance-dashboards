package main

import (
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
)

const cpuComparisonNodeVar = "node"
const cpuComparisonCPUVar = "cpu"

var cpuModes = []string{
	"user",
	"system",
	"idle",
	"iowait",
	"irq",
	"softirq",
	"steal",
	"nice",
}

// cpuModeMax defines a shared fixed percentage scale for the lower-frequency
// CPU modes. User, system, and idle intentionally use Grafana's automatic scale.
var cpuModeMax = map[string]float64{
	"iowait":  100,
	"irq":     50,
	"softirq": 100,
	"steal":   100,
	"nice":    100,
}

func buildNodeCPUComparisonDashboard() *dashboard.DashboardBuilder {
	return buildNodeCPUComparison(&queryTracker{})
}

func buildNodeCPUComparisonProfiles() []namedProfile {
	agg := &mg.Generator{}
	buildNodeCPUComparison(&queryTracker{g: agg})
	raw := &mg.Generator{}
	buildNodeCPUComparison(&rawTracker{g: raw, seen: map[string]struct{}{}})
	return []namedProfile{{"-metrics", agg}, {"-raw-metrics", raw}}
}

func buildNodeCPUComparison(t panelTracker) *dashboard.DashboardBuilder {
	b := dashboard.NewDashboardBuilder("Node CPU Comparison").
		Description("Compare per-core CPU-mode behavior side-by-side for selected OpenShift nodes.\n").
		Tags([]string{}).
		Time("now-1h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"})).
		Refresh("30s").
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").Type("prometheus").Label("Datasource")).
		WithVariable(dashboard.NewQueryVariableBuilder(cpuComparisonNodeVar).
			Label("Nodes").
			Query(t.trackVarQuery("nodes", `label_values(`+string(mg.MetricKubeNodeInfo)+`, node)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false)).
		WithVariable(dashboard.NewQueryVariableBuilder(cpuComparisonCPUVar).
			Label("CPU IDs").
			Query(t.trackVarQuery("cpuIDs", `label_values(`+string(mg.MetricNodeCPU)+`, cpu)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(true)).
		WithVariable(dashboard.NewIntervalVariableBuilder("interval").
			Label("interval").
			Values(dashboard.StringOrMap{String: cog.ToPtr("2m,3m,4m,5m")}).
			Current(intervalOption("2m")).
			Options([]dashboard.VariableOption{intervalOption("2m"), intervalOption("3m"), intervalOption("4m"), intervalOption("5m")}))

	for _, mode := range cpuModes {
		b = b.WithRow(nodeCPUComparisonRow(t, mode))
	}
	return b
}

func nodeCPUComparisonRow(t panelTracker, mode string) *dashboard.RowBuilder {
	instanceFilter := `instance=~"$` + cpuComparisonNodeVar + `"`
	cpuFilter := `cpu=~"$` + cpuComparisonCPUVar + `"`
	panel := genericLegendTimeSeries("CPU "+mode+": $"+cpuComparisonNodeVar, "percent", 6, 8,
		t.track("nodeCPU"+mode,
			mg.Q(mg.MetricNodeCPU, instanceFilter+`,`+cpuFilter+`,mode="`+mode+`"`).
				IRate(intervalVar).
				Multiply("100"),
			"CPU {{cpu}}"),
	).
		Stacking(common.NewStackingConfigBuilder().Mode(common.StackingModeNormal))
	if max, clamped := cpuModeMax[mode]; clamped {
		panel = panel.Max(max)
	}
	return dashboard.NewRowBuilder("CPU mode: " + mode).
		Collapsed(true).
		WithPanel(panel.
			Repeat(cpuComparisonNodeVar).
			RepeatDirection(dashboard.PanelRepeatDirectionH).
			MaxPerRow(4))
}
