local panels = import '../../assets/api-performance-overview/panels.libsonnet';
local queries = import '../../assets/api-performance-overview/queries.libsonnet';
local variables = import '../../assets/api-performance-overview/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('API-Performance')
+ g.dashboard.withDescription(|||
  Dashboard for Api-performance-overview
|||)
+ g.dashboard.withTags('Api-performance')
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
  variables.apiserver,
  variables.instance,
  variables.resource,
  variables.code,
  variables.verb,
  variables.flowSchema,
  variables.priorityLevel,
  variables.interval,
])

+ g.dashboard.withPanels([

  panels.timeSeries.withCommonAggregations('request duration - 99th quantile', 'short', queries.requestDuration99thQuantile.query(), { x: 0, y: 0, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('request rate - by instance', 'short', queries.requestRateByInstance.query(), { x: 12, y: 0, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('request duration - 99th quantile - by resource', 'short', queries.requestDuarationByResource.query(), { x: 0, y: 8, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('request duration - 99th quantile', 'short', queries.requestDurationBy99Quatile.query(), { x: 12, y: 8, w: 12, h: 8 }),
  panels.timeSeries.withReadWriteSettings('request duration - read vs write', 'short', queries.requestDurationReadWrite.query(), { x: 0, y: 16, w: 12, h: 8 }),
  panels.timeSeries.withReadWriteSettings('request rate - read vs write', 'short', queries.requestRateReadWrite.query(), { x: 12, y: 16, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('requests dropped rate', 'short', queries.requestRateDropped.query(), { x: 0, y: 24, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('requests terminated rate', 'short', queries.requestRateTerminated.query(), { x: 12, y: 24, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('requests status rate', 'short', queries.requestRateStatus.query(), { x: 0, y: 32, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('long running requests', 'short', queries.requestsLongRunning.query(), { x: 12, y: 32, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('request in flight', 'short', queries.requestInFlight.query(), { x: 0, y: 40, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('p&f - requests rejected', 'short', queries.requestRejectPandF.query(), { x: 12, y: 40, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('response size - 99th quantile', 'short', queries.responseSize99Quatile.query(), { x: 0, y: 48, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('p&f - request queue length', 'short', queries.requestQueueLengthPandF.query(), { x: 12, y: 48, w: 12, h: 8 }),
  panels.timeSeries.withRequestWaitDurationAggregations('p&f - request wait duration - 99th quantile', 'short', queries.requestWaitDuration99QuatilePandF.query(), { x: 0, y: 56, w: 24, h: 8 }),
  panels.timeSeries.withCommonAggregations('p&f - request dispatch rate', 'short', queries.requestDispatchRatePandF.query(), { x: 0, y: 64, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('p&f - request execution duration', 'short', queries.requestExecutionDurationPandF.query(), { x: 12, y: 64, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('p&f - pending in queue', 'short', queries.PendingInQueuePandF.query(), { x: 0, y: 72, w: 12, h: 8 }),
  panels.timeSeries.withCommonAggregations('p&f - concurrency limit by kube-apiserver', 'short', queries.ConcurrencyLimitByKubeapiserverPandF.query(), { x: 12, y: 72, w: 12, h: 8 }),
])