local annotation = import '../../assets/pgbench-dashboard/annotation.libsonnet';
local panels = import '../../assets/pgbench-dashboard/panels.libsonnet';
local queries = import '../../assets/pgbench-dashboard/queries.libsonnet';
local variables = import '../../assets/pgbench-dashboard/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Pgbench')
+ g.dashboard.time.withFrom('now/y')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(true)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource1,
  variables.Datasource2,
  variables.uuid,
  variables.user,
])
+ g.dashboard.withAnnotations([
  annotation.run_start_timestamp,
  annotation.sample_start_timestamp,
])
+ g.dashboard.withPanels([
  panels.timeSeries.tps_report('TPS Report', 'ops', queries.tps_report.query(), { x: 0, y: 0, w: 12, h: 9 }),
  panels.timeSeries.avg_tps('Overall Average TPS Per Run', 'ops', queries.avg_tps.query(), { x: 12, y: 0, w: 12, h: 9 }),
  panels.heatmap.base('Latency Report', 'ms', queries.latency_report.query(), { x: 0, y: 9, w: 12, h: 9 }),
  panels.table.base('Result Summary', queries.results.query(), { x: 12, y: 9, w: 12, h: 9 }),

])
