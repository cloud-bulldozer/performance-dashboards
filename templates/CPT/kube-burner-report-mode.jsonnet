local panels = import '../../assets/kube-burner-report-mode/panels.libsonnet';
local queries = import '../../assets/kube-burner-report-mode/queries.libsonnet';
local variables = import '../../assets/kube-burner-report-mode/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Kube-burner Report Mode')
+ g.dashboard.withDescription(|||
  Dashboard for kube-burner Mode
|||)
+ g.dashboard.withTags('kube-burner')
+ g.dashboard.time.withFrom('2024-01-28 00:00:00')
+ g.dashboard.time.withTo('2024-01-29 23:59:59')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(true)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.platform,
  variables.sdn,
  variables.clusterType,
  variables.benchmark,
  variables.workerNodesCount,
  variables.ocpMajorVersion,
  variables.uuid,
  variables.compare_by,
  variables.component,
  variables.node_roles,
])
+ g.dashboard.withPanels([
  panels.table.withBenchmarkOverview('', '', queries.benchmarkOveriew.query(), { x: 6, y: 0, w: 24, h: 6 }),
  panels.table.withGarbageCollection('', '', queries.garbageCollection.query(), { x: 0, y: 6, w: 24, h: 5 }),
  g.panel.row.new('Node Usage')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.barGauge.withnodeCPUUsage('$workerNodesCount nodes - CPU usage $node_roles', 'cores', queries.nodeCPUusage.query(), { x: 0, y: 12, w: 24, h: 4 }),
    panels.barGauge.withnodeCPUUsage('Maximum CPU usage $node_roles', 'cores', queries.maximumCPUusage.query(), { x: 4, y: 16, w: 8, h: 4 }),
    panels.barGauge.withnodeMemoryUsage('$workerNodesCount nodes - Memory usage $node_roles', 'bytes', queries.masterMemoryUsage.query(), { x: 0, y: 20, w: 8, h: 4 }),
    panels.barGauge.withnodeMemoryUsage('$workerNodesCount nodes - Maximum aggregated memory usage $node_roles', 'bytes', queries.maximumAggregatedMemory.query(), { x: 0, y: 24, w: 8, h: 4 }),
    panels.barChart.maxClusterCPUusageRatio('Max Cluster CPU usage ratio', '', queries.maxClusterCPUusageRatio.query(), { x: 0, y: 28, w: 7, h: 6 }),
    panels.barChart.maxClusterCPUusageRatio('Max Cluster memory usage ratio', '', queries.maxClusterMemoryUsageratio.query(), { x: 7, y: 28, w: 7, h: 6 }),
  ]),
  g.panel.row.new('Pod & Service ready latency')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.barGauge.withP99PodReadyLatency('P99 Pod ready latency', 'ms', queries.P99PodReadyLatency.query(), { x: 0, y: 13, w: 10, h: 6 }),
    panels.barGauge.withP99PodReadyLatency('P99 Service ready latency', 'ns', queries.P99ServiceReadyLatency.query(), { x: 10, y: 35, w: 10, h: 6 }),
  ]),
  g.panel.row.new('API latency')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.barChart.ReadOnlyAPIrequestP99latency('Read Only API request P99 latency - resource scoped', 's', queries.ReadOnlyAPIRequestP99LatencyResourceScoped.query(), { x: 0, y: 14, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Maximum Read Only API request P99 latency - resource scoped', 's', queries.MaxReadOnlyAPIrequestP99ResourceScoped.query(), { x: 12, y: 14, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Read Only API request P99 latency - namespace scoped', 's', queries.ReadonlyAPIrequestP99LatencyNamespaceScoped.query(), { x: 0, y: 20, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Maximum Read Only API request P99 latency - namespace scoped', 's', queries.MaxReadOnlyAPIrequestP99LatencyNamespaceScoped.query(), { x: 12, y: 20, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Read Only API request P99 latency - cluster scoped', 's', queries.ReadOnlyAPIrequestP99LatencyClusterScoped.query(), { x: 0, y: 26, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Maximum Read Only API request P99 latency - cluster scoped', 's', queries.MaxReadonlyAPIrequestP99LatencyClusterScoped.query(), { x: 12, y: 26, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Mutating API request P99 latency', 's', queries.MutatingAPIrequestP99Latency.query(), { x: 0, y: 32, w: 12, h: 6 }),
    panels.barChart.ReadOnlyAPIrequestP99latency('Maximum Mutating API request P99 latency', 's', queries.MaxMutatingAPIrequestP99Latency.query(), { x: 12, y: 32, w: 12, h: 6 }),
  ]),
  g.panel.row.new('ETCD')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.barChart.etcdScaleDistribution('99th WAL fsync', 's', queries.etcd99thWALfsync.query(), { x: 0, y: 15, w: 7, h: 5 }),
    panels.barChart.etcdScaleDistribution('Maximum 99th WAL fsync', 's', queries.Max99thWALfsync.query(), { x: 7, y: 15, w: 11, h: 5 }),
    panels.barChart.etcdroundtrip('99th Roundtrip', 's', queries.etcd99Roundtrip.query(), { x: 0, y: 20, w: 7, h: 5 }),
    panels.barChart.etcdroundtrip('Maximum 99th Roundtrip', 's', queries.Max99Roundtrip.query(), { x: 7, y: 20, w: 11, h: 5 }),
    panels.barChart.etcdScaleDistribution('99th Backend I/O', 's', queries.etcd99BackendIandO.query(), { x: 0, y: 25, w: 7, h: 5 }),
    panels.barChart.etcdScaleDistribution('Maximum 99th Backend I/O', 's', queries.Max99thBackendIandO.query(), { x: 7, y: 25, w: 11, h: 5 }),
    panels.barGauge.etcdCPUusage('Etcd CPU usage', 'cores', queries.etcdCPUusage.query(), { x: 0, y: 30, w: 7, h: 6 }),
    panels.barGauge.etcdCPUusage('Maximum Etcd CPU usage', 'cores', queries.MaxetcdCPUusage.query(), { x: 7, y: 30, w: 7, h: 6 }),
    panels.barGauge.etcdCPUusage('Etcd RSS usage', 'bytes', queries.etcdRSSusage.query(), { x: 0, y: 36, w: 7, h: 6 }),
    panels.barGauge.etcdCPUusage('Etcd max RSS usage', 'bytes', queries.etcdMaxRSSusage.query(), { x: 7, y: 36, w: 7, h: 6 }),
  ]),
  g.panel.row.new('$component')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('component')
  + g.panel.row.withPanels([
    panels.barChart.ComponentRepeatPanelsBlue('Average RSS Usage $component', 'bytes', queries.AvgRSSUsageComponet.query(), { x: 0, y: 43, w: 9, h: 10 }),
    panels.barChart.ComponentRepeatPanelsRed('Max Aggregated RSS Usage $component', 'bytes', queries.MaxAggregatedRSSUsageComponent.query(), { x: 9, y: 43, w: 8, h: 10 }),
    panels.barChart.ComponentRepeatPanelsRed('Max RSS Usage $component', 'bytes', queries.MaxRSSUsageComponent.query(), { x: 17, y: 43, w: 7, h: 10 }),
    panels.barChart.ComponentRepeatPanelsYellow('Average CPU Usage $component', 'cores', queries.AvgCPUUsageComponent.query(), { x: 0, y: 53, w: 11, h: 5 }),
    panels.barChart.ComponentRepeatPanelsYellow('Maximum CPU Usage $component', 'cores', queries.MaxCPUUsageComponent.query(), { x: 11, y: 53, w: 13, h: 5 }),
  ]),
])
