local panels = import '../../assets/ingress-performance-ocp/panels.libsonnet';
local queries = import '../../assets/ingress-performance-ocp/queries.libsonnet';
local variables = import '../../assets/ingress-performance-ocp/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Ingress-perf')
+ g.dashboard.withDescription(|||
  Dashboard for Ingress Performance
|||)
+ g.dashboard.withTags('ingress-perf')
+ g.dashboard.time.withFrom('now-12h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(false)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.platform,
  variables.clusterType,
  variables.workerNodesCount,
  variables.infraNodesType,
  variables.ocpMajorVersion,
  variables.uuid,
  variables.termination,
  variables.latency_metric,
  variables.compare_by,
  variables.all_uuids,
])
+ g.dashboard.withPanels([
  g.panel.row.new('SLIs - by Version')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.stat.withAvgThresholds('Average RPS - $termination', 'reqps', queries.avgRPSAll.query(), { x: 0, y: 1, w: 6, h: 3 }),
    panels.stat.withAvgTimeThresholds('$latency_metric - $termination', 'µs', queries.avgTime.query(), { x: 0, y: 1, w: 6, h: 3 }),
  ]),
  g.panel.row.new('Workloads summary')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.table.withWorkloadSummary('', '', queries.workloadSummary.query(), { x: 0, y: 2, w: 24, h: 6 }),
  ]),
  g.panel.row.new('$termination')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('termination')
  + g.panel.row.withPanels([
    panels.timeSeries.withMeanReq('RPS $termination trend', 'reqps', queries.trendRPS.query(), { x: 0, y: 15, w: 12, h: 8 }),
    panels.timeSeries.withMeanReq('$latency_metric trend', 'µs', queries.latencyTrend.query(), { x: 12, y: 15, w: 12, h: 8 }),
    panels.bargauge.withAvgTimeThresholds('RPS $termination', 'reqps', queries.terminationRPS.query(), { x: 0, y: 23, w: 12, h: 7 }),
    panels.bargauge.withAvgTimeThresholds('$latency_metric $termination', 'µs', queries.latencyTermination.query(), { x: 12, y: 23, w: 12, h: 7 }),
    panels.bargauge.withAvgTimeThresholds('HAProxy avg CPU usage $termination', 'percent', queries.HAProxyAvgCPUUsage.query(), { x: 0, y: 30, w: 12, h: 7 }),
    panels.bargauge.withAvgTimeThresholds('Infra nodes CPU usage $termination', 'percent', queries.InfraNodesCPUUsageEdge.query(), { x: 12, y: 30, w: 12, h: 7 }),
    panels.gauge.withAvgTimeThresholds('RPS data quality', 'none', queries.qualityRPS.query(), { x: 0, y: 30, w: 12, h: 4 }),
    panels.gauge.withAvgTimeThresholds('Data quality: $latency_metric', 'none', queries.dataQuality.query(), { x: 12, y: 30, w: 12, h: 4 }),
    panels.table.withTerminationRawData('$termination raw data', 'short', queries.rawData.query(), { x: 8, y: 118, w: 24, h: 8 }),
  ]),
])
