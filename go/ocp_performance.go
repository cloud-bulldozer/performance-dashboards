package main

import (
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	"github.com/grafana/grafana-foundation-sdk/go/timeseries"
)

const (
	intervalVar = mg.RateInterval("$interval")

	cgroupIDFilter = `job=~".*", id =~"/system.slice|/system.slice/.*.service|/.*/ovs-vswitchd.service|/kubepods.slice"`

	fsDeviceFilter   = `device!~".+dm.+"`
	cgroupFSIDFilter = fsDeviceFilter + `,` + cgroupIDFilter

	// TODO refactor these constants to more easily configurable variables, that might even be supplied or discovered at runtime
	infraList                       = "" //`ip-10-0-31-91.us-west-2.compute.internal|ip-10-0-47-124.us-west-2.compute.internal|ip-10-0-69-138.us-west-2.compute.internal`
	controlPlaneList                = "" //`ip-10-0-7-201.us-west-2.compute.internal|ip-10-0-95-165.us-west-2.compute.internal|ip-10-0-32-128.us-west-2.compute.internal`
	nonWorkerList                   = infraList + `|` + controlPlaneList
	controlPlaneInstanceFilter      = `instance=~"` + controlPlaneList + `"`
	workerInstanceFilter            = "" //`instance!~"` + nonWorkerList + `"`
	workerNodesFilter               = "" //`node!~"` + nonWorkerList + `"`
	useNodeCpuInstanceRecordingRule = false
)

func q(metric mg.Metric, filters string) string {
	return mg.Q(metric, filters).String()
}

func buildOCPPerformanceDashboard() *dashboard.DashboardBuilder {
	return buildOCPDashboard(&queryTracker{})
}

func buildOCPCollectedDashboard() *dashboard.DashboardBuilder {
	return buildOCPDashboard(&queryTracker{useMetricNames: true})
}

func buildOCPProfiles() []namedProfile {
	agg := &mg.Generator{}
	buildOCPDashboard(&queryTracker{g: agg})

	raw := &mg.Generator{}
	buildOCPDashboard(&rawTracker{g: raw, seen: map[string]struct{}{}})

	return []namedProfile{
		{"-metrics", agg},
		{"-raw-metrics", raw},
	}
}

// ocpDashboardMetrics lists every raw Prometheus metric used in the OCP performance dashboard.
// Keep in sync with panel queries — enforced by TestOCPDashboardMetricsDeclared.
var ocpDashboardMetrics = []mg.Metric{
	mg.MetricContainerCPU,
	mg.MetricContainerMemoryRSS,
	mg.MetricContainerFSWrites,
	mg.MetricNodeCPU,
	mg.MetricNodeMemoryAvailable,
	mg.MetricNodeMemoryActive,
	mg.MetricNodeMemoryTotal,
	mg.MetricNodeMemoryCached,
	mg.MetricNodeMemoryFree,
	mg.MetricNodeDiskRead,
	mg.MetricNodeDiskWritten,
	mg.MetricNodeNetworkRx,
	mg.MetricNodeNetworkTx,
	mg.MetricNodeNetworkRxDrop,
	mg.MetricNodeMemoryBuffers,
	mg.MetricNodeFsFiles,
	mg.MetricNodeFsFilesFree,
	mg.MetricNodeNFConntrackEntries,
	mg.MetricNodeNFConntrackEntriesLimit,
	mg.MetricNodeNetworkRxPackets,
	mg.MetricNodeNetworkTxPackets,
	mg.MetricNodeNetworkTxDrop,
	mg.MetricContainerFSReads,
	mg.MetricProcessCPU,
	mg.MetricProcessMemory,
	mg.MetricKubeNodeStatusCondition,
	mg.MetricKubeNamespacePhase,
	mg.MetricKubePodStatusPhase,
	mg.MetricKubePodInfo,
	mg.MetricKubeSecretInfo,
	mg.MetricKubeConfigmapInfo,
	mg.MetricKubeServiceInfo,
	mg.MetricClusterOperatorConditions,
}

