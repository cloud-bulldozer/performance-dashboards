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
  ovnClusterManagerLeader: {
    query():
      generateTimeSeriesQuery('ovnkube_clustermanager_leader > 0', '{{pod}}'),
  },

  ovnNorthd: {
    query():
      generateTimeSeriesQuery('ovn_northd_status', '{{pod}}'),
  },

  numOnvController: {
    query():
      generateTimeSeriesQuery('count(ovn_controller_monitor_all) by (namespace)', ''),
  },

  ovnKubeControlPlaneCPU: {
    query():
      generateTimeSeriesQuery('sum( irate(container_cpu_usage_seconds_total{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}[2m])*100 ) by (pod, node)', '{{pod}} - {{node}}'),
  },

  ovnKubeControlPlaneMem: {
    query():
      generateTimeSeriesQuery('container_memory_rss{pod=~"(ovnkube-master|ovnkube-control-plane).+",namespace="openshift-ovn-kubernetes",container!~"POD|"}', '{{pod}} - {{node}}'),
  },

  topOvnControllerCPU: {
    query():
      generateTimeSeriesQuery('topk(10, sum( irate(container_cpu_usage_seconds_total{pod=~"ovnkube-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}[2m])*100)  by (pod,node) )', '{{pod}} - {{node}}'),
  },
  topOvnControllerMem: {
    query():
      generateTimeSeriesQuery('topk(10, sum(container_memory_rss{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container="ovn-controller"}) by (pod,node))', '{{pod}} - {{node}}'),
  },

  ovnAnnotationLatency: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum by (pod, le) (rate(ovnkube_controller_pod_creation_latency_seconds_bucket[2m]))) > 0', '{{pod}} - Pod Annotation latency'),
  },

  ovnCNIAdd: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_node_cni_request_duration_seconds_bucket{command="ADD"}[2m])) by (pod,le)) > 0', '{{pod}}'),
  },

  podLatency: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_master_pod_lsp_created_port_binding_duration_seconds_bucket[2m])) by (pod,le))', '{{pod}} - LSP created')
      + generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_master_pod_port_binding_port_binding_chassis_duration_seconds_bucket[2m])) by (pod,le))', '{{pod}} - Port Binding')
      + generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_master_pod_port_binding_chassis_port_binding_up_duration_seconds_bucket[2m])) by (pod,le))', '{{pod}} - Port Binding Up')
      + generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_master_pod_first_seen_lsp_created_duration_seconds_bucket[2m])) by (pod,le))', '{{pod}} - Pod First seen'),
  },

  synclatency: {
    query():
      generateTimeSeriesQuery('rate(ovnkube_master_sync_service_latency_seconds_sum[2m])', '{{pod}} - Sync service latency'),
  },

  ovnLatencyCalculate: {
    query():
      generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_master_network_programming_duration_seconds_bucket[2m])) by (pod, le))', '{{pod}} - Kind Pod')
      + generateTimeSeriesQuery('histogram_quantile(0.99, sum(rate(ovnkube_master_network_programming_duration_seconds_bucket[2m])) by (service, le))', '{{service}} - Kind Service'),
  },

  ovnkubeNodeReadyLatency: {
    query():
      generateTimeSeriesQuery('ovnkube_node_ready_duration_seconds{pod=~"ovnkube-node-.*",namespace="openshift-ovn-kubernetes",container!~"POD|"}', '{{pod}}'),
  },

  workQueue: {
    query():
      generateTimeSeriesQuery('rate(ovnkube_master_workqueue_adds_total[2m])', '{{pod}} - Rate of handled adds'),
  },

  workQueueDepth: {
    query():
      generateTimeSeriesQuery('ovnkube_master_workqueue_depth', '{{pod}} - Depth of workqueue'),
  },

  workQueueLatency: {
    query():
      generateTimeSeriesQuery('ovnkube_master_workqueue_longest_running_processor_seconds', '{{pod}} - Longest processor duration'),
  },

  workQueueUnfinishedLatency: {
    query():
      generateTimeSeriesQuery('ovnkube_master_workqueue_unfinished_work_seconds', '{{pod}} - Unfinished work duration'),
  },
}
