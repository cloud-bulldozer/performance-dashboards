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
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Platform'),

  workers:
    var.query.new('workerNodesType', "{\"find\": \"terms\", \"field\": \"metadata.workerNodesType.keyword\", \"query\": \"metadata.platform.keyword: $platform\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('workers'),

  uuid:
    var.query.new('uuid', "{\"find\": \"terms\", \"field\": \"uuid.keyword\", \"query\":\"metadata.platform.keyword: $platform AND  metadata.workerNodesType.keyword: $workerNodesType\"}")
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

  throughput_profile:
    var.query.new('throughput_profile', "{\"find\": \"terms\", \"field\": \"profile.keyword\", \"query\":\"uuid:$uuid\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRegex(".*STREAM.*")
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Throughput profile'),

  latency_profile:
    var.query.new('latency_profile', "{\"find\": \"terms\", \"field\": \"profile.keyword\", \"query\":\"uuid:$uuid\"}")
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.withRegex(".*RR.*")
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Latency profile'),

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

  compare_by:
    var.custom.new('compare_by', ['uuid.keyword', 'metadata.ocpVersion.keyword', 'metadata.clusterName.keyword', 'metadata.ocpShortVersion.keyword', 'metadata.platform.keyword'],)
    + var.custom.selectionOptions.withMulti(false)
    + var.custom.selectionOptions.withIncludeAll(false)
    + var.custom.generalOptions.withLabel('Compare By'),
}
