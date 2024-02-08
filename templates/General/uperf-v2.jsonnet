local panels = import '../../assets/uperf/panels.libsonnet';
local queries = import '../../assets/uperf/queries.libsonnet';
local variables = import '../../assets/uperf/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Public - UPerf Results dashboard')
+ g.dashboard.withTags(['network', 'performance'])
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
  variables.uuid,
  variables.cluster_name,
  variables.user,
  variables.iteration,
  variables.server,
  variables.test_type,
  variables.protocol,
  variables.message_size,
  variables.threads,
])
+ g.dashboard.withPanels([
  panels.timeSeries.uperfPerformance('UPerf Performance : Throughput per-second', 'bps', queries.throughput.query(), { x: 0, y: 0, w: 12, h: 9 }),
  panels.timeSeries.uperfPerformance('UPerf Performance : Operations per-second', 'pps', queries.operations.query(), { x: 12, y: 0, w: 12, h: 9 }),
  panels.table.base('UPerf Result Summary', queries.results.query(), { x: 0, y: 20, w: 24, h: 18 }),
])
