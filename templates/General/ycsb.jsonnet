local panels = import '../../assets/ycsb/panels.libsonnet';
local queries = import '../../assets/ycsb/queries.libsonnet';
local variables = import '../../assets/ycsb/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('YCSB')
+ g.dashboard.time.withFrom('now/y')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(false)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource1,
  variables.Datasource2,
  variables.uuid,
  variables.user,
  variables.phase,
  variables.operation,
])
+ g.dashboard.withPanels([
  panels.timeSeries.throughputOvertimePhase('Throughput overtime - Phase = $phase : Operation = $operation', '$Datasource1', 'ops', queries.throughput_overtime.query(), { x: 0, y: 0, w: 12, h: 9 }),
  panels.timeSeries.latency90percReportedFromYCSB('Phase = $phase :: Latency - 90%tile Reported from YCSB', '$Datasource1', 'µs', queries.phase_average_latency.query(), { x: 12, y: 0, w: 12, h: 9 }),
  panels.timeSeries.LatancyofEachWorkloadPerYCSBOperation('95th% Latency of each workload per YCSB Operation', '$Datasource2', 'µs', queries.latency_95.query(), { x: 0, y: 9, w: 24, h: 6 }),
  panels.timeSeries.overallThroughputPerYCSB('Overall Throughput per YCSB Workload', '$Datasource2', 'ops', queries.overall_workload_throughput.query(), { x: 0, y: 15, w: 16, h: 10 }),
  panels.table.base('Phase = $phase :: $operation - Count', '$Datasource2', queries.aggregate_operation_sum.query(), { x: 16, y: 15, w: 8, h: 10 }),
])
