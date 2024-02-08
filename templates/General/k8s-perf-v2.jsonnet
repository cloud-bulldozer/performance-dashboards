local panels = import '../../assets/k8s-perf/panels.libsonnet';
local queries = import '../../assets/k8s-perf/queries.libsonnet';
local variables = import '../../assets/k8s-perf/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('k8s Performance dashboard')
+ g.dashboard.time.withFrom('now-1h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('30s')
+ g.dashboard.withEditable(false)
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
  g.panel.row.new('Cluster Details')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withPanels([
    panels.stat.genericStatLegendPanel('Current Node Count', 'none', queries.currentNodeCount.query(), { x: 0, y: 4, w: 8, h: 3 }),
    panels.stat.genericStatLegendPanel('Current namespace Count', 'none', queries.currentNamespaceCount.query(), { x: 8, y: 4, w: 8, h: 3 }),
    panels.stat.genericStatLegendPanel('Current Pod Count', 'none', queries.currentPodCount.query(), { x: 16, y: 4, w: 8, h: 3 }),
    panels.timeSeries.genericTimeSeriesPanel('Number of nodes', 'none', queries.numberOfNodes.query(), { x: 0, y: 12, w: 8, h: 8 }),
    panels.timeSeries.genericTimeSeriesPanel('Namespace count', 'none', queries.namespaceCount.query(), { x: 8, y: 12, w: 8, h: 8 }),
    panels.timeSeries.genericTimeSeriesPanel('Pod count', 'none', queries.podCount.query(), { x: 16, y: 12, w: 8, h: 8 }),
    panels.timeSeries.genericTimeSeriesPanel('Secret & configmap count', 'none', queries.secretAndConfigMapCount.query(), { x: 0, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericTimeSeriesPanel('Deployment count', 'none', queries.deployCount.query(), { x: 8, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericTimeSeriesPanel('Services count', 'none', queries.serviceCount.query(), { x: 16, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Top 10 container RSS', 'bytes', queries.top10ContainerRSS.query(), { x: 0, y: 28, w: 24, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Top 10 container CPU', 'percent', queries.top10ContainerCPU.query(), { x: 0, y: 36, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesPanel('Goroutines count', 'none', queries.goroutinesCount.query(), { x: 12, y: 36, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Pod Distribution', 'none', queries.podDistribution.query(), { x: 0, y: 44, w: 24, h: 8 }),
  ]),

  g.panel.row.new('Node: $_worker_node')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withRepeat('_worker_node')
  + g.panel.row.withPanels([
    panels.timeSeries.genericTimeSeriesLegendPanel('CPU Basic: $_worker_node ', 'percent', queries.basicCPU.query('$_worker_node'), { x: 0, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('System Memory: $_worker_node ', 'bytes', queries.systemMemory.query('$_worker_node'), { x: 12, y: 0, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Disk throughput: $_worker_node ', 'Bps', queries.diskThroughput.query('$_worker_node'), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Disk IOPS: $_worker_node', 'iops', queries.diskIOPS.query('$_worker_node'), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Network Utilization: $_worker_node', 'bps', queries.networkUtilization.query('$_worker_node'), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Network Packets: $_worker_node', 'pps', queries.networkPackets.query('$_worker_node'), { x: 12, y: 16, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Network packets drop: $_worker_node', 'pps', queries.networkDrop.query('$_worker_node'), { x: 0, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Conntrack stats: $_worker_node', '', queries.conntrackStats.query('$_worker_node'), { x: 12, y: 24, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Top 10 container CPU: $_worker_node', 'percent', queries.top10ContainersCPU.query('$_worker_node'), { x: 0, y: 32, w: 12, h: 8 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Top 10 container RSS:  $_worker_node', 'bytes', queries.top10ContainersRSS.query(' $_worker_node'), { x: 12, y: 32, w: 12, h: 8 }),

  ]),
])
