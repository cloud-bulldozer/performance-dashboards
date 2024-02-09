local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
    Datasource:
        var.datasource.new('Datasource','elasticsearch')
        + var.datasource.withRegex('/(.*vegeta.*)/')
        + var.query.generalOptions.withLabel('vegeta-results datasource'),

    uuid:
        var.query.new('uuid','{"find": "terms", "field": "uuid.keyword"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(2)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('UUID'),

    hostname: 
        var.query.new('hostname','{"find": "terms", "field": "hostname.keyword"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(2)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true),

    targets:
        var.query.new('targets','{"find": "terms", "field": "targets.keyword"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(2)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true),

    iteration:
        var.query.new('iteration','{"find": "terms", "field": "iteration"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(2)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(true),
}