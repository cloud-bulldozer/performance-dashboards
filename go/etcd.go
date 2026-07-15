package main

import (
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/common"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"github.com/grafana/grafana-foundation-sdk/go/stat"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

func buildEtcdDashboard() *dashboard.DashboardBuilder {
	return buildEtcdDash(&queryTracker{})
}

func buildEtcdProfiles() []namedProfile {
	agg := &mg.Generator{}
	buildEtcdDash(&queryTracker{g: agg})

	raw := &mg.Generator{}
	buildEtcdDash(&rawTracker{g: raw, seen: map[string]struct{}{}})

	return []namedProfile{
		{"-metrics", agg},
		{"-raw-metrics", raw},
	}
}

func buildEtcdDash(t panelTracker) *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("etcd-cluster-info dashboard").
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
		WithVariable(dashboard.NewQueryVariableBuilder("etcd_pod").
			Query(t.trackVarQuery(`label_values(etcd_cluster_version, pod)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(true),
		).
		WithRow(etcdGeneralResourceUsageRow(t)).
		WithRow(etcdCompactDefragRow(t)).
		WithRow(etcdWALFsyncRow(t)).
		WithRow(etcdBackendCommitRow(t)).
		WithRow(etcdNetworkUsageRow(t)).
		WithRow(etcdDBInfoRow(t)).
		WithRow(etcdGeneralInfoRow(t))
}

// base timeseries for etcd panels
func etcdBase(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	p := timeseries.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		Span(span).Height(height).
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
			Placement(common.LegendPlacementBottom),
		)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

func etcdGeneralUsageAgg(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return etcdBase(title, unit, span, height, targets...).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			Placement(common.LegendPlacementBottom).
			DisplayMode(common.LegendDisplayModeTable).
			Calcs([]string{"mean", "max"}).
			SortBy("Max").
			SortDesc(true),
		)
}

func etcdGeneralCounter(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return etcdBase(title, unit, span, height, targets...).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			Placement(common.LegendPlacementBottom).
			Calcs([]string{"first", "min", "max", "last"}),
		)
}

func etcdHistogramStatsRightHand(title, unit string, span, height uint32, leftAxis string, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return etcdGeneralCounter(title, unit, span, height, targets...).
		AxisLabel(leftAxis).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			Placement(common.LegendPlacementBottom).
			DisplayMode(common.LegendDisplayModeTable).
			Calcs([]string{"first", "min", "max", "last"}).
			SortBy("Max"),
		).
		OverrideByRegexp(".*rate.*", []dashboard.DynamicConfigValue{
			{Id: "custom.axisPlacement", Value: "right"},
			{Id: "custom.axisLabel", Value: "rate"},
			{Id: "unit", Value: "none"},
		})
}

func etcdWithoutCalcsAgg(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return etcdBase(title, unit, span, height, targets...).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			Placement(common.LegendPlacementBottom).
			DisplayMode(common.LegendDisplayModeTable).
			Calcs([]string{}),
		)
}

func etcdGeneralInfo(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *timeseries.PanelBuilder {
	return etcdBase(title, unit, span, height, targets...).
		Legend(common.NewVizLegendOptionsBuilder().
			ShowLegend(true).
			Placement(common.LegendPlacementBottom).
			DisplayMode(common.LegendDisplayModeList).
			Calcs([]string{}),
		)
}

func etcdStatBase(title, unit string, span, height uint32, targets ...*prometheus.DataqueryBuilder) *stat.PanelBuilder {
	p := stat.NewPanelBuilder().
		Title(title).
		Datasource(promDatasourceRef()).
		Unit(unit).
		Span(span).Height(height).
		JustifyMode(common.BigValueJustifyModeAuto).
		GraphMode(common.BigValueGraphModeNone).
		Text(common.NewVizTextDisplayOptionsBuilder().
			TitleSize(12),
		).
		ColorScheme(dashboard.NewFieldColorBuilder().
			Mode(dashboard.FieldColorModeIdThresholds),
		).
		ColorMode(common.BigValueColorModeNone)
	for _, t := range targets {
		p = p.WithTarget(t)
	}
	return p
}

// Row: General Resource Usage
func etcdGeneralResourceUsageRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("General Resource Usage").
		Collapsed(true).
		WithPanel(etcdGeneralUsageAgg("CPU usage", "percent",
			12, 8,
			t.trackRaw("etcdContainerCPU", `sum(irate(container_cpu_usage_seconds_total{namespace="openshift-etcd", container="etcd",pod=~"$etcd_pod"}[2m])) by (pod) * 100`, "{{ pod }}"),
		)).
		WithPanel(etcdGeneralUsageAgg("Memory usage", "bytes",
			12, 8,
			t.trackRaw("etcdContainerMemory", `sum(avg_over_time(container_memory_working_set_bytes{container="",pod!="", namespace=~"openshift-etcd.*",pod=~"$etcd_pod"}[2m])) by (pod, namespace)`, "{{ pod }}"),
		)).
		WithPanel(etcdGeneralUsageAgg("Disk WAL Sync Duration", "s",
			12, 8,
			t.trackRaw("etcdDiskWALFsyncP99", `histogram_quantile(0.99, sum(rate(etcd_disk_wal_fsync_duration_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[5m])) by (pod, le))`, "{{pod}} WAL fsync"),
		)).
		WithPanel(etcdGeneralUsageAgg("Disk Backend Sync Duration", "s",
			12, 8,
			t.trackRaw("etcdDiskBackendCommitP99", `histogram_quantile(0.99, sum(rate(etcd_disk_backend_commit_duration_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[5m])) by (pod, le))`, "{{pod}} DB fsync"),
		)).
		WithPanel(etcdGeneralUsageAgg("Etcd container disk writes", "Bps",
			12, 8,
			t.trackRaw("etcdContainerFSWrites", `rate(container_fs_writes_bytes_total{namespace="openshift-etcd",device!~".+dm.+"}[2m])`, "{{ pod }}: {{ device }}"),
		)).
		WithPanel(etcdGeneralUsageAgg("DB Size", "bytes",
			12, 8,
			t.trackRaw("etcdMvccDBTotalSize", `etcd_mvcc_db_total_size_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{pod}} DB physical size"),
			t.trackRaw("etcdMvccDBTotalSizeInUse", `etcd_mvcc_db_total_size_in_use_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{pod}} DB logical size"),
		))
}

// Row: Compact/Defrag Detailed
func etcdCompactDefragRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Compact/Defrag Detailed").
		Collapsed(true).
		WithPanel(etcdHistogramStatsRightHand("Compaction Duration sum", "none",
			8, 8, "sum",
			t.trackRaw("etcdCompactionDurationRate", `delta(etcd_debugging_mvcc_db_compaction_total_duration_milliseconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[1m:30s])/2`, "rate compact sum {{instance}} "),
			t.trackRaw("etcdCompactionDurationSum", `etcd_debugging_mvcc_db_compaction_total_duration_milliseconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "compact sum {{instance}} "),
		)).
		WithPanel(etcdHistogramStatsRightHand("Defrag Duration sum", "none",
			8, 8, "count",
			t.trackRaw("etcdDefragDurationRate", `delta(etcd_disk_backend_defrag_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[1m:30s])/2`, "rate defrag sum {{instance}} "),
			t.trackRaw("etcdDefragDurationSum", `etcd_disk_backend_defrag_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "defrag sum {{instance}} "),
		)).
		WithPanel(etcdHistogramStatsRightHand("vmstat major page faults", "none",
			8, 8, "count",
			t.trackRaw("nodeVmstatPgMajFaultRate", `rate(node_vmstat_pgmajfault[2m])* on (instance) group_left label_replace(kube_node_role{role="control-plane"},"instance","$1","node","(.*)")`, "rate pgmajfault {{instance}} "),
			t.trackRaw("nodeVmstatPgMajFault", `node_vmstat_pgmajfault * on (instance) group_left label_replace(kube_node_role{role="control-plane"},"instance","$1","node","(.*)")`, "pgmajfault {{instance}} "),
		))
}

// Row: WAL fsync Duration Detailed
func etcdWALFsyncRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("WAL fsync Duration Detailed").
		Collapsed(true).
		WithPanel(etcdGeneralUsageAgg("WAL fsync Duration p99", "s",
			8, 8,
			t.trackRaw("etcdDiskWALFsyncP99", `histogram_quantile(0.99, sum(rate(etcd_disk_wal_fsync_duration_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[5m])) by (pod, le))`, "{{pod}} WAL fsync"),
		)).
		WithPanel(etcdHistogramStatsRightHand("WAL fsync Duration sum", "none",
			8, 8, "sum",
			t.trackRaw("etcdDiskWALFsyncSumRate", `irate(etcd_disk_wal_fsync_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "2m irate WAL sum {{instance}} "),
			t.trackRaw("etcdDiskWALFsyncSum", `etcd_disk_wal_fsync_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "WAL sum {{instance}} "),
		)).
		WithPanel(etcdHistogramStatsRightHand("WAL fsync Duration count", "none",
			8, 8, "count",
			t.trackRaw("etcdDiskWALFsyncCountRate", `irate(etcd_disk_wal_fsync_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "2m irate WAL count {{instance}} "),
			t.trackRaw("etcdDiskWALFsyncCount", `etcd_disk_wal_fsync_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "WAL count {{instance}} "),
		))
}

// Row: Backend Commit Duration Detailed
func etcdBackendCommitRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Backend Commit Duration Detailed").
		Collapsed(true).
		WithPanel(etcdGeneralUsageAgg("Backend Commit Duration", "s",
			8, 8,
			t.trackRaw("etcdDiskBackendCommitP99", `histogram_quantile(0.99, sum(rate(etcd_disk_backend_commit_duration_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[5m])) by (pod, le))`, "{{pod}} DB fsync"),
		)).
		WithPanel(etcdHistogramStatsRightHand("Backend Commit Duration sum", "none",
			8, 8, "sum",
			t.trackRaw("etcdDiskBackendCommitSumRate", `irate(etcd_disk_backend_commit_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "2m irate WAL sum {{instance}} "),
			t.trackRaw("etcdDiskBackendCommitSum", `etcd_disk_backend_commit_duration_seconds_sum{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "WAL sum {{instance}} "),
		)).
		WithPanel(etcdHistogramStatsRightHand("Backend Commit Duration count", "none",
			8, 8, "count",
			t.trackRaw("etcdDiskBackendCommitCountRate", `irate(etcd_disk_backend_commit_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "2m irate WAL count {{instance}} "),
			t.trackRaw("etcdDiskBackendCommitCount", `etcd_disk_backend_commit_duration_seconds_count{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "WAL count {{instance}} "),
		))
}

// Row: Network Usage
func etcdNetworkUsageRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Network Usage").
		Collapsed(true).
		WithPanel(etcdGeneralUsageAgg("Container network traffic", "Bps",
			12, 8,
			t.trackRaw("etcdContainerNetworkRx", `sum(rate(container_network_receive_bytes_total{namespace=~"openshift-etcd.*"}[2m])) by (namespace, pod)`, "rx {{ pod }}"),
			t.trackRaw("etcdContainerNetworkTx", `sum(rate(container_network_transmit_bytes_total{namespace=~"openshift-etcd.*"}[2m])) by (namespace, pod)`, "tx {{ pod }}"),
		)).
		WithPanel(etcdGeneralUsageAgg("p99 peer to peer latency", "s",
			12, 8,
			t.trackRaw("etcdNetworkPeerRTTP99", `histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m]))`, "{{pod}}"),
		)).
		WithPanel(etcdGeneralUsageAgg("Peer network traffic", "Bps",
			12, 8,
			t.trackRaw("etcdNetworkPeerRx", `rate(etcd_network_peer_received_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "rx {{pod}} Peer Traffic"),
			t.trackRaw("etcdNetworkPeerTx", `rate(etcd_network_peer_sent_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "tx {{pod}} Peer Traffic"),
		)).
		WithPanel(etcdGeneralUsageAgg("gRPC network traffic", "Bps",
			12, 8,
			t.trackRaw("etcdNetworkGRPCRx", `rate(etcd_network_client_grpc_received_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "rx {{pod}}"),
			t.trackRaw("etcdNetworkGRPCTx", `rate(etcd_network_client_grpc_sent_bytes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "tx {{pod}}"),
		)).
		WithPanel(etcdWithoutCalcsAgg("Active Streams", "",
			12, 8,
			t.trackRaw("etcdActiveWatchStreams", `sum(grpc_server_started_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Watch",grpc_type="bidi_stream"})`, "Watch Streams"),
			t.trackRaw("etcdActiveLeaseStreams", `sum(grpc_server_started_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"}) - sum(grpc_server_handled_total{namespace="openshift-etcd",grpc_service="etcdserverpb.Lease",grpc_type="bidi_stream"})`, "Lease Streams"),
		)).
		WithPanel(etcdWithoutCalcsAgg("Snapshot duration", "s",
			12, 8,
			t.trackRaw("etcdSnapSaveDuration", `sum(rate(etcd_debugging_snap_save_total_duration_seconds_sum{namespace="openshift-etcd"}[2m]))`, "the total latency distributions of save called by snapshot"),
		))
}

// Row: DB Info per Member
func etcdDBInfoRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("DB Info per Member").
		Collapsed(true).
		WithPanel(etcdWithoutCalcsAgg("% DB Space Used", "percent",
			8, 8,
			t.trackRaw("etcdDBSpaceUsedPct", `(etcd_mvcc_db_total_size_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"} / etcd_server_quota_backend_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"})*100`, "{{pod}}"),
		)).
		WithPanel(etcdWithoutCalcsAgg("DB Left capacity (with fragmented space)", "bytes",
			8, 8,
			t.trackRaw("etcdDBLeftCapacity", `etcd_server_quota_backend_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"} - etcd_mvcc_db_total_size_in_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{pod}}"),
		)).
		WithPanel(etcdWithoutCalcsAgg("DB Size Limit (Backend-bytes)", "bytes",
			8, 8,
			t.trackRaw("etcdServerQuotaBackendBytes", `etcd_server_quota_backend_bytes{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{ pod }} Quota Bytes"),
		))
}

// Row: General Info
func etcdGeneralInfoRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("General Info").
		Collapsed(true).
		WithPanel(etcdGeneralInfo("Raft Proposals", "",
			12, 8,
			t.trackRaw("etcdServerProposalsFailed", `sum(rate(etcd_server_proposals_failed_total{namespace="openshift-etcd"}[2m]))`, "Proposal Failure Rate"),
			t.trackRaw("etcdServerProposalsPending", `sum(etcd_server_proposals_pending{namespace="openshift-etcd"})`, "Proposal Pending Total"),
			t.trackRaw("etcdServerProposalsCommitted", `sum(rate(etcd_server_proposals_committed_total{namespace="openshift-etcd"}[2m]))`, "Proposal Commit Rate"),
			t.trackRaw("etcdServerProposalsApplied", `sum(rate(etcd_server_proposals_applied_total{namespace="openshift-etcd"}[2m]))`, "Proposal Apply Rate"),
		)).
		WithPanel(etcdGeneralInfo("Number of leader changes seen", "",
			12, 8,
			t.trackRaw("etcdServerLeaderChanges", `sum(rate(etcd_server_leader_changes_seen_total{namespace="openshift-etcd"}[2m]))`, ""),
		)).
		WithPanel(
			etcdStatBase("Etcd has a leader?", "none",
				6, 2,
				t.trackRaw("etcdServerHasLeader", `max(etcd_server_has_leader{namespace="openshift-etcd"})`, ""),
			).
				ReduceOptions(common.NewReduceDataOptionsBuilder().
					Calcs([]string{"mean"}),
				).
				Mappings([]dashboard.ValueMapping{
					{ValueMap: &dashboard.ValueMap{
						Type: dashboard.MappingTypeValueToText,
						Options: map[string]dashboard.ValueMappingResult{
							"0": {Text: cog.ToPtr("NO")},
							"1": {Text: cog.ToPtr("YES")},
						},
					}},
				}),
		).
		WithPanel(
			etcdStatBase("Total number of failed proposals seen", "none",
				6, 2,
				t.trackRaw("etcdServerProposalsCommittedTotal", `max(etcd_server_proposals_committed_total{namespace="openshift-etcd"})`, ""),
			).
				ReduceOptions(common.NewReduceDataOptionsBuilder().
					Calcs([]string{"mean"}),
				).
				Mappings([]dashboard.ValueMapping{
					{SpecialValueMap: &dashboard.SpecialValueMap{
						Type: dashboard.MappingTypeSpecialValue,
						Options: dashboard.DashboardSpecialValueMapOptions{
							Match:  dashboard.SpecialValueMatchNull,
							Result: dashboard.ValueMappingResult{Text: cog.ToPtr("N/A")},
						},
					}},
				}),
		).
		WithPanel(etcdGeneralInfo("Keys", "short",
			12, 8,
			t.trackRaw("etcdDebuggingMvccKeys", `etcd_debugging_mvcc_keys_total{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{ pod }} Num keys"),
		)).
		WithPanel(etcdGeneralInfo("Leader Elections Per Day", "short",
			12, 6,
			t.trackRaw("etcdLeaderElectionsPerDay", `changes(etcd_server_leader_changes_seen_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[1d])`, "{{instance}} Total Leader Elections Per Day"),
		)).
		WithPanel(etcdGeneralInfo("Slow Operations", "ops",
			12, 8,
			t.trackRaw("etcdSlowApply", `delta(etcd_server_slow_apply_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "{{ pod }} slow applies"),
			t.trackRaw("etcdSlowReadIndexes", `delta(etcd_server_slow_read_indexes_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "{{ pod }} slow read indexes"),
		)).
		WithPanel(etcdGeneralInfo("Key Operations", "ops",
			12, 8,
			t.trackRaw("etcdMvccPuts", `rate(etcd_mvcc_put_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "{{ pod }} puts/s"),
			t.trackRaw("etcdMvccDeletes", `rate(etcd_mvcc_delete_total{namespace="openshift-etcd",pod=~"$etcd_pod"}[2m])`, "{{ pod }} deletes/s"),
		)).
		WithPanel(etcdGeneralCounter("Heartbeat Failures", "short",
			12, 8,
			t.trackRaw("etcdServerHeartbeatFailures", `etcd_server_heartbeat_send_failures_total{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{ pod }} heartbeat failures"),
			t.trackRaw("etcdServerHealthFailures", `etcd_server_health_failures{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{ pod }} health failures"),
		)).
		WithPanel(etcdGeneralInfo("Compacted Keys", "short",
			12, 8,
			t.trackRaw("etcdDebuggingCompactionKeys", `etcd_debugging_mvcc_db_compaction_keys_total{namespace="openshift-etcd",pod=~"$etcd_pod"}`, "{{ pod  }} keys compacted"),
		))
}