func ocpBase(t panelTracker, name string, summarize bool) *dashboard.DashboardBuilder {
	dbBuilder := dashboard.NewDashboardBuilder(name).
		Description("Performance dashboard for Red Hat OpenShift\n").
		Tags([]string{}).
		Time("now-1h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().
			RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"}),
		).
		Refresh("30s").
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").
			Type("prometheus").
			Label("Datasource"),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("namespace").
			Label("Namespace").
			Query(t.trackVarQuery("namespaces", `label_values(`+q(mg.MetricKubePodInfo, mg.Filters(mg.NSNotRegex("cluster-density.*|node-density-.*")))+",namespace)")).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex("").
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("block_device").
			Label("Block device").
			Query(t.trackVarQuery("blockDevices", `label_values(node_disk_written_bytes_total, device)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex(`/^(?:(?!dm|rb).)*$/`).
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("net_device").
			Label("Network device").
			Query(t.trackVarQuery("netDevices", `label_values(node_network_receive_bytes_total, device)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex(`/^((br|en|et).*)$/`).
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewIntervalVariableBuilder("interval").
			Label("interval").
			Values(dashboard.StringOrMap{String: cog.ToPtr("2m,3m,4m,5m")}).
			Current(intervalOption("2m")).
			Options([]dashboard.VariableOption{
				intervalOption("2m"),
				intervalOption("3m"),
				intervalOption("4m"),
				intervalOption("5m"),
			}),
		).
		WithRow(ocpClusterAtAGlanceRow(t, summarize)).
		// Row: OVN
		WithRow(ocpOVNRow(t, summarize)).
		// Row: Monitoring stack
		WithRow(ocpMonitoringStackRow(t)).
		// Row: Cluster Kubelet
		WithRow(ocpClusterKubeletRow(t)).
		// Row: Cluster Details
		WithRow(ocpClusterDetailsRow(t)).
		// Row: Cluster Operators Details
		WithRow(ocpClusterOperatorsDetailsRow(t))
	// Row: Master
	withMasterNodeDetailRow(dbBuilder, t)
	// Row: Worker
	withWorkerNodeDetailRow(dbBuilder, t)
	// Row: Infra
	withInfraNodeDetailRow(dbBuilder, t)
	// Row: Stackrox
	dbBuilder.WithRow(ocpStackroxRow(t))
	return dbBuilder
}

func buildOCPDashboard(t panelTracker) *dashboard.DashboardBuilder {
	return ocpBase(t, "OpenShift Performance", false)
}

// Row: Cluster-at-a-Glance
func ocpClusterAtAGlanceRow(t panelTracker, summarize bool) *dashboard.RowBuilder {
	clusterAtAGlanceRow := dashboard.NewRowBuilder("Cluster-at-a-Glance").
		Collapsed(true)
	clusterAtAGlanceRow = rolesCpuUsageRow(clusterAtAGlanceRow, t, summarize)
	clusterAtAGlanceRow = rolesLoad1Row(clusterAtAGlanceRow, t)
	clusterAtAGlanceRow = rolesAvailableMemoryRow(clusterAtAGlanceRow, t, summarize)
	clusterAtAGlanceRow = rolesCgroupCpuRow(clusterAtAGlanceRow, t)
	clusterAtAGlanceRow = rolesCgroupMemoryRow(clusterAtAGlanceRow, t)
	clusterAtAGlanceRow = rolesContainerThreadsRow(clusterAtAGlanceRow, t, summarize)
	clusterAtAGlanceRow = rolesDiskIops(clusterAtAGlanceRow, t, summarize)
	return clusterAtAGlanceRow
}

func rolesCpuUsageRow(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker, summarize bool) *dashboard.RowBuilder {
	return clusterAtAGlanceRow.
		WithPanel(glanceNodeCpuPanel(mg.RoleWorker, summarize, t)).
		WithPanel(glanceNodeCpuPanel(mg.RoleControlPlane, false, t))
}

func glanceNodeCpuPanel(role mg.NodeRole, summarize bool, t panelTracker) *timeseries.PanelBuilder {
	rolePretty := capitalCamelName(role)
	trackedName := "nodeCPU" + rolePretty
	var nodeCpuDqBuilder []*prometheus.DataqueryBuilder
	if summarize {
		nodeCpuDqBuilder = summaryStatsQueriesWithTop(t, trackedName, nodeCpuQueryFn(role), "{{instance}}")
	} else {
		nodeCpuDqBuilder = []*prometheus.DataqueryBuilder{t.track(trackedName, nodeCpuQueryFn(role)(), "{{instance}}")}
	}
	var cpuUnits string
	if useNodeCpuInstanceRecordingRule {
		cpuUnits = "percentunit"
	} else {
		cpuUnits = "percent"
	}
	panel := genericLegendTimeSeries(rolePretty+" CPU Usage", cpuUnits, 12, 8, nodeCpuDqBuilder...)
	return panel
}

func capitalCamelName(role mg.NodeRole) string {
	return capitalize(containerToCamel(string(role)))
}

func nodeCpuQueryFn(role mg.NodeRole) func() *mg.Query {
	var baseMetric mg.Metric
	if useNodeCpuInstanceRecordingRule {
		baseMetric = mg.MetricInstanceNodeCPURate
	} else {
		baseMetric = mg.MetricNodeCPU
	}
	var query func() *mg.Query
	if workerInstanceFilter != "" && role == mg.RoleWorker {
		query = func() *mg.Query {
			baseQuery := mg.Q(baseMetric, `mode!="idle", `+workerInstanceFilter)
			if useNodeCpuInstanceRecordingRule {
				return baseQuery
			} else {
				return baseQuery.
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance).
					Multiply("100")
			}
		}
	} else {
		query = func() *mg.Query {
			baseQuery := mg.Q(baseMetric, `mode!="idle"`).
				MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance}, mg.NodeRoleLabelReplace(role))
			if useNodeCpuInstanceRecordingRule {
				return baseQuery
			} else {
				return baseQuery.
					RateSubquery(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance).
					Multiply("100")
			}
		}
	}
	return query
}

func rolesLoad1Row(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker) *dashboard.RowBuilder {
	for _, role := range []mg.NodeRole{mg.RoleWorker, mg.RoleControlPlane} {
		roleName := capitalCamelName(role)
		clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(genericLegendTimeSeries(roleName+" Load1", "short",
			12, 8,
			t.track("nodeLoad1"+roleName,
				mg.QRaw(mg.MetricNodeLoad1).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(role)),
				"{{instance}}"),
		))
	}
	return clusterAtAGlanceRow
}

func rolesAvailableMemoryRow(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker, summarize bool) *dashboard.RowBuilder {
	return clusterAtAGlanceRow.
		WithPanel(roleAvailableMemoryPanel(mg.RoleWorker, summarize, t)).
		WithPanel(roleAvailableMemoryPanel(mg.RoleControlPlane, false, t))
}

func roleAvailableMemoryPanel(role mg.NodeRole, summarize bool, t panelTracker) *timeseries.PanelBuilder {
	newVar := genericLegendCounterSumRightHandTimeSeries(capitalCamelName(role)+" Memory Available", "bytes",
		12, 8,
		nodeMemoryDqBuilder(summarize, t, role)...,
	)
	return newVar
}

func nodeMemoryDqBuilder(summarize bool, t panelTracker, role mg.NodeRole) []*prometheus.DataqueryBuilder {
	var nodeMemDqBuilders []*prometheus.DataqueryBuilder
	trackedName := `nodeMemoryAvailable` + capitalCamelName(role)
	var query func() *mg.Query
	if workerInstanceFilter != "" {
		query = func() *mg.Query {
			return mg.Q(mg.MetricNodeMemoryAvailable, workerInstanceFilter)
		}
	} else {
		query = func() *mg.Query {
			return mg.QRaw(mg.MetricNodeMemoryAvailable).
				MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
					mg.NodeRoleLabelReplace(role))
		}
	}
	if summarize {
		nodeMemDqBuilders = summaryStatsQueriesWithBottom(t, trackedName, query, "{{instance}}")
	} else {
		nodeMemDqBuilders = append(nodeMemDqBuilders, t.track(trackedName, query(), "{{instance}}"))
	}
	return append(nodeMemDqBuilders, t.track(trackedName+"Sum",
		mg.Q(mg.MetricNodeMemoryAvailable, "").
			MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
				mg.NodeRoleLabelReplace(role)).
			Agg(mg.AggSum),
		"sum"))
}

