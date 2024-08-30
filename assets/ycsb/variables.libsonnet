local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource1:
    var.datasource.new('Datasource1', 'elasticsearch')
    + var.datasource.withRegex('')
    + var.query.withRefresh(1)
    + var.query.generalOptions.withLabel('ycsb-results datasource'),

  Datasource2:
    var.datasource.new('Datasource2', 'elasticsearch')
    + var.datasource.withRegex('')
    + var.query.withRefresh(1)
    + var.query.generalOptions.withLabel('ycsb-summary datasource'),

  uuid:
    var.query.new('uuid', '{"find": "terms", "field": "uuid.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource2)
    + var.query.withRefresh(2)
    + var.datasource.withRegex('')
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true),

  user:
    var.query.new('user', '{"find": "terms", "field": "user.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource2)
    + var.query.withRefresh(2)
    + var.datasource.withRegex('')
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true),

  phase:
    var.query.new('phase', '{"find": "terms", "field": "phase.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource2)
    + var.query.withRefresh(2)
    + var.datasource.withRegex('')
    + var.query.generalOptions.withCurrent('run', 'run')
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true),

  operation:
    var.query.new('operation', '{"find": "fields", "field": "data.*.Operations"}')
    + var.query.withDatasourceFromVariable(self.Datasource2)
    + var.query.withRefresh(2)
    + var.query.generalOptions.withCurrent('READ', 'READ')
    + var.datasource.withRegex('/data.(.*).Operations/')
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true),
}
