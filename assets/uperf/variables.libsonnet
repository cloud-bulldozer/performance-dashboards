local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'elasticsearch')
    + var.datasource.withRegex('/(.*uperf.*)/')
    + var.query.generalOptions.withLabel('uperf-results datasource')
    + var.query.withRefresh(1),

  uuid:
    var.query.new('uuid', '{"find": "terms", "field": "uuid.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  cluster_name:
    var.query.new('cluster_name', '{"find": "terms", "field": "cluster_name.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  user:
    var.query.new('user', '{"find": "terms", "field": "user.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  iteration:
    var.query.new('iteration', '{"find": "terms", "field": "iteration"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  server:
    var.query.new('server', '{"find": "terms", "field": "remote_ip.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  test_type:
    var.query.new('test_type', '{"find": "terms", "field": "test_type.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  protocol:
    var.query.new('protocol', '{"find": "terms", "field": "protocol.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  message_size:
    var.query.new('message_size', '{"find": "terms", "field": "message_size"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),

  threads:
    var.query.new('threads', '{"find": "terms", "field": "num_threads"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.withRefresh(2),
}
