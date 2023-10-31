local panels = import '../../assets/kube-burner-report-ocp-wrapper/panels.libsonnet';
local queries = import '../../assets/kube-burner-report-ocp-wrapper/queries.libsonnet';
local variables = import '../../assets/kube-burner-report-ocp-wrapper/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Kube-burner Report - OCP wrapper')
+ g.dashboard.withDescription(|||
  Dashboard for kube-burner OCP wrapper
|||)
+ g.dashboard.withTags('kube-burner')
+ g.dashboard.time.withFrom('now-12h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(false)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.platform,
  variables.sdn,
  variables.workload,
  variables.nodes,
  variables.uuid,
  variables.master,
  variables.worker,
  variables.infra,
  variables.latencyPercentile,
])
+ g.dashboard.withPanels([
  panels.stat.withLastNotNullCalcs('Node count', 'none', queries.nodeCount.query(), { x: 0, y: 0, w: 4, h: 3 }),
  panels.stat.withLastNotNullCalcs('', '', queries.aggregatesCount.queries(), { x: 4, y: 0, w: 12, h: 3 }),
  panels.stat.withFieldSummary('OpenShift version', '', '/^metadata\\.ocpVersion$/', queries.openshiftVersion.query(), { x: 16, y: 0, w: 6, h: 3 }),
  panels.stat.withFieldSummary('Etcd version', '', '/^labels\\.cluster_version$/', queries.openshiftVersion.query(), { x: 22, y: 0, w: 2, h: 3 }),
  panels.table.withJobSummary('', '', queries.jobSummary.query(), { x: 0, y: 3, w: 24, h: 3 }),
  panels.table.withClusterMetadata('', '', queries.clusterMetadata.query(), { x: 0, y: 6, w: 24, h: 3 }),
  panels.table.withAlerts('Alerts', '', queries.alerts.query(), { x: 0, y: 9, w: 24, h: 4 }),
  g.panel.row.new('Cluster status')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.withMeanMax('Masters CPU utilization', 'percent', queries.mastersCPUUtilization.queries(), { x: 0, y: 14, w: 12, h: 9 }, -1),
    panels.timeSeries.sortByMin('Masters Memory utilization', 'bytes', queries.mastersMemoryUtilization.queries(), { x: 12, y: 14, w: 12, h: 9 }, -1),
    panels.timeSeries.sortMaxWithRightLegend('Node status summary', 'short', queries.nodeStatusSummary.query(), { x: 0, y: 23, w: 12, h: 8 }, null),
    panels.timeSeries.maxWithBottomLegend('Pod status summary', 'none', queries.podStatusSummary.query(), { x: 12, y: 23, w: 12, h: 8 }, null),
    panels.timeSeries.kupeApiCustomOverrides('Kube-apiserver usage', 'percent', queries.kubeApiServerUsage.queries(), { x: 0, y: 31, w: 12, h: 9 }, null),
    panels.timeSeries.kupeApiAverageCustomOverrides('Average kube-apiserver usage', 'percent', queries.averageKubeApiServerUsage.queries(), { x: 12, y: 31, w: 12, h: 9 }, null),
    panels.timeSeries.activeKubeControllerManagerOverrides('Active Kube-controller-manager usage', 'percent', queries.activeKubeControllerManagerUsage.queries(), { x: 0, y: 40, w: 12, h: 9 }, null),
    panels.timeSeries.kubeSchedulerUsageOverrides('Kube-scheduler usage', 'percent', queries.kubeSchedulerUsage.queries(), { x: 12, y: 40, w: 12, h: 9 }, null),
  ]),
  g.panel.row.new('Pod latency stats')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.sortByMeanCommon('Average pod latency', 'ms', queries.averagePodLatency.query(), { x: 0, y: 13, w: 12, h: 8 }, -1),
    panels.stat.withMeanThresholds('Pod latencies summary $latencyPercentile', 'ms', queries.podLatenciesSummary.query(), { x: 12, y: 15, w: 12, h: 8 }),
    panels.table.withLatencyTableOverrides('Pod conditions latency', 'ms', queries.podConditionsLatency.query(), { x: 0, y: 23, w: 24, h: 10 }),
    panels.timeSeries.sortByMax('Top 10 Container runtime network setup latency', 'µs', queries.top10ContainerRuntimeNetworkSetupLatency.query(), { x: 0, y: 33, w: 12, h: 9 }, -1),
    panels.timeSeries.withMeanMax('Scheduling throughput', 'reqps', queries.schedulingThroughput.query(), { x: 12, y: 33, w: 12, h: 9 }, -1),
  ]),
  g.panel.row.new('OVNKubernetes')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.sortByMean('ovnkube-master pods CPU usage', 'percent', queries.ovnKubeMasterPodStats.queries('containerCPU'), { x: 0, y: 16, w: 12, h: 9 }, null),
    panels.timeSeries.sortByMax('ovnkube-master pods Memory usage', 'bytes', queries.ovnKubeMasterPodStats.queries('containerMemory'), { x: 12, y: 16, w: 12, h: 9 }, null),
    panels.timeSeries.sortByMean('ovnkube-master CPU usage', 'percent', queries.ovnKubeMasterStats.queries('containerCPU'), { x: 0, y: 25, w: 12, h: 8 }, null),
    panels.timeSeries.sortByMaxCommon('ovnkube-master Memory Usage', 'bytes', queries.ovnKubeMasterStats.queries('containerMemory'), { x: 12, y: 25, w: 12, h: 8 }, null),
    panels.timeSeries.sortByMean('ovnkube-node pods CPU Usage', 'percent', queries.ovnKubeNodePodStats.queries('containerCPU'), { x: 0, y: 33, w: 12, h: 8 }, null),
    panels.timeSeries.sortByMean('ovnkube-node pods Memory Usage', 'bytes', queries.ovnKubeNodePodStats.queries('containerMemory'), { x: 12, y: 33, w: 12, h: 8 }, null),
    panels.timeSeries.sortByMax('ovn-controller CPU Usage', 'percent', queries.ovnControllerStats.query('containerCPU'), { x: 0, y: 41, w: 12, h: 8 }, null),
    panels.timeSeries.sortByMax('ovn-controller Memory Usage', 'bytes', queries.ovnControllerStats.query('containerMemory'), { x: 12, y: 41, w: 12, h: 8 }, null),
    panels.timeSeries.withMeanMax('Aggregated OVNKube-master containers CPU', 'percent', queries.aggregatedOVNKubeMasterStats.queries('containerCPU'), { x: 0, y: 49, w: 12, h: 14 }, null),
    panels.timeSeries.withMeanMax('Aggregated OVNKube-master containers memory', 'bytes', queries.aggregatedOVNKubeMasterStats.queries('containerMemory'), { x: 12, y: 49, w: 12, h: 14 }, null),
    panels.timeSeries.withMeanMax('Aggregated OVNKube-node containers CPU', 'percent', queries.aggregatedOVNKubeNodeStats.query('containerCPU'), { x: 0, y: 63, w: 12, h: 14 }, null),
    panels.timeSeries.sortByMeanCommon('Aggregated OVNKube-node containers Memory', 'bytes', queries.aggregatedOVNKubeNodeStats.query('containerMemory'), { x: 12, y: 63, w: 12, h: 14 }, null),
  ]),
  g.panel.row.new('etcd')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.etcd99thDiskWalLatencyOverrides('etcd 99th disk WAL fsync latency', 's', queries.etcd99thLatencies.query('99thEtcdDiskWalFsyncDurationSeconds'), { x: 0, y: 17, w: 12, h: 9 }, null),
    panels.timeSeries.etcd99thCommitLatencyOverrides('etcd 99th disk backend commit latency', 's', queries.etcd99thLatencies.query('99thEtcdDiskBackendCommitDurationSeconds'), { x: 12, y: 17, w: 12, h: 9 }, null),
    panels.timeSeries.base('Etcd leader changes', 'none', queries.etcdLeaderChanges.query(), { x: 0, y: 26, w: 12, h: 9 }, null),
    panels.timeSeries.etcd99thNetworkPeerRTOverrides('Etcd 99th network peer roundtrip time', 's', queries.etcd99thNetworkPeerRT.query(), { x: 12, y: 26, w: 12, h: 9 }, null),
    panels.timeSeries.etcdResouceUtilizationOverrides('Etcd resource utilization', 'percent', queries.etcdResourceUtilization.queries(), { x: 0, y: 35, w: 12, h: 9 }, null),
  ]),
  g.panel.row.new('API and Kubeproxy')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.readOnlyAPIRequestp99ResourceOverrides('Read Only API request P99 latency - resource scoped', 's', queries.readOnlyAPILatencyResource.query(), { x: 0, y: 18, w: 12, h: 8 }, -1),
    panels.timeSeries.readOnlyAPIRequestp99NamespaceOverrides('Read Only API request P99 latency - namespace scoped', 's', queries.readOnlyAPILatencyNamespace.query(), { x: 12, y: 18, w: 12, h: 8 }, -1),
    panels.timeSeries.readOnlyAPIRequestp99ClusterOverrides('Read Only API request P99 latency - cluster scoped', 's', queries.readOnlyAPILatencyCluster.query(), { x: 0, y: 26, w: 12, h: 8 }, -1),
    panels.timeSeries.readOnlyAPIRequestp99MutatingOverrides('Mutating API request P99 latency', 's', queries.readOnlyAPILatencyMutating.query(), { x: 12, y: 26, w: 12, h: 8 }, -1),
    panels.timeSeries.base('Service sync latency', 's', queries.serviceSyncLatency.query(), { x: 0, y: 34, w: 12, h: 10 }, null),
    panels.timeSeries.sortByMax('API request rate', 'reqps', queries.apiRequestRate.query(), { x: 12, y: 34, w: 12, h: 10 }, -1),
  ]),
  g.panel.row.new('Cluster Kubelet & CRI-O')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.meanWithRightLegendCommons('Top 5 Kubelet process by CPU usage', 'percent', queries.top5KubeletProcessByCpuUsage.queries(), { x: 0, y: 19, w: 12, h: 8 }, null),
    panels.timeSeries.meanWithRightLegendCommons('Top 5 CRI-O process by CPU usage', 'percent', queries.top5CrioProcessByCpuUsage.queries(), { x: 12, y: 19, w: 12, h: 8 }, null),
    panels.timeSeries.maxMeanWithRightLegend('Top 5 Kubelet RSS by memory usage', 'bytes', queries.top5KubeletRSSByMemoryUsage.queries(), { x: 0, y: 27, w: 12, h: 8 }, -1),
    panels.timeSeries.maxMeanWithRightLegend('Top 5 CRI-O RSS by memory usage', 'bytes', queries.top5CrioRSSByMemoryUsage.queries(), { x: 12, y: 27, w: 12, h: 8 }, null),
  ]),
  g.panel.row.new('Master: $master')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('master')
  + g.panel.row.withPanels([
    panels.timeSeries.sortByMax('Container CPU usage $master', 'percent', queries.mastersContainerStats.query('containerCPU'), { x: 0, y: 20, w: 12, h: 9 }, null),
    panels.timeSeries.maxWithBottomLegend('Container RSS memory $master', 'bytes', queries.mastersContainerStats.query('containerMemory'), { x: 12, y: 20, w: 12, h: 9 }, null),
    panels.timeSeries.withCommonAggregationsRightPlacement('CPU $master', 'percent', queries.masterCPU.query(), { x: 0, y: 29, w: 12, h: 9 }, null),
    panels.timeSeries.allWithRightLegend('Memory $master', 'bytes', queries.masterMemory.queries(), { x: 12, y: 29, w: 12, h: 9 }, null),
  ]),
  g.panel.row.new('Worker: $worker')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('worker')
  + g.panel.row.withPanels([
    panels.timeSeries.sortByMax('Container CPU usage $worker', 'percent', queries.workersContainerStats.query('containerCPU'), { x: 0, y: 21, w: 12, h: 9 }, null),
    panels.timeSeries.withMeanMax('Container RSS memory $worker', 'bytes', queries.workersContainerStats.query('containerMemory'), { x: 12, y: 21, w: 12, h: 9 }, null),
    panels.timeSeries.workerCPUCustomOverrides('CPU $worker', 'percent', queries.workerCPU.query(), { x: 0, y: 30, w: 12, h: 8 }, null),
    panels.timeSeries.maxWithRightLegend('Memory $worker', 'bytes', queries.workerMemory.queries(), { x: 12, y: 30, w: 12, h: 8 }, null),
  ]),
  g.panel.row.new('Infra: $infra')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('infra')
  + g.panel.row.withPanels([
    panels.timeSeries.sortByMean('Container CPU usage $infra', 'percent', queries.infraContainerStats.queries('containerCPU'), { x: 0, y: 31, w: 12, h: 9 }, null),
    panels.timeSeries.sortByMax('Container RSS memory $infra', 'bytes', queries.infraContainerStats.queries('containerMemory'), { x: 12, y: 31, w: 12, h: 9 }, null),
    panels.timeSeries.meanWithRightLegend('CPU $infra', 'percent', queries.infraCPU.query(), { x: 0, y: 31, w: 12, h: 9 }, null),
    panels.timeSeries.minMaxWithRightLegend('Memory $infra', 'bytes', queries.infraMemory.queries(), { x: 12, y: 31, w: 12, h: 9 }, null),
  ]),
  g.panel.row.new('Aggregated worker nodes usage (only in aggregated metrics profile)')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 0, h: 8 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('_infra_node')
  + g.panel.row.withPanels([
    panels.timeSeries.meanWithRightLegend('Avg CPU usage', 'percent', queries.aggWorkerNodeCpuUsage.query(), { x: 0, y: 23, w: 12, h: 9 }, -1),
    panels.timeSeries.maxWithRightLegend('Avg Memory', 'bytes', queries.aggWorkerNodeMemory.queries(), { x: 12, y: 23, w: 12, h: 9 }, null),
    panels.timeSeries.sortByMax('container CPU usage', 'percent', queries.aggWorkerNodeContainerCpuUsage.query(), { x: 0, y: 32, w: 12, h: 9 }, -1),
    panels.timeSeries.sortByMax('Container memory RSS', 'bytes', queries.aggWorkerNodeContainerMemoryUsage.query(), { x: 12, y: 32, w: 12, h: 9 }, null),
  ]),
])