func rolesCgroupCpuRow(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker) *dashboard.RowBuilder {
	clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(genericLegendTimeSeries("Workers CGroup CPU Rate", "percent",
		12, 8,
		glanceWorkerCGroupCpuQueries(t),
		promQuery(`sum by (id) (container_cpu_usage_seconds_total_cgroup_sum_rate_id_node * on (node) group_left kube_node_role{ role = "worker" })`, "{{id}}"),
	))
	clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(genericLegendTimeSeries("Control Plane CGroup CPU Rate", "percent",
		12, 8,
		glanceCGroupCpuQueries(t, mg.RoleControlPlane),
		promQuery(`sum by (id) (container_cpu_usage_seconds_total_cgroup_sum_rate_id_node * on (node) group_left kube_node_role{ role = "master" })`, "{{id}}"),
	))
	return clusterAtAGlanceRow
}

func glanceWorkerCGroupCpuQueries(t panelTracker) *prometheus.DataqueryBuilder {
	const role = mg.RoleWorker
	// TODO not summarize, but instance filter
	if workerInstanceFilter != "" {
		return t.track("cgroupCPU"+capitalCamelName(role),
			mg.Q(mg.MetricContainerCPU, cgroupIDFilter+`,`+workerNodesFilter).
				Rate(intervalVar).
				Multiply("100").
				Agg(mg.AggSum, mg.GroupByID),
			"{{instance}}")
	} else {
		return glanceCGroupCpuQueries(t, role)
	}
}

func glanceCGroupCpuQueries(t panelTracker, role mg.NodeRole) *prometheus.DataqueryBuilder {
	metricName := "cgroupCPU" + capitalCamelName(role)
	return t.track(metricName,
		mg.Q(mg.MetricContainerCPU, cgroupIDFilter).
			Rate(intervalVar).
			Multiply("100").
			MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
				mg.NodeRoleFilter(role)).
			Agg(mg.AggSum, mg.GroupByID),
		"{{instance}}")
}

func rolesCgroupMemoryRow(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker) *dashboard.RowBuilder {
	const metricRoot = "cgroupMemoryRSS"
	var workerCgroupMemory *mg.Query
	if workerNodesFilter != "" {
		workerCgroupMemory = mg.Q(mg.MetricContainerMemoryRSS, cgroupIDFilter+`,`+workerNodesFilter).
			Agg(mg.AggSum, mg.GroupByID)
	} else {
		workerCgroupMemory = mg.Q(mg.MetricContainerMemoryRSS, cgroupIDFilter).
			MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
				mg.NodeRoleFilter(mg.RoleWorker)).
			Agg(mg.AggSum, mg.GroupByID)
	}
	clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(genericLegendCounterTimeSeries("Workers CGroup Memory RSS", "bytes",
		12, 8,
		t.track(metricRoot+"Worker",
			workerCgroupMemory,
			"{{instance}}"),
		promQuery(`sum by (id) (container_memory_working_set_bytes_cgroup * on (node) group_left kube_node_role{ role = "worker" })`, "{{id}}"),
	))
	clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(genericLegendCounterTimeSeries("Control Plane CGroup Memory RSS", "bytes",
		12, 8,
		t.track(metricRoot+"ControlPlane",
			mg.Q(mg.MetricContainerMemoryRSS, cgroupIDFilter).
				MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
					mg.NodeRoleFilter(mg.RoleControlPlane)).
				Agg(mg.AggSum, mg.GroupByID),
			"{{instance}}"),
		promQuery(`sum by (id) (container_memory_working_set_bytes_cgroup * on (node) group_left kube_node_role{ role = "master" })`, "{{id}}"),
	))
	return clusterAtAGlanceRow
}

func rolesContainerThreadsRow(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker, summarize bool) *dashboard.RowBuilder {
	return clusterAtAGlanceRow.
		WithPanel(containerThreadsPanel(mg.RoleWorker, summarize, t)).
		WithPanel(containerThreadsPanel(mg.RoleControlPlane, false, t))
}

func containerThreadsPanel(role mg.NodeRole, summarize bool, t panelTracker) *timeseries.PanelBuilder {
	const metricRoot = "containerThreads"
	var containerThreadsQuery func() *mg.Query
	roleCamel := capitalCamelName(role)
	if workerNodesFilter != "" && role == mg.RoleWorker {
		containerThreadsQuery = func() *mg.Query {
			return mg.Q(mg.MetricContainerThreads, `container!="",`+workerNodesFilter).
				Agg(mg.AggSum, mg.GroupByNode)
		}
	} else {
		containerThreadsQuery = func() *mg.Query {
			return mg.Q(mg.MetricContainerThreads, `container!=""`).
				Agg(mg.AggSum, mg.GroupByNode).
				MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
					mg.NodeRoleFilter(role))
		}
	}
	// role , summarize , nodes filter
	var containerThreadsBuilders []*prometheus.DataqueryBuilder
	if summarize {
		containerThreadsBuilders = summaryStatsQueries(t, metricRoot+roleCamel, containerThreadsQuery)
	} else {
		containerThreadsBuilders = []*prometheus.DataqueryBuilder{t.track(metricRoot+roleCamel,
			containerThreadsQuery(), "{{instance}}")}
	}
	newVar := genericLegendCounterTimeSeries(roleCamel+" Container Threads", "short",
		12, 8, containerThreadsBuilders...)
	return newVar
}

func rolesDiskIops(clusterAtAGlanceRow *dashboard.RowBuilder, t panelTracker, summarize bool) *dashboard.RowBuilder {
	clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(diskIopsRolePanel(t, mg.RoleWorker, summarize))
	clusterAtAGlanceRow = clusterAtAGlanceRow.WithPanel(diskIopsRolePanel(t, mg.RoleControlPlane, false))
	return clusterAtAGlanceRow
}

