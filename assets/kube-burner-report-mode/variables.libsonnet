local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable; 

{
    Datasource:
        var.datasource.new('Datasource','elasticsearch')
        + var.datasource.withRegex('/.*kube-burner.*/')
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.selectionOptions.withMulti(false),
    
    platform: 
        var.query.new('platform', '{"find": "terms", "field": "platform.keyword"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(2)
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('Platform'),

    sdn:
        var.query.new('sdn', '{"find": "terms", "field": "sdnType.keyword", "query": "platform.keyword: $platform"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('SDN type'),

    clusterType:
        var.query.new('clusterType', '{"find": "terms", "field": "clusterType.keyword", "query": "platform.keyword: $platform"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('Cluster Type'),

    benchmark:
        var.query.new('benchmark', '{"find": "terms", "field": "benchmark.keyword", "query": "platform.keyword: $platform AND sdnType.keyword: $sdn AND clusterType.keyword: $clusterType"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('Benchmark'),

    workerNodesCount:
        var.query.new('workerNodesCount', '{"find": "terms", "field": "workerNodesCount", "query": "platform.keyword: $platform AND sdnType.keyword: $sdn AND benchmark.keyword: $benchmark AND clusterType.keyword: $clusterType"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withMulti(false)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('Workers'),

    ocpMajorVersion:
        var.query.new('ocpMajorVersion', '{"find": "terms", "field": "ocpMajorVersion.keyword", "query": "platform.keyword: $platform AND sdnType.keyword: $sdn AND benchmark.keyword: $benchmark AND workerNodesCount: $workerNodesCount AND  clusterType.keyword: $clusterType"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('OCP Major'),

    uuid:
        var.query.new('uuid', '{"find": "terms", "field": "uuid.keyword", "query": "platform.keyword: $platform AND sdnType.keyword: $sdn AND benchmark.keyword: $benchmark AND workerNodesCount: $workerNodesCount AND  ocpMajorVersion.keyword: $ocpMajorVersion AND clusterType.keyword: $clusterType"}')
        + var.query.withDatasourceFromVariable(self.Datasource)
        + var.query.withRefresh(1)
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(false)
        + var.query.generalOptions.withLabel('UUID'),

    compare_by:
        var.custom.new('compare_by', ['uuid', 'metadata.ocpVersion', 'metadata.ocpMajorVersion'])
        + var.custom.generalOptions.withLabel('Compare by')
        + var.custom.selectionOptions.withIncludeAll(false)
        + var.custom.selectionOptions.withMulti(false),

    component:
        var.custom.new('component', ['crio', 'kube-apiserver', 'kube-controller-manager','kubelet','multus','openshift-apiserver','openshift-controller-manager','ovn-control-plane','ovnkube-node','prometheus','router'])
        + var.custom.generalOptions.withLabel('Component')
        + var.custom.selectionOptions.withIncludeAll(true)
        + var.custom.selectionOptions.withMulti(true),

    node_roles:
        var.custom.new('node_roles', ['masters', 'workers', 'infra'])
        + var.custom.generalOptions.withLabel('Node roles')
        + var.custom.selectionOptions.withIncludeAll(false)
        + var.custom.selectionOptions.withMulti(true),
}