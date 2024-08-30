local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'elasticsearch')
    + var.datasource.withRegex('/.*Ingress.*/')
    + var.query.generalOptions.withLabel('Datasource'),

  platform:
    var.query.new('platform', '{"find": "terms", "field": "platform.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti()
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Platform'),
  clusterType:
    var.query.new('clusterType', '{"find": "terms", "field": "clusterType.keyword", "query": "platform.keyword: $platform"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Cluster Type'),


  workerNodesCount:
    var.query.new('workerNodesCount', '{"find": "terms", "field": "workerNodesCount", "query": "platform.keyword: $platform AND clusterType.keyword: $clusterType"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Worker Nodes Count'),

  infraNodesType:
    var.query.new('infraNodesType', '{"find": "terms", "field": "infraNodesType.keyword", "query": "platform.keyword: $platform AND workerNodesCount: $workerNodesCount AND clusterType.keyword: $clusterType"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Infra Nodes Type'),

  ocpMajorVersion:
    var.query.new('ocpMajorVersion', '{"find": "terms", "field": "ocpMajorVersion.keyword", "query": "platform.keyword: $platform AND infraNodesType.keyword: $infraNodesType AND workerNodesCount: $workerNodesCount AND clusterType.keyword: $clusterType"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('Major Version'),

  uuid:
    var.query.new('uuid', '{"find": "terms", "field": "uuid.keyword", "query": "platform.keyword: $platform AND infraNodesType.keyword: $infraNodesType AND workerNodesCount: $workerNodesCount AND clusterType.keyword: $clusterType AND ocpMajorVersion.keyword: $ocpMajorVersion"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.generalOptions.withLabel('UUID'),

  termination:
    var.query.new('termination', '{"find": "terms", "field": "config.termination.keyword"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(true)
    + var.query.generalOptions.withLabel('Termination'),

  latency_metric:
    var.custom.new('latency_metric', ['avg_lat_us', 'max_lat_us', 'p99_lat_us', 'p95_lat_us', 'p90_lat_us'],)
    + var.custom.generalOptions.withLabel('Latency Metric'),

  compare_by:
    var.custom.new('compare_by', ['uuid.keyword', 'ocpVersion.keyword', 'ocpMajorVersion.keyword', 'clusterName.keyword', 'haproxyVersion.keyword'],)
    + var.custom.generalOptions.withLabel('Compare By'),

  all_uuids:
    var.query.new('all_uuids', '{"find": "terms", "field": "uuid.keyword", "query": "platform.keyword: $platform AND infraNodesType.keyword: $infraNodesType AND workerNodesCount: $workerNodesCount AND clusterType.keyword: $clusterType AND ocpMajorVersion.keyword: $ocpMajorVersion"}')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.withRefresh(2)
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(true),
}