func diskIopsRolePanel(t panelTracker, role mg.NodeRole, summarize bool) *timeseries.PanelBuilder {
	var readQuery, writeQuery func() *mg.Query
	if workerInstanceFilter != "" && role == mg.RoleWorker {
		readQuery = func() *mg.Query {
			return mg.Q(mg.MetricNodeDiskReadsCompleted, workerInstanceFilter).
				RateSubquery(intervalVar)
		}
		writeQuery = func() *mg.Query {
			return mg.Q(mg.MetricNodeDiskWritesCompleted, workerInstanceFilter).
				RateSubquery(intervalVar)
		}
	} else {
		readQuery = func() *mg.Query {
			return mg.QRaw(mg.MetricNodeDiskReadsCompleted).
				MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
					mg.NodeRoleLabelReplace(role)).
				RateSubquery(intervalVar)
		}
		writeQuery = func() *mg.Query {
			return mg.QRaw(mg.MetricNodeDiskWritesCompleted).
				MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
					mg.NodeRoleLabelReplace(role)).
				RateSubquery(intervalVar)
		}
	}
	var dqBuilders []*prometheus.DataqueryBuilder
	roleCamel := capitalCamelName(role)
	if summarize {
		dqBuilders = append(dqBuilders, summaryStatsQueries(t, "nodeDiskReads"+roleCamel, readQuery, "read")...)
		dqBuilders = append(dqBuilders, summaryStatsQueries(t, "nodeDiskWrites"+roleCamel, writeQuery, "write")...)
	} else {
		dqBuilders = append(dqBuilders, t.track("nodeDiskReads"+roleCamel, readQuery(), "{{instance}} - {{ device }} - read"))
		dqBuilders = append(dqBuilders, t.track("nodeDiskWrites"+roleCamel, writeQuery(), "{{instance}} - {{ device }} - write"))
	}
	return genericLegendTimeSeries(roleCamel+" Disk IOPS", "short",
		12, 8,
		dqBuilders...,
	)
}

