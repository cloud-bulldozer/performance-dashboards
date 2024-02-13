local panels = import '../../assets/vegeta-wrapper/panels.libsonnet';
local queries = import '../../assets/vegeta-wrapper/queries.libsonnet';
local variables = import '../../assets/vegeta-wrapper/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Vegeta Results')
+ g.dashboard.withDescription(|||
  Dashboard for Ingress Performance
|||)
+ g.dashboard.withTags('')
+ g.dashboard.time.withFrom('now-24h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(false)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.uuid,
  variables.hostname,
  variables.targets,
  variables.iteration,
])
+ g.dashboard.withPanels([
  panels.timeSeries.legendDisplayModeTable('RPS (rate of sent requests per second)', 'reqps', queries.rps.query(), { x: 0, y: 0, w: 12, h: 9 }),
  panels.timeSeries.legendDisplayModeTable('Throughput (rate of successful requests per second)', 'reqps', queries.throughput.query(), { x: 12, y: 0, w: 12, h: 9 }),
  panels.timeSeries.legendDisplayModeTable('Request Latency (observed over given interval)', 'µs', queries.latency.query(), { x: 0, y: 12, w: 12, h: 9 }),
  panels.table.base('Vegeta Result Summary', queries.results.query(), { x: 0, y: 24, w: 24, h: 9 }),
])
