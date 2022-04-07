local grafana = import 'grafonnet-lib/grafonnet/grafana.libsonnet';
local prometheus = grafana.prometheus;


// Helper functions

local genericGraphPanel(title, format) = grafana.graphPanel.new(
  title=title,
  datasource='$datasource',
  format=format,
  nullPointMode='null as zero',
  sort='decreasing',
  legend_alignAsTable=true,
);

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
  legend_sort='min',
  nullPointMode='null as zero',
  sort='decreasing',
);


local nodeMemory(nodeName) = genericGraphLegendPanel('System Memory: ' + nodeName, 'bytes').addTarget(
  prometheus.target(
    'node_memory_Active_bytes{node=~"' + nodeName + '"}',
    legendFormat='Active',
  )
).addTarget(
  prometheus.target(
    'node_memory_MemTotal_bytes{node=~"' + nodeName + '"}',
    legendFormat='Total',
  )
).addTarget(
  prometheus.target(
    'node_memory_Cached_bytes{node=~"' + nodeName + '"} + node_memory_Buffers_bytes{node=~"' + nodeName + '"}',
    legendFormat='Cached + Buffers',
  )
).addTarget(
  prometheus.target(
    'node_memory_MemAvailable_bytes{node=~"' + nodeName + '"}',
    legendFormat='Available',
  )
);


local nodeCPU(nodeName) = genericGraphLegendPanel('CPU Basic: ' + nodeName, 'percent').addTarget(
  prometheus.target(
    'sum by (instance, mode)(rate(node_cpu_seconds_total{node=~"' + nodeName + '",job=~".*"}[$interval])) * 100',
    legendFormat='Busy {{mode}}',
  )
);


local diskThroughput(nodeName) = genericGraphLegendPanel('Disk throughput: ' + nodeName, 'Bps').addTarget(
  prometheus.target(
    'rate(node_disk_read_bytes_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])',
    legendFormat='{{ device }} - read',
  )
).addTarget(
  prometheus.target(
    'rate(node_disk_written_bytes_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])',
    legendFormat='{{ device }} - write',
  )
);

local diskIOPS(nodeName) = genericGraphLegendPanel('Disk IOPS: ' + nodeName, 'iops').addTarget(
  prometheus.target(
    'rate(node_disk_reads_completed_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])',
    legendFormat='{{ device }} - read',
  )
).addTarget(
  prometheus.target(
    'rate(node_disk_writes_completed_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])',
    legendFormat='{{ device }} - write',
  )
);

local networkUtilization(nodeName) = genericGraphLegendPanel('Network Utilization: ' + nodeName, 'bps').addTarget(
  prometheus.target(
    'rate(node_network_receive_bytes_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval]) * 8',
    legendFormat='{{instance}} - {{device}} - RX',
  )
).addTarget(
  prometheus.target(
    'rate(node_network_transmit_bytes_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval]) * 8',
    legendFormat='{{instance}} - {{device}} - TX',
  )
);

local networkPackets(nodeName) = genericGraphLegendPanel('Network Packets: ' + nodeName, 'pps').addTarget(
  prometheus.target(
    'rate(node_network_receive_packets_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval])',
    legendFormat='{{instance}} - {{device}} - RX',
  )
).addTarget(
  prometheus.target(
    'rate(node_network_transmit_packets_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval])',
    legendFormat='{{instance}} - {{device}} - TX',
  )
);

local networkDrop(nodeName) = genericGraphLegendPanel('Network packets drop: ' + nodeName, 'pps').addTarget(
  prometheus.target(
    'topk(10, rate(node_network_receive_drop_total{node=~"' + nodeName + '"}[$interval]))',
    legendFormat='rx-drop-{{ device }}',
  )
).addTarget(
  prometheus.target(
    'topk(10,rate(node_network_transmit_drop_total{node=~"' + nodeName + '"}[$interval]))',
    legendFormat='tx-drop-{{ device }}',
  )
);

local conntrackStats(nodeName) = genericGraphLegendPanel('Conntrack stats: ' + nodeName, '')
                                 {
  seriesOverrides: [{
    alias: 'conntrack_limit',
    yaxis: 2,
  }],
  yaxes: [{ show: true }, { show: true }],
}
                                 .addTarget(
  prometheus.target(
    'node_nf_conntrack_entries{node=~"' + nodeName + '"}',
    legendFormat='conntrack_entries',
  )
).addTarget(
  prometheus.target(
    'node_nf_conntrack_entries_limit{node=~"' + nodeName + '"}',
    legendFormat='conntrack_limit',
  )
);

