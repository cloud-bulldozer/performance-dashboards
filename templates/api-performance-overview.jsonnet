local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;

//Panel definitions

local request_duration_99th_quantile = grafana.graphPanel.new(
  title='request duration - 99th quantile',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[$interval])) by(verb,le))',
    legendFormat='{{verb}}',
  )
);

local request_rate_by_instance = grafana.graphPanel.new(
  title='request rate - by instance',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",code=~"$code",verb=~"$verb"}[$interval])) by(instance)',
    legendFormat='{{instance}}',
  )
);

local request_duration_99th_quantile_by_resource = grafana.graphPanel.new(
  title='request duration - 99th quantile - by resource',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",subresource!="log",verb!~"WATCH|WATCHLIST|PROXY"}[$interval])) by(resource,le))',
    legendFormat='{{resource}}',
  )
);

local request_rate_by_resource = grafana.graphPanel.new(
  title='request duration - 99th quantile',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",code=~"$code",verb=~"$verb"}[$interval])) by(resource)',
    legendFormat='{{resource}}',
  )
);

local request_duration_read_write = grafana.graphPanel.new(
  title='request duration - read vs write',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"LIST|GET"}[$interval])) by(le))',
    legendFormat='read',
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[$interval])) by(le))',
    legendFormat='write',
  )
);


local request_rate_read_write = grafana.graphPanel.new(
  title='request rate - read vs write',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"LIST|GET"}[$interval]))',
    legendFormat='read',
  )
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"POST|PUT|PATCH|UPDATE|DELETE"}[$interval]))',
    legendFormat='write',
  )
);


local requests_dropped_rate = grafana.graphPanel.new(
  title='requests dropped rate',
  datasource='$datasource',
  description='Number of requests dropped with "Try again later" response',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_dropped_requests_total{instance=~"$instance"}[$interval])) by (requestKind)',
  )
);


local requests_terminated_rate = grafana.graphPanel.new(
  title='requests terminated rate',
  datasource='$datasource',
  description='Number of requests which apiserver terminated in self-defense',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_terminations_total{instance=~"$instance",resource=~"$resource",code=~"$code"}[$interval])) by(component)',
  )
);

local requests_status_rate = grafana.graphPanel.new(
  title='requests status rate',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_request_total{apiserver=~"$apiserver",instance=~"$instance",resource=~"$resource",verb=~"$verb",code=~"$code"}[$interval])) by(code)',
    legendFormat='{{code}}'
  )
);

local long_running_requests = grafana.graphPanel.new(
  title='long running requests',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(apiserver_longrunning_gauge{instance=~"$instance",resource=~"$resource",verb=~"$verb"}) by(instance)',
    legendFormat='{{instance}}'
  )
);

local request_in_flight = grafana.graphPanel.new(
  title='request in flight',
  datasource='$datasource',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(apiserver_current_inflight_requests{instance=~"$instance"}) by (instance,requestKind)',
    legendFormat='{{requestKind}}-{{instance}}',
  )
);

local pf_requests_rejected = grafana.graphPanel.new(
  title='p&f - requests rejected',
  datasource='$datasource',
  description='Number of requests rejected by API Priority and Fairness system',
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_flowcontrol_rejected_requests_total{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by (reason)',
  )
);

local response_size_99th_quartile = grafana.graphPanel.new(
  title='response size - 99th quantile',
  datasource='$datasource',
  description='Response size distribution in bytes for each group, version, verb, resource, subresource, scope and component',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_response_sizes_bucket{instance=~"$instance",resource=~"$resource",verb=~"$verb"}[$interval])) by(instance,le))',
    legendFormat='{{instance}}',
  )
);

local pf_request_queue_length = grafana.graphPanel.new(
  title='p&f - request queue length',
  datasource='$datasource',
  description='Length of queue in the API Priority and Fairness system, as seen by each request after it is enqueued',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_queue_length_after_enqueue_bucket{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema, priorityLevel, le))',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_request_wait_duration_99th_quartile = grafana.graphPanel.new(
  title='p&f - request wait duration - 99th quantile',
  datasource='$datasource',
  description='Length of time a request spent waiting in its queue',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_wait_duration_seconds_bucket{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema, priorityLevel, le))',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_request_execution_duration = grafana.graphPanel.new(
  title='p&f - request execution duration',
  datasource='$datasource',
  description='Duration of request execution in the API Priority and Fairness system',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(apiserver_flowcontrol_request_execution_seconds_bucket{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema, priorityLevel, le))',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_request_dispatch_rate = grafana.graphPanel.new(
  title='p&f - request dispatch rate',
  datasource='$datasource',
  description='Number of requests released by API Priority and Fairness system for service',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(rate(apiserver_flowcontrol_dispatched_requests_total{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}[$interval])) by(flowSchema,priorityLevel)',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