// Row: OVN
func ocpOVNRow(t panelTracker, summarize bool) *dashboard.RowBuilder {
	ovnRowBuilder := dashboard.NewRowBuilder("OVN").
		Collapsed(true)
		// The many containers of the ovnkube-node pod
	for _, container := range []string{"ovnkube-controller", "ovn-controller", "northd", "sbdb", "nbdb"} {
		camelizedContainer := containerToCamel(container)
		var cpuQueries, memoryQueries []*prometheus.DataqueryBuilder
		// TODO I am not sure if this is overall better, except that we can extract labels as string constants
		ovnkContainerFilters := mg.Filters(`pod=~"ovnkube-.*"`, mg.NSExact("openshift-ovn-kubernetes"), `container="`+container+`"`)
		ovnkCPUQueryFunc := func() *mg.Query {
			return mg.Q(mg.MetricContainerCPU, ovnkContainerFilters).IRate(intervalVar).Multiply("100").Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode)
		}
		if summarize {
			cpuQueries = summaryStatsQueries(t, camelizedContainer+"CPU", ovnkCPUQueryFunc)
		} else {
			cpuQueries = append(cpuQueries, t.track(camelizedContainer+"CPU", ovnkCPUQueryFunc(), "{{pod}} - {{node}}"))
		}
		ovnRowBuilder.WithPanel(genericLegendTimeSeries(container+" CPU Usage", "percent",
			12, 8,
			append(cpuQueries,
				promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="`+container+`"}`, "{{pod}} - {{node}}"),
			)...,
		))
		ovnkMemoryQueryFunc := func() *mg.Query {
			return mg.Q(mg.MetricContainerMemoryRSS, ovnkContainerFilters).Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode)
		}
		if summarize {
			memoryQueries = summaryStatsQueries(t, camelizedContainer+"Memory", ovnkMemoryQueryFunc)
		} else {
			memoryQueries = append(memoryQueries, t.track(camelizedContainer+"Memory", ovnkMemoryQueryFunc(), "{{pod}} - {{node}}"))
		}
		ovnRowBuilder.WithPanel(genericLegendTimeSeries(container+" Memory Usage", "bytes",
			12, 8,
			append(memoryQueries,
				promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="`+container+`"}`, "{{pod}} - {{node}}"),
			)...,
		))
	}
	for _, role := range []string{"master", "worker"} {
		capitalizedRole := capitalize(role)
		// ovs panels are a little different
		ovnRowBuilder.WithPanel(genericLegendTimeSeries("ovs-"+role+" CPU Usage", "percent",
			12, 8,
			t.track("ovs"+capitalizedRole+"VswitchdCPU",
				mg.Q(mg.MetricContainerCPU, `id=~"/.*/ovs-vswitchd.service", node=~"$_`+role+`_node"`).
					IRate(intervalVar).Multiply("100"),
				"OVS CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovs-vswitchd.service", node=~"$_`+role+`_node"}`, "OVS CPU - {{ node }}"),
			t.track("ovs"+capitalizedRole+"OvsdbCPU",
				mg.Q(mg.MetricContainerCPU, `id=~"/.*/ovsdb-server.service", node=~"$_`+role+`_node"`).
					IRate(intervalVar).Multiply("100"),
				"OVS DB CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovsdb-server.service", node=~"$_`+role+`_node"}`, "OVS DB CPU - {{ node }}"),
		)).
			WithPanel(genericLegendTimeSeries("ovs-"+role+"  Memory Usage", "bytes",
				12, 8,
				t.track("ovs"+capitalizedRole+"VswitchdMemory",
					mg.Q(mg.MetricContainerMemoryRSS, `id=~"/.*/ovs-vswitchd.service", node=~"$_`+role+`_node"`),
					"OVS Memory - {{ node }}"),
				promQuery(`container_memory_rss_cgroup{id=~"/.*/ovs-vswitchd.service", node=~"$_`+role+`_node"}`, "OVS Memory - {{ node }}"),
				t.track("ovs"+capitalizedRole+"OvsdbMemory",
					mg.Q(mg.MetricContainerMemoryRSS, `id=~"/.*/ovsdb-server.service", node=~"$_`+role+`_node"`),
					"OVS DB Memory - {{ node }}"),
				promQuery(`container_memory_rss_cgroup{id=~"/.*/ovsdb-server.service", node=~"$_`+role+`_node"}`, "OVS DB Memory - {{ node }}"),
			))
	}
	// 99% latencies are also a little different
	ovnRowBuilder.WithPanel(genericLegendTimeSeries("99% Pod Annotation Latency", "s",
		8, 8,
		t.track("ovnPodAnnotationLatencyP99",
			mg.QRaw(mg.MetricOVNKubeControllerPodLatency).
				BucketRate(intervalVar).
				Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByPod, mg.GroupByLE).
				HistogramQuantile(mg.P99).
				Gt("0"),
			"{{ pod }} - {{ instance }}"),
	)).
		WithPanel(genericLegendTimeSeries("99% CNI Request ADD Latency", "s",
			8, 8,
			t.track("ovnCNIAddLatencyP99",
				mg.Q(mg.MetricOVNKubeNodeCNIRequestDuration, `command="ADD"`).
					BucketRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByPod, mg.GroupByLE).
					HistogramQuantile(mg.P99).
					Gt("0"),
				"{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% CNI Request DEL Latency", "s",
			8, 8,
			t.track("ovnCNIDelLatencyP99",
				mg.Q(mg.MetricOVNKubeNodeCNIRequestDuration, `command="DEL"`).
					BucketRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByPod, mg.GroupByLE).
					HistogramQuantile(mg.P99).
					Gt("0"),
				"{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovnkube-control-plane CPU Usage", "percent",
			12, 8,
			t.track("ovnkubeControlPlaneCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"`).
					IRate(intervalVar).Multiply("100").
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode),
				"{{pod}} - {{node}}"),
			promQuery(`sum(container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes"}) by (pod, node)`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("ovnkube-control-plane Memory Usage", "bytes",
			12, 8,
			t.track("ovnkubeControlPlaneMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"`),
				"{{pod}} - {{node}}"),
			promQuery(`sum(container_memory_working_set_bytes_container{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes"}) by (pod,node)`, "{{pod}} - {{node}}"),
		))
	return ovnRowBuilder
}

// Row: Monitoring stack
func ocpMonitoringStackRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Monitoring stack").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Prometheus Replica CPU", "percent",
			12, 8,
			t.track("prometheusCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer, mg.GroupByNode).
					Multiply("100"),
				"{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Prometheus Replica RSS", "bytes",
			12, 8,
			t.track("prometheusMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"`).
					Agg(mg.AggSum, mg.GroupByPod),
				"{{pod}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"}`, "{{pod}}"),
		)).
		WithPanel(genericLegendTimeSeries("metrics-server/prom-adapter CPU", "percent",
			12, 8,
			t.track("metricsServerCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"metrics-server-.*",namespace!="",name!=""`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer).
					Multiply("100"),
				"{{pod}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"metrics-server-.*",namespace!="",name!=""}`, "{{pod}}"),
			t.track("promAdapterCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer).
					Multiply("100"),
				"{{pod}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}`, "{{pod}}"),
		)).
		WithPanel(genericLegendTimeSeries("metrics-server/prom-adapter RSS", "bytes",
			12, 8,
			t.track("metricsServerMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"metrics-server-.*",namespace!="",name!=""`).
					Agg(mg.AggSum, mg.GroupByPod),
				"{{pod}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"metrics-server-.*",namespace!="",name!=""}`, "{{pod}}"),
			t.track("promAdapterMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""`).
					Agg(mg.AggSum, mg.GroupByPod),
				"{{pod}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}`, "{{pod}}"),
		))
}

// Row: Stackrox
func ocpStackroxRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Stackrox").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 25 stackrox container RSS bytes", "bytes",
			12, 8,
			t.track("stackroxContainerMemoryRSS",
				mg.Q(mg.MetricContainerMemoryRSS, `container!="POD",name!="",namespace!="",namespace=~"stackrox"`).
					TopK(25),
				"{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 25 stackrox container CPU percent", "percent",
			12, 8,
			t.track("stackroxContainerCPU",
				mg.Q(mg.MetricContainerCPU, `container!="POD",name!="",namespace!="",namespace=~"stackrox"`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer, mg.GroupByNamespace, mg.GroupByName, "service").
					Multiply("100").
					TopK(25),
				"{{ pod }}: {{ container }}"),
		))
}

// Row: Cluster Kubelet
func ocpClusterKubeletRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Kubelet").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 Kubelet CPU usage", "percent",
			12, 8,
			t.track("kubeletCPU",
				mg.Q(mg.MetricProcessCPU, `service="kubelet",job="kubelet"`).
					IRate(intervalVar).Multiply("100").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)).
					TopK(10),
				"kubelet - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 crio CPU usage", "percent",
			12, 8,
			t.track("crioCPU",
				mg.Q(mg.MetricProcessCPU, `service="kubelet",job="crio"`).
					IRate(intervalVar).Multiply("100").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)).
					TopK(10),
				"crio - {{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 Kubelet memory usage", "bytes",
			12, 8,
			t.track("kubeletMemory",
				mg.Q(mg.MetricProcessMemory, `service="kubelet",job="kubelet"`).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)).
					TopK(10),
				"kubelet - {{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 crio memory usage", "bytes",
			12, 8,
			t.track("crioMemory",
				mg.Q(mg.MetricProcessMemory, `service="kubelet",job="crio"`).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)).
					TopK(10),
				"crio - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("inodes usage in /run", "percent",
			12, 8,
			t.trackRaw("nodeInodesUsageRun", `(1 - node_filesystem_files_free{fstype!="",mountpoint="/run"} / node_filesystem_files{fstype!="",mountpoint="/run"}) * 100`, "{{instance}}"),
		)).
		WithPanel(genericLegendCounterSumRightHandTimeSeries("inodes count in /run", "none",
			12, 8,
			t.track("nodeInodesCountRun",
				mg.Q(mg.MetricNodeFsFiles, `fstype!="",mountpoint="/run"`).
					Sub(mg.Q(mg.MetricNodeFsFilesFree, `fstype!="",mountpoint="/run"`)),
				"{{instance}}"),
			promQuery(
				mg.Q(mg.MetricNodeFsFiles, `fstype!="",mountpoint="/run"`).
					Sub(mg.Q(mg.MetricNodeFsFilesFree, `fstype!="",mountpoint="/run"`)).
					Agg(mg.AggSum).String(),
				"sum"),
		))
}

