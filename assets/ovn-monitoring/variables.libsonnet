local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  Datasource:
    var.datasource.new('Datasource', 'prometheus')
    + var.datasource.withRegex('')
    + var.query.generalOptions.withLabel('Datasource')
    + var.query.selectionOptions.withMulti(false)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.refresh.onTime(),

  _master_node:
    var.query.new('_master_node', 'label_values(kube_node_role{role="master"}, node)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.generalOptions.withLabel('Master')
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.refresh.onTime(),

  _worker_node:
    var.query.new('_worker_node', 'label_values(kube_node_role{role=~"work.*"}, node)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.generalOptions.withLabel('Worker')
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.refresh.onTime(),

  controlplane_pod:
    var.query.new('controlplane_pod', 'label_values({pod=~"ovnkube-control-plane.*", namespace=~"openshift-ovn-kubernetes"}, pod)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.generalOptions.withLabel('OVNKube-Controlplane')
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.refresh.onTime(),

  kubenode_pod:
    var.query.new('kubenode_pod', 'label_values({pod=~"ovnkube-node.*", namespace=~"openshift-ovn-kubernetes"}, pod)')
    + var.query.withDatasourceFromVariable(self.Datasource)
    + var.query.generalOptions.withLabel('OVNKube-Node')
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(false)
    + var.query.refresh.onTime(),
}
