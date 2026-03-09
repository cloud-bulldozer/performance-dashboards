local variables = import './variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local generateTimeSeriesQuery(query, legend) = [
  local prometheusQuery = g.query.prometheus;
  prometheusQuery.new(
    '$' + variables.Datasource.name,
    query
  )
  + prometheusQuery.withFormat('time_series')
  + prometheusQuery.withIntervalFactor(2)
  + prometheusQuery.withLegendFormat(legend),
];

{
  workersCPU: {
    query():
      generateTimeSeriesQuery('sum( rate( (node_cpu_seconds_total{ mode != "idle" } * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") )[$interval:] ) ) by (instance) * 100', '{{instance}}'),
  },
  controlPlanesCPU: {
    query():
      generateTimeSeriesQuery('sum( rate( (node_cpu_seconds_total{ mode != "idle" } * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") )[$interval:] ) ) by (instance) * 100', '{{instance}}'),
  },
  workersLoad1: {
    query():
      generateTimeSeriesQuery('node_load1 * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") ', '{{instance}}'),
  },
  controlPlanesLoad1: {
    query():
      generateTimeSeriesQuery('node_load1 * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") ', '{{instance}}'),
  },
  workersMemoryAvailable: {
    query():
      generateTimeSeriesQuery('node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)")', '{{instance}}') +
      generateTimeSeriesQuery('sum( node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "worker"} , "instance" , "$1" , "node" ,"(.*)") )', 'sum'),
  },
  controlPlaneMemoryAvailable: {
    query():
      generateTimeSeriesQuery('node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)")', '{{instance}}') +
      generateTimeSeriesQuery('sum( node_memory_MemAvailable_bytes * on (instance) group_left label_replace( kube_node_role{ role = "control-plane"} , "instance" , "$1" , "node" ,"(.*)") )', 'sum'),
  },
  workersIOPS: {
    query():
      generateTimeSeriesQuery('rate( (  node_disk_reads_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "worker" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])', '{{instance}} - {{ device }} - read') +
      generateTimeSeriesQuery('rate( (  node_disk_writes_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "worker" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])', '{{instance}} - {{ device }} - write'),
  },
  controlPlaneIOPS: {
    query():
      generateTimeSeriesQuery('rate( (  node_disk_reads_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "control-plane" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])', '{{instance}} - {{ device }} - read') +
      generateTimeSeriesQuery('rate( (  node_disk_writes_completed_total *  on (instance) group_left label_replace( kube_node_role{ role = "control-plane" } , "instance" , "$1" , "node" ,"(.*)") )[$interval:])', '{{instance}} - {{ device }} - write'),
  },
  workersContainerThreads: {
    query():
      generateTimeSeriesQuery('sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "worker" }', '{{instance}}'),
  },
  controlPlaneContainerThreads: {
    query():
      generateTimeSeriesQuery('sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "control-plane" }', '{{instance}}'),
  },
  workersCGroupCpuRate: {
    query():
      generateTimeSeriesQuery('sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "worker" } )', '{{instance}}'),
  },
  controlPlaneCGroupCpuRate: {
    query():
      generateTimeSeriesQuery('sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "control-plane" } )', '{{instance}}'),
  },
  workersCGroupMemWorkingSet: {
    query():
      generateTimeSeriesQuery('sum by (id) (container_memory_working_set_bytes{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "worker" } )', '{{instance}}'),
  },
  controlPlaneCGroupMemWorkingSet: {
    query():
      generateTimeSeriesQuery('sum by (id) (container_memory_working_set_bytes{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/system.slice/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "control-plane" } )', '{{instance}}'),
  },
  containerMemWorkingSetSystemSlice: {
    query():
      generateTimeSeriesQuery('sum by (node)(container_memory_working_set_bytes{id="/system.slice"})', 'system.slice - {{ node }}'),
  },
  contCPUSystemSlice: {
    query():
      generateTimeSeriesQuery('sum by (node) (( rate(container_cpu_usage_seconds_total{id="/system.slice"}[$interval])) * 100)', 'system.slice - {{ node }}'),
  },
  podCount: {
    query():
      generateTimeSeriesQuery('sum(kube_pod_status_phase{}) by (phase)', '{{phase}} pods'),
  },
  podDistribution: {
    query():
      generateTimeSeriesQuery('count(kube_pod_info{}) by (node)', '{{ node }}'),
  },
  containerCount: {
    query():
      generateTimeSeriesQuery('count(kube_pod_container_info)', 'Containers'),
  },
  containerDistribution: {
    query():
      generateTimeSeriesQuery('count(container_last_seen{}) by (node)', 'Containers on {{node}}'),
  },
  top10ContMemWorkingSet: {
    query():
      generateTimeSeriesQuery('topk(10, container_memory_working_set_bytes{namespace!="",container!="POD",name!=""})', '{{ namespace }} - {{ name }}'),
  },
  top10ContCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[$interval])*100)', '{{ namespace }} - {{ name }}'),
  },
  goroutinesCount: {
    query():
      generateTimeSeriesQuery('topk(10, sum(go_goroutines{}) by (job,instance))', '{{ job }} - {{ instance }}'),
  },
  workersKubeletRuntimeOperationsErrors: {
    query():
      generateTimeSeriesQuery('sum by (node, operation_type) (rate(kubelet_runtime_operations_errors_total [$interval])  *  on (node) group_left kube_node_role{ role = "worker" })', '{{node}}: {{operation_type}}'),
  },
  controlPlaneKubeletRuntimeOperationsErrors: {
    query():
      generateTimeSeriesQuery('sum by (node, operation_type) (rate(kubelet_runtime_operations_errors_total [$interval]) *  on (node) group_left kube_node_role{ role = "control-plane" })', '{{node}}: {{operation_type}}'),
  },
  p99KubeletCroupManagerDurationCreate: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_cgroup_manager_duration_seconds_bucket{node=~".*",operation_type="create"}[5m])) by (node, operation_type, le)', '{{node}}: {{operation_type}}'),
  },
  p99KubeletCroupManagerDurationUpdate: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_cgroup_manager_duration_seconds_bucket{node=~".*",operation_type="update"}[5m])) by (node, operation_type, le)', '{{node}}: {{operation_type}}'),
  },
  p99KubeletCroupManagerDurationDestroy: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_cgroup_manager_duration_seconds_bucket{node=~".*",operation_type="destroy"}[5m])) by (node, operation_type, le)', '{{node}}: {{operation_type}}'),
  },
  kubeletCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(process_cpu_seconds_total{service="kubelet",job="kubelet"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })', 'kubelet - {{node}}'),
  },
  kubeletMemory: {
    query():
      generateTimeSeriesQuery('topk(10,process_resident_memory_bytes{service="kubelet",job="kubelet"} *  on (node) group_left kube_node_role{ role = "worker" })', 'kubelet - {{node}}'),
  },
  kubeletHttpRequestsCountByPath: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (path)', '{{ path }}'),
  },
  kubeletHttpRequestsCountByNode: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (node)', '{{ node }}'),
  },
  kubeletHttpRequestsLatencyPerRequestByPath: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_http_requests_duration_seconds_sum[$interval])) by (path) * 1000/sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (path)', '{{ path }}'),
  },
  kubeletHttpRequestsLatencyPerRequestByNode: {
    query():
      generateTimeSeriesQuery('sum(rate(kubelet_http_requests_duration_seconds_sum[$interval])) by (node) * 1000/sum(rate(kubelet_http_requests_duration_seconds_count[$interval])) by (node)', '{{ node }}'),
  },
  workersRuntimeCrioOperationsErrors: {
    query():
      generateTimeSeriesQuery('sum by (node, operation) (rate(container_runtime_crio_operations_errors_total [$interval])  *  on (node) group_left kube_node_role{ role = "worker" })', '{{node}}: {{ operation }}'),
  },
  controlPlaneRuntimeCrioOperationsErrors: {
    query():
      generateTimeSeriesQuery('sum by (node, operation) (rate(container_runtime_crio_operations_errors_total [$interval]) *  on (node) group_left kube_node_role{ role = "control-plane" })', '{{node}}: {{ operation }}'),
  },
  workerCrioOperationsLatencyPerSeconds: {
    query():
      generateTimeSeriesQuery('topk(10, sum by (operation, node) (rate(container_runtime_crio_operations_latency_seconds_total[$interval]))/sum by (operation, node) (rate(container_runtime_crio_operations_total[$interval])) * on (node) group_left kube_node_role{ role = "worker" } * 100)', '{{node}}: {{ operation }}'),
  },
  controlPlaneCrioOperationsLatencyPerSeconds: {
    query():
      generateTimeSeriesQuery('topk(10, sum by (operation, node) (rate(container_runtime_crio_operations_latency_seconds_total[$interval]))/sum by (operation, node) (rate(container_runtime_crio_operations_total[$interval])) * on (node) group_left kube_node_role{ role = "control-plane" } * 100)', '{{node}}: {{ operation }}'),
  },
  crioCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(process_cpu_seconds_total{service="kubelet",job="crio"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })', 'crio - {{node}}'),
  },
  crioMemory: {
    query():
      generateTimeSeriesQuery('topk(10,process_resident_memory_bytes{service="kubelet",job="crio"} *  on (node) group_left kube_node_role{ role = "worker" })', 'crio - {{node}}'),
  },
  crioINodes: {
    query():
      generateTimeSeriesQuery('(1 - node_filesystem_files_free{fstype!="",mountpoint="/run"} / node_filesystem_files{fstype!="",mountpoint="/run"}) * 100', '{{instance}}'),
  },
  crioINodesCount: {
    query():
      generateTimeSeriesQuery('node_filesystem_files{fstype!="",mountpoint="/run"} - node_filesystem_files_free{fstype!="",mountpoint="/run"}', '{{instance}}')
      + generateTimeSeriesQuery('sum(node_filesystem_files{fstype!="",mountpoint="/run"} - node_filesystem_files_free{fstype!="",mountpoint="/run"})', 'sum'),
  },
  p95PLEGLatency: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.95, sum(rate(kubelet_pleg_relist_duration_seconds_bucket [$interval])) by (node, le))', '{{node}}'),
  },
  p99PLEGLatency: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(kubelet_pleg_relist_duration_seconds_bucket [$interval])) by (node, le))', '{{node}}'),
  },
  averagePLEGLatency: {
    query():
      generateTimeSeriesQuery('rate(kubelet_pleg_relist_duration_seconds_sum [$interval])/rate(kubelet_pleg_relist_duration_seconds_count[$interval])', '{{node}}'),
  },
  pLEGRelistCount5Minutes: {
    query():
      generateTimeSeriesQuery('sum(increase(kubelet_pleg_relist_duration_seconds_count[5m])) by (node)', '{{node}}'),
  },
  top10ContainerPressureMemoryStalled: {
    query():
      generateTimeSeriesQuery('topk(10, sum(rate(container_pressure_memory_stalled_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)', '{{node}}: {{ pod }}: {{ container }}'),
  },
  top10ContainerPressureMemoryWaiting: {
    query():
      generateTimeSeriesQuery('topk(10, sum(rate(container_pressure_memory_waiting_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)', '{{node}}: {{ pod }}: {{ container }}'),
  },
  top10ContainerPressureCPUStalled: {
    query():
      generateTimeSeriesQuery('topk(10, sum(irate(container_pressure_cpu_stalled_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)', '{{node}}: {{ pod }}: {{ container }}'),
  },
  top10ContainerPressureCPUWaiting: {
    query():
      generateTimeSeriesQuery('topk(10, sum(rate(container_pressure_cpu_waiting_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)', '{{node}}: {{ pod }}: {{ container }}'),
  },
  top10ContainerPressureIOStalled: {
    query():
      generateTimeSeriesQuery('topk(10, sum(rate(container_pressure_io_stalled_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)', '{{node}}: {{ pod }}: {{ container }}'),
  },
  top10ContainerPressureIOWaiting: {
    query():
      generateTimeSeriesQuery('topk(10, sum(rate(container_pressure_io_waiting_seconds_total{container!="POD",name!="",namespace!="",namespace=~"$namespace"}[$interval])) by (node,pod,container,namespace,name,service) * 100)', '{{node}}: {{ pod }}: {{ container }}'),
  },
  top10NodePressureMemoryStalled: {
    query():
      generateTimeSeriesQuery('topk(10, rate(node_pressure_memory_stalled_seconds_total [$interval]) * 100)', '{{instance}}'),
  },
  top10NodePressureMemoryWaiting: {
    query():
      generateTimeSeriesQuery('topk(10, rate(node_pressure_memory_waiting_seconds_total [$interval]) * 100)', '{{instance}}'),
  },
  top10NodePressureIOStalled: {
    query():
      generateTimeSeriesQuery('topk(10, rate(node_pressure_io_stalled_seconds_total [$interval]) * 100)', '{{instance}}'),
  },
  top10NodePressureIOWaiting: {
    query():
      generateTimeSeriesQuery('topk(10, rate(node_pressure_io_waiting_seconds_total[$interval]) * 100)', '{{instance}}'),
  },
  top10NodePressureCPUWaiting: {
    query():
      generateTimeSeriesQuery('topk(10, rate(node_pressure_cpu_waiting_seconds_total [$interval]) * 100)', '{{instance}}'),
  },
  top10NodePressureIRQStalled: {
    query():
      generateTimeSeriesQuery('topk(10, rate(node_pressure_irq_stalled_seconds_total [$interval]) * 100)', '{{instance}}'),
  },
}
