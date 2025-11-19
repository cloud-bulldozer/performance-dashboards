local panels = import '../../assets/ocp-performance/panels.libsonnet';
local queries = import '../../assets/ocp-performance/queries.libsonnet';
local variables = import '../../assets/ocp-performance/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Openshift Performance')
+ g.dashboard.withDescription(|||
  Performance dashboard for Red Hat Openshift
|||)
+ g.dashboard.time.withFrom('now-1h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('30s')
+ g.dashboard.withEditable(true)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.master_node,
  variables.worker_node,
  variables.infra_node,
  variables.namespace,
  variables.block_device,
  variables.net_device,
  variables.interval,
])
+ g.dashboard.withPanels([
  g.panel.row.new('Cluster-at-a-Glance')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Workers CPU Usage', 'percent', queries.workersCPU.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane CPU Usage', 'percent', queries.controlPlanesCPU.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Workers Load1', 'short', queries.workersLoad1.query(), { x: 0, y: 9, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane Load1', 'short', queries.controlPlanesLoad1.query(), { x: 12, y: 9, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounterSumRightHand('Workers Memory Available', 'bytes', queries.workersMemoryAvailable.query(), { x: 0, y: 17, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounterSumRightHand('Control Plane Memory Available', 'bytes', queries.controlPlaneMemoryAvailable.query(), { x: 12, y: 17, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Workers CGroup CPU Rate', 'percent', queries.workersCGroupCpuRate.query(), { x: 0, y: 25, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane CGroup CPU Rate', 'percent', queries.controlPlaneCGroupCpuRate.query(), { x: 12, y: 25, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Workers CGroup Memory RSS', 'bytes', queries.workersCGroupMemoryRSS.query(), { x: 0, y: 33, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane CGroup Memory RSS', 'bytes', queries.controlPlaneCGroupMemoryRSS.query(), { x: 12, y: 33, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Workers Container Threads', 'short', queries.workersContainerThreads.query(), { x: 0, y: 41, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane Container Threads', 'short', queries.controlPlaneContainerThreads.query(), { x: 12, y: 41, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Workers Disk IOPS', 'short', queries.workersIOPS.query(), { x: 0, y: 49, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane Disk IOPS', 'short', queries.controlPlaneIOPS.query(), { x: 12, y: 49, w: 12, h: 8 }),
  ]),
  g.panel.row.new('OVN')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 ovnkube-controller CPU Usage', 'percent', queries.ovnKubeControllerCPU.query(), { x: 0, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 ovnkube-controller Memory Usage', 'bytes', queries.ovnKubeControllerMem.query(), { x: 12, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 ovn-controller CPU Usage', 'percent', queries.topOvnControllerCPU.query(), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 ovn-controller Memory Usage', 'bytes', queries.topOvnControllerMem.query(), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 nbdb CPU Usage', 'percent', queries.topNbdbCPU.query(), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 nbdb Memory Usage', 'bytes', queries.topNbdbMem.query(), { x: 12, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 northd CPU Usage', 'percent', queries.topNorthdCPU.query(), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 northd Memory Usage', 'bytes', queries.topNorthdMem.query(), { x: 12, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 sbdb CPU Usage', 'percent', queries.topSbdbCPU.query(), { x: 0, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 sbdb Memory Usage', 'bytes', queries.topSbdbMem.query(), { x: 12, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('ovs-master CPU Usage', 'percent', queries.OVSCPU.query('$_master_node'), { x: 0, y: 40, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('ovs-master Memory Usage', 'bytes', queries.OVSMemory.query('$_master_node'), { x: 12, y: 40, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('ovs-worker CPU Usage', 'percent', queries.OVSCPU.query('$_worker_node'), { x: 0, y: 48, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('ovs-worker Memory Usage', 'bytes', queries.OVSMemory.query('$_worker_node'), { x: 12, y: 48, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('99% Pod Annotation Latency', 's', queries.ovnAnnotationLatency.query(), { x: 0, y: 56, w: 8, h: 8 }),
    panels.timeSeries.genericLegend('99% CNI Request ADD Latency', 's', queries.ovnCNIAdd.query(), { x: 8, y: 56, w: 8, h: 8 }),
    panels.timeSeries.genericLegend('99% CNI Request DEL Latency', 's', queries.ovnCNIDel.query(), { x: 16, y: 56, w: 8, h: 8 }),
    panels.timeSeries.genericLegend('ovnkube-control-plane CPU Usage', 'percent', queries.ovnKubeControlPlaneCPU.query(), { x: 0, y: 64, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('ovnkube-control-plane Memory Usage', 'bytes', queries.ovnKubeControlPlaneMem.query(), { x: 12, y: 64, w: 12, h: 8 }),

  ]),
  g.panel.row.new('Monitoring stack')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Prometheus Replica CPU', 'percent', queries.promReplCpuUsage.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Prometheus Replica RSS', 'bytes', queries.promReplMemUsage.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('metrics-server/prom-adapter CPU', 'percent', queries.metricsServerCpuUsage.query(), { x: 0, y: 10, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('metrics-server/prom-adapter RSS', 'bytes', queries.metricsServerMemUsage.query(), { x: 12, y: 10, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Stackrox')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 25 stackrox container RSS bytes', 'bytes', queries.stackroxMem.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 25 stackrox container CPU percent', 'percent', queries.stackroxCPU.query(), { x: 12, y: 2, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Cluster Kubelet')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 Kubelet CPU usage', 'percent', queries.kubeletCPU.query(), { x: 0, y: 3, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 crio CPU usage', 'percent', queries.crioCPU.query(), { x: 12, y: 3, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Top 10 Kubelet memory usage', 'bytes', queries.kubeletMemory.query(), { x: 0, y: 11, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Top 10 crio memory usage', 'bytes', queries.crioMemory.query(), { x: 12, y: 11, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('inodes usage in /run', 'percent', queries.crioINodes.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounterSumRightHand('inodes count in /run', 'none', queries.crioINodesCount.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Cluster Details')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.stat.base('Current Node Count', queries.currentNodeCount.query(), { x: 0, y: 4, w: 8, h: 3 }),
    panels.stat.base('Current Namespace Count', queries.currentNamespaceCount.query(), { x: 8, y: 4, w: 8, h: 3 }),
    panels.stat.base('Current Pod Count', queries.currentPodCount.query(), { x: 16, y: 4, w: 8, h: 3 }),
    panels.timeSeries.generic('Number of nodes', 'none', queries.currentNodeCount.query(), { x: 0, y: 12, w: 8, h: 8 }),
    panels.timeSeries.generic('Namespace count', 'none', queries.nsCount.query(), { x: 8, y: 12, w: 8, h: 8 }),
    panels.timeSeries.generic('Pod count', 'none', queries.podCount.query(), { x: 16, y: 12, w: 8, h: 8 }),
    panels.timeSeries.generic('Secret & configmap count', 'none', queries.secretCmCount.query(), { x: 0, y: 20, w: 8, h: 8 }),
    panels.timeSeries.generic('Deployment count', 'none', queries.deployCount.query(), { x: 8, y: 20, w: 8, h: 8 }),
    panels.timeSeries.generic('Services count', 'none', queries.servicesCount.query(), { x: 16, y: 20, w: 8, h: 8 }),
    panels.timeSeries.generic('Routes count', 'none', queries.routesCount.query(), { x: 0, y: 20, w: 8, h: 8 }),
    panels.timeSeries.generic('Alerts', 'none', queries.alerts.query(), { x: 8, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericLegend('Pod Distribution', 'none', queries.podDistribution.query(), { x: 16, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 container CPU', 'percent', queries.top10ContCPU.query(), { x: 0, y: 28, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 container RSS', 'bytes', queries.top10ContMem.query(), { x: 12, y: 28, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('container RSS system.slice', 'bytes', queries.contMemRSSSystemSlice.query(), { x: 12, y: 36, w: 12, h: 8 }),
    panels.timeSeries.generic('Goroutines count', 'none', queries.goroutinesCount.query(), { x: 0, y: 36, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Cluster Operators Details')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.stat.base('Cluster operators overview', queries.clusterOperatorsOverview.query(), { x: 0, y: 4, w: 24, h: 3 }),
    panels.timeSeries.genericLegend('Cluster operators information', 'none', queries.clusterOperatorsInformation.query(), { x: 0, y: 4, w: 8, h: 8 }),
    panels.timeSeries.genericLegend('Cluster operators degraded', 'none', queries.clusterOperatorsDegraded.query(), { x: 8, y: 4, w: 8, h: 8 }),
  ]),
  g.panel.row.new('Master: $_master_node')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('_master_node')
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('CPU Basic: $_master_node', 'percent', queries.nodeCPU.query('$_master_node'), { x: 0, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('System Memory: $_master_node', 'bytes', queries.nodeMemory.query('$_master_node'), { x: 12, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Disk throughput: $_master_node', 'Bps', queries.diskThroughput.query('$_master_node'), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Disk IOPS: $_master_node', 'iops', queries.diskIOPS.query('$_master_node'), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network Utilization: $_master_node', 'bps', queries.networkUtilization.query('$_master_node'), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network Packets: $_master_node', 'pps', queries.networkPackets.query('$_master_node'), { x: 12, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network packets drop: $_master_node', 'pps', queries.networkDrop.query('$_master_node'), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Conntrack stats: $_master_node', '', queries.conntrackStats.query('$_master_node'), { x: 12, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 container CPU: $_master_node', 'percent', queries.top10ContainerCPU.query('$_master_node'), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Top 10 container RSS: $_master_node', 'bytes', queries.top10ContainerRSS.query('$_master_node'), { x: 12, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('cgroup CPU: $_master_node', 'percent', queries.nodeCGroupCPU.query('$_master_node'), { x: 0, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('cgroup RSS: $_master_node', 'bytes', queries.nodeCGroupRSS.query('$_master_node'), { x: 12, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Pod fs rw rate: $_master_node', 'Bps', queries.containerReadWriteBytesPod.query('$_master_node'), { x: 0, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('cgroup fs rw rate: $_master_node', 'Bps', queries.containerReadWriteBytesCGroup.query('$_master_node'), { x: 12, y: 32, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Worker: $_worker_node')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('_worker_node')
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('CPU Basic: $_worker_node', 'percent', queries.nodeCPU.query('$_worker_node'), { x: 0, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('System Memory: $_worker_node', 'bytes', queries.nodeMemory.query('$_worker_node'), { x: 12, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Disk throughput: $_worker_node', 'Bps', queries.diskThroughput.query('$_worker_node'), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Disk IOPS: $_worker_node', 'iops', queries.diskIOPS.query('$_worker_node'), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network Utilization: $_worker_node', 'bps', queries.networkUtilization.query('$_worker_node'), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network Packets: $_worker_node', 'pps', queries.networkPackets.query('$_worker_node'), { x: 12, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network packets drop: $_worker_node', 'pps', queries.networkDrop.query('$_worker_node'), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Conntrack stats: $_worker_node', '', queries.conntrackStats.query('$_worker_node'), { x: 12, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 container CPU: $_worker_node', 'percent', queries.top10ContainerCPU.query('$_worker_node'), { x: 0, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Top 10 container RSS: $_worker_node', 'bytes', queries.top10ContainerRSS.query('$_worker_node'), { x: 12, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('cgroup CPU: $_worker_node', 'percent', queries.nodeCGroupCPU.query('$_worker_node'), { x: 0, y: 40, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('cgroup RSS: $_worker_node', 'bytes', queries.nodeCGroupRSS.query('$_worker_node'), { x: 12, y: 40, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Infra: $_infra_node')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('_infra_node')
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('CPU Basic: $_infra_node', 'percent', queries.nodeCPU.query('$_infra_node'), { x: 0, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('System Memory: $_infra_node', 'bytes', queries.nodeMemory.query('$_infra_node'), { x: 12, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Disk throughput: $_infra_node', 'Bps', queries.diskThroughput.query('$_infra_node'), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Disk IOPS: $_infra_node', 'iops', queries.diskIOPS.query('$_infra_node'), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network Utilization: $_infra_node', 'bps', queries.networkUtilization.query('$_infra_node'), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network Packets: $_infra_node', 'pps', queries.networkPackets.query('$_infra_node'), { x: 12, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Network packets drop: $_infra_node', 'pps', queries.networkDrop.query('$_infra_node'), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Conntrack stats: $_infra_node', '', queries.conntrackStats.query('$_infra_node'), { x: 12, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 container CPU: $_infra_node', 'percent', queries.top10ContainerCPU.query('$_infra_node'), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 container RSS: $_infra_node', 'bytes', queries.top10ContainerRSS.query('$_infra_node'), { x: 12, y: 24, w: 12, h: 8 }),
  ]),
])
