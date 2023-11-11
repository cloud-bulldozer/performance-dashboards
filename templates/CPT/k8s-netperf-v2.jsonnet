local panels = import '../../assets/k8s-netperf/panels.libsonnet';
local queries = import '../../assets/k8s-netperf/queries.libsonnet';
local variables = import '../../assets/k8s-netperf/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('k8s-netperf')
+ g.dashboard.time.withFrom('now-6h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(true)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.datasource,
  variables.platform,
  variables.workers,
  variables.uuid,
  variables.hostNetwork,
  variables.service,
  variables.streams,
  variables.throughput_profile,
  variables.latency_profile,
  variables.messageSize,
  variables.driver,
])
+ g.dashboard.withPanels([
  panels.row.base('$latency_profile', 'latency_profile', { x: 0, y: 0, w: 24, h: 1 }),
  panels.timeSeries.base('$latency_profile - $driver - $messageSize', queries.all.query('$latency_profile', 'latency'), { x: 0, y: 0, w: 24, h: 8 }),
  panels.row.base('$throughput_profile', 'throughput_profile', { x: 0, y: 9, w: 24, h: 1 }),
  panels.timeSeries.withThroughputOverrides('$throughput_profile - $driver - $messageSize', queries.all.query('$throughput_profile', 'throughput'), { x: 0, y: 10, w: 24, h: 8 }),
  panels.row.base('Parallelism $parallelism', 'parallelism', { x: 0, y: 18, w: 24, h: 1 }),
  panels.table.base('Throughput - Parallelism: $parallelism', queries.parallelismAll.query('$throughput_profile', 'throughput'), { x: 0, y: 19, w: 24, h: 11 }),
  panels.table.withLatencyOverrides('Latency - Parallelism: $parallelism', queries.parallelismAll.query('$latency_profile', 'latency'), { x: 0, y: 19, w: 24, h: 11 }),
])
