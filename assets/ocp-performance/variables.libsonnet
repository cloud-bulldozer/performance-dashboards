local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'prometheus')
    + var.query.generalOptions.withLabel('Datasource'),

  master_node:
    var.query.new('_master_node')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'node',
      'kube_node_role{role="master"}',
    )
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Master'),

  worker_node:
    var.query.new('_worker_node')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'node',
      'kube_node_role{role=~"worker"}',
    )
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Worker'),

  infra_node:
    var.query.new('_infra_node')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'node',
      'kube_node_role{role="infra"}',
    )
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Infra'),

  namespace:
    var.query.new('namespace')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'namespace',
      'kube_pod_info{namespace!="(cluster-density.*|node-density-.*)"}',
    )
    + var.query.withRefresh(2)
    + var.query.withRegex('')
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Namespace'),

  block_device:
    var.query.new('block_device')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'device',
      'node_disk_written_bytes_total',
    )
    + var.query.withRefresh(2)
    + var.query.withRegex('/^(?:(?!dm|rb).)*$/')
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Block device'),

  net_device:
    var.query.new('net_device')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'device',
      'node_network_receive_bytes_total',
    )
    + var.query.withRefresh(2)
    + var.query.withRegex('/^((br|en|et).*)$/')
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Network device'),

  interval:
    var.interval.new('interval', ['2m', '3m', '4m', '5m'],)
    + var.interval.generalOptions.withLabel('interval'),
}
