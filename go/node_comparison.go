package main

import (
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

const nodeComparisonVar = "node"

type nodeComparisonMetric struct {
	title string
	panel *timeseries.PanelBuilder
}

func buildNodeComparisonDashboard() *dashboard.DashboardBuilder {
	return buildNodeComparison(&queryTracker{})
}

func buildNodeComparisonProfiles() []namedProfile {
	agg := &mg.Generator{}
	buildNodeComparison(&queryTracker{g: agg})
	raw := &mg.Generator{}
	buildNodeComparison(&rawTracker{g: raw, seen: map[string]struct{}{}})
	return []namedProfile{{"-metrics", agg}, {"-raw-metrics", raw}}
}

func buildNodeComparison(t panelTracker) *dashboard.DashboardBuilder {
	b := dashboard.NewDashboardBuilder("Node Comparison").
		Description("Compare the same node metric side-by-side for selected OpenShift nodes.\n").
		Tags([]string{}).
		Time("now-1h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"})).
		Refresh("30s").
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").Type("prometheus").Label("Datasource")).
		WithVariable(dashboard.NewQueryVariableBuilder(nodeComparisonVar).
			Label("Nodes").
			Query(t.trackVarQuery("nodes", `label_values(`+string(mg.MetricKubeNodeInfo)+`, node)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false)).
		WithVariable(dashboard.NewQueryVariableBuilder("namespace").
			Label("Namespace").
			Query(t.trackVarQuery("namespaces", `label_values(`+q(mg.MetricKubePodInfo, mg.Filters(mg.NSNotRegex("cluster-density.*|node-density-.*")))+`,namespace)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex("").Multi(true).IncludeAll(true)).
		WithVariable(dashboard.NewQueryVariableBuilder("block_device").
			Label("Block device").Query(t.trackVarQuery("blockDevices", `label_values(node_disk_written_bytes_total, device)`)).
			Datasource(promDatasourceRef()).Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex(`/^(?:(?!dm|rb).)*$/`).Multi(true).IncludeAll(true)).
		WithVariable(dashboard.NewQueryVariableBuilder("net_device").
			Label("Network device").Query(t.trackVarQuery("netDevices", `label_values(node_network_receive_bytes_total, device)`)).
			Datasource(promDatasourceRef()).Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex(`/^((br|en|et).*)$/`).Multi(true).IncludeAll(true)).
		WithVariable(dashboard.NewIntervalVariableBuilder("interval").
			Label("interval").Values(dashboard.StringOrMap{String: cog.ToPtr("2m,3m,4m,5m")}).Current(intervalOption("2m")).
			Options([]dashboard.VariableOption{intervalOption("2m"), intervalOption("3m"), intervalOption("4m"), intervalOption("5m")}))

	for _, metric := range nodeComparisonMetrics(t, nodeComparisonVar) {
		b = b.WithRow(dashboard.NewRowBuilder(metric.title).
			Collapsed(true).
			WithPanel(metric.panel.Repeat(nodeComparisonVar).
				RepeatDirection(dashboard.PanelRepeatDirectionH).
				MaxPerRow(2)))
	}
	return b
}

func nodeComparisonMetrics(t panelTracker, nodeVar string) []nodeComparisonMetric {
	instanceFilter := `instance=~"$` + nodeVar + `"`
	nodeFilter := `node=~"$` + nodeVar + `"`
	name := func(metric string) string { return metric + ": $" + nodeVar }
	return []nodeComparisonMetric{
		{"CPU Basic", genericLegendTimeSeries(name("CPU Basic"), "percent", 12, 8,
			t.track("nodeCPU", mg.Q(mg.MetricNodeCPU, instanceFilter+`,job=~".*"`).IRate(intervalVar).Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByMode).Multiply("100"), "Busy {{mode}}"),
			promQuery(`node_cpu_seconds_sum_rate_2m_30s_instance_mode_node_panel{`+instanceFilter+`}`, "Busy {{mode}}"))},
		{"System Memory", genericLegendCounterTimeSeries(name("System Memory"), "bytes", 12, 8,
			t.track("nodeMemoryActive", mg.Q(mg.MetricNodeMemoryActive, instanceFilter), "Active"),
			t.track("nodeMemoryTotal", mg.Q(mg.MetricNodeMemoryTotal, instanceFilter), "Total"),
			t.trackRaw("nodeMemoryCachedBuffers", `node_memory_Cached_bytes{`+instanceFilter+`} + node_memory_Buffers_bytes{`+instanceFilter+`}`, "Cached + Buffers"),
			t.track("nodeMemoryAvailable", mg.Q(mg.MetricNodeMemoryAvailable, instanceFilter), "Available"),
			t.track("nodeMemoryUsed", mg.Q(mg.MetricNodeMemoryTotal, instanceFilter).Sub(mg.Q(mg.MetricNodeMemoryFree, instanceFilter).Paren()), "Used"))},
		{"Disk throughput", genericLegendTimeSeries(name("Disk throughput"), "Bps", 12, 8,
			t.track("nodeDiskRead", mg.Q(mg.MetricNodeDiskRead, `device=~"$block_device",`+instanceFilter).Rate(intervalVar), "{{ device }} - read"),
			t.track("nodeDiskWritten", mg.Q(mg.MetricNodeDiskWritten, `device=~"$block_device",`+instanceFilter).Rate(intervalVar), "{{ device }} - write"))},
		{"Disk IOPS", genericLegendTimeSeries(name("Disk IOPS"), "iops", 12, 8,
			t.track("nodeDiskReadsCompleted", mg.Q(mg.MetricNodeDiskReadsCompleted, `device=~"$block_device",`+instanceFilter).Rate(intervalVar), "{{ device }} - read"),
			t.track("nodeDiskWritesCompleted", mg.Q(mg.MetricNodeDiskWritesCompleted, `device=~"$block_device",`+instanceFilter).Rate(intervalVar), "{{ device }} - write"))},
		{"Network Utilization", genericLegendTimeSeries(name("Network Utilization"), "bps", 12, 8,
			t.track("nodeNetworkRx", mg.Q(mg.MetricNodeNetworkRx, instanceFilter+`,device=~"$net_device"`).Rate(intervalVar).Multiply("8"), "{{instance}} - {{device}} - RX"),
			t.track("nodeNetworkTx", mg.Q(mg.MetricNodeNetworkTx, instanceFilter+`,device=~"$net_device"`).Rate(intervalVar).Multiply("8"), "{{instance}} - {{device}} - TX"))},
		{"Network Packets", genericLegendTimeSeries(name("Network Packets"), "pps", 12, 8,
			t.track("nodeNetworkRxPackets", mg.Q(mg.MetricNodeNetworkRxPackets, instanceFilter+`,device=~"$net_device"`).Rate(intervalVar), "{{instance}} - {{device}} - RX"),
			t.track("nodeNetworkTxPackets", mg.Q(mg.MetricNodeNetworkTxPackets, instanceFilter+`,device=~"$net_device"`).Rate(intervalVar), "{{instance}} - {{device}} - TX"))},
		{"Network packets drop", genericLegendTimeSeries(name("Network packets drop"), "pps", 12, 8,
			t.track("nodeNetworkRxDrop", mg.Q(mg.MetricNodeNetworkRxDrop, instanceFilter).Rate(intervalVar).TopK(10), "rx-drop-{{ device }}"),
			t.track("nodeNetworkTxDrop", mg.Q(mg.MetricNodeNetworkTxDrop, instanceFilter).Rate(intervalVar).TopK(10), "tx-drop-{{ device }}"))},
		{"Conntrack stats", genericLegendCounterTimeSeries(name("Conntrack stats"), "", 12, 8,
			t.track("nodeConntrackEntries", mg.Q(mg.MetricNodeNFConntrackEntries, instanceFilter), "conntrack_entries"),
			t.track("nodeConntrackLimit", mg.Q(mg.MetricNodeNFConntrackEntriesLimit, instanceFilter), "conntrack_limit"))},
		{"Container CPU", genericLegendTimeSeries(name("Container CPU"), "percent", 12, 8,
			t.track("containerCPU", mg.Q(mg.MetricContainerCPU, `container!="POD",name!="",`+nodeFilter+`,namespace!="",namespace=~"$namespace"`).IRate(intervalVar).Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer, mg.GroupByNamespace, mg.GroupByName, "service").Multiply("100"), "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{`+nodeFilter+`,namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"))},
		{"Container RSS", genericLegendCounterTimeSeries(name("Container RSS"), "bytes", 12, 8,
			t.track("containerMemoryRSS", mg.Q(mg.MetricContainerMemoryRSS, `container!="POD",name!="",`+nodeFilter+`,namespace!="",namespace=~"$namespace"`), "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{`+nodeFilter+`,namespace=~"$namespace"})`, "{{pod}} - {{node}}"))},
		{"Cgroup CPU", genericLegendTimeSeries(name("Cgroup CPU"), "percent", 12, 8,
			t.track("cgroupCPU", mg.Q(mg.MetricContainerCPU, mg.Filters(cgroupIDFilter, nodeFilter)).Rate(intervalVar).Agg(mg.AggSum, mg.GroupByID).Multiply("100"), "{{ id }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{`+nodeFilter+`}`, "{{ id }}"))},
		{"Cgroup RSS", genericLegendCounterTimeSeries(name("Cgroup RSS"), "bytes", 12, 8,
			t.track("cgroupRSS", mg.Q(mg.MetricContainerMemoryRSS, mg.Filters(cgroupIDFilter, nodeFilter)).Agg(mg.AggSum, mg.GroupByID), "{{ id }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{`+nodeFilter+`}`, "{{ id }}"))},
		{"Pod fs rw rate", genericLegendTimeSeries(name("Pod fs rw rate"), "Bps", 12, 8,
			t.track("podFSWrites", mg.Q(mg.MetricContainerFSWrites, mg.Filters(fsDeviceFilter, nodeFilter, `pod!=""`)).Rate(intervalVar).Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByPod), "{{ pod }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_container_sum_rate_pod_node_device{`+nodeFilter+`}`, "{{ pod }}: {{ device }} - write"),
			t.track("podFSReads", mg.Q(mg.MetricContainerFSReads, mg.Filters(fsDeviceFilter, nodeFilter, `pod!=""`)).Rate(intervalVar).Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByPod), "{{ pod }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_container_sum_rate_pod_node_device{`+nodeFilter+`}`, "{{ pod }}: {{ device }} - read"))},
		{"Cgroup fs rw rate", genericLegendTimeSeries(name("Cgroup fs rw rate"), "Bps", 12, 8,
			t.track("cgroupFSWrites", mg.Q(mg.MetricContainerFSWrites, mg.Filters(cgroupFSIDFilter, nodeFilter)).Rate(intervalVar).Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByID), "{{ id }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_cgroup_sum_rate_id_node_device{`+nodeFilter+`}`, "{{ id }}: {{ device }} - write"),
			t.track("cgroupFSReads", mg.Q(mg.MetricContainerFSReads, mg.Filters(cgroupFSIDFilter, nodeFilter)).Rate(intervalVar).Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByID), "{{ id }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_cgroup_sum_rate_id_node_device{`+nodeFilter+`}`, "{{ id }}: {{ device }} - read"))},
	}
}