local top10ContainerCPU(nodeName) = genericGraphLegendPanel('Top 10 container CPU: ' + nodeName, 'percent').addTarget(
  prometheus.target(
    'topk(10, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",instance=~"' + nodeName + '",namespace!="",namespace=~"$namespace"}[$interval])) by (pod,container,namespace,name,service) * 100)',
    legendFormat='{{ pod }}: {{ container }}',
  )
);

local top10ContainerRSS(nodeName) = genericGraphLegendPanel('Top 10 container RSS: ' + nodeName, 'bytes').addTarget(
  prometheus.target(
    'topk(10, container_memory_rss{container!="POD",name!="",instance=~"' + nodeName + '",namespace!="",namespace=~"$namespace"})',
    legendFormat='{{ pod }}: {{ container }}',
  )
);

local containerWriteBytes(nodeName) = genericGraphLegendPanel('Container fs write rate: ' + nodeName, 'Bps').addTarget(
  prometheus.target(
    'sum(rate(container_fs_writes_bytes_total{device!~".+dm.+", node=~"' + nodeName + '", container!=""}[$interval])) by (device, container)',
    legendFormat='{{ container }}: {{ device }}',
  )
);

// Individual panel definitions

// Monitoring Stack

local promReplMemUsage = genericGraphLegendPanel('Prometheus Replica Memory usage', 'bytes').addTarget(
  prometheus.target(
    'sum(container_memory_rss{pod="prometheus-k8s-1",namespace!="",name!="",container="prometheus"}) by (pod)',
    legendFormat='{{pod}}',
  )
).addTarget(
  prometheus.target(
    'sum(container_memory_rss{pod="prometheus-k8s-0",namespace!="",name!="",container="prometheus"}) by (pod)',
    legendFormat='{{pod}}',
  )
);

// Kubelet

local kubeletCPU = genericGraphLegendPanel('Top 10 Kubelet CPU usage', 'percent').addTarget(
  prometheus.target(
    'topk(10,rate(process_cpu_seconds_total{service="kubelet",job="kubelet"}[$interval])*100)',
    legendFormat='kubelet - {{node}}',
  )
);

local crioCPU = genericGraphLegendPanel('Top 10 crio CPU usage', 'percent').addTarget(
  prometheus.target(
    'topk(10,rate(process_cpu_seconds_total{service="kubelet",job="crio"}[$interval])*100)',
    legendFormat='crio - {{node}}',
  )
);

local kubeletMemory = genericGraphLegendPanel('Top 10 Kubelet memory usage', 'bytes').addTarget(
  prometheus.target(
    'topk(10,process_resident_memory_bytes{service="kubelet",job="kubelet"})',
    legendFormat='kubelet - {{node}}',
  )
);

local crioMemory = genericGraphLegendPanel('Top 10 crio memory usage', 'bytes').addTarget(
  prometheus.target(
    'topk(10,process_resident_memory_bytes{service="kubelet",job="crio"})',
    legendFormat='crio - {{node}}',
  )
);

// Cluster details

local current_node_count = grafana.statPanel.new(
  title='Current Node Count',
  datasource='$datasource',
  reducerFunction='last',
).addTarget(
  prometheus.target(
    'sum(kube_node_info{})',
    legendFormat='Number of nodes',
  )
).addTarget(
  prometheus.target(
    'sum(kube_node_status_condition{status="true"}) by (condition) > 0',
    legendFormat='Node: {{ condition }}',
  )
);

local current_namespace_count = grafana.statPanel.new(
  title='Current namespace Count',
  datasource='$datasource',
  reducerFunction='last',
).addTarget(
  prometheus.target(
    'sum(kube_namespace_status_phase) by (phase)',
    legendFormat='{{ phase }}',
  )
);

local current_pod_count = grafana.statPanel.new(
  title='Current Pod Count',
  reducerFunction='last',
  datasource='$datasource',
).addTarget(
  prometheus.target(
    'sum(kube_pod_status_phase{}) by (phase) > 0',
    legendFormat='{{ phase}} Pods',
  )
);

local nodeCount = genericGraphPanel('Number of nodes', 'none').addTarget(
  prometheus.target(
    'sum(kube_node_info{})',
    legendFormat='Number of nodes',
  )
).addTarget(
  prometheus.target(
    'sum(kube_node_status_condition{status="true"}) by (condition) > 0',
    legendFormat='Node: {{ condition }}',
  )
);

local nsCount = genericGraphPanel('Namespace count', 'none').addTarget(
  prometheus.target(
    'sum(kube_namespace_status_phase) by (phase) > 0',
    legendFormat='{{ phase }} namespaces',
  )
);

local podCount = genericGraphPanel('Pod count', 'none').addTarget(
  prometheus.target(
    'sum(kube_pod_status_phase{}) by (phase)',
    legendFormat='{{phase}} pods',
  )
);

