local variables = import './variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local prometheus = g.query.prometheus;

{
  request_duration_99th_quantile: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[$interval])) by(verb,le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{verb}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestRateByInstance: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",code=~"$code",verb=~"$verb"}[$interval])) by(instance)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{instance}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestDuarationByResource: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[$interval])) by(resource,le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{resource}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestRateByResource: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",code=~"$code",verb=~"$verb"}[$interval])) by(resource)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{resource}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestDurationReadWrite: {
    query():
      [
        prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"LIST|GET"}[$interval])) by(le))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('read')
        + prometheus.withDatasource('$Datasource'),

        prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[$interval])) by(le))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('write')
        + prometheus.withDatasource('$Datasource'),
      ],
  },

  requestRateReadWrite: {
    query():
      [
        prometheus.withExpr('sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"LIST|GET"}[$interval]))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('read')
        + prometheus.withDatasource('$Datasource'),

        prometheus.withExpr('sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[$interval]))')
        + prometheus.withFormat('time_series')
        + prometheus.withIntervalFactor(2)
        + prometheus.withLegendFormat('write')
        + prometheus.withDatasource('$Datasource'),
      ],
  },

  requestRateDropped: {
    query():
      prometheus.withExpr('sum(rate(apiserver_dropped_requests_total{instance=~"$instance"}[$interval])) by (requestKind)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('')
      + prometheus.withDatasource('$Datasource'),
  },

  requestRateTerminated: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_terminations_total{instance=~"$instance",resource=~"$resource",code=~"$code"}[$interval])) by(component)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('')
      + prometheus.withDatasource('$Datasource'),
  },

  requestRateStatus: {
    query():
      prometheus.withExpr('sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"$verb",code=~"$code"}[$interval])) by(code)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{code}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestsLongRunning: {
    query():
      prometheus.withExpr('sum(apiserver_longrunning_gauge{instance=~"$instance",resource=~"$resource",verb=~"$verb"}) by(instance)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{instance}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestInFlight: {
    query():
      prometheus.withExpr('sum(apiserver_current_inflight_requests{instance=~"$instance"}) by (instance,requestKind)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{requestKind}}-{{instance}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestRejectPandF: {
    query():
      prometheus.withExpr('sum(rate(apiserver_flowcontrol_rejected_requests_total{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by (reason)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('')
      + prometheus.withDatasource('$Datasource'),
  },

  responseSize99Quatile: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_response_sizes_bucket{instance=~"$instance",resource=~"$resource",verb=~"$verb"}[$interval])) by(instance,le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{instance}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestQueueLengthPandF: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_queue_length_after_enqueue_bucket{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema, priorityLevel, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestWaitDuration99QuatilePandF: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_wait_duration_seconds_bucket{instance=~"$instance"}[5m])) by(flow_schema, priority_level, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('')
      + prometheus.withDatasource('$Datasource'),
  },

  requestDispatchRatePandF: {
    query():
      prometheus.withExpr('sum(rate(apiserver_flowcontrol_dispatched_requests_total{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema,priorityLevel)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withDatasource('$Datasource'),
  },

  requestExecutionDurationPandF: {
    query():
      prometheus.withExpr('histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_execution_seconds_bucket{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema, priorityLevel, le))')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withDatasource('$Datasource'),
  },

  pendingInQueuePandF: {
    query():
      prometheus.withExpr('sum(apiserver_flowcontrol_current_inqueue_requests{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}) by (flowSchema,priorityLevel)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('{{flowSchema}}:{{priorityLevel}}')
      + prometheus.withDatasource('$Datasource'),
  },

  concurrencyLimitByKubeapiserverPandF: {
    query():
      prometheus.withExpr('sum(apiserver_flowcontrol_request_concurrency_limit{instance=~".*:6443",priorityLevel=~"$priorityLevel"}) by (instance,priorityLevel)')
      + prometheus.withFormat('time_series')
      + prometheus.withIntervalFactor(2)
      + prometheus.withLegendFormat('')
      + prometheus.withDatasource('$Datasource'),
  },
}
