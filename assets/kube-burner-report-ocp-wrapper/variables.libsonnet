local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'elasticsearch')
    + var.datasource.withRegex('/.*kube-burner.*/')
    + var.query.generalOptions.withLabel('Datasource'),

  platform:
    var.query.new('platform', "{\"find\": \"terms\", \"field\": \"metadata.platform.keyword\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Platform'),
  
  sdn:
    var.query.new('sdn', "{\"find\": \"terms\", \"field\": \"metadata.sdnType.keyword\", \"query\": \"metadata.platform.keyword: $platform\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('SDN type'),
  
  workload:
    var.query.new('workload', "{\"find\": \"terms\", \"field\": \"jobConfig.name.keyword\", \"query\": \"metadata.platform.keyword: $platform AND metadata.sdnType.keyword: $sdn\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Workload'),
  
  nodes:
    var.query.new('nodes', "{\"find\": \"terms\", \"field\": \"metadata.totalNodes\", \"query\": \"metadata.platform.keyword: $platform AND metadata.sdnType.keyword: $sdn AND jobConfig.name.keyword: $workload\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(1)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('nodes'),
  
  uuid:
    var.query.new('uuid', "{\"find\": \"terms\", \"field\": \"uuid.keyword\", \"query\": \"metadata.platform.keyword: $platform AND metadata.sdnType.keyword: $sdn AND jobConfig.name.keyword: $workload AND metadata.totalNodes: $nodes\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('UUID'),
  
  master:
    var.query.new('master', "{ \"find\" : \"terms\", \"field\": \"labels.node.keyword\", \"query\": \"metricName.keyword: nodeRoles AND labels.role.keyword: master AND uuid.keyword: $uuid\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Master nodes'),
  
  worker:
    var.query.new('worker', "{ \"find\" : \"terms\", \"field\": \"labels.node.keyword\", \"query\": \"metricName.keyword: nodeRoles AND labels.role.keyword: worker AND uuid.keyword: $uuid\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Worker nodes'),
  
  infra:
    var.query.new('infra', "{ \"find\" : \"terms\", \"field\": \"labels.node.keyword\",  \"query\": \"metricName.keyword: nodeRoles AND labels.role.keyword: infra AND uuid.keyword: $uuid\"}")
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Infra nodes'),
  
  latencyPercentile:
    var.custom.new('latencyPercentile', ['P99', 'P95', 'P50'],)
    + var.custom.generalOptions.withLabel('Latency percentile'),
}