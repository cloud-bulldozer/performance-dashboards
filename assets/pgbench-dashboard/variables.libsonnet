local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
    Datasource1:
        var.datasource.new('Datasource1','elasticsearch')
        + var.datasource.withRegex("")
        + var.query.generalOptions.withLabel('pgbench-results datasource')
        + var.query.withRefresh(1),

    Datasource2:
        var.datasource.new('Datasource2','elasticsearch')
        + var.datasource.withRegex("")
        + var.query.generalOptions.withLabel('pgbench-summary datasource')
        + var.query.withRefresh(1),

    uuid:
        var.query.new('uuid','{"find": "terms", "field": "uuid.keyword"}')
        + var.query.withDatasourceFromVariable(self.Datasource1)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.withRefresh(2),

    user:
        var.query.new('user','{"find": "terms", "field": "user.keyword"}')
        + var.query.withDatasourceFromVariable(self.Datasource1)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.withRefresh(2),
}