local secretCmCount = genericGraphPanel('Secret & configmap count', 'none').addTarget(
  prometheus.target(
    'count(kube_secret_info{})',
    legendFormat='secrets',
  )
).addTarget(
  prometheus.target(
    'count(kube_configmap_info{})',
    legendFormat='Configmaps',
  )
);

local deployCount = genericGraphPanel('Deployment count', 'none').addTarget(
  prometheus.target(
    'count(kube_deployment_labels{})',
    legendFormat='Deployments',
  )
);


local servicesCount = genericGraphPanel('Services count', 'none').addTarget(
  prometheus.target(
    'count(kube_service_info{})',
    legendFormat='Services',
  )
);

local alerts = genericGraphPanel('Alerts', 'none').addTarget(
  prometheus.target(
    'topk(10,sum(ALERTS{severity!="none"}) by (alertname, severity))',
    legendFormat='{{severity}}: {{alertname}}',
  )
);

local top10ContMem = genericGraphLegendPanel('Top 10 container RSS', 'bytes').addTarget(
  prometheus.target(
    'topk(10, container_memory_rss{namespace!="",container!="POD",name!=""})',
    legendFormat='{{ namespace }} - {{ name }}',
  )
);

local podDistribution = genericGraphLegendPanel('Pod Distribution', 'none').addTarget(
  prometheus.target(
    'count(kube_pod_info{}) by (exported_node)',
    legendFormat='{{ node }}',
  )
);

local top10ContCPU = genericGraphLegendPanel('Top 10 container CPU', 'percent').addTarget(
  prometheus.target(
    'topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[$interval])*100)',
    legendFormat='{{ namespace }} - {{ name }}',
  )
);


local goroutines_count = genericGraphPanel('Goroutines count', 'none').addTarget(
  prometheus.target(
    'topk(10, sum(go_goroutines{}) by (job,instance))',
    legendFormat='{{ job }} - {{ instance }}',
  )
);

// Cilium Panels

local cilium_container_cpu = genericGraphLegendPanel('Cilium Container CPU', 'percent').addTarget(
  prometheus.target(
    'sum(irate(container_cpu_usage_seconds_total{container=~"cilium.*",container!="cilium-operator.*",namespace!=""}[$interval])) by (instance,pod,container,namespace,name,service) * 100',
    legendFormat='{{ instance }} - {{ pod }}'
  )
);

local cilium_container_mem = genericGraphLegendPanel('Cilium Container Memory', 'bytes').addTarget(
  prometheus.target(
    'container_memory_rss{container=~"cilium.*",namespace!=""}',
    legendFormat='{{ instance }} - {{ pod }}'
  )
);

local cilium_ip_addresses = genericGraphLegendPanel('Cilium IP Address Allocation', 'none').addTarget(
  prometheus.target(
    'cilium_ip_addresses',
    legendFormat='{{ pod }} - {{ family }}'
  )
);

local cilium_netpol = genericGraphLegendPanel('Cilium Network Polices Per Agent', 'none').addTarget(
  prometheus.target(
    'cilium_policy',
    legendFormat='{{ instance }} - {{ pod }}'
  )
);

local cilium_bpf_op = genericGraphLegendPanel('Cilium BPF Operations', 'none').addTarget(
  prometheus.target(
    'sum by (instance,map_name,operation,outcome)(rate(cilium_bpf_map_ops_total[2m]))',
    legendFormat='{{instance}} - {{map_name}} - {{operation}}'
  )
);

local cilium_failing_control = genericGraphLegendPanel('Cilium Controller Failures', 'none').addTarget(
  prometheus.target(
    'cilium_controllers_failing',
    legendFormat='{{ instance }} - {{ pod }}'
  )
);


// Cluster operators

local clusterOperatorsOverview = grafana.statPanel.new(
  datasource='$datasource',
  title='Cluster operators overview',
).addTarget(
  prometheus.target(
    'sum by (condition)(cluster_operator_conditions{condition!=""})',
    legendFormat='{{ condition }}',
  )
);

local clusterOperatorsInformation = genericGraphLegendPanel('Cluster operators information', 'none').addTarget(
  prometheus.target(
    'cluster_operator_conditions{name!="",reason!=""}',
    legendFormat='{{name}} - {{reason}}',
  )
);

local clusterOperatorsDegraded = genericGraphLegendPanel('Cluster operators degraded', 'none').addTarget(
  prometheus.target(
    'cluster_operator_conditions{condition="Degraded",name!="",reason!=""}',
    legendFormat='{{name}} - {{reason}}',
  )
);


// Dashboard

grafana.dashboard.new(
  'Cilium k8s Performance',
  description='Performance dashboard for k8s w/ Cilium as the CNI',
  time_from='now-1h',
  timezone='utc',
  refresh='30s',
  editable='true',
)


