local panels = import '../../assets/ovn-monitoring/panels.libsonnet';
local queries = import '../../assets/ovn-monitoring/queries.libsonnet';
local variables = import '../../assets/ovn-monitoring/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('OVN-Monitoring-dashboard')
+ g.dashboard.time.withFrom('now-1h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(false)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables._master_node,
  variables._worker_node,
  variables.master_pod,
  variables.kubenode_pod,
])


+ g.dashboard.withPanels([
  g.panel.row.new('OVN Resource Monitoring')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withPanels([
    panels.stat.genericstatThresoldPanel('OVNKube Master', 'none', queries.ovnClusterManagerLeader.query(), { x: 0, y: 0, w: 8, h: 4 }),
    panels.stat.genericstatThresoldPanel('OVN Northd Status', 'none', queries.ovnNorthd.query(), { x: 8, y: 0, w: 8, h: 4 }),
    panels.stat.genericstatThresoldOVNControllerPanel('OVN controller', 'none', queries.numOnvController.query(), { x: 16, y: 0, w: 8, h: 4 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('ovnkube-control-plane CPU Usage', 'percent', queries.ovnKubeControlPlaneCPU.query(), { x: 0, y: 4, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('ovnkube-control-plane Memory Usage', 'bytes', queries.ovnKubeControlPlaneMem.query(), { x: 12, y: 4, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Top 10 ovn-controller CPU Usage', 'percent', queries.topOvnControllerCPU.query(), { x: 0, y: 12, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Top 10  ovn-controller Memory Usage', 'bytes', queries.topOvnControllerMem.query(), { x: 12, y: 12, w: 12, h: 10 }),
  ]),
  g.panel.row.new('Latency Monitoring')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withPanels([
    panels.timeSeries.genericTimeSeriesLegendPanel('Pod Annotation Latency', 's', queries.ovnAnnotationLatency.query(), { x: 0, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('CNI Request ADD Latency', 's', queries.ovnCNIAdd.query(), { x: 12, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Pod creation Latency', 's', queries.podLatency.query(), { x: 0, y: 8, w: 24, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Sync Service Latency', 's', queries.synclatency.query(), { x: 0, y: 16, w: 24, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Duration for OVN to apply network configuration', 's', queries.ovnLatencyCalculate.query(), { x: 0, y: 24, w: 24, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Node Ready Latency', 's', queries.ovnkubeNodeReadyLatency.query(), { x: 0, y: 32, w: 24, h: 10 }),
  ]),
  g.panel.row.new('WorkQueue Monitoring')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withPanels([
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Master workqueue', 'short', queries.workQueue.query(), { x: 0, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Master workqueue Depth', 'short', queries.workQueueDepth.query(), { x: 12, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Master workqueue duration', 's', queries.workQueueLatency.query(), { x: 0, y: 8, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Master workqueue - Unfinished', 's', queries.workQueueUnfinishedLatency.query(), { x: 12, y: 8, w: 12, h: 10 }),
  ]),
])
