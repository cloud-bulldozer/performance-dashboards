local grafana = import '../grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;
local stat = grafana.statPanel;

// Helper functions

local genericGraphLegendPanel(title, format) = grafana.graphPanel.new(
  title=title,
  datasource='$datasource',
  format=format,
  legend_values=true,
  legend_alignAsTable=true,
  legend_max=true,
  legend_avg=true,
  legend_hideEmpty=true,
  legend_hideZero=true,
  legend_sort='max',
  nullPointMode='null as zero',
  sort='decreasing',
);

local statPanel(title) = stat.new(
  title=title,
  datasource='$datasource',
  reducerFunction='last',
  graphMode='area',
  textMode='name',
).addThresholds([
  { color: 'green', value: null },
  { color: 'orange', value: 0 },
  { color: 'green', value: 1 },
]);

// Panel definitions

local num_onv_controller = stat.new(
  title='OVN controller',
  datasource='$datasource',
  reducerFunction='last',
).addTarget(
  prometheus.target(
    'count(ovn_controller_monitor_all) by (namespace)',
  )
).addThresholds([
  { color: 'green', value: null },
]);


local ovn_nbdb_leader = statPanel('OVN NBDB leader').addTarget(
  prometheus.target(
    'ovn_db_cluster_server_role{server_role="leader",db_name="OVN_Northbound"}',
    legendFormat='{{pod}}'
  )
);

local ovn_sbdb_leader = statPanel('OVN SBDB leader').addTarget(
  prometheus.target(
    'ovn_db_cluster_server_role{server_role="leader",db_name="OVN_Southbound"}',
    legendFormat='{{pod}}'
  )
);

local ovn_northd = statPanel('OVN Northd Status').addTarget(
  prometheus.target(
    'ovn_northd_status',
    legendFormat='{{pod}}'
  )
);

local ovn_master_leader = statPanel('OVNKube Master').addTarget(
  prometheus.target(
    'ovnkube_master_leader',
    legendFormat='{{pod}}'
  )
);


local ovnKubeMasterMem = genericGraphLegendPanel('ovnkube-master Memory Usage', 'bytes').addTarget(
  prometheus.target(
    'container_memory_rss{pod=~"ovnkube-master-.*",namespace="openshift-ovn-kubernetes",container!~"POD|"}',
    legendFormat='{{container}}-{{pod}}-{{node}}',
  )
);

local ovnKubeMasterCPU = genericGraphLegendPanel('ovnkube-master CPU Usage', 'percent').addTarget(
  prometheus.target(
    'irate(container_cpu_usage_seconds_total{pod=~"ovnkube-master.*",namespace="openshift-ovn-kubernetes",container!~"POD|"}[2m])*100',
    legendFormat='{{container}}-{{pod}}-{{node}}',
  )
);

local topOvnControllerCPU = genericGraphLegendPanel('Top 10 ovn-controller CPU Usage', 'percent').addTarget(
  prometheus.target(
    'topk(10, irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}[2m])*100)',
    legendFormat='{{node}}',
  )
);

local topOvnControllerMem = genericGraphLegendPanel('Top 10  ovn-controller Memory Usage', 'bytes').addTarget(
  prometheus.target(
    'topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}) by (node))',
    legendFormat='{{node}}',
  )
);

local pod_latency = genericGraphLegendPanel('Pod creation Latency', 's').addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_pod_lsp_created_port_binding_duration_seconds_bucket[2m])) by (pod,le))',
    legendFormat='{{pod}} - LSP created',
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_pod_port_binding_port_binding_chassis_duration_seconds_bucket[2m])) by (pod,le))',
    legendFormat='{{pod}} - Port Binding',
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_pod_port_binding_chassis_port_binding_up_duration_seconds_bucket[2m])) by (pod,le))',
    legendFormat='{{pod}} - Port Binding Up',
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_pod_first_seen_lsp_created_duration_seconds_bucket[2m])) by (pod,le))',
    legendFormat='{{pod}} - Pod First seen',
  )
);

local sync_latency = genericGraphLegendPanel('Sync Service Latency', 's').addTarget(
  prometheus.target(
    'rate(ovnkube_master_sync_service_latency_seconds_sum[2m])',
    legendFormat='{{pod}} - Sync service latency',
  )
);

local ovnkube_node_ready_latency = genericGraphLegendPanel('OVNKube Node Ready Latency', 's').addTarget(
  prometheus.target(
    'ovnkube_node_ready_duration_seconds{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container!~"POD|"}',
    legendFormat='{{pod}}',
  )
);

local work_queue = genericGraphLegendPanel('OVNKube Master workqueue', 'short').addTarget(
  prometheus.target(
    'rate(ovnkube_master_workqueue_adds_total[2m])',
    legendFormat='{{pod}} - Rate of handled adds',
  )
);

local work_queue_depth = genericGraphLegendPanel('OVNKube Master workqueue Depth', 'short').addTarget(
  prometheus.target(
    'ovnkube_master_workqueue_depth',
    legendFormat='{{pod}} - Depth of workqueue',
  )
);

