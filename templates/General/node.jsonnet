local panels = import '../../assets/node/panels.libsonnet';
local queries = import '../../assets/node/queries.libsonnet';
local variables = import '../../assets/node/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Node Performance')
+ g.dashboard.withDescription(|||
  Node Performance dashboard for Red Hat Openshift
|||)
+ g.dashboard.time.withFrom('now-1h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(true)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.namespace,
  variables.interval,
])
+ g.dashboard.withPanels([
  g.panel.row.new('Node Resource')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Workers CPU Usage', 'percent', queries.workersCPU.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane CPU Usage', 'percent', queries.controlPlanesCPU.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Workers Load1', 'short', queries.workersLoad1.query(), { x: 0, y: 9, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane Load1', 'short', queries.controlPlanesLoad1.query(), { x: 12, y: 9, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Workers Memory Available', 'bytes', queries.workersMemoryAvailable.query(), { x: 0, y: 17, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane Memory Available', 'bytes', queries.controlPlaneMemoryAvailable.query(), { x: 12, y: 17, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Workers Disk IOPS', 'short', queries.workersIOPS.query(), { x: 0, y: 49, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane Disk IOPS', 'short', queries.controlPlaneIOPS.query(), { x: 12, y: 49, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Workers Container Threads', 'short', queries.workersContainerThreads.query(), { x: 0, y: 41, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane Container Threads', 'short', queries.controlPlaneContainerThreads.query(), { x: 12, y: 41, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Cgroup Resource')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Workers CGroup CPU(% of 1 core)', 'short', queries.workersCGroupCpuRate.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Control Plane CGroup CPU(% of 1 core)', 'short', queries.controlPlaneCGroupCpuRate.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Workers CGroup Memory Working Set', 'bytes', queries.workersCGroupMemWorkingSet.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane CGroup Memory Working Set', 'bytes', queries.controlPlaneCGroupMemWorkingSet.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('system.slice Working Set by node', 'bytes', queries.containerMemWorkingSetSystemSlice.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('system.slice CPU by node', 'bytes', queries.contCPUSystemSlice.query(), { x: 12, y: 2, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Cluster Workload')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.generic('Pod count', 'none', queries.podCount.query(), { x: 0, y: 12, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Pod Distribution', 'none', queries.podDistribution.query(), { x: 12, y: 12, w: 12, h: 8 }),
    panels.timeSeries.generic('Container count', 'none', queries.containerCount.query(), { x: 0, y: 12, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Container Distribution', 'none', queries.containerDistribution.query(), { x: 12, y: 12, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Top Usage')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 Container Memory Working Set', 'bytes', queries.top10ContMemWorkingSet.query(), { x: 0, y: 28, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Container CPU(% of 1 core)', 'percent', queries.top10ContCPU.query(), { x: 12, y: 28, w: 12, h: 8 }),
    panels.timeSeries.generic('Top 10 Goroutines count', 'none', queries.goroutinesCount.query(), { x: 0, y: 36, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Kubelet Operation')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegendCounter('Workers Kubelet Runtime Operations Errors/second, >0.001 Waning, >0.01 Critical, >0.1 Severe', 'short', queries.workersKubeletRuntimeOperationsErrors.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane Kubelet Runtime Operations Errors/second, >0.001 Waning, >0.01 Critical, >0.1 Severe', 'short', queries.controlPlaneKubeletRuntimeOperationsErrors.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('P99 Kubelet Croup Manager Duration')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegendCounter('P99 Kubelet Croup Manager Duration - Create', 'short', queries.p99KubeletCroupManagerDurationCreate.query(), { x: 0, y: 19, w: 8, h: 8 }),
    panels.timeSeries.genericLegendCounter('p99KubeletCroupManagerDuration - Update', 'short', queries.p99KubeletCroupManagerDurationUpdate.query(), { x: 8, y: 19, w: 8, h: 8 }),
    panels.timeSeries.genericLegendCounter('p99KubeletCroupManagerDuration - Destroy', 'short', queries.p99KubeletCroupManagerDurationDestroy.query(), { x: 16, y: 19, w: 8, h: 8 }),
  ]),
  g.panel.row.new('Kubelet Resource Usage')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 Kubelet Process CPU Usage(% of 1 core)', 'percent', queries.kubeletCPU.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Top 10 Kubelet Process Resident Memory', 'bytes', queries.kubeletMemory.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Kubelet HTTP requests Performance')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Kubelet HTTP requests count by path', 'none', queries.kubeletHttpRequestsCountByPath.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Kubelet HTTP requests count by node', 'none', queries.kubeletHttpRequestsCountByNode.query(), { x: 12, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Kubelet HTTP requests latency per request by path (ms)', 'none', queries.kubeletHttpRequestsLatencyPerRequestByPath.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Kubelet HTTP requests latency per request by node (ms)> 200ms Warning, > 500ms Critical', 'none', queries.kubeletHttpRequestsLatencyPerRequestByNode.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('CRIO Operation')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegendCounter('Workers Runtime Crio Operations Errors/second, > 0.001 Warning, >0.01 Critical', 'short', queries.workersRuntimeCrioOperationsErrors.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane Runtime Crio Operations Errors/second, > 0.001 Warning, >0.01 Critical', 'short', queries.controlPlaneRuntimeCrioOperationsErrors.query(), { x: 12, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Workers Runtime Crio Operations Latency Avg(second), > 1s Warning, >5s Critical', 'short', queries.workerCrioOperationsLatencyPerSeconds.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Control Plane Runtime Crio Operations Latency Avg(second), > 1s Warning, >5s Critical', 'short', queries.controlPlaneCrioOperationsLatencyPerSeconds.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('CRIO Resource Usage')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 crio Process CPU Usage(% of 1 core)', 'percent', queries.crioCPU.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegendCounter('Top 10 crio Process Resident Memory', 'bytes', queries.crioMemory.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('iNodes Usage')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('inodes usage in /run', 'percent', queries.crioINodes.query(), { x: 0, y: 19, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('inodes count in /run', 'none', queries.crioINodesCount.query(), { x: 12, y: 19, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Pod Lifecycle Event Generator (PLEG)')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('P95 PLEG Latency (s), >1s Waning, >3s Critical', 'short', queries.p95PLEGLatency.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('P95 PLEG Latency (s), >3s Waning, >5s Critical', 'short', queries.p99PLEGLatency.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Average Latency  (s), >0.5s Waning, >1s Critical', 'short', queries.averagePLEGLatency.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('PLEG Relist Count in 5 mins, <150 Waning, <50 Critical', 'short', queries.pLEGRelistCount5Minutes.query(), { x: 12, y: 2, w: 12, h: 8 }),
  ]),
  g.panel.row.new('PSI - Containers (need to enable PSI)')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 Container Pressure Memory Stalled, >1% Waning, >5% Critical', 'percent', queries.top10ContainerPressureMemoryStalled.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Container Pressure Memory Waiting, >5% Waning, >10% Critical', 'percent', queries.top10ContainerPressureMemoryWaiting.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Container Pressure CPU Stalled, >1% Waning, >5% Critical', 'percent', queries.top10ContainerPressureCPUStalled.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Container Pressure CPU Waiting, >20% Waning, >50% Critical', 'percent', queries.top10ContainerPressureCPUWaiting.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Container Pressure IO Stalled, >5% Waning, >10% Critical', 'percent', queries.top10ContainerPressureIOStalled.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Container Pressure IO Waiting, >10% Waning, >30% Critical', 'percent', queries.top10ContainerPressureIOWaiting.query(), { x: 12, y: 2, w: 12, h: 8 }),
  ]),
  g.panel.row.new('PSI - Nodes (need to enable PSI)')
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.genericLegend('Top 10 Node Pressure Memory Stalled, >1% Waning, >5% Critical', 'percent', queries.top10NodePressureMemoryStalled.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Node Pressure Memory Waiting, >10% Waning, >30% Critical', 'percent', queries.top10NodePressureMemoryWaiting.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Node Pressure IO Stalled, >10% Waning, >30% Critical', 'percent', queries.top10NodePressureIOStalled.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Node Pressure IO Waiting, >30% Waning, >60% Critical', 'percent', queries.top10NodePressureIOWaiting.query(), { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Node Pressure CPU Waiting, >5% Waning, >20% Critical', 'percent', queries.top10NodePressureCPUWaiting.query(), { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericLegend('Top 10 Node Pressure IRQ Stalled, >5% Waning, >10% Critical', 'percent', queries.top10NodePressureIRQStalled.query(), { x: 12, y: 2, w: 12, h: 8 }),
  ]),
])
