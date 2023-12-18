local panels = import '../../assets/cilium-k8s-perf/panels.libsonnet';
local queries = import '../../assets/cilium-k8s-perf/queries.libsonnet';
local variables = import '../../assets/cilium-k8s-perf/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Cilium k8s Performance')
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
  variables._worker_node,
  variables.namespace,
  variables.block_device,
  variables.net_device,
  variables.interval,
])

+ g.dashboard.withPanels([
  g.panel.row.new('Cilium Details')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.withCiliumAgg('Cilium Controller Failures', 'none', queries.ciliumControllerFailures.query(), { x: 0, y: 1, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Cilium IP Address Allocation', 'none', queries.ciliumIPAddressAllocation.query(), { x: 12, y: 1, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Cilium Container CPU', 'percent', queries.ciliumContainerCPU.query(), { x: 0, y: 9, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Cilium Container Memory', 'bytes', queries.ciliumConatinerMemory.query(), { x: 12, y: 9, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Cilium Network Polices Per Agent', 'none', queries.ciliumNetworkPolicesPerAgent.query(), { x: 0, y: 17, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Cilium BPF Operations', 'none', queries.ciliumBPFOperations.query(), { x: 12, y: 17, w: 12, h: 8 }),
  ]),
  g.panel.row.new('Cluster Details')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.stat.withclusterAgg('Current Node Count', 'none', queries.currentNodeCount.query(), { x: 0, y: 26, w: 8, h: 3 }),
    panels.stat.withclusterAgg('Current namespace Count', 'none', queries.currentNamespaceCount.query(), { x: 8, y: 26, w: 8, h: 3 }),
    panels.stat.withclusterAgg('Current Pod Count', 'none', queries.currentPodCount.query(), { x: 16, y: 26, w: 8, h: 3 }),
    panels.timeSeries.withClusterAgg('Number of nodes', 'none', queries.numberOfNodes.query(), { x: 0, y: 29, w: 8, h: 8 }),
    panels.timeSeries.withClusterAgg('Namespace count', 'none', queries.namespaceCount.query(), { x: 8, y: 29, w: 8, h: 8 }),
    panels.timeSeries.withClusterAgg('Pod count', 'none', queries.podCount.query(), { x: 16, y: 29, w: 8, h: 8 }),
    panels.timeSeries.withClusterAgg('Secret & configmap count', 'none', queries.secretConfigmapCount.query(), { x: 0, y: 37, w: 8, h: 8 }),
    panels.timeSeries.withClusterAgg('Deployment count', 'none', queries.deploymentCount.query(), { x: 8, y: 37, w: 8, h: 8 }),
    panels.timeSeries.withClusterAgg('Services count', 'none', queries.serviceCount.query(), { x: 16, y: 37, w: 8, h: 8 }),
    panels.timeSeries.withCiliumAgg('Top 10 container RSS', 'bytes', queries.top10ContainerRSS.query(), { x: 0, y: 45, w: 24, h: 8 }),
    panels.timeSeries.withCiliumAgg('Top 10 container CPU', 'percent', queries.top10ContainerCPU.query(), { x: 0, y: 53, w: 12, h: 8 }),
    panels.timeSeries.withClusterAgg('Goroutines count', 'none', queries.goroutinesCount.query(), { x: 12, y: 53, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Pod Distribution', 'none', queries.podDistribution.query(), { x: 0, y: 61, w: 24, h: 8 }),
  ]),

  g.panel.row.new('Node: $_worker_node')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('_worker_node')
  + g.panel.row.withPanels([
    panels.timeSeries.withCiliumAgg('CPU Basic: $_worker_node', 'percent', queries.CPUBasic.query(), { x: 0, y: 70, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('System Memory: $_worker_node', 'bytes', queries.SystemMemory.query(), { x: 12, y: 70, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Disk throughput: $_worker_node', 'Bps', queries.DiskThroughput.query(), { x: 0, y: 78, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Disk IOPS: $_worker_node', 'iops', queries.DiskIOPS.query(), { x: 12, y: 78, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Network Utilization: $_worker_node', 'bps', queries.networkUtilization.query(), { x: 0, y: 86, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Network Packets: $_worker_node', 'pps', queries.networkPackets.query(), { x: 12, y: 86, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Network packets drop: $_worker_node', 'pps', queries.networkPacketDrop.query(), { x: 0, y: 94, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Conntrack stats: $_worker_node', '', queries.conntrackStats.query(), { x: 12, y: 94, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Top 10 container CPU: $_worker_node', 'percent', queries.top10ContainerCPUNode.query(), { x: 0, y: 102, w: 12, h: 8 }),
    panels.timeSeries.withCiliumAgg('Top 10 container RSS: $_worker_node', 'bytes', queries.top10ContainerRSSNode.query(), { x: 12, y: 102, w: 12, h: 8 }),
  ]),


])