local work_queue_latency = genericGraphLegendPanel('OVNKube Master workqueue duration', 's').addTarget(
  prometheus.target(
    'ovnkube_master_workqueue_longest_running_processor_seconds',
    legendFormat='{{pod}} - Longest processor duration',
  )
);
local work_queue_unfinished_latency = genericGraphLegendPanel('OVNKube Master workqueue - Unfinished', 's').addTarget(
  prometheus.target(
    'ovnkube_master_workqueue_unfinished_work_seconds',
    legendFormat='{{pod}} - Unfinished work duration',
  )
);

local ovnAnnotationLatency = genericGraphLegendPanel('Pod Annotation Latency', 's').addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_pod_creation_latency_seconds_bucket[2m])) by (pod,le)) > 0',
    legendFormat='{{pod}} - Pod Annotation latency',
  )
);

local ovnCNIAdd = genericGraphLegendPanel('CNI Request ADD Latency', 's').addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="ADD"}[2m])) by (pod,le)) > 0',
    legendFormat='{{pod}}',
  )
);

local ovnCNIDel = genericGraphLegendPanel('CNI Request DEL Latency', 's').addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="DEL"}[2m])) by (pod,le)) > 0',
    legendFormat='{{pod}}',
  )
);

local ovnLatencyCalculate = genericGraphLegendPanel('Duration for OVN to apply network configuration', 's').addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_network_programming_duration_seconds_bucket[2m])) by (pod, le))',
    legendFormat='{{pod}} - Kind Pod',
  )
).addTarget(
  prometheus.target(
    'histogram_quantile(0.99, sum(rate(ovnkube_master_network_programming_duration_seconds_bucket[2m])) by (service, le))',
    legendFormat='{{service}} - Kind Service',
  )
);

// Creating the dashboard from the panels described above.

grafana.dashboard.new(
  'OVN Monitoring',
  description='',
  timezone='utc',
  time_from='now-1h',
  editable='true'
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
    '_master_node',
    '$datasource',
    'label_values(kube_node_role{role="master"}, node)',
    '',
    refresh=2,
  ) {
    label: 'Master',
    type: 'query',
    multi: true,
    includeAll: false,
  }
)

.addTemplate(
  grafana.template.new(
    '_worker_node',
    '$datasource',
    'label_values(kube_node_role{role=~"work.*"}, node)',
    '',
    refresh=2,
  ) {
    label: 'Worker',
    type: 'query',
    multi: true,
    includeAll: false,
  },
)

.addTemplate(
  grafana.template.new(
    'master_pod',
    '$datasource',
    'label_values({pod=~"ovnkube-master.*", namespace=~"openshift-ovn-kubernetes"}, pod)',
    refresh=1,
  ) {
    label: 'OVNKube-Master',
    type: 'query',
    multi: true,
    includeAll: false,
  }
)

.addTemplate(
  grafana.template.new(
    'kubenode_pod',
    '$datasource',
    'label_values({pod=~"ovnkube-node.*", namespace=~"openshift-ovn-kubernetes"}, pod)',
    refresh=1,
  ) {
    label: 'OVNKube-Node',
    type: 'query',
    multi: true,
    includeAll: false,
  }
)


.addPanel(
  grafana.row.new(title='OVN Resource Monitoring', collapse=true).addPanels(
    [
      ovn_master_leader { gridPos: { x: 0, y: 0, w: 4, h: 4 } },
      ovn_northd { gridPos: { x: 4, y: 0, w: 4, h: 4 } },
      ovn_nbdb_leader { gridPos: { x: 8, y: 0, w: 4, h: 4 } },
      ovn_sbdb_leader { gridPos: { x: 12, y: 0, w: 4, h: 4 } },
      num_onv_controller { gridPos: { x: 16, y: 0, w: 4, h: 4 } },
      ovnKubeMasterCPU { gridPos: { x: 0, y: 4, w: 12, h: 10 } },
      ovnKubeMasterMem { gridPos: { x: 12, y: 4, w: 12, h: 10 } },
      topOvnControllerCPU { gridPos: { x: 0, y: 12, w: 12, h: 10 } },
      topOvnControllerMem { gridPos: { x: 12, y: 12, w: 12, h: 10 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)


.addPanel(
  grafana.row.new(title='Latency Monitoring', collapse=true).addPanels(
    [
      ovnAnnotationLatency { gridPos: { x: 0, y: 0, w: 12, h: 10 } },
      ovnCNIAdd { gridPos: { x: 12, y: 0, w: 12, h: 10 } },
      pod_latency { gridPos: { x: 0, y: 8, w: 24, h: 10 } },
      sync_latency { gridPos: { x: 0, y: 16, w: 24, h: 10 } },
      ovnLatencyCalculate { gridPos: { x: 0, y: 24, w: 24, h: 10 } },
      ovnkube_node_ready_latency { gridPos: { x: 0, y: 32, w: 24, h: 10 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)

.addPanel(
  grafana.row.new(title='WorkQueue Monitoring', collapse=true).addPanels(
    [
      work_queue { gridPos: { x: 0, y: 0, w: 12, h: 10 } },
      work_queue_depth { gridPos: { x: 12, y: 0, w: 12, h: 10 } },
      work_queue_latency { gridPos: { x: 0, y: 8, w: 12, h: 10 } },
      work_queue_unfinished_latency { gridPos: { x: 12, y: 8, w: 12, h: 10 } },
    ]
  ), { gridPos: { x: 0, y: 0, w: 24, h: 1 } }
)
