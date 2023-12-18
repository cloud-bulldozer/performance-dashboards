local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local variables = import './variables.libsonnet';
local prometheus = g.query.prometheus;

{
    ciliumControllerFailures: {
        query():
            prometheus.withExpr('cilium_controllers_failing')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ instance }} - {{ pod }}')
            + prometheus.withDatasource('$Datasource')
    },

    ciliumIPAddressAllocation: {
        query():
           prometheus.withExpr('cilium_ip_addresses')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ pod }} - {{ family }}')
            + prometheus.withDatasource('$Datasource') 
    },

    ciliumContainerCPU: {
        query():
            prometheus.withExpr('sum(irate(container_cpu_usage_seconds_total{container=~\"cilium.*\",container!=\"cilium-operator.*\",namespace!=\"\"}[$interval])) by (instance,pod,container,namespace,name,service) * 100')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ instance }} - {{ pod }}')
            + prometheus.withDatasource('$Datasource') 
    },

    ciliumConatinerMemory: {
        query():
            prometheus.withExpr('container_memory_rss{container=~\"cilium.*\",namespace!=\"\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ instance }} - {{ pod }}')
            + prometheus.withDatasource('$Datasource') 
    },

    ciliumNetworkPolicesPerAgent: {
        query():
            prometheus.withExpr('cilium_policy')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ instance }} - {{ pod }}')
            + prometheus.withDatasource('$Datasource') 
    },

    ciliumBPFOperations: {
        query():
            prometheus.withExpr('sum by (instance,map_name,operation,outcome)(rate(cilium_bpf_map_ops_total[2m]))')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{instance}} - {{map_name}} - {{operation}}')
            + prometheus.withDatasource('$Datasource') 
    },

    currentNodeCount: {
        query():
            [
            prometheus.withExpr('sum(kube_node_info{})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Number of nodes')
            + prometheus.withDatasource('$Datasource') ,
            prometheus.withExpr('sum(kube_node_status_condition{status=\"true\"}) by (condition) > 0')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Node: {{ condition }}')
            + prometheus.withDatasource('$Datasource') 
            ]
    },

    currentNamespaceCount: {
        query():
            prometheus.withExpr('sum(kube_namespace_status_phase) by (phase)')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ phase }}')
            + prometheus.withDatasource('$Datasource')
    },

    currentPodCount: {
        query():
            prometheus.withExpr('sum(kube_pod_status_phase{}) by (phase) > 0')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ phase }} Pods')
            + prometheus.withDatasource('$Datasource')
    },

    numberOfNodes: {
        query():
            [
            prometheus.withExpr('sum(kube_node_info{})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Number of nodes')
            + prometheus.withDatasource('$Datasource'),
            prometheus.withExpr('sum(kube_node_status_condition{status=\"true\"}) by (condition) > 0')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Node: {{ condition }}')
            + prometheus.withDatasource('$Datasource')
            ]
    },

    namespaceCount: {
        query():
            prometheus.withExpr('sum(kube_namespace_status_phase) by (phase) > 0')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ phase }} namespaces')
            + prometheus.withDatasource('$Datasource')
    },

    podCount: {
        query():
            prometheus.withExpr('sum(kube_pod_status_phase{}) by (phase)')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{phase}} pods')
            + prometheus.withDatasource('$Datasource')
    },

    secretConfigmapCount: {
        query():
            [prometheus.withExpr('count(kube_secret_info{})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('secrets')
            + prometheus.withDatasource('$Datasource'),
            prometheus.withExpr('count(kube_configmap_info{})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Configmaps')
            + prometheus.withDatasource('$Datasource')
            ]
    },

    deploymentCount: {
        query():

            prometheus.withExpr('count(kube_deployment_labels{})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Deployments')
            + prometheus.withDatasource('$Datasource')
    },

    serviceCount: {
        query():
            prometheus.withExpr('count(kube_service_info{})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Services')
            + prometheus.withDatasource('$Datasource')
    },

    top10ContainerRSS: {
        query():
            prometheus.withExpr('topk(10, container_memory_rss{namespace!=\"\",container!=\"POD\",name!=\"\"})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ namespace }} - {{ name }}')
            + prometheus.withDatasource('$Datasource')
    },

    top10ContainerCPU: {
        query():
            prometheus.withExpr('topk(10,irate(container_cpu_usage_seconds_total{namespace!=\"\",container!=\"POD\",name!=\"\"}[$interval])*100)')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ namespace }} - {{ name }}')
            + prometheus.withDatasource('$Datasource')
    },

    goroutinesCount: {
        query():
            prometheus.withExpr('topk(10, sum(go_goroutines{}) by (job,instance))')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ job }} - {{ instance }}')
            + prometheus.withDatasource('$Datasource')
    },

    podDistribution: {
        query():
           prometheus.withExpr('count(kube_pod_info{}) by (exported_node)')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ node }}')
            + prometheus.withDatasource('$Datasource') 
    },

    CPUBasic: {
        query():
            prometheus.withExpr('sum by (instance, mode)(rate(node_cpu_seconds_total{node=~\"$_worker_node\",job=~\".*\"}[$interval])) * 100')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Busy {{mode}}')
            + prometheus.withDatasource('$Datasource') 
    },

    SystemMemory: {
        query():
           [
            prometheus.withExpr('node_memory_Active_bytes{node=~\"$_worker_node\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Active')
            + prometheus.withDatasource('$Datasource') ,

            prometheus.withExpr('node_memory_MemTotal_bytes{node=~\"$_worker_node\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Total')
            + prometheus.withDatasource('$Datasource'),

             prometheus.withExpr('node_memory_Cached_bytes{node=~\"$_worker_node\"} + node_memory_Buffers_bytes{node=~\"$_worker_node\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Total')
            + prometheus.withDatasource('$Datasource'),

             prometheus.withExpr('node_memory_MemAvailable_bytes{node=~\"$_worker_node\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('Total')
            + prometheus.withDatasource('$Datasource')

           ]
    },

    DiskThroughput: {
        query():
            [
                prometheus.withExpr('rate(node_disk_read_bytes_total{device=~\"$block_device\",node=~\"$_worker_node\"}[$interval])')
                + prometheus.withFormat('time_series')
                + prometheus.withIntervalFactor(2)
                + prometheus.withLegendFormat('{{ device }} - read')
                + prometheus.withDatasource('$Datasource') ,

                prometheus.withExpr('rate(node_disk_written_bytes_total{device=~\"$block_device\",node=~\"$_worker_node\"}[$interval])')
                + prometheus.withFormat('time_series')
                + prometheus.withIntervalFactor(2)
                + prometheus.withLegendFormat('{{ device }} - write')
                + prometheus.withDatasource('$Datasource') 
            ]
    },

    DiskIOPS: {
        query():
            [
                prometheus.withExpr('rate(node_disk_reads_completed_total{device=~\"$block_device\",node=~\"$_worker_node\"}[$interval])')
                + prometheus.withFormat('time_series')
                + prometheus.withIntervalFactor(2)
                + prometheus.withLegendFormat('{{ device }} - read')
                + prometheus.withDatasource('$Datasource') ,

                prometheus.withExpr('rate(node_disk_writes_completed_total{device=~\"$block_device\",node=~\"$_worker_node\"}[$interval])')
                + prometheus.withFormat('time_series')
                + prometheus.withIntervalFactor(2)
                + prometheus.withLegendFormat('{{ device }} - write')
                + prometheus.withDatasource('$Datasource') 
            ]
    },

    networkUtilization: {
        query(): 
        [
            prometheus.withExpr('rate(node_network_receive_bytes_total{node=~\"$_worker_node\",device=~\"$net_device\"}[$interval]) * 8')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{instance}} - {{device}} - RX')
            + prometheus.withDatasource('$Datasource'),

            prometheus.withExpr('rate(node_network_transmit_bytes_total{node=~\"$_worker_node\",device=~\"$net_device\"}[$interval]) * 8')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{instance}} - {{device}} - TX')
            + prometheus.withDatasource('$Datasource')
        ]
    },

    networkPackets: {
        query():
        [
            prometheus.withExpr('rate(node_network_receive_packets_total{node=~\"$_worker_node\",device=~\"$net_device\"}[$interval])')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{instance}} - {{device}} - RX')
            + prometheus.withDatasource('$Datasource'),

           prometheus.withExpr('rate(node_network_transmit_packets_total{node=~\"$_worker_node\",device=~\"$net_device\"}[$interval])')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{instance}} - {{device}} - TX')
            + prometheus.withDatasource('$Datasource')    

           
        ]
    },

    networkPacketDrop: {
        query():
        [
            prometheus.withExpr('topk(10, rate(node_network_receive_drop_total{node=~\"$_worker_node\"}[$interval]))')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('rx-drop-{{ device }}')
            + prometheus.withDatasource('$Datasource'),

            prometheus.withExpr('topk(10,rate(node_network_transmit_drop_total{node=~\"$_worker_node\"}[$interval]))')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('tx-drop-{{ device }}')
            + prometheus.withDatasource('$Datasource')
        ]
    },

    conntrackStats: {
        query():
        [
            prometheus.withExpr('node_nf_conntrack_entries{node=~\"$_worker_node\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('conntrack_entries')
            + prometheus.withDatasource('$Datasource'),

            prometheus.withExpr('node_nf_conntrack_entries_limit{node=~\"$_worker_node\"}')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('conntrack_limit')
            + prometheus.withDatasource('$Datasource')
        ]
    },

    top10ContainerCPUNode: {
        query():
            prometheus.withExpr('topk(10, sum(irate(container_cpu_usage_seconds_total{container!=\"POD\",name!=\"\",instance=~\"$_worker_node\",namespace!=\"\",namespace=~\"$namespace\"}[$interval])) by (pod,container,namespace,name,service) * 100)')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ pod }}: {{ container }}')
            + prometheus.withDatasource('$Datasource')
    },

    top10ContainerRSSNode: {
        query():
            prometheus.withExpr('topk(10, container_memory_rss{container!=\"POD\",name!=\"\",instance=~\"$_worker_node\",namespace!=\"\",namespace=~\"$namespace\"})')
            + prometheus.withFormat('time_series')
            + prometheus.withIntervalFactor(2)
            + prometheus.withLegendFormat('{{ pod }}: {{ container }}')
            + prometheus.withDatasource('$Datasource')
    },






}