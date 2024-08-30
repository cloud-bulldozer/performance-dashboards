local variables = import './variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local generateTimeSeriesQuery(query, legend) = [
  local prometheusQuery = g.query.prometheus;
  prometheusQuery.new('$' + variables.Datasource.name, query)
  + prometheusQuery.withFormat('time_series')
  + prometheusQuery.withIntervalFactor(2)
  + prometheusQuery.withLegendFormat(legend),
];

{
  currentNodeCount: {
    query():
      generateTimeSeriesQuery('sum(kube_node_info{})', 'Number of nodes')
      + generateTimeSeriesQuery('sum(kube_node_status_condition{status="true"}) by (condition) > 0', 'Node: {{ condition }}'),
  },

  currentNamespaceCount: {
    query():
      generateTimeSeriesQuery('sum(kube_namespace_status_phase) by (phase)', '{{ phase }}'),
  },

  currentPodCount: {
    query():
      generateTimeSeriesQuery('sum(kube_pod_status_phase{}) by (phase) > 0', '{{ phase}} Pods'),
  },

  numberOfNodes: {
    query():
      generateTimeSeriesQuery('sum(kube_node_info{})', 'Number of nodes')
      + generateTimeSeriesQuery('sum(kube_node_status_condition{status="true"}) by (condition) > 0', 'Node: {{ condition }}'),
  },

  namespaceCount: {
    query():
      generateTimeSeriesQuery('sum(kube_namespace_status_phase) by (phase) > 0', '{{ phase }} namespaces'),
  },

  podCount: {
    query():
      generateTimeSeriesQuery('sum(kube_pod_status_phase{}) by (phase)', '{{phase}} pods'),
  },

  secretAndConfigMapCount: {
    query():
      generateTimeSeriesQuery('count(kube_secret_info{})', 'secrets')
      + generateTimeSeriesQuery('count(kube_configmap_info{})', 'Configmaps'),
  },
  deployCount: {
    query():
      generateTimeSeriesQuery('count(kube_deployment_labels{})', 'Deployments'),
  },

  serviceCount: {
    query():
      generateTimeSeriesQuery('count(kube_service_info{})', 'Services'),
  },

  top10ContainerRSS: {
    query():
      generateTimeSeriesQuery('topk(10, container_memory_rss{namespace!="",container!="POD",name!=""})', '{{ namespace }} - {{ name }}'),
  },

  top10ContainerCPU: {
    query():
      generateTimeSeriesQuery('topk(10,irate(container_cpu_usage_seconds_total{namespace!="",container!="POD",name!=""}[$interval])*100)', '{{ namespace }} - {{ name }}'),
  },

  goroutinesCount: {
    query():
      generateTimeSeriesQuery('topk(10, sum(go_goroutines{}) by (job,instance))', '{{ job }} - {{ instance }}'),
  },

  podDistribution: {
    query():
      generateTimeSeriesQuery('count(kube_pod_info{}) by (exported_node)', '{{ node }}'),
  },

  basicCPU: {
    query(nodeName):
      generateTimeSeriesQuery('sum by (instance, mode)(rate(node_cpu_seconds_total{node=~"' + nodeName + '",job=~".*"}[$interval])) * 100', 'Busy {{mode}}'),
  },

  systemMemory: {
    query(nodeName):
      generateTimeSeriesQuery('node_memory_Active_bytes{node=~"' + nodeName + '"}', 'Active')
      + generateTimeSeriesQuery('node_memory_MemTotal_bytes{node=~"' + nodeName + '"}', 'Total')
      + generateTimeSeriesQuery('node_memory_Cached_bytes{node=~"' + nodeName + '"} + node_memory_Buffers_bytes{node=~"' + nodeName + '"}', 'Cached + Buffers')
      + generateTimeSeriesQuery('node_memory_MemAvailable_bytes{node=~"' + nodeName + '"}', 'Available'),
  },

  diskThroughput: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_disk_read_bytes_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])', '{{ device }} - read')
      + generateTimeSeriesQuery('rate(node_disk_written_bytes_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])', '{{ device }} - write'),
  },

  diskIOPS: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_disk_reads_completed_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])', '{{ device }} - read')
      + generateTimeSeriesQuery('rate(node_disk_writes_completed_total{device=~"$block_device",node=~"' + nodeName + '"}[$interval])', '{{ device }} - write'),
  },

  networkUtilization: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_network_receive_bytes_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval]) * 8', '{{instance}} - {{device}} - RX')
      + generateTimeSeriesQuery('rate(node_network_transmit_bytes_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval]) * 8', '{{instance}} - {{device}} - TX'),
  },

  networkPackets: {
    query(nodeName):
      generateTimeSeriesQuery('rate(node_network_receive_packets_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval])', '{{instance}} - {{device}} - RX')
      + generateTimeSeriesQuery('rate(node_network_transmit_packets_total{node=~"' + nodeName + '",device=~"$net_device"}[$interval])', '{{instance}} - {{device}} - TX'),
  },

  networkDrop: {
    query(nodeName):
      generateTimeSeriesQuery('topk(10, rate(node_network_receive_drop_total{node=~"' + nodeName + '"}[$interval]))', 'rx-drop-{{ device }}')
      + generateTimeSeriesQuery('topk(10,rate(node_network_transmit_drop_total{node=~"' + nodeName + '"}[$interval]))', 'tx-drop-{{ device }}'),
  },

  conntrackStats: {
    query(nodeName):
      generateTimeSeriesQuery('node_nf_conntrack_entries{node=~"' + nodeName + '"}', 'conntrack_entries')
      + generateTimeSeriesQuery('node_nf_conntrack_entries_limit{node=~"' + nodeName + '"}', 'conntrack_limit'),
  },

  top10ContainersCPU: {
    query(nodeName):
      generateTimeSeriesQuery('topk(10, sum(irate(container_cpu_usage_seconds_total{container!="POD",name!="",instance=~"' + nodeName + '",namespace!="",namespace=~"$namespace"}[$interval])) by (pod,container,namespace,name,service) * 100)', '{{ pod }}: {{ container }}'),
  },

  top10ContainersRSS: {
    query(nodeName):
      generateTimeSeriesQuery('topk(10, container_memory_rss{container!="POD",name!="",instance=~"' + nodeName + '",namespace!="",namespace=~"$namespace"})', '{{ pod }}: {{ container }}'),
  },
}
