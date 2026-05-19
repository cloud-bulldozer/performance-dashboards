package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
)

func buildOCPPerformanceDashboard() *dashboard.DashboardBuilder {
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
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(kube_node_role{role="master"}, node)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("_worker_node").
			Label("Worker").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(kube_node_role{role=~"worker"}, node)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("_infra_node").
			Label("Infra").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(kube_node_role{role="infra"}, node)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Multi(true).
			IncludeAll(false),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("namespace").
			Label("Namespace").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{namespace!~"(cluster-density.*|node-density-.*)"},namespace)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex("").
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("block_device").
			Label("Block device").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(node_disk_written_bytes_total, device)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex(`/^(?:(?!dm|rb).)*$/`).
			Multi(true).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("net_device").
			Label("Network device").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(node_network_receive_bytes_total, device)`)}).
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
		WithRow(ocpClusterAtAGlanceRow()).
		// Row: OVN
		WithRow(ocpOVNRow()).
		// Row: Monitoring stack
		WithRow(ocpMonitoringStackRow()).
		// Row: Cluster Kubelet
		WithRow(ocpClusterKubeletRow()).
		// Row: Cluster Details
		WithRow(ocpClusterDetailsRow()).
		// Row: Cluster Operators Details
		WithRow(ocpClusterOperatorsDetailsRow()).
		// Row: Master
		WithRow(ocpMasterRow()).
		// Row: Worker
		WithRow(ocpWorkerRow()).
		// Row: Infra
		WithRow(ocpInfraRow()).
		// Row: Stackrox
		WithRow(ocpStackroxRow())
}


// Row: Cluster-at-a-Glance
func ocpClusterAtAGlanceRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster-at-a-Glance").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericLegendTimeSeries("Workers CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 2, W: 12, H: 8},
			promQuery(`sum( rate( (node_cpu_seconds_total{ mode != "idle" } * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") )[$interval:] ) ) by (instance) * 100`, "{{instance}}"),
			promQuery("node_cpu_seconds_sum_rate_2m_30s_worker", "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane CPU Usage", "percent",
			dashboard.GridPos{X: 12, Y: 2, W: 12, H: 8},
			promQuery(`sum( rate( (node_cpu_seconds_total{ mode != "idle" } * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") )[$interval:] ) ) by (instance) * 100`, "{{instance}}"),
			promQuery("node_cpu_seconds_sum_rate_2m_30s_master", "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Load1", "short",
			dashboard.GridPos{X: 0, Y: 9, W: 12, H: 8},
			promQuery(`node_load1 * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") `, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Load1", "short",
			dashboard.GridPos{X: 12, Y: 9, W: 12, H: 8},
			promQuery(`node_load1 * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") `, "{{instance}}"),
		)).
		WithPanel(genericLegendCounterSumRightHandTimeSeries("Workers Memory Available", "bytes",
			dashboard.GridPos{X: 0, Y: 17, W: 12, H: 8},
			promQuery(`node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)")`, "{{instance}}"),
			promQuery(`sum( node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") )`, "sum"),
		)).
		WithPanel(genericLegendCounterSumRightHandTimeSeries("Control Plane Memory Available", "bytes",
			dashboard.GridPos{X: 12, Y: 17, W: 12, H: 8},
			promQuery(`node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)")`, "{{instance}}"),
			promQuery(`sum( node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") )`, "sum"),
		)).
		WithPanel(genericLegendTimeSeries("Workers CGroup CPU Rate", "percent",
			dashboard.GridPos{X: 0, Y: 25, W: 12, H: 8},
			promQuery(`sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "worker" } )`, "{{id}}"),
			promQuery(`sum by (id) (container_cpu_usage_seconds_total_cgroup_sum_rate_id_node * on (node) group_left kube_node_role{ role = "worker" })`, "{{id}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane CGroup CPU Rate", "percent",
			dashboard.GridPos{X: 12, Y: 25, W: 12, H: 8},
			promQuery(`sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "control-plane" } )`, "{{id}}"),
			promQuery(`sum by (id) (container_cpu_usage_seconds_total_cgroup_sum_rate_id_node * on (node) group_left kube_node_role{ role = "control-plane" })`, "{{id}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers CGroup Memory RSS", "bytes",
			dashboard.GridPos{X: 0, Y: 33, W: 12, H: 8},
			promQuery(`sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "worker" } )`, "{{id}}"),
			promQuery(`sum by (id) (container_memory_working_set_bytes_cgroup * on (node) group_left kube_node_role{ role = "worker" })`, "{{id}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane CGroup Memory RSS", "bytes",
			dashboard.GridPos{X: 12, Y: 33, W: 12, H: 8},
			promQuery(`sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "control-plane" } )`, "{{id}}"),
			promQuery(`sum by (id) (container_memory_working_set_bytes_cgroup * on (node) group_left kube_node_role{ role = "control-plane" })`, "{{id}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers Container Threads", "short",
			dashboard.GridPos{X: 0, Y: 41, W: 12, H: 8},
			promQuery(`sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "worker" }`, "{{node}}"),
			promQuery("container_threads_sum_by_node_worker", "{{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane Container Threads", "short",
			dashboard.GridPos{X: 12, Y: 41, W: 12, H: 8},
			promQuery(`sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "control-plane" }`, "{{node}}"),
			promQuery("container_threads_sum_by_node_master", "{{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Disk IOPS", "short",
			dashboard.GridPos{X: 0, Y: 49, W: 12, H: 8},
			promQuery(`rate( (  node_disk_reads_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "worker" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - read"),
			promQuery(`rate( (  node_disk_writes_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "worker" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Disk IOPS", "short",
			dashboard.GridPos{X: 12, Y: 49, W: 12, H: 8},
			promQuery(`rate( (  node_disk_reads_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "control-plane" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - read"),
			promQuery(`rate( (  node_disk_writes_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "control-plane" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - write"),
		))
}

// Row: OVN
func ocpOVNRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("OVN").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericLegendTimeSeries("Top 10 ovnkube-controller CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 1, W: 12, H: 8},
			promQuery(`topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}[$interval])*100)  by (pod,node) )`, "{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 ovnkube-controller Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 1, W: 12, H: 8},
			promQuery(`topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}) by (pod,node))`, "{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 ovn-controller CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 8},
			promQuery(`topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}[$interval])*100)  by (pod,node) )`, "{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 ovn-controller Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 8},
			promQuery(`topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}) by (pod,node))`, "{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 nbdb CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 16, W: 12, H: 8},
			promQuery(`topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}[$interval])*100)  by (pod,node) )`, "{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 nbdb Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 16, W: 12, H: 8},
			promQuery(`topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}) by (pod,node))`, "{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 northd CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"}[$interval])*100)  by (pod,node) )`, "{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 northd Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="northd"}) by (pod,node))`, "{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 sbdb CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 32, W: 12, H: 8},
			promQuery(`topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}[$interval])*100)  by (pod,node) )`, "{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 sbdb Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 32, W: 12, H: 8},
			promQuery(`topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}) by (pod,node))`, "{{pod}} - {{node}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-master CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 40, W: 12, H: 8},
			promQuery(`irate(container_cpu_usage_seconds_total{id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"}[$interval])*100`, "OVS CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"}`, "OVS CPU - {{ node }}"),
			promQuery(`irate(container_cpu_usage_seconds_total{id=~"/.*/ovsdb-server.service", node=~"$_master_node"}[$interval])*100`, "OVS DB CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovsdb-server.service", node=~"$_master_node"}`, "OVS DB CPU - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-master Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 40, W: 12, H: 8},
			promQuery(`container_memory_rss{id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"}`, "OVS Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovs-vswitchd.service", node=~"$_master_node"}`, "OVS Memory - {{ node }}"),
			promQuery(`container_memory_rss{id=~"/.*/ovsdb-server.service", node=~"$_master_node"}`, "OVS DB Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovsdb-server.service", node=~"$_master_node"}`, "OVS DB Memory - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-worker CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 48, W: 12, H: 8},
			promQuery(`irate(container_cpu_usage_seconds_total{id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"}[$interval])*100`, "OVS CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"}`, "OVS CPU - {{ node }}"),
			promQuery(`irate(container_cpu_usage_seconds_total{id=~"/.*/ovsdb-server.service", node=~"$_worker_node"}[$interval])*100`, "OVS DB CPU - {{ node }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{id=~"/.*/ovsdb-server.service", node=~"$_worker_node"}`, "OVS DB CPU - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovs-worker Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 48, W: 12, H: 8},
			promQuery(`container_memory_rss{id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"}`, "OVS Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovs-vswitchd.service", node=~"$_worker_node"}`, "OVS Memory - {{ node }}"),
			promQuery(`container_memory_rss{id=~"/.*/ovsdb-server.service", node=~"$_worker_node"}`, "OVS DB Memory - {{ node }}"),
			promQuery(`container_memory_rss_cgroup{id=~"/.*/ovsdb-server.service", node=~"$_worker_node"}`, "OVS DB Memory - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% Pod Annotation Latency", "s",
			dashboard.GridPos{X: 0, Y: 56, W: 8, H: 8},
			promQuery(`histogram_quantile(0.99, sum by (instance, pod, le) (rate(ovnkube_controller_pod_creation_latency_seconds_bucket[$interval]))) > 0`, "{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% CNI Request ADD Latency", "s",
			dashboard.GridPos{X: 8, Y: 56, W: 8, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="ADD"}[$interval])) by (instance,pod,le)) > 0`, "{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("99% CNI Request DEL Latency", "s",
			dashboard.GridPos{X: 16, Y: 56, W: 8, H: 8},
			promQuery(`histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="DEL"}[$interval])) by (instance,pod,le)) > 0`, "{{ pod }} - {{ instance }}"),
		)).
		WithPanel(genericLegendTimeSeries("ovnkube-control-plane CPU Usage", "percent",
			dashboard.GridPos{X: 0, Y: 64, W: 12, H: 8},
			promQuery(`sum( irate(container_cpu_usage_seconds_total{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}[$interval])*100 ) by (pod, node)`, "{{pod}} - {{node}}"),
			promQuery(`sum(container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes"}) by (pod, node)`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("ovnkube-control-plane Memory Usage", "bytes",
			dashboard.GridPos{X: 12, Y: 64, W: 12, H: 8},
			promQuery(`sum(container_memory_rss{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}) by (pod,node)`, "{{pod}} - {{node}}"),
			promQuery(`sum(container_memory_working_set_bytes_container{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes"}) by (pod,node)`, "{{pod}} - {{node}}"),
		))
}

// Row: Monitoring stack
func ocpMonitoringStackRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Monitoring stack").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericLegendTimeSeries("Prometheus Replica CPU", "percent",
			dashboard.GridPos{X: 0, Y: 2, W: 12, H: 8},
			promQuery(`sum(irate(container_cpu_usage_seconds_total{pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"}[$interval])) by (pod,container,node) * 100`, "{{pod}} - {{node}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"}`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Prometheus Replica RSS", "bytes",
			dashboard.GridPos{X: 12, Y: 2, W: 12, H: 8},
			promQuery(`sum(container_memory_rss{pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"}) by (pod)`, "{{pod}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"prometheus-k8s-[01]",namespace!="",name!="",container="prometheus"}`, "{{pod}}"),
		)).
		WithPanel(genericLegendTimeSeries("metrics-server/prom-adapter CPU", "percent",
			dashboard.GridPos{X: 0, Y: 10, W: 12, H: 8},
			promQuery(`sum(irate(container_cpu_usage_seconds_total{pod=~"metrics-server-.*",namespace!="",name!=""}[$interval])) by (pod,container) * 100`, "{{pod}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"metrics-server-.*",namespace!="",name!=""}`, "{{pod}}"),
			promQuery(`sum(irate(container_cpu_usage_seconds_total{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}[$interval])) by (pod,container) * 100`, "{{pod}}"),
			promQuery(`container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}`, "{{pod}}"),
		)).
		WithPanel(genericLegendTimeSeries("metrics-server/prom-adapter RSS", "bytes",
			dashboard.GridPos{X: 12, Y: 10, W: 12, H: 8},
			promQuery(`sum(container_memory_rss{pod=~"metrics-server-.*",namespace!="",name!=""}) by (pod)`, "{{pod}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"metrics-server-.*",namespace!="",name!=""}`, "{{pod}}"),
			promQuery(`sum(container_memory_rss{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}) by (pod)`, "{{pod}}"),
			promQuery(`container_memory_working_set_bytes_container{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}`, "{{pod}}"),
		))
}

// Row: Stackrox
func ocpStackroxRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Stackrox").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericLegendTimeSeries("Top 25 stackrox container RSS bytes", "bytes",
			dashboard.GridPos{X: 0, Y: 2, W: 12, H: 8},
			promQuery(`topk(25, container_memory_rss{container!="POD",name!="",namespace!="",namespace=~"stackrox"})`, "{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 25 stackrox container CPU percent", "percent",
			dashboard.GridPos{X: 12, Y: 2, W: 12, H: 8},
			promQuery(`topk(25, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",namespace!="",namespace=~"stackrox"}[$interval])) by (pod,container,namespace,name,service) * 100)`, "{{ pod }}: {{ container }}"),
		))
}

// Row: Cluster Kubelet
func ocpClusterKubeletRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Kubelet").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericLegendTimeSeries("Top 10 Kubelet CPU usage", "percent",
			dashboard.GridPos{X: 0, Y: 3, W: 12, H: 8},
			promQuery(`topk(10,irate(process_cpu_seconds_total{service="kubelet",job="kubelet"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })`, "kubelet - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 crio CPU usage", "percent",
			dashboard.GridPos{X: 12, Y: 3, W: 12, H: 8},
			promQuery(`topk(10,irate(process_cpu_seconds_total{service="kubelet",job="crio"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })`, "crio - {{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 Kubelet memory usage", "bytes",
			dashboard.GridPos{X: 0, Y: 11, W: 12, H: 8},
			promQuery(`topk(10,process_resident_memory_bytes{service="kubelet",job="kubelet"} *  on (node) group_left kube_node_role{ role = "worker" })`, "kubelet - {{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 crio memory usage", "bytes",
			dashboard.GridPos{X: 12, Y: 11, W: 12, H: 8},
			promQuery(`topk(10,process_resident_memory_bytes{service="kubelet",job="crio"} *  on (node) group_left kube_node_role{ role = "worker" })`, "crio - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("inodes usage in /run", "percent",
			dashboard.GridPos{X: 0, Y: 19, W: 12, H: 8},
			promQuery(`(1 - node_filesystem_files_free{fstype!="",mountpoint="/run"} / node_filesystem_files{fstype!="",mountpoint="/run"}) * 100`, "{{instance}}"),
		)).
		WithPanel(genericLegendCounterSumRightHandTimeSeries("inodes count in /run", "none",
			dashboard.GridPos{X: 12, Y: 19, W: 12, H: 8},
			promQuery(`node_filesystem_files{fstype!="",mountpoint="/run"} - node_filesystem_files_free{fstype!="",mountpoint="/run"}`, "{{instance}}"),
			promQuery(`sum(node_filesystem_files{fstype!="",mountpoint="/run"} - node_filesystem_files_free{fstype!="",mountpoint="/run"})`, "sum"),
		))
}

// Row: Cluster Details
func ocpClusterDetailsRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Details").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericStat("Current Node Count",
			dashboard.GridPos{X: 0, Y: 4, W: 8, H: 3},
			promQuery(`sum(kube_node_info{})`, "Number of nodes"),
			promQuery(`sum(kube_node_status_condition{status="true"}) by (condition) > 0`, "Node: {{ condition }}"),
		)).
		WithPanel(genericStat("Current Namespace Count",
			dashboard.GridPos{X: 8, Y: 4, W: 8, H: 3},
			promQuery(`sum(kube_namespace_status_phase) by (phase)`, "{{ phase }}"),
			promQuery(`kube_namespace_status_phase_sum_by_phase`, "{{ phase }}"),
		)).
		WithPanel(genericStat("Current Pod Count",
			dashboard.GridPos{X: 16, Y: 4, W: 8, H: 3},
			promQuery(`sum(kube_pod_status_phase{}) by (phase) > 0`, "{{ phase}} Pods"),
			promQuery(`sum(kube_pod_info_by_node)`, "{{ phase}} Pods"),
		)).
		WithPanel(genericTimeSeries("Number of nodes", "none",
			dashboard.GridPos{X: 0, Y: 12, W: 8, H: 8},
			promQuery(`sum(kube_node_info{})`, "Number of nodes"),
			promQuery(`sum(kube_node_status_condition{status="true"}) by (condition) > 0`, "Node: {{ condition }}"),
		)).
		WithPanel(genericTimeSeries("Namespace count", "none",
			dashboard.GridPos{X: 8, Y: 12, W: 8, H: 8},
			promQuery(`sum(kube_namespace_status_phase) by (phase) > 0`, "{{ phase }} namespaces"),
			promQuery(`kube_namespace_status_phase_sum_by_phase > 0`, "{{ phase }} namespaces"),
		)).
		WithPanel(genericTimeSeries("Pod count", "none",
			dashboard.GridPos{X: 16, Y: 12, W: 8, H: 8},
			promQuery(`sum(kube_pod_status_phase{}) by (phase)`, "{{phase}} pods"),
			promQuery(`kube_pod_status_phase_sum_by_failed`, "Failed pods"),
			promQuery(`kube_pod_status_phase_sum_by_pending`, "Pending pods"),
			promQuery(`kube_pod_status_phase_sum_by_running`, "Running pods"),
			promQuery(`kube_pod_status_phase_sum_by_succeeded`, "Succeeded pods"),
			promQuery(`kube_pod_status_phase_sum_by_unknown`, "Unknown pods"),
		)).
		WithPanel(genericTimeSeries("Secret & configmap count", "none",
			dashboard.GridPos{X: 0, Y: 20, W: 8, H: 8},
			promQuery(`count(kube_secret_info{})`, "secrets"),
			promQuery(`kube_secret_info_count`, "secrets"),
			promQuery(`count(kube_configmap_info{})`, "Configmaps"),
			promQuery(`kube_configmap_info_count`, "Configmaps"),
		)).
		WithPanel(genericTimeSeries("Deployment count", "none",
			dashboard.GridPos{X: 8, Y: 20, W: 8, H: 8},
			promQuery(`count(kube_deployment_spec_replicas{})`, "Deployments"),
			promQuery(`kube_deployment_spec_paused_count`, "Deployments"),
		)).
		WithPanel(genericTimeSeries("Services count", "none",
			dashboard.GridPos{X: 16, Y: 20, W: 8, H: 8},
			promQuery(`count(kube_service_info{})`, "Services"),
			promQuery(`kube_service_info_count`, "Services"),
		)).
		WithPanel(genericTimeSeries("Routes count", "none",
			dashboard.GridPos{X: 0, Y: 20, W: 8, H: 8},
			promQuery(`count(openshift_route_info{})`, "Routes"),
			promQuery(`openshift_route_info_count`, "Routes"),
		)).
		WithPanel(genericTimeSeries("Alerts", "none",
			dashboard.GridPos{X: 8, Y: 20, W: 8, H: 8},
			promQuery(`topk(10,sum(ALERTS{severity!="none"}) by (alertname, severity))`, "{{severity}}: {{alertname}}"),
		)).
		WithPanel(genericLegendTimeSeries("Pod Distribution", "none",
			dashboard.GridPos{X: 16, Y: 20, W: 8, H: 8},
			promQuery(`count(kube_pod_info{}) by (node)`, "{{ node }}"),
			promQuery(`kube_pod_info_by_node`, "{{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container CPU", "percent",
			dashboard.GridPos{X: 0, Y: 28, W: 12, H: 8},
			promQuery(`topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[$interval])*100)`, "{{ namespace }} - {{ pod }} - {{ node }}"),
			promQuery(`topk(10,container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ pod }} - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container RSS", "bytes",
			dashboard.GridPos{X: 12, Y: 28, W: 12, H: 8},
			promQuery(`topk(10, container_memory_rss{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ pod }} - {{ node }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ pod }} - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("container RSS system.slice", "bytes",
			dashboard.GridPos{X: 12, Y: 36, W: 12, H: 8},
			promQuery(`sum by (node)(container_memory_rss{id="/system.slice"})`, "system.slice - {{ node }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{id="/system.slice"}`, "system.slice - {{ node }}"),
		)).
		WithPanel(genericTimeSeries("Goroutines count", "none",
			dashboard.GridPos{X: 0, Y: 36, W: 12, H: 8},
			promQuery(`topk(10, sum(go_goroutines{}) by (job,instance))`, "{{ job }} - {{ instance }}"),
		))
}

// Row: Cluster Operators Details
func ocpClusterOperatorsDetailsRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Operators Details").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 1}).
		WithPanel(genericStat("Cluster operators overview",
			dashboard.GridPos{X: 0, Y: 4, W: 24, H: 3},
			promQuery(`sum by (condition)(cluster_operator_conditions{condition!=""})`, "{{ condition }}"),
		)).
		WithPanel(genericLegendTimeSeries("Cluster operators information", "none",
			dashboard.GridPos{X: 0, Y: 4, W: 8, H: 8},
			promQuery(`cluster_operator_conditions{name!="",reason!=""}`, "{{name}} - {{reason}}"),
		)).
		WithPanel(genericLegendTimeSeries("Cluster operators degraded", "none",
			dashboard.GridPos{X: 8, Y: 4, W: 8, H: 8},
			promQuery(`cluster_operator_conditions{condition="Degraded",name!="",reason!=""}`, "{{name}} - {{reason}}"),
		))
}

// Row: Master (repeats on _master_node)
func ocpMasterRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Master: $_master_node").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 8}).
		Repeat("_master_node").
		WithPanel(genericLegendTimeSeries("CPU Basic: $_master_node", "percent",
			dashboard.GridPos{X: 0, Y: 1, W: 12, H: 8},
			promQuery(`sum by (instance, mode)(irate(node_cpu_seconds_total{instance=~"$_master_node",job=~".*"}[$interval])) * 100`, "Busy {{mode}}"),
			promQuery(`node_cpu_seconds_sum_rate_2m_30s_instance_mode_node_panel{instance=~"$_master_node"}`, "Busy {{mode}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("System Memory: $_master_node", "bytes",
			dashboard.GridPos{X: 12, Y: 1, W: 12, H: 8},
			promQuery(`node_memory_Active_bytes{instance=~"$_master_node"}`, "Active"),
			promQuery(`node_memory_MemTotal_bytes{instance=~"$_master_node"}`, "Total"),
			promQuery(`node_memory_Cached_bytes{instance=~"$_master_node"} + node_memory_Buffers_bytes{instance=~"$_master_node"}`, "Cached + Buffers"),
			promQuery(`node_memory_MemAvailable_bytes{instance=~"$_master_node"}`, "Available"),
			promQuery(`(node_memory_MemTotal_bytes{instance=~"$_master_node"} - (node_memory_MemFree_bytes{instance=~"$_master_node"} + node_memory_Buffers_bytes{instance=~"$_master_node"} +  node_memory_Cached_bytes{instance=~"$_master_node"}))`, "Used"),
		)).
		WithPanel(genericLegendTimeSeries("Disk throughput: $_master_node", "Bps",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 8},
			promQuery(`rate(node_disk_read_bytes_total{device=~"$block_device",instance=~"$_master_node"}[$interval])`, "{{ device }} - read"),
			promQuery(`rate(node_disk_written_bytes_total{device=~"$block_device",instance=~"$_master_node"}[$interval])`, "{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Disk IOPS: $_master_node", "iops",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 8},
			promQuery(`rate(node_disk_reads_completed_total{device=~"$block_device",instance=~"$_master_node"}[$interval])`, "{{ device }} - read"),
			promQuery(`rate(node_disk_writes_completed_total{device=~"$block_device",instance=~"$_master_node"}[$interval])`, "{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Network Utilization: $_master_node", "bps",
			dashboard.GridPos{X: 0, Y: 16, W: 12, H: 8},
			promQuery(`rate(node_network_receive_bytes_total{instance=~"$_master_node",device=~"$net_device"}[$interval]) * 8`, "{{instance}} - {{device}} - RX"),
			promQuery(`rate(node_network_transmit_bytes_total{instance=~"$_master_node",device=~"$net_device"}[$interval]) * 8`, "{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network Packets: $_master_node", "pps",
			dashboard.GridPos{X: 12, Y: 16, W: 12, H: 8},
			promQuery(`rate(node_network_receive_packets_total{instance=~"$_master_node",device=~"$net_device"}[$interval])`, "{{instance}} - {{device}} - RX"),
			promQuery(`rate(node_network_transmit_packets_total{instance=~"$_master_node",device=~"$net_device"}[$interval])`, "{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network packets drop: $_master_node", "pps",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, rate(node_network_receive_drop_total{instance=~"$_master_node"}[$interval]))`, "rx-drop-{{ device }}"),
			promQuery(`topk(10,rate(node_network_transmit_drop_total{instance=~"$_master_node"}[$interval]))`, "tx-drop-{{ device }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Conntrack stats: $_master_node", "",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`node_nf_conntrack_entries{instance=~"$_master_node"}`, "conntrack_entries"),
			promQuery(`node_nf_conntrack_entries_limit{instance=~"$_master_node"}`, "conntrack_limit"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container CPU: $_master_node", "percent",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",node=~"$_master_node",namespace!="",namespace=~"$namespace"}[$interval])) by (pod,container,namespace,name,service) * 100)`, "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{node=~"$_master_node",namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 container RSS: $_master_node", "bytes",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, container_memory_rss{container!="POD",name!="",node=~"$_master_node",namespace!="",namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{node=~"$_master_node",namespace=~"$namespace"})`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("cgroup CPU: $_master_node", "percent",
			dashboard.GridPos{X: 0, Y: 32, W: 12, H: 8},
			promQuery(`sum by (id) ( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice", node=~"$_master_node"}[$interval])) * 100`, "{{ id }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{node=~"$_master_node"}`, "{{ id }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("cgroup RSS: $_master_node", "bytes",
			dashboard.GridPos{X: 12, Y: 32, W: 12, H: 8},
			promQuery(`sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/.*.service|/system.slice/systemd-udevd.service|/kubepods.slice", node=~"$_master_node"})`, "{{ id }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{node=~"$_master_node"}`, "{{ id }}"),
		)).
		WithPanel(genericLegendTimeSeries("Pod fs rw rate: $_master_node", "Bps",
			dashboard.GridPos{X: 0, Y: 32, W: 12, H: 8},
			promQuery(`sum(rate(container_fs_writes_bytes_total{device!~".+dm.+", node=~"$_master_node", pod!=""}[$interval])) by (device, pod)`, "{{ pod }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_container_sum_rate_pod_node_device{node=~"$_master_node"}`, "{{ pod }}: {{ device }} - write"),
			promQuery(`sum(rate(container_fs_reads_bytes_total{device!~".+dm.+", node=~"$_master_node", pod!=""}[$interval])) by (device, pod)`, "{{ pod }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_container_sum_rate_pod_node_device{node=~"$_master_node"}`, "{{ pod }}: {{ device }} - read"),
		)).
		WithPanel(genericLegendTimeSeries("cgroup fs rw rate: $_master_node", "Bps",
			dashboard.GridPos{X: 12, Y: 32, W: 12, H: 8},
			promQuery(`sum(rate(container_fs_writes_bytes_total{device!~".+dm.+", node=~"$_master_node", id =~"/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) by (device, id)`, "{{ id }}: {{ device }} - write"),
			promQuery(`container_fs_writes_bytes_total_cgroup_sum_rate_id_node_device{node=~"$_master_node"}`, "{{ id }}: {{ device }} - write"),
			promQuery(`sum(rate(container_fs_reads_bytes_total{device!~".+dm.+", node=~"$_master_node", id =~"/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) by (device, id)`, "{{ id }}: {{ device }} - read"),
			promQuery(`container_fs_reads_bytes_total_cgroup_sum_rate_id_node_device{node=~"$_master_node"}`, "{{ id }}: {{ device }} - read"),
		))
}

// Row: Worker (repeats on _worker_node)
func ocpWorkerRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Worker: $_worker_node").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 8}).
		Repeat("_worker_node").
		WithPanel(genericLegendTimeSeries("CPU Basic: $_worker_node", "percent",
			dashboard.GridPos{X: 0, Y: 1, W: 12, H: 8},
			promQuery(`sum by (instance, mode)(irate(node_cpu_seconds_total{instance=~"$_worker_node",job=~".*"}[$interval])) * 100`, "Busy {{mode}}"),
			promQuery(`node_cpu_seconds_sum_rate_2m_30s_instance_mode_node_panel{instance=~"$_worker_node",job=~".*"}`, "Busy {{mode}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("System Memory: $_worker_node", "bytes",
			dashboard.GridPos{X: 12, Y: 1, W: 12, H: 8},
			promQuery(`node_memory_Active_bytes{instance=~"$_worker_node"}`, "Active"),
			promQuery(`node_memory_MemTotal_bytes{instance=~"$_worker_node"}`, "Total"),
			promQuery(`node_memory_Cached_bytes{instance=~"$_worker_node"} + node_memory_Buffers_bytes{instance=~"$_worker_node"}`, "Cached + Buffers"),
			promQuery(`node_memory_MemAvailable_bytes{instance=~"$_worker_node"}`, "Available"),
			promQuery(`(node_memory_MemTotal_bytes{instance=~"$_worker_node"} - (node_memory_MemFree_bytes{instance=~"$_worker_node"} + node_memory_Buffers_bytes{instance=~"$_worker_node"} +  node_memory_Cached_bytes{instance=~"$_worker_node"}))`, "Used"),
		)).
		WithPanel(genericLegendTimeSeries("Disk throughput: $_worker_node", "Bps",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 8},
			promQuery(`rate(node_disk_read_bytes_total{device=~"$block_device",instance=~"$_worker_node"}[$interval])`, "{{ device }} - read"),
			promQuery(`rate(node_disk_written_bytes_total{device=~"$block_device",instance=~"$_worker_node"}[$interval])`, "{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Disk IOPS: $_worker_node", "iops",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 8},
			promQuery(`rate(node_disk_reads_completed_total{device=~"$block_device",instance=~"$_worker_node"}[$interval])`, "{{ device }} - read"),
			promQuery(`rate(node_disk_writes_completed_total{device=~"$block_device",instance=~"$_worker_node"}[$interval])`, "{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Network Utilization: $_worker_node", "bps",
			dashboard.GridPos{X: 0, Y: 16, W: 12, H: 8},
			promQuery(`rate(node_network_receive_bytes_total{instance=~"$_worker_node",device=~"$net_device"}[$interval]) * 8`, "{{instance}} - {{device}} - RX"),
			promQuery(`rate(node_network_transmit_bytes_total{instance=~"$_worker_node",device=~"$net_device"}[$interval]) * 8`, "{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network Packets: $_worker_node", "pps",
			dashboard.GridPos{X: 12, Y: 16, W: 12, H: 8},
			promQuery(`rate(node_network_receive_packets_total{instance=~"$_worker_node",device=~"$net_device"}[$interval])`, "{{instance}} - {{device}} - RX"),
			promQuery(`rate(node_network_transmit_packets_total{instance=~"$_worker_node",device=~"$net_device"}[$interval])`, "{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network packets drop: $_worker_node", "pps",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, rate(node_network_receive_drop_total{instance=~"$_worker_node"}[$interval]))`, "rx-drop-{{ device }}"),
			promQuery(`topk(10,rate(node_network_transmit_drop_total{instance=~"$_worker_node"}[$interval]))`, "tx-drop-{{ device }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Conntrack stats: $_worker_node", "",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`node_nf_conntrack_entries{instance=~"$_worker_node"}`, "conntrack_entries"),
			promQuery(`node_nf_conntrack_entries_limit{instance=~"$_worker_node"}`, "conntrack_limit"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container CPU: $_worker_node", "percent",
			dashboard.GridPos{X: 0, Y: 32, W: 12, H: 8},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",node=~"$_worker_node",namespace!="",namespace=~"$namespace"}[$interval])) by (pod,container,namespace,name,service) * 100)`, "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{node=~"$_worker_node",namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 container RSS: $_worker_node", "bytes",
			dashboard.GridPos{X: 12, Y: 32, W: 12, H: 8},
			promQuery(`topk(10, container_memory_rss{container!="POD",name!="",node=~"$_worker_node",namespace!="",namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{node=~"$_worker_node",namespace=~"$namespace"})`, "{{pod}} - {{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("cgroup CPU: $_worker_node", "percent",
			dashboard.GridPos{X: 0, Y: 40, W: 12, H: 8},
			promQuery(`sum by (id) ( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice", node=~"$_worker_node"}[$interval])) * 100`, "{{ id }}"),
			promQuery(`container_cpu_usage_seconds_total_cgroup_sum_rate_id_node{node=~"$_worker_node"}`, "{{ id }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("cgroup RSS: $_worker_node", "bytes",
			dashboard.GridPos{X: 12, Y: 40, W: 12, H: 8},
			promQuery(`sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/.*.service|/system.slice/systemd-udevd.service|/kubepods.slice", node=~"$_worker_node"})`, "{{ id }}"),
			promQuery(`container_memory_working_set_bytes_cgroup{node=~"$_worker_node"}`, "{{ id }}"),
		))
}

// Row: Infra (repeats on _infra_node)
func ocpInfraRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Infra: $_infra_node").
		Collapsed(true).
		GridPos(dashboard.GridPos{X: 0, Y: 0, W: 24, H: 8}).
		Repeat("_infra_node").
		WithPanel(genericLegendTimeSeries("CPU Basic: $_infra_node", "percent",
			dashboard.GridPos{X: 0, Y: 1, W: 12, H: 8},
			promQuery(`sum by (instance, mode)(irate(node_cpu_seconds_total{instance=~"$_infra_node",job=~".*"}[$interval])) * 100`, "Busy {{mode}}"),
			promQuery(`node_cpu_seconds_sum_rate_2m_30s_instance_mode_node_panel{instance=~"$_infra_node",job=~".*"}`, "Busy {{mode}}"),
		)).
		WithPanel(genericLegendTimeSeries("System Memory: $_infra_node", "bytes",
			dashboard.GridPos{X: 12, Y: 1, W: 12, H: 8},
			promQuery(`node_memory_Active_bytes{instance=~"$_infra_node"}`, "Active"),
			promQuery(`node_memory_MemTotal_bytes{instance=~"$_infra_node"}`, "Total"),
			promQuery(`node_memory_Cached_bytes{instance=~"$_infra_node"} + node_memory_Buffers_bytes{instance=~"$_infra_node"}`, "Cached + Buffers"),
			promQuery(`node_memory_MemAvailable_bytes{instance=~"$_infra_node"}`, "Available"),
			promQuery(`(node_memory_MemTotal_bytes{instance=~"$_infra_node"} - (node_memory_MemFree_bytes{instance=~"$_infra_node"} + node_memory_Buffers_bytes{instance=~"$_infra_node"} +  node_memory_Cached_bytes{instance=~"$_infra_node"}))`, "Used"),
		)).
		WithPanel(genericLegendTimeSeries("Disk throughput: $_infra_node", "Bps",
			dashboard.GridPos{X: 0, Y: 8, W: 12, H: 8},
			promQuery(`rate(node_disk_read_bytes_total{device=~"$block_device",instance=~"$_infra_node"}[$interval])`, "{{ device }} - read"),
			promQuery(`rate(node_disk_written_bytes_total{device=~"$block_device",instance=~"$_infra_node"}[$interval])`, "{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Disk IOPS: $_infra_node", "iops",
			dashboard.GridPos{X: 12, Y: 8, W: 12, H: 8},
			promQuery(`rate(node_disk_reads_completed_total{device=~"$block_device",instance=~"$_infra_node"}[$interval])`, "{{ device }} - read"),
			promQuery(`rate(node_disk_writes_completed_total{device=~"$block_device",instance=~"$_infra_node"}[$interval])`, "{{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Network Utilization: $_infra_node", "bps",
			dashboard.GridPos{X: 0, Y: 16, W: 12, H: 8},
			promQuery(`rate(node_network_receive_bytes_total{instance=~"$_infra_node",device=~"$net_device"}[$interval]) * 8`, "{{instance}} - {{device}} - RX"),
			promQuery(`rate(node_network_transmit_bytes_total{instance=~"$_infra_node",device=~"$net_device"}[$interval]) * 8`, "{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network Packets: $_infra_node", "pps",
			dashboard.GridPos{X: 12, Y: 16, W: 12, H: 8},
			promQuery(`rate(node_network_receive_packets_total{instance=~"$_infra_node",device=~"$net_device"}[$interval])`, "{{instance}} - {{device}} - RX"),
			promQuery(`rate(node_network_transmit_packets_total{instance=~"$_infra_node",device=~"$net_device"}[$interval])`, "{{instance}} - {{device}} - TX"),
		)).
		WithPanel(genericLegendTimeSeries("Network packets drop: $_infra_node", "pps",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, rate(node_network_receive_drop_total{instance=~"$_infra_node"}[$interval]))`, "rx-drop-{{ device }}"),
			promQuery(`topk(10,rate(node_network_transmit_drop_total{instance=~"$_infra_node"}[$interval]))`, "tx-drop-{{ device }}"),
		)).
		WithPanel(genericLegendTimeSeries("Conntrack stats: $_infra_node", "",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`node_nf_conntrack_entries{instance=~"$_infra_node"}`, "conntrack_entries"),
			promQuery(`node_nf_conntrack_entries_limit{instance=~"$_infra_node"}`, "conntrack_limit"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container CPU: $_infra_node", "percent",
			dashboard.GridPos{X: 0, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",node=~"$_infra_node",namespace!="",namespace=~"$namespace"}[$interval])) by (pod,container,namespace,name,service) * 100)`, "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_cpu_usage_seconds_total_container_sum_rate_pod_node_container_namespace_name{node=~"$_infra_node",namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 container RSS: $_infra_node", "bytes",
			dashboard.GridPos{X: 12, Y: 24, W: 12, H: 8},
			promQuery(`topk(10, container_memory_rss{container!="POD",name!="",node=~"$_infra_node",namespace!="",namespace=~"$namespace"})`, "{{ pod }}: {{ container }}"),
			promQuery(`topk(10, container_memory_working_set_bytes_container{node=~"$_infra_node",namespace=~"$namespace"})`, "{{pod}} - {{node}}"),
		))
}