// Row: Cluster Details
func ocpClusterDetailsRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Details").
		Collapsed(true).
		WithPanel(genericStat("Current Node Count",
			8, 3,
			t.track("kubeNodeInfo", mg.QRaw(mg.MetricKubeNodeInfo).Agg(mg.AggSum), "Number of nodes"),
			t.track("kubeNodeStatusCondition",
				mg.Q(mg.MetricKubeNodeStatusCondition, `status="true"`).
					Agg(mg.AggSum, mg.GroupByCondition).
					Gt("0"),
				"Node: {{ condition }}"),
		)).
		WithPanel(genericStat("Current Namespace Count",
			8, 3,
			t.track("kubeNamespacePhase",
				mg.Q(mg.MetricKubeNamespacePhase, "").
					Agg(mg.AggSum, mg.GroupByPhase).
					Gt("0"),
				"{{ phase }}"),
			promQuery(`kube_namespace_status_phase_sum_by_phase`, "{{ phase }}"),
		)).
		WithPanel(genericStat("Current Pod Count",
			8, 3,
			t.track("kubePodStatusPhase",
				mg.Q(mg.MetricKubePodStatusPhase, "").
					Agg(mg.AggSum, mg.GroupByPhase).
					Gt("0"),
				"{{ phase}} Pods"),
			promQuery(`sum(kube_pod_info_by_node)`, "{{ phase}} Pods"),
		)).
		WithPanel(genericTimeSeries("Number of nodes", "none",
			8, 8,
			t.track("kubeNodeInfo", mg.QRaw(mg.MetricKubeNodeInfo).Agg(mg.AggSum), "Number of nodes"),
			t.track("kubeNodeStatusCondition",
				mg.Q(mg.MetricKubeNodeStatusCondition, `status="true"`).
					Agg(mg.AggSum, mg.GroupByCondition).
					Gt("0"),
				"Node: {{ condition }}"),
		)).
		WithPanel(genericTimeSeries("Namespace count", "none",
			8, 8,
			t.track("kubeNamespacePhase",
				mg.Q(mg.MetricKubeNamespacePhase, "").
					Agg(mg.AggSum, mg.GroupByPhase).
					Gt("0"),
				"{{ phase }} namespaces"),
			promQuery(`kube_namespace_status_phase_sum_by_phase > 0`, "{{ phase }} namespaces"),
		)).
		WithPanel(genericTimeSeries("Pod count", "none",
			8, 8,
			t.track("kubePodStatusPhase",
				mg.Q(mg.MetricKubePodStatusPhase, "").
					Agg(mg.AggSum, mg.GroupByPhase).
					Gt("0"),
				"{{phase}} pods"),
			promQuery(`kube_pod_status_phase_sum_by_failed`, "Failed pods"),
			promQuery(`kube_pod_status_phase_sum_by_pending`, "Pending pods"),
			promQuery(`kube_pod_status_phase_sum_by_running`, "Running pods"),
			promQuery(`kube_pod_status_phase_sum_by_succeeded`, "Succeeded pods"),
			promQuery(`kube_pod_status_phase_sum_by_unknown`, "Unknown pods"),
		)).
		WithPanel(genericTimeSeries("Secret & configmap count", "none",
			8, 8,
			t.track("kubeSecretInfo", mg.QRaw(mg.MetricKubeSecretInfo).Agg(mg.AggCount), "secrets"),
			promQuery(`kube_secret_info_count`, "secrets"),
			t.track("kubeConfigmapInfo", mg.QRaw(mg.MetricKubeConfigmapInfo).Agg(mg.AggCount), "Configmaps"),
			promQuery(`kube_configmap_info_count`, "Configmaps"),
		)).
		WithPanel(genericTimeSeries("Deployment count", "none",
			8, 8,
			// MetricKubeDeploymentReplicas
			t.track("kubeDeploymentReplicas", mg.QRaw(mg.MetricKubeDeploymentReplicas).Agg(mg.AggCount), "Deployments"),
			promQuery(`kube_deployment_spec_paused_count`, "Deployments"),
		)).
		WithPanel(genericTimeSeries("Services count", "none",
			8, 8,
			t.track("kubeServiceInfo", mg.QRaw(mg.MetricKubeServiceInfo).Agg(mg.AggCount), "Services"),
			promQuery(`kube_service_info_count`, "Services"),
		)).
		WithPanel(genericTimeSeries("Routes count", "none",
			8, 8,
			t.track("openshiftRouteInfo", mg.QRaw(mg.MetricOCPRouteInfo).Agg(mg.AggCount), "Routes"),
			promQuery(`openshift_route_info_count`, "Routes"),
		)).
		WithPanel(genericTimeSeries("Alerts", "none",
			8, 8,
			t.track("alerts",
				mg.Q(mg.MetricAlerts, `severity!="none"`).
					Agg(mg.AggSum, mg.GroupByAlertname, mg.GroupBySeverity).
					TopK(10),
				"{{severity}}: {{alertname}}"),
		)).
		WithPanel(genericLegendTimeSeries("Pod Distribution", "none",
			8, 8,
			t.track("kubePodDistribution",
				mg.Q(mg.MetricKubePodInfo, "").
					Agg(mg.AggCount, mg.GroupByNode),
				"{{ node }}"),
			promQuery(`kube_pod_info_by_node`, "{{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container CPU", "percent",
			12, 8,
			t.track("containerCPUTop10",
				mg.Q(mg.MetricContainerCPU, `namespace!="",container!="POD",name!=""`).
					IRate(intervalVar).Multiply("100").
					TopK(10),
				"{{ namespace }} - {{ pod }} - {{ node }}"),
			promQuery(`topk(10,container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ pod }} - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container RSS", "bytes",
			12, 8,
			t.track("containerMemoryRSSTop10",
				mg.Q(mg.MetricContainerMemoryRSS, `namespace!="",container!="POD",name!=""`).
					TopK(10),
				"{{ namespace }} - {{ pod }} - {{ node }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ pod }} - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("container RSS system.slice", "bytes",
			12, 8,
			t.track("containerMemoryRSSSystemSlice",
				mg.Q(mg.MetricContainerMemoryRSS, `id="/system.slice"`).
					Agg(mg.AggSum, mg.GroupByNode),
				"system.slice - {{ node }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{id="/system.slice"}`, "system.slice - {{ node }}"),
		)).
		WithPanel(genericTimeSeries("Goroutines count", "none",
			12, 8,
			t.track("goGoroutines",
				mg.QRaw(mg.MetricGoGoroutines).
					Agg(mg.AggSum, mg.GroupByJob, mg.GroupByInstance).
					TopK(10),
				"{{ job }} - {{ instance }}"),
		))
}

