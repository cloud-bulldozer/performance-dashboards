package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"github.com/grafana/grafana-foundation-sdk/go/stat"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

func buildOVNDashboard() *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("Openshift Networking").
		Time("now-1h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().
			RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"}),
		).
		Refresh("").
		Readonly().
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").
			Type("prometheus").
			Regex("").
			Label("Datasource"),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("_master_node").
			Label("Master").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(kube_node_role{role="master"}, node)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("_worker_node").
			Label("Worker").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(kube_node_role{role=~"work.*"}, node)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("controlplane_pod").
			Label("OVNKube-Controlplane").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values({pod=~"ovnkube-control-plane.*", namespace=~"openshift-ovn-kubernetes"}, pod)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("kubenode_pod").
			Label("OVNKube-Node").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values({pod=~"ovnkube-node.*", namespace=~"openshift-ovn-kubernetes"}, pod)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithRow(ovnResourceMonitoringRow()).
		WithRow(ovnPodStartupLatencyRow()).
		WithRow(ovnComponentResourceRow()).
		WithRow(ovnWorkQueueRow())
}

// timeseries: same base as etcd (line, lineWidth 1, fillOpacity 10, etc.) + calcs [mean, max], table, sortBy Max desc
func ovnTimeSeries(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
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
			Mode(common.StackingModeNone),
		).
		Tooltip(common.NewVizTooltipOptionsBuilder().
			Mode(common.TooltipDisplayModeMulti).
			Sort(common.SortOrderDescending),
		).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			Placement(common.LegendPlacementBottom).
			DisplayMode(common.LegendDisplayModeTable).
			Calcs([]string{"mean", "max"}).
			SortBy("Max").
			SortDesc(true),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