local pf_concurrency_limit = grafana.graphPanel.new(
  title='p&f - concurrency limit by priority level',
  datasource='$datasource',
  description='Shared concurrency limit in the API Priority and Fairness system',
).addTarget(
  prometheus.target(
    'sum(apiserver_flowcontrol_request_concurrency_limit{instance=~"$instance",priorityLevel=~"$priorityLevel"}) by (priorityLevel)',
    legendFormat='{{priorityLevel}}'
  )
);

local pf_pending_in_queue = grafana.graphPanel.new(
  title='p&f - pending in queue',
  datasource='$datasource',
  description='Number of requests currently pending in queues of the API Priority and Fairness system',
  legend_values=true,
  legend_alignAsTable=true,
  legend_current=true,
  legend_rightSide=true,
  legend_sort='max',
  legend_sortDesc=true,
  nullPointMode='null as zero',
  legend_hideZero=true,
).addTarget(
  prometheus.target(
    'sum(apiserver_flowcontrol_current_inqueue_requests{instance=~"$instance",flowSchema=~"$flowSchema",priorityLevel=~"$priorityLevel"}) by (flowSchema,priorityLevel)',
    legendFormat='{{flowSchema}}:{{priorityLevel}}',
  )
);

//Dashboard + Templates

grafana.dashboard.new(
  'API Performance',
  description='',
  timezone='utc',
  time_from='now-1h',
  refresh='30s',
  editable='true',
)

.addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    '',
    label='datasource'
  )
)

.addTemplate(
  grafana.template.new(
    'apiserver',
    '$datasource',
    'label_values(apiserver_request_duration_seconds_bucket, apiserver)',
    refresh='time',
    label='apiserver'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'instance',
    '$datasource',
    'label_values(apiserver_request_total, instance)',
    refresh='time',
    label='instance'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  }
)

.addTemplate(
  grafana.template.new(
    'resource',
    '$datasource',
    'label_values(apiserver_request_duration_seconds_bucket, resource)',
    refresh='time',
    label='resource'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'code',
    '$datasource',
    'label_values(code)',
    refresh='time',
    label='code',
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'verb',
    '$datasource',
    'label_values(verb)',
    refresh='time',
    label='verb',
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'flowSchema',
    '$datasource',
    'label_values(flowSchema)',
    refresh='time',
    label='flow-schema'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'priorityLevel',
    '$datasource',
    'label_values(priorityLevel)',
    refresh='time',
    label='priority-level'
  ) {
    type: 'query',
    multi: false,
    includeAll: true,
  },
)

.addTemplate(
  grafana.template.new(
    'interval',
    '$datasource',
    '$__auto_interval_period',
    label='interval',
    refresh='time',
  ) {
    type: 'interval',
    query: '1m,5m',
    multi: false,
    includeAll: true,
    auto: true,
    auto_count: 30,
    auto_min: '10s',
  },
)

.addPanel(request_duration_99th_quantile, gridPos={ x: 0, y: 0, w: 12, h: 8 })
.addPanel(request_rate_by_instance, gridPos={ x: 12, y: 0, w: 12, h: 8 })
.addPanel(request_duration_99th_quantile_by_resource, gridPos={ x: 0, y: 8, w: 12, h: 8 })
.addPanel(request_rate_by_resource, gridPos={ x: 12, y: 8, w: 12, h: 8 })
.addPanel(request_duration_read_write, gridPos={ x: 0, y: 16, w: 12, h: 8 })
.addPanel(request_rate_read_write, gridPos={ x: 12, y: 16, w: 12, h: 8 })
.addPanel(requests_dropped_rate, gridPos={ x: 0, y: 24, w: 12, h: 8 })
.addPanel(requests_terminated_rate, gridPos={ x: 12, y: 24, w: 12, h: 8 })
.addPanel(requests_status_rate, gridPos={ x: 0, y: 32, w: 12, h: 8 })
.addPanel(long_running_requests, gridPos={ x: 12, y: 32, w: 12, h: 8 })
.addPanel(request_in_flight, gridPos={ x: 0, y: 40, w: 12, h: 8 })
.addPanel(pf_requests_rejected, gridPos={ x: 12, y: 40, w: 12, h: 8 })
.addPanel(response_size_99th_quartile, gridPos={ x: 0, y: 48, w: 12, h: 8 })
.addPanel(pf_request_queue_length, gridPos={ x: 12, y: 48, w: 12, h: 8 })
.addPanel(pf_request_wait_duration_99th_quartile, gridPos={ x: 0, y: 56, w: 12, h: 8 })
.addPanel(pf_request_execution_duration, gridPos={ x: 12, y: 56, w: 12, h: 8 })
.addPanel(pf_request_dispatch_rate, gridPos={ x: 0, y: 64, w: 12, h: 8 })
.addPanel(pf_concurrency_limit, gridPos={ x: 12, y: 64, w: 12, h: 8 })
.addPanel(pf_pending_in_queue, gridPos={ x: 0, y: 72, w: 12, h: 8 })
