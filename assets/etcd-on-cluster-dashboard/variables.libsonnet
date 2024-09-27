local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'prometheus')
    + var.datasource.withRegex('')
    + var.query.generalOptions.withLabel('Datasource')
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false),

  etcd_pod:
    var.query.new('etcd_pod')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.queryTypes.withLabelValues(
      'pod',
      'etcd_cluster_version',
    )
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(true),
}
