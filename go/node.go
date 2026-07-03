package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
)

func buildNodeDashboard() *dashboard.DashboardBuilder {
	return dashboard.NewDashboardBuilder("Node Performance").
		Description("Node Performance dashboard for Red Hat Openshift\n").
		Tags([]string{}).
		Time("now-1h", "now").
		Timezone("utc").
		Timepicker(dashboard.NewTimePickerBuilder().
			RefreshIntervals([]string{"5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"}),
		).
		Refresh("").
		Tooltip(dashboard.DashboardCursorSyncCrosshair).
		WithVariable(dashboard.NewDatasourceVariableBuilder("Datasource").
			Type("prometheus").
			Label("Datasource"),
		).
		WithVariable(dashboard.NewQueryVariableBuilder("namespace").
			Label("Namespace").
			Query(dashboard.StringOrMap{String: cog.ToPtr(`label_values(kube_pod_info{namespace!="(cluster-density.*|node-density-.*)"},namespace)`)}).
			Datasource(promDatasourceRef()).
			Refresh(dashboard.VariableRefreshOnTimeRangeChanged).
			Regex("").
			Multi(false).
			IncludeAll(true),
		).
		WithVariable(dashboard.NewIntervalVariableBuilder("interval").
			Label("interval").
			Values(dashboard.StringOrMap{String: cog.ToPtr("5m,2m,1m")}).
			Current(intervalOption("5m")).
			Options([]dashboard.VariableOption{
				intervalOption("5m"),
				intervalOption("2m"),
				intervalOption("1m"),
			}),
		).
		WithRow(nodeResourceRow()).
		WithRow(nodeCgroupResourceRow()).
		WithRow(nodeClusterWorkloadRow()).
		WithRow(nodeTopUsageRow()).
		WithRow(nodeKubeletOperationRow()).
		WithRow(nodeP99KubeletCgroupRow()).
		WithRow(nodeKubeletResourceUsageRow()).
		WithRow(nodeKubeletHTTPRow()).
		WithRow(nodeCRIOOperationRow()).
		WithRow(nodeCRIOResourceUsageRow()).
		WithRow(nodeINodesRow()).
		WithRow(nodePLEGRow()).
		WithRow(nodePSIContainersRow()).
		WithRow(nodePSINodesRow())
}

func nodeResourceRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Node Resource").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Workers CPU Usage", "percent",
			12, 8,
			promQuery(`sum( rate( (node_cpu_seconds_total{ mode != "idle" } * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") )[$interval:] ) ) by (instance) * 100`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane CPU Usage", "percent",
			12, 8,
			promQuery(`sum( rate( (node_cpu_seconds_total{ mode != "idle" } * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") )[$interval:] ) ) by (instance) * 100`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Load1", "short",
			12, 8,
			promQuery(`node_load1 * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") `, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Load1", "short",
			12, 8,
			promQuery(`node_load1 * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") `, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Memory Available", "bytes",
			12, 8,
			promQuery(`node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)")`, "{{instance}}"),
			promQuery(`sum( node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") )`, "sum"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Memory Available", "bytes",
			12, 8,
			promQuery(`node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)")`, "{{instance}}"),
			promQuery(`sum( node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") )`, "sum"),
		)).
		WithPanel(genericLegendTimeSeries("Workers Disk IOPS", "short",
			12, 8,
			promQuery(`rate( (  node_disk_reads_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "worker" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - read"),
			promQuery(`rate( (  node_disk_writes_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "worker" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - write"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane Disk IOPS", "short",
			12, 8,
			promQuery(`rate( (  node_disk_reads_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "control-plane" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - read"),
			promQuery(`rate( (  node_disk_writes_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "control-plane" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])`, "{{instance}} - {{ device }} - write"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers Container Threads", "short",
			12, 8,
			promQuery(`sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "worker" }`, "{{instance}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane Container Threads", "short",
			12, 8,
			promQuery(`sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "control-plane" }`, "{{instance}}"),
		))
}

func nodeCgroupResourceRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cgroup Resource").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Workers CGroup CPU(% of 1 core)", "short",
			12, 8,
			promQuery(`sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "worker" } )`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Control Plane CGroup CPU(% of 1 core)", "short",
			12, 8,
			promQuery(`sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "control-plane" } )`, "{{instance}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers CGroup Memory Working Set", "bytes",
			12, 8,
			promQuery(`sum by (id) (container_memory_working_set_bytes{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "worker" } )`, "{{instance}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane CGroup Memory Working Set", "bytes",
			12, 8,
			promQuery(`sum by (id) (container_memory_working_set_bytes{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "control-plane" } )`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("system.slice Working Set by node", "bytes",
			12, 8,
			promQuery(`sum by (node)(container_memory_working_set_bytes{id="/system.slice"})`, "system.slice - {{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("system.slice CPU by node", "bytes",
			12, 8,
			promQuery(`sum by (node) (( rate(container_cpu_usage_seconds_total{id="/system.slice"}[$interval])) * 100)`, "system.slice - {{ node }}"),
		))
}

func nodeClusterWorkloadRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Cluster Workload").
		Collapsed(true).
		WithPanel(genericTimeSeries("Pod count", "none",
			12, 8,
			promQuery(`sum(kube_pod_status_phase{}) by (phase)`, "{{phase}} pods"),
		)).
		WithPanel(genericLegendTimeSeries("Pod Distribution", "none",
			12, 8,
			promQuery(`count(kube_pod_info{}) by (node)`, "{{ node }}"),
		)).
		WithPanel(genericTimeSeries("Container count", "none",
			12, 8,
			promQuery(`count(kube_pod_container_info)`, "Containers"),
		)).
		WithPanel(genericLegendTimeSeries("Container Distribution", "none",
			12, 8,
			promQuery(`count(container_last_seen{}) by (node)`, "Containers on {{node}}"),
		))
}

func nodeTopUsageRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Top Usage").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 Container Memory Working Set", "bytes",
			12, 8,
			promQuery(`topk(10, container_memory_working_set_bytes{namespace!="",container!="POD",name!=""})`, "{{ namespace }} - {{ name }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Container CPU(% of 1 core)", "percent",
			12, 8,
			promQuery(`topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[$interval])*100)`, "{{ namespace }} - {{ name }}"),
		)).
		WithPanel(genericTimeSeries("Top 10 Goroutines count", "none",
			12, 8,
			promQuery(`topk(10, sum(go_goroutines{}) by (job,instance))`, "{{ job }} - {{ instance }}"),
		))
}

func nodeKubeletOperationRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Kubelet Operation").
		Collapsed(true).
		WithPanel(genericLegendCounterTimeSeries("Workers Kubelet Runtime Operations Errors/second, >0.001 Waning, >0.01 Critical, >0.1 Severe", "short",
			12, 8,
			promQuery(`sum by (node, operation_type) (rate(kubelet_runtime_operations_errors_total [$interval])  *  on (node) group_left kube_node_role{ role = "worker" })`, "{{node}}: {{operation_type}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane Kubelet Runtime Operations Errors/second, >0.001 Waning, >0.01 Critical, >0.1 Severe", "short",
			12, 8,
			promQuery(`sum by (node, operation_type) (rate(kubelet_runtime_operations_errors_total [$interval]) *  on (node) group_left kube_node_role{ role = "control-plane" })`, "{{node}}: {{operation_type}}"),
		))
}

func nodeP99KubeletCgroupRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("P99 Kubelet Croup Manager Duration").
		Collapsed(true).
		WithPanel(genericLegendCounterTimeSeries("P99 Kubelet Croup Manager Duration - Create", "short",
			8, 8,
			promQuery(`sum(rate(kubelet_cgroup_manager_duration_seconds_bucket{node=~".*",operation_type="create"}[5m])) by (node, operation_type, le)`, "{{node}}: {{operation_type}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("p99KubeletCroupManagerDuration - Update", "short",
			8, 8,
			promQuery(`sum(rate(kubelet_cgroup_manager_duration_seconds_bucket{node=~".*",operation_type="update"}[5m])) by (node, operation_type, le)`, "{{node}}: {{operation_type}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("p99KubeletCroupManagerDuration - Destroy", "short",
			8, 8,
			promQuery(`sum(rate(kubelet_cgroup_manager_duration_seconds_bucket{node=~".*",operation_type="destroy"}[5m])) by (node, operation_type, le)`, "{{node}}: {{operation_type}}"),
		))
}

func nodeKubeletResourceUsageRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Kubelet Resource Usage").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 Kubelet Process CPU Usage(% of 1 core)", "percent",
			12, 8,
			promQuery(`topk(10,irate(process_cpu_seconds_total{service="kubelet",job="kubelet"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })`, "kubelet - {{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 Kubelet Process Resident Memory", "bytes",
			12, 8,
			promQuery(`topk(10,process_resident_memory_bytes{service="kubelet",job="kubelet"} *  on (node) group_left kube_node_role{ role = "worker" })`, "kubelet - {{node}}"),
		))
}

func nodeKubeletHTTPRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Kubelet HTTP requests Performance").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Kubelet HTTP requests count by path", "none",
			12, 8,
			promQuery(`sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (path)`, "{{ path }}"),
		)).
		WithPanel(genericLegendTimeSeries("Kubelet HTTP requests count by node", "none",
			12, 8,
			promQuery(`sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (node)`, "{{ node }}"),
		)).
		WithPanel(genericLegendTimeSeries("Kubelet HTTP requests latency per request by path (ms)", "none",
			12, 8,
			promQuery(`sum(rate(kubelet_http_requests_duration_seconds_sum[$interval])) by (path) * 1000/sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (path)`, "{{ path }}"),
		)).
		WithPanel(genericLegendTimeSeries("Kubelet HTTP requests latency per request by node (ms)> 200ms Warning, > 500ms Critical", "none",
			12, 8,
			promQuery(`sum(rate(kubelet_http_requests_duration_seconds_sum[$interval])) by (node) * 1000/sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (node)`, "{{ node }}"),
		))
}

func nodeCRIOOperationRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("CRIO Operation").
		Collapsed(true).
		WithPanel(genericLegendCounterTimeSeries("Workers Runtime Crio Operations Errors/second, > 0.001 Warning, >0.01 Critical", "short",
			12, 8,
			promQuery(`sum by (node, operation) (rate(container_runtime_crio_operations_errors_total [$interval])  *  on (node) group_left kube_node_role{ role = "worker" })`, "{{node}}: {{ operation }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane Runtime Crio Operations Errors/second, > 0.001 Warning, >0.01 Critical", "short",
			12, 8,
			promQuery(`sum by (node, operation) (rate(container_runtime_crio_operations_errors_total [$interval]) *  on (node) group_left kube_node_role{ role = "control-plane" })`, "{{node}}: {{ operation }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Workers Runtime Crio Operations Latency Avg(second), > 1s Warning, >5s Critical", "short",
			12, 8,
			promQuery(`topk(10, sum by (operation, node) (rate(container_runtime_crio_operations_latency_seconds_total[$interval]))/sum by (operation, node) (rate(container_runtime_crio_operations_total[$interval])) * on (node) group_left kube_node_role{ role = "worker" } * 100)`, "{{node}}: {{ operation }}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Control Plane Runtime Crio Operations Latency Avg(second), > 1s Warning, >5s Critical", "short",
			12, 8,
			promQuery(`topk(10, sum by (operation, node) (rate(container_runtime_crio_operations_latency_seconds_total[$interval]))/sum by (operation, node) (rate(container_runtime_crio_operations_total[$interval])) * on (node) group_left kube_node_role{ role = "control-plane" } * 100)`, "{{node}}: {{ operation }}"),
		))
}

func nodeCRIOResourceUsageRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("CRIO Resource Usage").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 crio Process CPU Usage(% of 1 core)", "percent",
			12, 8,
			promQuery(`topk(10,irate(process_cpu_seconds_total{service="kubelet",job="crio"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })`, "crio - {{node}}"),
		)).
		WithPanel(genericLegendCounterTimeSeries("Top 10 crio Process Resident Memory", "bytes",
			12, 8,
			promQuery(`topk(10,process_resident_memory_bytes{service="kubelet",job="crio"} *  on (node) group_left kube_node_role{ role = "worker" })`, "crio - {{node}}"),
		))
}

func nodeINodesRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("iNodes Usage").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("inodes usage in /run", "percent",
			12, 8,
			promQuery(`(1 - node_filesystem_files_free{fstype!="",mountpoint="/run"} / node_filesystem_files{fstype!="",mountpoint="/run"}) * 100`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("inodes count in /run", "none",
			12, 8,
			promQuery(`node_filesystem_files{fstype!="",mountpoint="/run"} - node_filesystem_files_free{fstype!="",mountpoint="/run"}`, "{{instance}}"),
			promQuery(`sum(node_filesystem_files{fstype!="",mountpoint="/run"} - node_filesystem_files_free{fstype!="",mountpoint="/run"})`, "sum"),
		))
}

func nodePLEGRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("Pod Lifecycle Event Generator (PLEG)").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("P95 PLEG Latency (s), >1s Waning, >3s Critical", "short",
			12, 8,
			promQuery(`histogram_quantile(0.95, sum(rate(kubelet_pleg_relist_duration_seconds_bucket [$interval])) by (node, le))`, "{{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("P95 PLEG Latency (s), >3s Waning, >5s Critical", "short",
			12, 8,
			promQuery(`histogram_quantile(0.99, sum(rate(kubelet_pleg_relist_duration_seconds_bucket [$interval])) by (node, le))`, "{{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("Average Latency  (s), >0.5s Waning, >1s Critical", "short",
			12, 8,
			promQuery(`rate(kubelet_pleg_relist_duration_seconds_sum [$interval])/rate(kubelet_pleg_relist_duration_seconds_count[$interval])`, "{{node}}"),
		)).
		WithPanel(genericLegendTimeSeries("PLEG Relist Count in 5 mins, <150 Waning, <50 Critical", "short",
			12, 8,
			promQuery(`sum(increase(kubelet_pleg_relist_duration_seconds_count[5m])) by (node)`, "{{node}}"),
		))
}

func nodePSIContainersRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("PSI - Containers (need to enable PSI)").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 Container Pressure Memory Stalled, >1% Waning, >5% Critical", "percent",
			12, 8,
			promQuery(`topk(10, sum(rate(container_pressure_memory_stalled_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)`, "{{node}}: {{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Container Pressure Memory Waiting, >5% Waning, >10% Critical", "percent",
			12, 8,
			promQuery(`topk(10, sum(rate(container_pressure_memory_waiting_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)`, "{{node}}: {{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Container Pressure CPU Stalled, >1% Waning, >5% Critical", "percent",
			12, 8,
			promQuery(`topk(10, sum(irate(container_pressure_cpu_stalled_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)`, "{{node}}: {{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Container Pressure CPU Waiting, >20% Waning, >50% Critical", "percent",
			12, 8,
			promQuery(`topk(10, sum(rate(container_pressure_cpu_waiting_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)`, "{{node}}: {{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Container Pressure IO Stalled, >5% Waning, >10% Critical", "percent",
			12, 8,
			promQuery(`topk(10, sum(rate(container_pressure_io_stalled_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)`, "{{node}}: {{ pod }}: {{ container }}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Container Pressure IO Waiting, >10% Waning, >30% Critical", "percent",
			12, 8,
			promQuery(`topk(10, sum(rate(container_pressure_io_waiting_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)`, "{{node}}: {{ pod }}: {{ container }}"),
		))
}

func nodePSINodesRow() *dashboard.RowBuilder {
	return dashboard.NewRowBuilder("PSI - Nodes (need to enable PSI)").
		Collapsed(true).
		WithPanel(genericLegendTimeSeries("Top 10 Node Pressure Memory Stalled, >1% Waning, >5% Critical", "percent",
			12, 8,
			promQuery(`topk(10, rate(node_pressure_memory_stalled_seconds_total [$interval]) * 100)`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Node Pressure Memory Waiting, >10% Waning, >30% Critical", "percent",
			12, 8,
			promQuery(`topk(10, rate(node_pressure_memory_waiting_seconds_total [$interval]) * 100)`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Node Pressure IO Stalled, >10% Waning, >30% Critical", "percent",
			12, 8,
			promQuery(`topk(10, rate(node_pressure_io_stalled_seconds_total [$interval]) * 100)`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Node Pressure IO Waiting, >30% Waning, >60% Critical", "percent",
			12, 8,
			promQuery(`topk(10, rate(node_pressure_io_waiting_seconds_total[$interval]) * 100)`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Node Pressure CPU Waiting, >5% Waning, >20% Critical", "percent",
			12, 8,
			promQuery(`topk(10, rate(node_pressure_cpu_waiting_seconds_total [$interval]) * 100)`, "{{instance}}"),
		)).
		WithPanel(genericLegendTimeSeries("Top 10 Node Pressure IRQ Stalled, >5% Waning, >10% Critical", "percent",
			12, 8,
			promQuery(`topk(10, rate(node_pressure_irq_stalled_seconds_total [$interval]) * 100)`, "{{instance}}"),
		))
}
