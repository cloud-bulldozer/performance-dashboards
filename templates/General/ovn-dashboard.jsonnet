local panels = import '../../assets/ovn-monitoring/panels.libsonnet';
local queries = import '../../assets/ovn-monitoring/queries.libsonnet';
local variables = import '../../assets/ovn-monitoring/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Openshift Networking')
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
    panels.stat.genericstatThresoldPanel('OVNKube Cluster Manager Leader', 'none', queries.ovnClusterManagerLeader.query(), { x: 0, y: 0, w: 8, h: 4 }),
    panels.stat.genericstatThresoldPanel('OVN Northd Status', 'none', queries.ovnNorthd.query(), { x: 8, y: 0, w: 8, h: 4 }),
    panels.stat.genericstatThresoldOVNControllerPanel('OVN Controller Count', 'none', queries.numOnvController.query(), { x: 16, y: 0, w: 8, h: 4 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Control Plane CPU Usage', 'percent', queries.ovnKubeControlPlaneCPU.query(), { x: 0, y: 4, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Control Plane Memory Usage', 'bytes', queries.ovnKubeControlPlaneMem.query(), { x: 12, y: 4, w: 12, h: 10 }),
  ]),
  g.panel.row.new('Pod Startup Latency Breakdown')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withPanels([
    panels.timeSeries.genericTimeSeriesLegendPanel('Scheduler Pod Scheduling Duration (P99)', 's', queries.podSchedulingLatency.query(), { x: 0, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Pod First Seen to LSP Created Latency (P99)', 's', queries.firstSeenToLSPCreated.query(), { x: 12, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Pod Annotation Latency (P99)', 's', queries.ovnAnnotationLatency.query(), { x: 0, y: 10, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Port Binding After LSP Creation Latency (P99)', 's', queries.lspCreated.query(), { x: 12, y: 10, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Port Binding to Chassis Assignment Latency (P99)', 's', queries.lspToChassis.query(), { x: 0, y: 20, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Port Marked As Up (P99)', 's', queries.portMarkedAsUp.query(), { x: 12, y: 20, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('CNI Request ADD Latency (P99)', 's', queries.ovnCNIAdd.query(), { x: 0, y: 30, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Network Programming Complete (P99)', 's', queries.networkProgrammingComplete.query(), { x: 12, y: 30, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Sync Service Latency', 's', queries.synclatency.query(), { x: 0, y: 40, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Node Ready Latency', 's', queries.ovnkubeNodeReadyLatency.query(), { x: 12, y: 40, w: 12, h: 10 }),
  ]),
  g.panel.row.new('OVN Component Resource Usage')
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withGridPos({ x: 0, y: 0, w: 24, h: 1 })
  + g.panel.row.withPanels([
    // Worker node pod resource usage
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Node Pods CPU Usage (Top 10)', 'percent', queries.topOvnkubenodePodCPU.query(), { x: 0, y: 0, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Node Pods Memory Usage (Top 10)', 'bytes', queries.topOvnkubenodePodMem.query(), { x: 12, y: 0, w: 12, h: 10 }),

    // Component resource usage
    panels.timeSeries.genericTimeSeriesLegendPanel('Northd CPU Usage (Top 10)', 'percent', queries.topNorthdCPU.query(), { x: 0, y: 8, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Northd Memory Usage (Top 10)', 'bytes', queries.topNorthdMem.query(), { x: 12, y: 8, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Sbdb CPU Usage (Top 10)', 'percent', queries.topSbdbCPU.query(), { x: 0, y: 16, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Sbdb Memory Usage (Top 10)', 'bytes', queries.topSbdbMem.query(), { x: 12, y: 16, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Nbdb CPU Usage (Top 10)', 'percent', queries.topNbdbCPU.query(), { x: 0, y: 24, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('Nbdb Memory Usage (Top 10)', 'bytes', queries.topNbdbMem.query(), { x: 12, y: 24, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Controller CPU Usage (Top 10)', 'percent', queries.topOvnkubeControllerCPU.query(), { x: 0, y: 32, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVNKube Controller Memory Usage (Top 10)', 'bytes', queries.topOvnkubeControllerMem.query(), { x: 12, y: 32, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVN Controller CPU Usage (Top 10)', 'percent', queries.topOvnControllerCPU.query(), { x: 0, y: 40, w: 12, h: 10 }),
    panels.timeSeries.genericTimeSeriesLegendPanel('OVN Controller Memory Usage (Top 10)', 'bytes', queries.topOvnControllerMem.query(), { x: 12, y: 40, w: 12, h: 10 }),
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
