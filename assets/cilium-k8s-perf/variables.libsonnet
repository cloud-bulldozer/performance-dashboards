local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
    Datasource: 
        var.datasource.new('Datasource','prometheus')
        + var.datasource.withRegex("")
        + var.query.generalOptions.withLabel('Datasource')
        + var.query.withRefresh(1), 

    _worker_node: 
        var.query.new('_worker_node','label_values(kube_node_labels{}, exported_node)')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('Worker')
        + var.query.withRefresh(2),

    namespace:
        var.query.new('namespace','label_values(kube_pod_info, exported_namespace)')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('Namespace')
        + var.query.withRefresh(2),
    
    block_device:
        var.query.new('block_device','label_values(node_disk_written_bytes_total,device)')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.datasource.withRegex('/^(?:(?!dm|rb).)*$/')
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('Block device')
        + var.query.withRefresh(2),

    net_device:
        var.query.new('net_device','label_values(node_network_receive_bytes_total,device)')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.datasource.withRegex('/^((br|en|et).*)$/')
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('Network device')
        + var.query.withRefresh(2),

    interval:
        var.interval.new('interval',['2m','3m','4m','5m'])
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.interval.generalOptions.withLabel('interval')
        + var.query.withRefresh(2)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true)

}