// Row: Cluster Operators Details
func ocpClusterOperatorsDetailsRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Operators Details").
		Collapsed(true).
		WithPanel(genericStat("Cluster operators overview",
			24, 3,
			t.track("clusterOperatorConditions",
				mg.Q(mg.MetricClusterOperatorConditions, `condition!=""`).
					Agg(mg.AggSum, mg.GroupByCondition),
				"{{ condition }}"),
		)).
		WithPanel(genericLegendTimeSeries("Cluster operators information", "none",
			8, 8,
			t.track("clusterOperatorInfo", mg.Q(mg.MetricClusterOperatorConditions, `name!="",reason!=""`), "{{name}} - {{reason}}"),
		)).
		WithPanel(genericLegendTimeSeries("Cluster operators degraded", "none",
			8, 8,
			t.track("clusterOperatorDegraded", mg.Q(mg.MetricClusterOperatorConditions, `condition="Degraded",name!="",reason!=""`), "{{name}} - {{reason}}"),
		))
}

func withMasterNodeDetailRow(builder *dashboard.DashboardBuilder, t panelTracker) *dashboard.DashboardBuilder {
	var nodesQuery string
	if controlPlaneList != "" {
		nodesQuery = `label_values(kube_node_role{node=~"` + controlPlaneList + `"}, node)`
	} else {
		nodesQuery = `label_values(` + mg.NodeRoleFilter(mg.RoleControlPlane).String() + `, node)`
	}
	return builder.WithRow(ocpNodeRow(t, "_master_node", mg.RoleMaster)).
		WithVariable(dashboard.NewQueryVariableBuilder("_master_node").
			Label("Master").
			Query(t.trackVarQuery("masterNodes", nodesQuery)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		)
}
func withWorkerNodeDetailRow(builder *dashboard.DashboardBuilder, t panelTracker) *dashboard.DashboardBuilder {
	var nodesQuery string
	if workerNodesFilter != "" {
		nodesQuery = `label_values(kube_node_role{` + workerNodesFilter + `}, node)`
	} else {
		nodesQuery = `label_values(` + mg.NodeRoleFilter(mg.RoleWorker).String() + `, node)`
	}
	return builder.WithRow(ocpNodeRow(t, "_worker_node", mg.RoleWorker)).
		WithVariable(dashboard.NewQueryVariableBuilder("_worker_node").
			Label("Worker").
			Query(t.trackVarQuery("workerNodes", nodesQuery)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		)
}
func withInfraNodeDetailRow(builder *dashboard.DashboardBuilder, t panelTracker) *dashboard.DashboardBuilder {
	var nodesQuery string
	if infraList != "" {
		nodesQuery = `label_values(kube_node_role{node=~"` + infraList + `"}, node)`
	} else {
		nodesQuery = `label_values(` + mg.NodeRoleFilter(mg.RoleInfra).String() + `, node)`
	}
	return builder.WithRow(ocpNodeRow(t, "_infra_node", mg.RoleInfra)).
		WithVariable(dashboard.NewQueryVariableBuilder("_infra_node").
			Label("Infra").
			Query(t.trackVarQuery("infraNodes", nodesQuery)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		)

}

func ocpNodeRow(t panelTracker, nodeVar string, role mg.NodeRole) *dashboard.RowBuilder {
	instanceFilter := `instance=~"$` + nodeVar + `"`
	nodeFilter := `node=~"$` + nodeVar + `"`
	roleStr := string(role)

	row := dashboard.NewRowBuilder(roleStr + ": $" + nodeVar).
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 8}).
		Repeat(nodeVar).
		WithPanel(genericLegendTimeSeries("CPU Basic: $"+nodeVar, "percent",
			12, 8,
			t.track("nodeCPU",
				mg.Q(mg.MetricNodeCPU, instanceFilter+`,job=~".*"`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByMode).
					Multiply("100"),
				"Busy {{mode}}"),
			promQuery(`node_cpu_seconds_sum_rate_2m_30s_instance_mode_node_panel{`+instanceFilter+`}`, "Busy {{mode}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("System Memory: $"+nodeVar, "bytes",
			12, 8,
			t.track("nodeMemoryActive", mg.Q(mg.MetricNodeMemoryActive, instanceFilter), "Active"),
			t.track("nodeMemoryTotal", mg.Q(mg.MetricNodeMemoryTotal, instanceFilter), "Total"),
			t.trackRaw("nodeMemoryCachedBuffers",
				`node_memory_Cached_bytes{`+instanceFilter+`} + node_memory_Buffers_bytes{`+instanceFilter+`}`,
				"Cached + Buffers"),
			t.track("nodeMemoryAvailable", mg.Q(mg.MetricNodeMemoryAvailable, instanceFilter), "Available"),
			t.track("nodeMemoryUsed",
				mg.Q(mg.MetricNodeMemoryTotal, instanceFilter).
					Sub(mg.Q(mg.MetricNodeMemoryFree, instanceFilter).Paren()),
				"Used"),
		)).
		WithPanel(genericLegendTimeSeries("Disk throughput: $"+nodeVar, "Bps",
			12, 8,
			t.track("nodeDiskRead",
				mg.Q(mg.MetricNodeDiskRead, `device=~"$block_device",`+instanceFilter).
					Rate(intervalVar),
				"{{ device }} - read"),
			t.track("nodeDiskWritten",
				mg.Q(mg.MetricNodeDiskWritten, `device=~"$block_device",`+instanceFilter).
					Rate(intervalVar),
				"{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Disk IOPS: $"+nodeVar, "iops",
			12, 8,
			t.track("nodeDiskReadsCompleted",
				mg.Q(mg.MetricNodeDiskReadsCompleted, `device=~"$block_device",`+instanceFilter).
					Rate(intervalVar),
				"{{ device }} - read"),
			t.track("nodeDiskWritesCompleted",
				mg.Q(mg.MetricNodeDiskWritesCompleted, `device=~"$block_device",`+instanceFilter).
					Rate(intervalVar),
				"{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Network Utilization: $"+nodeVar, "bps",
			12, 8,
			t.track("nodeNetworkRx",
				mg.Q(mg.MetricNodeNetworkRx, instanceFilter+`,device=~"$net_device"`).
					Rate(intervalVar).Multiply("8"),
				"{{instance}} - {{device}} - RX"),
			t.track("nodeNetworkTx",
				mg.Q(mg.MetricNodeNetworkTx, instanceFilter+`,device=~"$net_device"`).
					Rate(intervalVar).Multiply("8"),
				"{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network Packets: $"+nodeVar, "pps",
			12, 8,
			t.track("nodeNetworkRxPackets",
				mg.Q(mg.MetricNodeNetworkRxPackets, instanceFilter+`,device=~"$net_device"`).
					Rate(intervalVar),
				"{{instance}} - {{device}} - RX"),
			t.track("nodeNetworkTxPackets",
				mg.Q(mg.MetricNodeNetworkTxPackets, instanceFilter+`,device=~"$net_device"`).
					Rate(intervalVar),
				"{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network packets drop: $"+nodeVar, "pps",
			12, 8,
			t.track("nodeNetworkRxDrop",
				mg.Q(mg.MetricNodeNetworkRxDrop, instanceFilter).
					Rate(intervalVar).TopK(10),
				"rx-drop-{{ device }}"),
			t.track("nodeNetworkTxDrop",
				mg.Q(mg.MetricNodeNetworkTxDrop, instanceFilter).
					Rate(intervalVar).TopK(10),
				"tx-drop-{{ device }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Conntrack stats: $"+nodeVar, "",
			12, 8,
			t.track("nodeConntrackEntries", mg.Q(mg.MetricNodeNFConntrackEntries, instanceFilter), "conntrack_entries"),
			t.track("nodeConntrackLimit", mg.Q(mg.MetricNodeNFConntrackEntriesLimit, instanceFilter), "conntrack_limit"),
		)).
		WithPanel(genericLegendTimeSeries("container CPU: $"+nodeVar, "percent",
			12, 8,
			t.track("containerCPU",
				mg.Q(mg.MetricContainerCPU, `container!="POD",name!="",`+nodeFilter+`,namespace!="",namespace=~"$namespace"`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer, mg.GroupByNamespace, mg.GroupByName, "service").
					Multiply("100"),
				"{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{`+nodeFilter+`,namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("container RSS: $"+nodeVar, "bytes",
			12, 8,
			t.track("containerMemoryRSS",
				mg.Q(mg.MetricContainerMemoryRSS, `container!="POD",name!="",`+nodeFilter+`,namespace!="",namespace=~"$namespace"`),
				"{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{`+nodeFilter+`,namespace=~"$namespace"})`, "{{pod}} - {{node}}"),
		))

	row = row.
		WithPanel(genericLegendTimeSeries("cgroup CPU: $"+nodeVar, "percent",
			12, 8,
			t.track("cgroupCPU",
				mg.Q(mg.MetricContainerCPU, mg.Filters(cgroupIDFilter, nodeFilter)).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByID).
					Multiply("100"),
				"{{ id }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{`+nodeFilter+`}`, "{{ id }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("cgroup RSS: $"+nodeVar, "bytes",
			12, 8,
			t.track("cgroupRSS",
				mg.Q(mg.MetricContainerMemoryRSS, mg.Filters(cgroupIDFilter, nodeFilter)).
					Agg(mg.AggSum, mg.GroupByID),
				"{{ id }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{`+nodeFilter+`}`, "{{ id }}"),
		)).
		WithPanel(genericLegendTimeSeries("Pod fs rw rate: $"+nodeVar, "Bps",
			12, 8,
			t.track("podFSWrites",
				mg.Q(mg.MetricContainerFSWrites, mg.Filters(fsDeviceFilter, nodeFilter, `pod!=""`)).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByPod),
				"{{ pod }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_container_sum_rate_pod_node_device{`+nodeFilter+`}`, "{{ pod }}: {{ device }} - write"),
			t.track("podFSReads",
				mg.Q(mg.MetricContainerFSReads, mg.Filters(fsDeviceFilter, nodeFilter, `pod!=""`)).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByPod),
				"{{ pod }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_container_sum_rate_pod_node_device{`+nodeFilter+`}`, "{{ pod }}: {{ device }} - read"),
		)).
		WithPanel(genericLegendTimeSeries("cgroup fs rw rate: $"+nodeVar, "Bps",
			12, 8,
			t.track("cgroupFSWrites",
				mg.Q(mg.MetricContainerFSWrites, mg.Filters(cgroupFSIDFilter, nodeFilter)).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByID),
				"{{ id }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_cgroup_sum_rate_id_node_device{`+nodeFilter+`}`, "{{ id }}: {{ device }} - write"),
			t.track("cgroupFSReads",
				mg.Q(mg.MetricContainerFSReads, mg.Filters(cgroupFSIDFilter, nodeFilter)).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByID),
				"{{ id }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_cgroup_sum_rate_id_node_device{`+nodeFilter+`}`, "{{ id }}: {{ device }} - read"),
		))

	return row
}