// Templates

.addTemplate(
  grafana.template.datasource(
    'datasource',
    'prometheus',
    '',
  )
)

.addTemplate(
  grafana.template.new(
    '_worker_node',
    '$datasource',
    'label_values(kube_node_labels{}, exported_node)',
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
    'namespace',
    '$datasource',
    'label_values(kube_pod_info, exported_namespace)',
    '',
    refresh=2,
  ) {
    label: 'Namespace',
    type: 'query',
    multi: false,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'block_device',
    '$datasource',
    'label_values(node_disk_written_bytes_total,device)',
    '',
    regex='/^(?:(?!dm|rb).)*$/',
    refresh=2,
  ) {
    label: 'Block device',
    type: 'query',
    multi: true,
    includeAll: true,
  },
)


.addTemplate(
  grafana.template.new(
    'net_device',
    '$datasource',
    'label_values(node_network_receive_bytes_total,device)',
    '',
    regex='/^((br|en|et).*)$/',
    refresh=2,
  ) {
    label: 'Network device',
    type: 'query',
    multi: true,
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
    query: '2m,3m,4m,5m',
    auto: false,
  },
)

// Dashboard definition

.addPanel(grafana.row.new(title='Cilium Details', collapse=true).addPanels(
  [
    cilium_failing_control { gridPos: { x: 0, y: 4, w: 12, h: 8 } },
    cilium_ip_addresses { gridPos: { x: 12, y: 4, w: 12, h: 8 } },
    cilium_container_cpu { gridPos: { x: 0, y: 4, w: 12, h: 8 } },
    cilium_container_mem { gridPos: { x: 12, y: 4, w: 12, h: 8 } },
    cilium_netpol { gridPos: { x: 0, y: 4, w: 12, h: 8 } },
    cilium_bpf_op { gridPos: { x: 12, y: 12, w: 12, h: 8 } },
  ]
), { gridPos: { x: 0, y: 3, w: 24, h: 1 } })

.addPanel(grafana.row.new(title='Cluster Details', collapse=true).addPanels(
  [
    current_node_count { gridPos: { x: 0, y: 4, w: 8, h: 3 } },
    current_namespace_count { gridPos: { x: 8, y: 4, w: 8, h: 3 } },
    current_pod_count { gridPos: { x: 16, y: 4, w: 8, h: 3 } },
    nodeCount { gridPos: { x: 0, y: 12, w: 8, h: 8 } },
    nsCount { gridPos: { x: 8, y: 12, w: 8, h: 8 } },
    podCount { gridPos: { x: 16, y: 12, w: 8, h: 8 } },
    secretCmCount { gridPos: { x: 0, y: 20, w: 8, h: 8 } },
    deployCount { gridPos: { x: 8, y: 20, w: 8, h: 8 } },
    servicesCount { gridPos: { x: 16, y: 20, w: 8, h: 8 } },
    top10ContMem { gridPos: { x: 0, y: 28, w: 24, h: 8 } },
    top10ContCPU { gridPos: { x: 0, y: 36, w: 12, h: 8 } },
    goroutines_count { gridPos: { x: 12, y: 36, w: 12, h: 8 } },
    podDistribution { gridPos: { x: 0, y: 44, w: 24, h: 8 } },
  ]
), { gridPos: { x: 0, y: 3, w: 24, h: 1 } })

.addPanel(grafana.row.new(title='Node: $_worker_node', collapse=true, repeat='_worker_node').addPanels(
  [
    nodeCPU('$_worker_node') { gridPos: { x: 0, y: 0, w: 12, h: 8 } },
    nodeMemory('$_worker_node') { gridPos: { x: 12, y: 0, w: 12, h: 8 } },
    diskThroughput('$_worker_node') { gridPos: { x: 0, y: 8, w: 12, h: 8 } },
    diskIOPS('$_worker_node') { gridPos: { x: 12, y: 8, w: 12, h: 8 } },
    networkUtilization('$_worker_node') { gridPos: { x: 0, y: 16, w: 12, h: 8 } },
    networkPackets('$_worker_node') { gridPos: { x: 12, y: 16, w: 12, h: 8 } },
    networkDrop('$_worker_node') { gridPos: { x: 0, y: 24, w: 12, h: 8 } },
    conntrackStats('$_worker_node') { gridPos: { x: 12, y: 24, w: 12, h: 8 } },
    top10ContainerCPU('$_worker_node') { gridPos: { x: 0, y: 32, w: 12, h: 8 } },
    top10ContainerRSS('$_worker_node') { gridPos: { x: 12, y: 32, w: 12, h: 8 } },
  ],
), { gridPos: { x: 0, y: 1, w: 0, h: 8 } })
