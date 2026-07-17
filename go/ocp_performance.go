package main

import (
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
)

const (
	intervalVar = mg.RateInterval("$interval")

	cgroupIDFilter             = `job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"`
	cgroupIDFilterWithJournald = `job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/.*.service|/system.slice/systemd-udevd.service|/kubepods.slice"`

	fsWriteFilter    = `device!~".+dm.+"`
	fsReadFilter     = `device!~".+dm.+"`
	cgroupFSIDFilter = `device!~".+dm.+", id =~"/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"`
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

func buildOCPDashboard(t panelTracker) *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("Openshift Performance").
		Description("Performance dashboard for Red Hat Openshift\n").
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
		WithVariable(dashboard.NewQueryVariableBuilder("_master_node").
			Label("Master").
			Query(t.trackVarQuery(`label_values(kube_node_role{role="master"}, node)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("_worker_node").
			Label("Worker").
			Query(t.trackVarQuery(`label_values(kube_node_role{role=~"worker"}, node)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("_infra_node").
			Label("Infra").
			Query(t.trackVarQuery(`label_values(kube_node_role{role="infra"}, node)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("namespace").
			Label("Namespace").
			Query(t.trackVarQuery(`label_values(` + q(mg.MetricKubePodInfo, mg.Filters(mg.NSNotRegex("cluster-density.*|node-density-.*"))) + ",namespace)")).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex("").
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("block_device").
			Label("Block device").
			Query(t.trackVarQuery(`label_values(node_disk_written_bytes_total, device)`)).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex(`/^(?:(?!dm|rb).)*$/`).
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("net_device").
			Label("Network device").
			Query(t.trackVarQuery(`label_values(node_network_receive_bytes_total, device)`)).
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
		// Row: Cluster-at-a-Glance
		WithRow(ocpClusterAtAGlanceRow(t)).
		// Row: OVN
		WithRow(ocpOVNRow(t)).
		// Row: Monitoring stack
		WithRow(ocpMonitoringStackRow(t)).
		// Row: Cluster Kubelet
		WithRow(ocpClusterKubeletRow(t)).
		// Row: Cluster Details
		WithRow(ocpClusterDetailsRow(t)).
		// Row: Cluster Operators Details
		WithRow(ocpClusterOperatorsDetailsRow(t)).
		// Row: Master
		WithRow(ocpNodeRow(t, "_master_node", mg.RoleMaster)).
		// Row: Worker
		WithRow(ocpNodeRow(t, "_worker_node", mg.RoleWorker)).
		// Row: Infra
		WithRow(ocpNodeRow(t, "_infra_node", mg.RoleInfra)).
		// Row: Stackrox
		WithRow(ocpStackroxRow(t))
}

// Row: Cluster-at-a-Glance
func ocpClusterAtAGlanceRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster-at-a-Glance").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Workers CPU Usage", "percent",
			12, 8,
			t.track("nodeCPUWorker",
				mg.Q(mg.MetricNodeCPU, `mode != "idle"`).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(mg.RoleWorker)).
					RateSubquery(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance).
					Multiply("100"),
				"{{instance}}"),
			promQuery("node_cpu_seconds_sum_rate_2m_30s_worker", "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane CPU Usage", "percent",
			12, 8,
			t.track("nodeCPUControlPlane",
				mg.Q(mg.MetricNodeCPU, `mode != "idle"`).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace("control-plane")).
					RateSubquery(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance).
					Multiply("100"),
				"{{instance}}"),
			promQuery("node_cpu_seconds_sum_rate_2m_30s_master", "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Load1", "short",
			12, 8,
			t.track("nodeLoad1Worker",
				mg.Raw("node_load1").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(mg.RoleWorker)),
				"{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Load1", "short",
			12, 8,
			t.track("nodeLoad1ControlPlane",
				mg.Raw("node_load1").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace("control-plane")),
				"{{instance}}"),
		)).
		WithPanel(genericLegendCounterSumRightHandTimeSeries("Workers Memory Available", "bytes",
			12, 8,
			t.track("nodeMemoryAvailableWorker",
				mg.Q(mg.MetricNodeMemoryAvailable, "").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(mg.RoleWorker)),
				"{{instance}}"),
			t.track("nodeMemoryAvailableWorkerSum",
				mg.Q(mg.MetricNodeMemoryAvailable, "").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(mg.RoleWorker)).
					Agg(mg.AggSum),
				"sum"),
		)).
		WithPanel(genericLegendCounterSumRightHandTimeSeries("Control Plane Memory Available", "bytes",
			12, 8,
			t.track("nodeMemoryAvailableControlPlane",
				mg.Q(mg.MetricNodeMemoryAvailable, "").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace("control-plane")),
				"{{instance}}"),
			t.track("nodeMemoryAvailableControlPlaneSum",
				mg.Q(mg.MetricNodeMemoryAvailable, "").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace("control-plane")).
					Agg(mg.AggSum),
				"sum"),
		)).
		WithPanel(genericLegendTimeSeries("Workers CGroup CPU Rate", "percent",
			12, 8,
			t.track("cgroupCPUWorker",
				mg.Q(mg.MetricContainerCPU, cgroupIDFilter).
					Rate(intervalVar).
					Multiply("100").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)).
					Agg(mg.AggSum, mg.GroupByID),
				"{{instance}}"),
			promQuery(`sum by (id) (container_cpu_usage_seconds_total_cgroup_sum_rate_id_node * on (node) group_left kube_node_role{ role = "worker" })`, "{{id}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane CGroup CPU Rate", "percent",
			12, 8,
			t.track("cgroupCPUControlPlane",
				mg.Q(mg.MetricContainerCPU, cgroupIDFilter).
					Rate(intervalVar).
					Multiply("100").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter("control-plane")).
					Agg(mg.AggSum, mg.GroupByID),
				"{{instance}}"),
			promQuery(`sum by (id) (container_cpu_usage_seconds_total_cgroup_sum_rate_id_node * on (node) group_left kube_node_role{ role = "control-plane" })`, "{{id}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers CGroup Memory RSS", "bytes",
			12, 8,
			t.track("cgroupMemoryRSSWorker",
				mg.Q(mg.MetricContainerMemoryRSS, cgroupIDFilter).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)).
					Agg(mg.AggSum, mg.GroupByID),
				"{{instance}}"),
			promQuery(`sum by (id) (container_memory_working_set_bytes_cgroup * on (node) group_left kube_node_role{ role = "worker" })`, "{{id}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane CGroup Memory RSS", "bytes",
			12, 8,
			t.track("cgroupMemoryRSSControlPlane",
				mg.Q(mg.MetricContainerMemoryRSS, cgroupIDFilter).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter("control-plane")).
					Agg(mg.AggSum, mg.GroupByID),
				"{{instance}}"),
			promQuery(`sum by (id) (container_memory_working_set_bytes_cgroup * on (node) group_left kube_node_role{ role = "control-plane" })`, "{{id}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers Container Threads", "short",
			12, 8,
			t.track("containerThreadsWorker",
				mg.Raw(`container_threads{container!=""}`).
					Agg(mg.AggSum, mg.GroupByNode).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter(mg.RoleWorker)),
				"{{instance}}"),
			promQuery("container_threads_sum_by_node_worker", "{{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane Container Threads", "short",
			12, 8,
			t.track("containerThreadsControlPlane",
				mg.Raw(`container_threads{container!=""}`).
					Agg(mg.AggSum, mg.GroupByNode).
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByNode},
						mg.NodeRoleFilter("control-plane")),
				"{{instance}}"),
			promQuery("container_threads_sum_by_node_master", "{{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Disk IOPS", "short",
			12, 8,
			t.track("nodeDiskReadsWorker",
				mg.Raw("node_disk_reads_completed_total").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(mg.RoleWorker)).
					RateSubquery(intervalVar),
				"{{instance}} - {{ device }} - read"),
			t.track("nodeDiskWritesWorker",
				mg.Raw("node_disk_writes_completed_total").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace(mg.RoleWorker)).
					RateSubquery(intervalVar),
				"{{instance}} - {{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Disk IOPS", "short",
			12, 8,
			t.track("nodeDiskReadsControlPlane",
				mg.Raw("node_disk_reads_completed_total").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace("control-plane")).
					RateSubquery(intervalVar),
				"{{instance}} - {{ device }} - read"),
			t.track("nodeDiskWritesControlPlane",
				mg.Raw("node_disk_writes_completed_total").
					MultiplyOnGroupLeft([]mg.GroupBy{mg.GroupByInstance},
						mg.NodeRoleLabelReplace("control-plane")).
					RateSubquery(intervalVar),
				"{{instance}} - {{ device }} - write"),
		))
}

// Row: OVN
func ocpOVNRow(t panelTracker) *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("OVN").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 ovnkube-controller CPU Usage", "percent",
			12, 8,
			t.track("ovnkubeControllerCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"`).
					IRate(intervalVar).Multiply("100").
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 ovnkube-controller Memory Usage", "bytes",
			12, 8,
			t.track("ovnkubeControllerMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"`).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 ovn-controller CPU Usage", "percent",
			12, 8,
			t.track("ovnControllerCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"`).
					IRate(intervalVar).Multiply("100").
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 ovn-controller Memory Usage", "bytes",
			12, 8,
			t.track("ovnControllerMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"`).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 nbdb CPU Usage", "percent",
			12, 8,
			t.track("ovnNbdbCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"`).
					IRate(intervalVar).Multiply("100").
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 nbdb Memory Usage", "bytes",
			12, 8,
			t.track("ovnNbdbMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="nbdb"`).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 northd CPU Usage", "percent",
			12, 8,
			t.track("ovnNorthdCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"`).
					IRate(intervalVar).Multiply("100").
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 northd Memory Usage", "bytes",
			12, 8,
			t.track("ovnNorthdMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="northd"`).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 sbdb CPU Usage", "percent",
			12, 8,
			t.track("ovnSbdbCPU",
				mg.Q(mg.MetricContainerCPU, `pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"`).
					IRate(intervalVar).Multiply("100").
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 sbdb Memory Usage", "bytes",
			12, 8,
			t.track("ovnSbdbMemory",
				mg.Q(mg.MetricContainerMemoryRSS, `pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="sbdb"`).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByNode).
					TopK(10),
				"{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-master CPU Usage", "percent",
			12, 8,
			t.track("ovsMasterVswitchdCPU",
				mg.Q(mg.MetricContainerCPU, `id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"`).
					IRate(intervalVar).Multiply("100"),
				"OVS CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"}`, "OVS CPU - {{ node }}"),
			t.track("ovsMasterOvsdbCPU",
				mg.Q(mg.MetricContainerCPU, `id=~"/.*/ovsdb-server.service", node=~"$_master_node"`).
					IRate(intervalVar).Multiply("100"),
				"OVS DB CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovsdb-server.service", node=~"$_master_node"}`, "OVS DB CPU - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-master Memory Usage", "bytes",
			12, 8,
			t.track("ovsMasterVswitchdMemory", mg.Q(mg.MetricContainerMemoryRSS, `id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"`), "OVS Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"}`, "OVS Memory - {{ node }}"),
			t.track("ovsMasterOvsdbMemory", mg.Q(mg.MetricContainerMemoryRSS, `id=~"/.*/ovsdb-server.service", node=~"$_master_node"`), "OVS DB Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovsdb-server.service", node=~"$_master_node"}`, "OVS DB Memory - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-worker CPU Usage", "percent",
			12, 8,
			t.track("ovsWorkerVswitchdCPU",
				mg.Q(mg.MetricContainerCPU, `id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"`).
					IRate(intervalVar).Multiply("100"),
				"OVS CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"}`, "OVS CPU - {{ node }}"),
			t.track("ovsWorkerOvsdbCPU",
				mg.Q(mg.MetricContainerCPU, `id=~"/.*/ovsdb-server.service", node=~"$_worker_node"`).
					IRate(intervalVar).Multiply("100"),
				"OVS DB CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovsdb-server.service", node=~"$_worker_node"}`, "OVS DB CPU - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-worker Memory Usage", "bytes",
			12, 8,
			t.track("ovsWorkerVswitchdMemory", mg.Q(mg.MetricContainerMemoryRSS, `id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"`), "OVS Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"}`, "OVS Memory - {{ node }}"),
			t.track("ovsWorkerOvsdbMemory", mg.Q(mg.MetricContainerMemoryRSS, `id=~"/.*/ovsdb-server.service", node=~"$_worker_node"`), "OVS DB Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovsdb-server.service", node=~"$_worker_node"}`, "OVS DB Memory - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% Pod Annotation Latency", "s",
			8, 8,
			t.track("ovnPodAnnotationLatencyP99",
				mg.Raw("ovnkube_controller_pod_creation_latency_seconds").
					BucketRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByPod, mg.GroupByLE).
					HistogramQuantile(mg.P99).
					Gt("0"),
				"{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% CNI Request ADD Latency", "s",
			8, 8,
			t.track("ovnCNIAddLatencyP99",
				mg.Raw(`ovnkube_node_cni_request_duration_seconds{command="ADD"}`).
					BucketRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByInstance, mg.GroupByPod, mg.GroupByLE).
					HistogramQuantile(mg.P99).
					Gt("0"),
				"{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% CNI Request DEL Latency", "s",
			8, 8,
			t.track("ovnCNIDelLatencyP99",
				mg.Raw(`ovnkube_node_cni_request_duration_seconds{command="DEL"}`).
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
			t.track("kubeNodeInfo", mg.Raw("kube_node_info{}").Agg(mg.AggSum), "Number of nodes"),
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
					Agg(mg.AggSum, mg.GroupByPhase),
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
			promQuery(mg.Raw("kube_node_info{}").Agg(mg.AggSum).String(), "Number of nodes"),
			promQuery(
				mg.Q(mg.MetricKubeNodeStatusCondition, `status="true"`).
					Agg(mg.AggSum, mg.GroupByCondition).
					Gt("0").String(),
				"Node: {{ condition }}"),
		)).
		WithPanel(genericTimeSeries("Namespace count", "none",
			8, 8,
			promQuery(
				mg.Q(mg.MetricKubeNamespacePhase, "").
					Agg(mg.AggSum, mg.GroupByPhase).
					Gt("0").String(),
				"{{ phase }} namespaces"),
			promQuery(`kube_namespace_status_phase_sum_by_phase > 0`, "{{ phase }} namespaces"),
		)).
		WithPanel(genericTimeSeries("Pod count", "none",
			8, 8,
			promQuery(
				mg.Q(mg.MetricKubePodStatusPhase, "").
					Agg(mg.AggSum, mg.GroupByPhase).String(),
				"{{phase}} pods"),
			promQuery(`kube_pod_status_phase_sum_by_failed`, "Failed pods"),
			promQuery(`kube_pod_status_phase_sum_by_pending`, "Pending pods"),
			promQuery(`kube_pod_status_phase_sum_by_running`, "Running pods"),
			promQuery(`kube_pod_status_phase_sum_by_succeeded`, "Succeeded pods"),
			promQuery(`kube_pod_status_phase_sum_by_unknown`, "Unknown pods"),
		)).
		WithPanel(genericTimeSeries("Secret & configmap count", "none",
			8, 8,
			t.track("kubeSecretInfo", mg.Q(mg.MetricKubeSecretInfo, "").Agg(mg.AggCount), "secrets"),
			promQuery(`kube_secret_info_count`, "secrets"),
			t.track("kubeConfigmapInfo", mg.Q(mg.MetricKubeConfigmapInfo, "").Agg(mg.AggCount), "Configmaps"),
			promQuery(`kube_configmap_info_count`, "Configmaps"),
		)).
		WithPanel(genericTimeSeries("Deployment count", "none",
			8, 8,
			t.track("kubeDeploymentReplicas", mg.Raw("kube_deployment_spec_replicas{}").Agg(mg.AggCount), "Deployments"),
			promQuery(`kube_deployment_spec_paused_count`, "Deployments"),
		)).
		WithPanel(genericTimeSeries("Services count", "none",
			8, 8,
			t.track("kubeServiceInfo", mg.Q(mg.MetricKubeServiceInfo, "").Agg(mg.AggCount), "Services"),
			promQuery(`kube_service_info_count`, "Services"),
		)).
		WithPanel(genericTimeSeries("Routes count", "none",
			8, 8,
			t.track("openshiftRouteInfo", mg.Raw("openshift_route_info{}").Agg(mg.AggCount), "Routes"),
			promQuery(`openshift_route_info_count`, "Routes"),
		)).
		WithPanel(genericTimeSeries("Alerts", "none",
			8, 8,
			t.trackRaw("alerts", `topk(10,sum(ALERTS{severity!="none"}) by (alertname, severity))`, "{{severity}}: {{alertname}}"),
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
				"{{ namespace }} - {{ name }} - {{ node }}"),
			promQuery(`topk(10,container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ pod }} - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container RSS", "bytes",
			12, 8,
			t.track("containerMemoryRSSTop10",
				mg.Q(mg.MetricContainerMemoryRSS, `namespace!="",container!="POD",name!=""`).
					TopK(10),
				"{{ namespace }} - {{ name }} - {{ node }}"),
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
			t.trackRaw("goGoroutines", `topk(10, sum(go_goroutines{}) by (job,instance))`, "{{ job }} - {{ instance }}"),
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
				mg.Raw("node_disk_reads_completed_total{device=~\"$block_device\","+instanceFilter+"}").
					Rate(intervalVar),
				"{{ device }} - read"),
			t.track("nodeDiskWritesCompleted",
				mg.Raw("node_disk_writes_completed_total{device=~\"$block_device\","+instanceFilter+"}").
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
				mg.Raw("node_network_receive_packets_total{"+instanceFilter+`,device=~"$net_device"}`).
					Rate(intervalVar),
				"{{instance}} - {{device}} - RX"),
			t.track("nodeNetworkTxPackets",
				mg.Raw("node_network_transmit_packets_total{"+instanceFilter+`,device=~"$net_device"}`).
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
				mg.Raw("node_network_transmit_drop_total{"+instanceFilter+"}").
					Rate(intervalVar).TopK(10),
				"tx-drop-{{ device }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Conntrack stats: $"+nodeVar, "",
			12, 8,
			t.track("nodeConntrackEntries", mg.Q(mg.MetricNodeNFConntrackEntries, instanceFilter), "conntrack_entries"),
			t.track("nodeConntrackLimit", mg.Q(mg.MetricNodeNFConntrackEntriesLimit, instanceFilter), "conntrack_limit"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container CPU: $"+nodeVar, "percent",
			12, 8,
			promQuery(
				mg.Q(mg.MetricContainerCPU, `container!="POD",name!="",`+nodeFilter+`,namespace!="",namespace=~"$namespace"`).
					IRate(intervalVar).
					Agg(mg.AggSum, mg.GroupByPod, mg.GroupByContainer, mg.GroupByNamespace, mg.GroupByName, "service").
					Multiply("100").
					TopK(10).String(),
				"{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{`+nodeFilter+`,namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 container RSS: $"+nodeVar, "bytes",
			12, 8,
			promQuery(
				mg.Q(mg.MetricContainerMemoryRSS, `container!="POD",name!="",`+nodeFilter+`,namespace!="",namespace=~"$namespace"`).
					TopK(10).String(),
				"{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{`+nodeFilter+`,namespace=~"$namespace"})`, "{{pod}} - {{node}}"),
		))

	row = row.
		WithPanel(genericLegendTimeSeries("cgroup CPU: $"+nodeVar, "percent",
			12, 8,
			t.track("cgroupCPU",
				mg.Q(mg.MetricContainerCPU, cgroupIDFilter+", "+nodeFilter).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByID).
					Multiply("100"),
				"{{ id }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{`+nodeFilter+`}`, "{{ id }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("cgroup RSS: $"+nodeVar, "bytes",
			12, 8,
			t.track("cgroupRSS",
				mg.Q(mg.MetricContainerMemoryRSS, cgroupIDFilterWithJournald+", "+nodeFilter).
					Agg(mg.AggSum, mg.GroupByID),
				"{{ id }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{`+nodeFilter+`}`, "{{ id }}"),
		)).
		WithPanel(genericLegendTimeSeries("Pod fs rw rate: $"+nodeVar, "Bps",
			12, 8,
			t.track("podFSWrites",
				mg.Q(mg.MetricContainerFSWrites, fsWriteFilter+", "+nodeFilter+`, pod!=""`).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByPod),
				"{{ pod }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_container_sum_rate_pod_node_device{`+nodeFilter+`}`, "{{ pod }}: {{ device }} - write"),
			t.track("podFSReads",
				mg.Raw(`container_fs_reads_bytes_total{`+fsReadFilter+", "+nodeFilter+`, pod!=""}`).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByPod),
				"{{ pod }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_container_sum_rate_pod_node_device{`+nodeFilter+`}`, "{{ pod }}: {{ device }} - read"),
		)).
		WithPanel(genericLegendTimeSeries("cgroup fs rw rate: $"+nodeVar, "Bps",
			12, 8,
			t.track("cgroupFSWrites",
				mg.Q(mg.MetricContainerFSWrites, cgroupFSIDFilter+", "+nodeFilter).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByID),
				"{{ id }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_cgroup_sum_rate_id_node_device{`+nodeFilter+`}`, "{{ id }}: {{ device }} - write"),
			t.track("cgroupFSReads",
				mg.Raw(`container_fs_reads_bytes_total{`+cgroupFSIDFilter+", "+nodeFilter+`}`).
					Rate(intervalVar).
					Agg(mg.AggSum, mg.GroupByDevice, mg.GroupByID),
				"{{ id }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_cgroup_sum_rate_id_node_device{`+nodeFilter+`}`, "{{ id }}: {{ device }} - read"),
		))

	return row
}