// stat base for OVN: graphMode area, justifyMode auto, colorMode value, titleSize 12, thresholds color mode
func ovnStatBase(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *stat.PanelBuilder {
	p := stat.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		GridPos(gridPos).
		JustifyMode(common.BigValueJustifyModeAuto).
		GraphMode(common.BigValueGraphModeArea).
		Text(common.NewVizTextDisplayOptionsBuilder().
			TitleSize(12),
		).
		ColorScheme(dashboard.NewFieldColorBuilder().
			Mode(dashboard.FieldColorModeIdThresholds),
		).
		ColorMode(common.BigValueColorModeValue).
		ReduceOptions(common.NewReduceDataOptionsBuilder().
			Calcs([]string{"last"}),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

func ovnStatThreshold(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *stat.PanelBuilder {
	return ovnStatBase(title, unit, gridPos, targets...).
		TextMode(common.BigValueTextModeName).
		Thresholds(dashboard.NewThresholdsConfigBuilder().
			Mode(dashboard.ThresholdsModeAbsolute).
			Steps([]dashboard.Threshold{
				{Value: nil, Color: "green"},
				{Value: cog.ToPtr(0.0), Color: "orange"},
				{Value: cog.ToPtr(1.0), Color: "green"},
			}),
		)
}

func ovnStatOVNController(title, unit string, gridPos dashboard.GridPos, targets ...*prometheus.DataqueryBuilder) *stat.PanelBuilder {
	return ovnStatBase(title, unit, gridPos, targets...).
		TextMode(common.BigValueTextModeAuto).
		Thresholds(dashboard.NewThresholdsConfigBuilder().
			Mode(dashboard.ThresholdsModeAbsolute).
			Steps([]dashboard.Threshold{
				{Value: nil, Color: "green"},
			}),
		)
}

// Row: OVN Resource Monitoring
func ovnResourceMonitoringRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("OVN Resource Monitoring").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(ovnStatThreshold("OVNKube Cluster Manager Leader", "none",
			dashboard.GridPos{X: 0, Y: 0, W: 8, H: 4},
			promQuery(`ovnkube_clustermanager_leader > 0`, "{{pod}}"),
		)).
		WithPanel(ovnStatThreshold("OVN Northd Status", "none",
			dashboard.GridPos{X: 8, Y: 0, W: 8, H: 4},
			promQuery(`ovn_northd_status`, "{{pod}}"),
		)).
		WithPanel(ovnStatOVNController("OVN Controller Count", "none",
			dashboard.GridPos{X: 16, Y: 0, W: 8, H: 4},
			promQuery(`count(ovn_controller_monitor_all) by (namespace)`, ""),
		)).
		WithPanel(ovnTimeSeries("OVNKube Control Plane CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 4, W: 12, H: 10},
			promQuery(`sum( irate(container_cpu_usage_seconds_total{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}[2m])*100 ) by (pod, node)`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Control Plane Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 4, W: 12, H: 10},
			promQuery(`container_memory_rss{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}`, "{{pod}} - {{node}}"),
		))
}

// Row: Pod Startup Latency Breakdown
func ovnPodStartupLatencyRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Pod Startup Latency Breakdown").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(ovnTimeSeries("Scheduler Pod Scheduling Duration (P99)", "s",
			dashboard.GridPos{X: 0, Y: 0, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, rate(scheduler_pod_scheduling_sli_duration_seconds_bucket[5m])) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Pod First Seen to LSP Created Latency (P99)", "s",
			dashboard.GridPos{X: 12, Y: 0, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_controller_pod_first_seen_lsp_created_duration_seconds_bucket[2m])) by (pod, le)) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Pod Annotation Latency (P99)", "s",
			dashboard.GridPos{X: 0, Y: 10, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum by (pod, le) (rate(ovnkube_controller_pod_creation_latency_seconds_bucket[2m]))) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Port Binding After LSP Creation Latency (P99)", "s",
			dashboard.GridPos{X: 12, Y: 10, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_controller_pod_lsp_created_port_binding_duration_seconds_bucket[2m])) by (pod,le)) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Port Binding to Chassis Assignment Latency (P99)", "s",
			dashboard.GridPos{X: 0, Y: 20, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_controller_pod_port_binding_port_binding_chassis_duration_seconds_bucket[2m])) by (pod, le)) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Port Marked As Up (P99)", "s",
			dashboard.GridPos{X: 12, Y: 20, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_controller_pod_port_binding_chassis_port_binding_up_duration_seconds_bucket[2m])) by (pod, le)) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("CNI Request ADD Latency (P99)", "s",
			dashboard.GridPos{X: 0, Y: 30, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="ADD"}[2m])) by (pod,le)) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Network Programming Complete (P99)", "s",
			dashboard.GridPos{X: 12, Y: 30, W: 12, H: 10},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_controller_network_programming_duration_seconds_bucket[2m])) by (pod, le)) > 0`, "{{pod}}"),
		)).
		WithPanel(ovnTimeSeries("Sync Service Latency", "s",
			dashboard.GridPos{X: 0, Y: 40, W: 12, H: 10},
			promQuery(`rate(ovnkube_controller_sync_service_latency_seconds_sum[2m])`, "{{pod}} - Sync service latency"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Node Ready Latency", "s",
			dashboard.GridPos{X: 12, Y: 40, W: 12, H: 10},
			promQuery(`ovnkube_node_ready_duration_seconds{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container!~"POD|"}`, "{{pod}}"),
		))
}

// Row: OVN Component Resource Usage
func ovnComponentResourceRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("OVN Component Resource Usage").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(ovnTimeSeries("OVNKube Node Pods CPU Usage (Top 10)", "percent",
			dashboard.GridPos{X: 0, Y: 0, W: 12, H: 10},
			promQuery(`topk(10, (sum(irate(container_cpu_usage_seconds_total{name!="",container!~"POD|",namespace=~"openshift-ovn-kubernetes", node=~"$_worker_node"}[2m]) * 100) by (pod, namespace, node)) > 0)`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Node Pods Memory Usage (Top 10)", "bytes",
			dashboard.GridPos{X: 12, Y: 0, W: 12, H: 10},
			promQuery(`topk(10, sum(container_memory_rss{name!="",container!~"POD|",namespace=~"openshift-ovn-kubernetes", node=~"$_worker_node"}) by (pod, namespace, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("Northd CPU Usage (Top 10)", "percent",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 10},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container="northd", namespace="openshift-ovn-kubernetes"}[2m])*100) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("Northd Memory Usage (Top 10)", "bytes",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 10},
			promQuery(`topk(10, sum(container_memory_rss{container="northd", namespace="openshift-ovn-kubernetes"}) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("Sbdb CPU Usage (Top 10)", "percent",
			dashboard.GridPos{X: 0, Y: 16, W: 12, H: 10},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container="sbdb", namespace="openshift-ovn-kubernetes"}[2m])*100) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("Sbdb Memory Usage (Top 10)", "bytes",
			dashboard.GridPos{X: 12, Y: 16, W: 12, H: 10},
			promQuery(`topk(10, sum(container_memory_rss{container="sbdb", namespace="openshift-ovn-kubernetes"}) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("Nbdb CPU Usage (Top 10)", "percent",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 10},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container="nbdb", namespace="openshift-ovn-kubernetes"}[2m])*100) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("Nbdb Memory Usage (Top 10)", "bytes",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 10},
			promQuery(`topk(10, sum(container_memory_rss{container="nbdb", namespace="openshift-ovn-kubernetes"}) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Controller CPU Usage (Top 10)", "percent",
			dashboard.GridPos{X: 0, Y: 32, W: 12, H: 10},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container="ovnkube-controller", namespace="openshift-ovn-kubernetes"}[2m])*100) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Controller Memory Usage (Top 10)", "bytes",
			dashboard.GridPos{X: 12, Y: 32, W: 12, H: 10},
			promQuery(`topk(10, sum(container_memory_rss{container="ovnkube-controller", namespace="openshift-ovn-kubernetes"}) by (pod, node))`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("OVN Controller CPU Usage (Top 10)", "percent",
			dashboard.GridPos{X: 0, Y: 40, W: 12, H: 10},
			promQuery(`topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}[2m])*100)  by (pod,node) )`, "{{pod}} - {{node}}"),
		)).
		WithPanel(ovnTimeSeries("OVN Controller Memory Usage (Top 10)", "bytes",
			dashboard.GridPos{X: 12, Y: 40, W: 12, H: 10},
			promQuery(`topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}) by (pod,node))`, "{{pod}} - {{node}}"),
		))
}

// Row: WorkQueue Monitoring
func ovnWorkQueueRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("WorkQueue Monitoring").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(ovnTimeSeries("OVNKube Controller workqueue", "short",
			dashboard.GridPos{X: 0, Y: 0, W: 12, H: 10},
			promQuery(`rate(ovnkube_controller_workqueue_adds_total[2m])`, "{{pod}} - Rate of handled adds"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Controller workqueue Depth", "short",
			dashboard.GridPos{X: 12, Y: 0, W: 12, H: 10},
			promQuery(`ovnkube_controller_workqueue_depth`, "{{pod}} - Depth of workqueue"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Controller workqueue duration", "s",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 10},
			promQuery(`ovnkube_controller_workqueue_longest_running_processor_seconds`, "{{pod}} - Longest processor duration"),
		)).
		WithPanel(ovnTimeSeries("OVNKube Controller workqueue - Unfinished", "s",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 10},
			promQuery(`ovnkube_controller_workqueue_unfinished_work_seconds`, "{{pod}} - Unfinished work duration"),
		))
}
