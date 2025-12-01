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
  workersCGroupCpuRate: {
    query():
      generateTimeSeriesQuery('sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "worker" } )', '{{instance}}'),
  },
  controlPlaneCGroupCpuRate: {
    query():
      generateTimeSeriesQuery('sum by (id) (( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) * 100 * on (node) group_left kube_node_role{ role = "control-plane" } )', '{{instance}}'),
  },
  workersCGroupMemoryRSS: {
    query():
      generateTimeSeriesQuery('sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "worker" } )', '{{instance}}'),
  },
  controlPlaneCGroupMemoryRSS: {
    query():
      generateTimeSeriesQuery('sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"} * on (node) group_left kube_node_role{ role = "control-plane" } )', '{{instance}}'),
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
  workersContainerThreads: {
    query():
      generateTimeSeriesQuery('sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "worker" }', '{{instance}}'),
  },
  controlPlaneContainerThreads: {
    query():
      generateTimeSeriesQuery('sum by (node) (container_threads{ container!=""})  * on (node) group_left kube_node_role{ role = "control-plane" }', '{{instance}}'),
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

  nodeMemory: {
    query(nodeName):
      generateTimeSeriesQuery('node_memory_Active_bytes{instance=~"' + nodeName + '"}', 'Active')
      + generateTimeSeriesQuery('node_memory_MemTotal_bytes{instance=~"' + nodeName + '"}', 'Total')
      + generateTimeSeriesQuery('node_memory_Cached_bytes{instance=~"' + nodeName + '"} + node_memory_Buffers_bytes{instance=~"' + nodeName + '"}', 'Cached + Buffers')
      + generateTimeSeriesQuery('node_memory_MemAvailable_bytes{instance=~"' + nodeName + '"}', 'Available')
      + generateTimeSeriesQuery('(node_memory_MemTotal_bytes{instance=~"' + nodeName + '"} - (node_memory_MemFree_bytes{instance=~"' + nodeName + '"} + node_memory_Buffers_bytes{instance=~"' + nodeName + '"} +  node_memory_Cached_bytes{instance=~"' + nodeName + '"}))', 'Used'),
  },
  nodeCPU: {
    query(nodeName):
      generateTimeSeriesQuery('sum by (instance, mode)(irate(node_cpu_seconds_total{instance=~"' + nodeName + '",job=~".*"}[$interval])) * 100', 'Busy {{mode}}'),
  },
  diskThroughput: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_disk_read_bytes_total{device=~"$block_device",instance=~"' + nodeName + '"}[$interval])', '{{ device }} - read')
      + generateTimeSeriesQuery('rate(node_disk_written_bytes_total{device=~"$block_device",instance=~"' + nodeName + '"}[$interval])', '{{ device }} - write'),
  },
  diskIOPS: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_disk_reads_completed_total{device=~"$block_device",instance=~"' + nodeName + '"}[$interval])', '{{ device }} - read')
      + generateTimeSeriesQuery('rate(node_disk_writes_completed_total{device=~"$block_device",instance=~"' + nodeName + '"}[$interval])', '{{ device }} - write'),
  },
  networkUtilization: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_network_receive_bytes_total{instance=~"' + nodeName + '",device=~"$net_device"}[$interval]) * 8', '{{instance}} - {{device}} - RX')
      + generateTimeSeriesQuery('rate(node_network_transmit_bytes_total{instance=~"' + nodeName + '",device=~"$net_device"}[$interval]) * 8', '{{instance}} - {{device}} - TX'),
  },
  networkPackets: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_network_receive_packets_total{instance=~"' + nodeName + '",device=~"$net_device"}[$interval])', '{{instance}} - {{device}} - RX')
      + generateTimeSeriesQuery('rate(node_network_transmit_packets_total{instance=~"' + nodeName + '",device=~"$net_device"}[$interval])', '{{instance}} - {{device}} - TX'),
  },
  networkDrop: {
    query(nodeName):
      generateTimeSeriesQuery('topk(10, rate(node_network_receive_drop_total{instance=~"' + nodeName + '"}[$interval]))', 'rx-drop-{{ device }}')
      + generateTimeSeriesQuery('topk(10,rate(node_network_transmit_drop_total{instance=~"' + nodeName + '"}[$interval]))', 'tx-drop-{{ device }}'),
  },
  conntrackStats: {
    query(nodeName):
      generateTimeSeriesQuery('node_nf_conntrack_entries{instance=~"' + nodeName + '"}', 'conntrack_entries')
      + generateTimeSeriesQuery('node_nf_conntrack_entries_limit{instance=~"' + nodeName + '"}', 'conntrack_limit'),
  },
  top10ContainerCPU: {
    query(nodeName):
      generateTimeSeriesQuery('topk(10, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",node=~"' + nodeName + '",namespace!="",namespace=~"$namespace"}[$interval])) by (pod,container,namespace,name,service) * 100)', '{{ pod }}: {{ container }}'),
  },
  top10ContainerRSS: {
    query(nodeName):
      generateTimeSeriesQuery('topk(10, container_memory_rss{container!="POD",name!="",node=~"' + nodeName + '",namespace!="",namespace=~"$namespace"})', '{{ pod }}: {{ container }}'),
  },
  nodeCGroupCPU: {
    query(nodeName):
      generateTimeSeriesQuery('sum by (id) ( rate(container_cpu_usage_seconds_total{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice", node=~"' + nodeName + '"}[$interval])) * 100', '{{ id }}'),
  },
  nodeCGroupRSS: {
    query(nodeName):
      generateTimeSeriesQuery('sum by (id) ( container_memory_rss{ job=~".*", id =~"/system.slice|/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/system.slice/.*.service|/system.slice/systemd-udevd.service|/kubepods.slice", node=~"' + nodeName + '"})', '{{ id }}'),
  },
  containerReadWriteBytesPod: {
    query(nodeName):
      generateTimeSeriesQuery('sum(rate(container_fs_writes_bytes_total{device!~".+dm.+", node=~"' + nodeName + '", pod!=""}[$interval])) by (device, pod)', '{{ pod }}: {{ device }} - write')
      + generateTimeSeriesQuery('sum(rate(container_fs_reads_bytes_total{device!~".+dm.+", node=~"' + nodeName + '", pod!=""}[$interval])) by (device, pod)', '{{ pod }}: {{ device }} - read'),
  },
  containerReadWriteBytesCGroup: {
    query(nodeName):
      generateTimeSeriesQuery('sum(rate(container_fs_writes_bytes_total{device!~".+dm.+", node=~"' + nodeName + '", id =~"/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) by (device, id)', '{{ id }}: {{ device }} - write')
      + generateTimeSeriesQuery('sum(rate(container_fs_reads_bytes_total{device!~".+dm.+", node=~"' + nodeName + '", id =~"/system.slice/kubelet.service|/.*/ovs-vswitchd.service|/system.slice/crio.service|/system.slice/systemd-journald.service|/.*/ovsdb-server.service|/system.slice/systemd-udevd.service|/kubepods.slice"}[$interval])) by (device, id)', '{{ id }}: {{ device }} - read'),
  },
  stackroxCPU: {
    query():
      generateTimeSeriesQuery('topk(25, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",namespace!="",namespace=~"stackrox"}[$interval])) by (pod,container,namespace,name,service) * 100)', '{{ pod }}: {{ container }}'),
  },
  stackroxMem: {
    query():
      generateTimeSeriesQuery('topk(25, container_memory_rss{container!="POD",name!="",namespace!="",namespace=~"stackrox"})', '{{ pod }}: {{ container }}'),
  },
  OVSCPU: {
    query(nodeName):
      generateTimeSeriesQuery('irate(container_cpu_usage_seconds_total{id=~"/.*/ovs-vswitchd.service", node=~"' + nodeName + '"}[$interval])*100', 'OVS CPU - {{ node }}')
      + generateTimeSeriesQuery('irate(container_cpu_usage_seconds_total{id=~"/.*/ovsdb-server.service", node=~"' + nodeName + '"}[$interval])*100', 'OVS DB CPU - {{ node }}'),
  },
  OVSMemory: {
    query(nodeName):
      generateTimeSeriesQuery('container_memory_rss{id=~"/.*/ovs-vswitchd.service", node=~"' + nodeName + '"}', 'OVS Memory - {{ node }}')
      + generateTimeSeriesQuery('container_memory_rss{id=~"/.*/ovsdb-server.service", node=~"' + nodeName + '"}', 'OVS DB Memory - {{ node }}'),
  },
  ovnAnnotationLatency: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum by (instance, pod, le) (rate(ovnkube_controller_pod_creation_latency_seconds_bucket[$interval]))) > 0', '{{ pod }} - {{ instance }}'),
  },
  ovnCNIAdd: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="ADD"}[$interval])) by (instance,pod,le)) > 0', '{{ pod }} - {{ instance }}'),
  },
  ovnCNIDel: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="DEL"}[$interval])) by (instance,pod,le)) > 0', '{{ pod }} - {{ instance }}'),
  },
  ovnKubeControlPlaneCPU: {
    query():
      generateTimeSeriesQuery('sum( irate(container_cpu_usage_seconds_total{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}[$interval])*100 ) by (pod, node)', '{{pod}} - {{node}}'),
  },
  ovnKubeControlPlaneMem: {
    query():
      generateTimeSeriesQuery('container_memory_rss{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}', '{{pod}} - {{node}}'),
  },
  topOvnControllerCPU: {
    query():
      generateTimeSeriesQuery('topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}[$interval])*100)  by (pod,node) )', '{{pod}} - {{node}}'),
  },
  topOvnControllerMem: {
    query():
      generateTimeSeriesQuery('topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}) by (pod,node))', '{{pod}} - {{node}}'),
  },
  ovnKubeControllerCPU: {
    query():
      generateTimeSeriesQuery('topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}[$interval])*100)  by (pod,node) )', '{{pod}} - {{node}}'),
  },
  ovnKubeControllerMem: {
    query():
      generateTimeSeriesQuery('topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovnkube-controller"}) by (pod,node))', '{{pod}} - {{node}}'),
  },
  topNbdbCPU: {
    query():
      generateTimeSeriesQuery('topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}[$interval])*100)  by (pod,node) )', '{{pod}} - {{node}}'),
  },
  topNbdbMem: {
    query():
      generateTimeSeriesQuery('topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="nbdb"}) by (pod,node))', '{{pod}} - {{node}}'),
  },
  topNorthdCPU: {
    query():
      generateTimeSeriesQuery('topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="northd"}[$interval])*100)  by (pod,node) )', '{{pod}} - {{node}}'),
  },
  topNorthdMem: {
    query():
      generateTimeSeriesQuery('topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="northd"}) by (pod,node))', '{{pod}} - {{node}}'),
  },
  topSbdbCPU: {
    query():
      generateTimeSeriesQuery('topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}[$interval])*100)  by (pod,node) )', '{{pod}} - {{node}}'),
  },
  topSbdbMem: {
    query():
      generateTimeSeriesQuery('topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="sbdb"}) by (pod,node))', '{{pod}} - {{node}}'),
  },

  promReplCpuUsage: {
    query():
      generateTimeSeriesQuery('sum(irate(container_cpu_usage_seconds_total{pod=~"prometheus-k8s-0",namespace!="",name!="",container="prometheus"}[$interval])) by (pod,container,node) * 100', '{{pod}} - {{node}}')
      + generateTimeSeriesQuery('sum(irate(container_cpu_usage_seconds_total{pod=~"prometheus-k8s-1",namespace!="",name!="",container="prometheus"}[$interval])) by (pod,container,node) * 100', '{{pod}} - {{node}}'),
  },
  promReplMemUsage: {
    query():
      generateTimeSeriesQuery('sum(container_memory_rss{pod="prometheus-k8s-1",namespace!="",name!="",container="prometheus"}) by (pod)', '{{pod}}')
      + generateTimeSeriesQuery('sum(container_memory_rss{pod="prometheus-k8s-0",namespace!="",name!="",container="prometheus"}) by (pod)', '{{pod}}'),
  },
  metricsServerCpuUsage: {
    query():
      generateTimeSeriesQuery('sum(irate(container_cpu_usage_seconds_total{pod=~"metrics-server-.*",namespace!="",name!=""}[$interval])) by (pod,container) * 100', '{{pod}}')
      + generateTimeSeriesQuery('sum(irate(container_cpu_usage_seconds_total{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}[$interval])) by (pod,container) * 100', '{{pod}}'),
  },
  metricsServerMemUsage: {
    query():
      generateTimeSeriesQuery('sum(container_memory_rss{pod=~"metrics-server-.*",namespace!="",name!=""}) by (pod)', '{{pod}}')
      + generateTimeSeriesQuery('sum(container_memory_rss{pod=~"prometheus-adapter-.*",namespace="openshift-monitoring",name!=""}) by (pod)', '{{pod}}'),
  },
  kubeletCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(process_cpu_seconds_total{service="kubelet",job="kubelet"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })', 'kubelet - {{node}}'),
  },
  crioCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(process_cpu_seconds_total{service="kubelet",job="crio"}[$interval])*100 *  on (node) group_left kube_node_role{ role = "worker" })', 'crio - {{node}}'),
  },
  kubeletMemory: {
    query():
      generateTimeSeriesQuery('topk(10,process_resident_memory_bytes{service="kubelet",job="kubelet"} *  on (node) group_left kube_node_role{ role = "worker" })', 'kubelet - {{node}}'),
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
  currentNodeCount: {
    query():
      generateTimeSeriesQuery('sum(kube_node_info{})', 'Number of nodes')
      + generateTimeSeriesQuery('sum(kube_node_status_condition{status="true"}) by (condition) > 0', 'Node: {{ condition }}'),
  },
  currentNamespaceCount: {
    query():
      generateTimeSeriesQuery('sum(kube_namespace_status_phase) by (phase)', '{{ phase }}'),
  },
  currentPodCount: {
    query():
      generateTimeSeriesQuery('sum(kube_pod_status_phase{}) by (phase) > 0', '{{ phase}} Pods'),
  },
  nsCount: {
    query():
      generateTimeSeriesQuery('sum(kube_namespace_status_phase) by (phase) > 0', '{{ phase }} namespaces'),
  },
  podCount: {
    query():
      generateTimeSeriesQuery('sum(kube_pod_status_phase{}) by (phase)', '{{phase}} pods'),
  },
  secretCmCount: {
    query():
      generateTimeSeriesQuery('count(kube_secret_info{})', 'secrets')
      + generateTimeSeriesQuery('count(kube_configmap_info{})', 'Configmaps'),
  },
  deployCount: {
    query():
      generateTimeSeriesQuery('count(kube_deployment_labels{})', 'Deployments'),
  },
  servicesCount: {
    query():
      generateTimeSeriesQuery('count(kube_service_info{})', 'Services'),
  },
  routesCount: {
    query():
      generateTimeSeriesQuery('count(openshift_route_info{})', 'Routes'),
  },
  alerts: {
    query():
      generateTimeSeriesQuery('topk(10,sum(ALERTS{severity!="none"}) by (alertname, severity))', '{{severity}}: {{alertname}}'),
  },
  podDistribution: {
    query():
      generateTimeSeriesQuery('count(kube_pod_info{}) by (node)', '{{ node }}'),
  },
  top10ContMem: {
    query():
      generateTimeSeriesQuery('topk(10, container_memory_rss{namespace!="",container!="POD",name!=""})', '{{ namespace }} - {{ name }} - {{ node }}'),
  },
  contMemRSSSystemSlice: {
    query():
      generateTimeSeriesQuery('sum by (node)(container_memory_rss{id="/system.slice"})', 'system.slice - {{ node }}'),
  },
  top10ContCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[$interval])*100)', '{{ namespace }} - {{ name }} - {{ node }}'),
  },
  goroutinesCount: {
    query():
      generateTimeSeriesQuery('topk(10, sum(go_goroutines{}) by (job,instance))', '{{ job }} - {{ instance }}'),
  },
  clusterOperatorsOverview: {
    query():
      generateTimeSeriesQuery('sum by (condition)(cluster_operator_conditions{condition!=""})', '{{ condition }}'),
  },
  clusterOperatorsInformation: {
    query():
      generateTimeSeriesQuery('cluster_operator_conditions{name!="",reason!=""}', '{{name}} - {{reason}}'),
  },
  clusterOperatorsDegraded: {
    query():
      generateTimeSeriesQuery('cluster_operator_conditions{condition="Degraded",name!="",reason!=""}', '{{name}} - {{reason}}'),
  },
}
