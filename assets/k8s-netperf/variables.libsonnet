local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  datasource:
    var.datasource.new('datasource', 'elasticsearch')
    + var.datasource.withRegex('/(.*netperf.*)/')
    + var.query.generalOptions.withLabel('datasource')
    + var.query.selectionOptions.withMulti(false)
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withIncludeAll(false),

  platform:
    var.query.new('platform', "{\"find\": \"terms\", \"field\": \"metadata.platform.keyword\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Platform'),
  
  samples:
    var.query.new('samples', "{\"find\": \"terms\", \"field\": \"samples\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('samples'),
  
  uuid:
    var.query.new('uuid', "{\"find\": \"terms\", \"field\": \"uuid.keyword\", \"query\":\"metadata.platform.keyword: $platform AND samples: $samples\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('uuid'),
  
  hostNetwork:
    var.custom.new('hostNetwork', ['true', 'false'],)
    + var.custom.selectionOptions.withMulti(true)
    + var.custom.selectionOptions.withIncludeAll(false)
    + var.custom.generalOptions.withLabel('hostNetwork'),

  service:
    var.custom.new('service', ['true', 'false'],)
    + var.custom.selectionOptions.withMulti(true)
    + var.custom.selectionOptions.withIncludeAll(true)
    + var.custom.generalOptions.withLabel('service'),
  
  streams:
    var.query.new('parallelism', "{\"find\": \"terms\", \"field\": \"parallelism\", \"query\":\"uuid: $uuid\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('streams'),
  
  profile:
    var.query.new('profile', "{\"find\": \"terms\", \"field\": \"profile.keyword\", \"query\":\"uuid:$uuid\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('profile'),
  
  messageSize:
    var.query.new('messageSize', "{\"find\": \"terms\", \"field\": \"messageSize\",\"query\":\"uuid:$uuid\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('messageSize'),

  driver:
    var.query.new('driver', "{\"find\": \"terms\", \"field\": \"driver.keyword\",\"query\":\"uuid:$uuid\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Driver'),
}