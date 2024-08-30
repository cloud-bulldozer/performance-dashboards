local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'prometheus')
    + var.datasource.withRegex('')
    + var.query.generalOptions.withLabel('Datasource')
    + var.query.withRefresh(1),
  apiserver:
    var.query.new('apiserver', 'label_values(apiserver_request_duration_seconds_bucket, apiserver)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('apisever')
    + var.query.withRefresh(2),

  instance:
    var.query.new('instance', 'label_values(apiserver_request_total, instance)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('instance')
    + var.query.withRefresh(2),

  resource:
    var.query.new('resource', 'label_values(apiserver_request_duration_seconds_bucket, resource)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('resource')
    + var.query.withRefresh(2),

  code:
    var.query.new('code', 'label_values(code)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('code')
    + var.query.withRefresh(2),

  verb:
    var.query.new('verb', 'label_values(verb)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('verb')
    + var.query.withRefresh(2),

  flowSchema:
    var.query.new('flowSchema', 'label_values(flowSchema)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('flow-schema')
    + var.query.withRefresh(2),

  priorityLevel:
    var.query.new('priorityLevel', 'label_values(priorityLevel)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('priority-level')
    + var.query.withRefresh(2),

  interval:
    var.interval.new('interval', ['1m', '5m'])
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.interval.generalOptions.withLabel('interval')
    + var.interval.withAutoOption(count=30, minInterval='10s')
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true),
}
