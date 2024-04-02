local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
    Namespace: 
        var.query.new('namespace','label_values(kube_pod_info, namespace)')
        + var.query.withDatasource('prometheus','PF55DCC5EC58ABF5A')
        + var.datasource.withRegex("/^ocm/")
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('Namespace')
        + var.query.withRefresh(2),

    Resource: 
        var.query.new('resource','label_values(apiserver_request_duration_seconds_bucket, resource)')
        + var.query.withDatasource('prometheus','PF55DCC5EC58ABF5A')
        + var.datasource.withRegex("")
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('resource')
        + var.query.withRefresh(2),

    Code:
        var.query.new('code','label_values(code)')
        + var.query.withDatasource('prometheus','PF55DCC5EC58ABF5A')
        + var.datasource.withRegex("")
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('code')
        + var.query.withRefresh(2),

    Verb:
        var.query.new('verb','label_values(verb)')
        + var.query.withDatasource('prometheus','PF55DCC5EC58ABF5A')
        + var.datasource.withRegex("")
        + var.query.selectionOptions.withMulti(true)
        + var.query.selectionOptions.withIncludeAll(true)
        + var.query.generalOptions.withLabel('verb')
        + var.query.withRefresh(2),
}
