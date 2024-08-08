local panels = import '../../assets/hypershift-perf-dashboard/panels.libsonnet';
local queries = import '../../assets/hypershift-perf-dashboard/queries.libsonnet';
local variables = import '../../assets/hypershift-perf-dashboard/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

local cluster_prometheus = 'PF55DCC5EC58ABF5A';
local OBO = 'P1BA917A37525EDF3';

g.dashboard.new('Hypershift Performance Dashboard')
+ g.dashboard.withDescription(|||
  Dashboard for Api-performance-overview
|||)
+ g.dashboard.withTags('')
+ g.dashboard.time.withFrom('now-6h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(true)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Namespace,
  variables.Resource,
  variables.Code,
  variables.Verb,
])
+ g.dashboard.withPanels([
  g.panel.row.new('Management cluster stats')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.stat.m_infrastructure('Management Cloud Infrastructure', '', queries.m_infrastructure.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 0, w: 6, h: 4 }),
    panels.stat.m_region('Management Cloud Region', '', queries.m_region.query(), 'PF55DCC5EC58ABF5A', { x: 6, y: 0, w: 6, h: 4 }),
    panels.stat.m_ocp_version('Management OCP Version', '', queries.m_ocp_version.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 0, w: 6, h: 4 }),
    panels.stat.num_hosted_cluster('Number of HostedCluster', '', queries.num_hosted_cluster.query(), 'PF55DCC5EC58ABF5A', { x: 18, y: 0, w: 6, h: 4 }),
    panels.stat.current_namespace_count('Current namespace Count', '', queries.current_namespace_count.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 5, w: 8, h: 4 }),
    panels.stat.current_node_count('Current Node Count', '', queries.current_node_count.query(), 'PF55DCC5EC58ABF5A', { x: 8, y: 5, w: 8, h: 4 }),
    panels.stat.current_pod_count('Current Pod Count', '', queries.current_pod_count.query(), 'PF55DCC5EC58ABF5A', { x: 16, y: 5, w: 8, h: 4 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Hosted Clusters container CPU', 'percent', queries.top10ContCPUHosted.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Hosted Clusters container RSS', 'bytes', queries.top10ContMemHosted.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Management Cluster container CPU', 'percent', queries.top10ContCPUManagement.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 20, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Management Cluster container RSS', 'bytes', queries.top10ContMemManagement.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 20, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Management Cluster OBO NS Pods CPU', 'percent', queries.top10ContCPUOBOManagement.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 28, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Management Cluster OBO NS Pods RSS', 'bytes', queries.top10ContMemOBOManagement.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 28, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Management Cluster Hypershift NS Pods CPU', 'percent', queries.top10ContCPUHypershiftManagement.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 36, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Top 10 Management Cluster Hypershift NS Pods RSS', 'bytes', queries.top10ContMemHypershiftManagement.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 36, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Active Gate Memory Usage', 'bytes', queries.dynaactivegateMem.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 18, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Active Gate CPU Usage', 'percent', queries.dynaactivegateCPU.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 18, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Opentelemetry CPU Usage', 'percent', queries.opentelemetryCPU.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 18, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Opentelemetry Memory Usage', 'bytes', queries.opentelemetryMem.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 18, w: 12, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Number of nodes', 'none', queries.nodeCount.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 44, w: 6, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Machine Set Replicas', 'none', queries.current_machine_set_replica_count.query(), 'PF55DCC5EC58ABF5A', { x: 6, y: 44, w: 6, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Namespace count', 'none', queries.nsCount.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 44, w: 6, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Pod count', 'none', queries.podCount.query(), 'PF55DCC5EC58ABF5A', { x: 18, y: 44, w: 6, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Cluster operators information', 'none', queries.clusterOperatorsInformation.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 52, w: 8, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Cluster operators degraded', 'none', queries.clusterOperatorsDegraded.query(), 'PF55DCC5EC58ABF5A', { x: 8, y: 52, w: 8, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Failed pods', 'none', queries.FailedPods.query(), 'PF55DCC5EC58ABF5A', { x: 16, y: 52, w: 8, h: 8 }),
    panels.timeSeries.managementClustersStatsTimeseriesSettings('Alerts', 'none', queries.alerts.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 60, w: 24, h: 8 }),
  ]),
  g.panel.row.new('Management cluster Etcd stats')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.mgmt('Disk WAL Sync Duration', 's', queries.mgmt_disk_wal_sync_duration.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.mgmt('Disk Backend Sync Duration', 's', queries.mgmt_disk_backend_sync_duration.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('% DB Space Used', 'percent', queries.mgmt_percent_db_used.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 10, w: 8, h: 8 }),
    panels.timeSeries.DBPanelsSettings('DB Left capacity (with fragmented space)', 'bytes', queries.mgmt_db_capacity_left.query(), 'PF55DCC5EC58ABF5A', { x: 8, y: 10, w: 8, h: 8 }),
    panels.timeSeries.DBPanelsSettings('DB Size Limit (Backend-bytes)', 'bytes', queries.mgmt_db_size_limit.query(), 'PF55DCC5EC58ABF5A', { x: 16, y: 10, w: 8, h: 8 }),
    panels.timeSeries.mgmt('DB Size', 'bytes', queries.mgmt_db_size.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 18, w: 12, h: 8 }),
    panels.timeSeries.mgmt('gRPC network traffic', 'Bps', queries.mgmt_grpc_traffic.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 18, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Active Streams', '', queries.mgmt_active_streams.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 26, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Snapshot duration', 's', queries.mgmt_snapshot_duration.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 26, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Raft Proposals', '', queries.mgmt_raft_proposals.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 1, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Number of leader changes seen', '', queries.mgmt_num_leader_changes.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 1, w: 12, h: 8 }),
    panels.stat.etcd_has_leader('Etcd has a leader?', '', queries.mgmt_etcd_has_leader.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 8, w: 6, h: 2 }),
    panels.stat.mgmt_num_failed_proposals('Total number of failed proposals seen', '', queries.mgmt_num_failed_proposals.query(), 'PF55DCC5EC58ABF5A', { x: 6, y: 8, w: 6, h: 2 }),
    panels.timeSeries.DBPanelsSettings('Leader Elections Per Day', '', queries.mgmt_leader_elections_per_day.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 12, w: 12, h: 6 }),
    panels.timeSeries.DBPanelsSettings('Keys', '', queries.mgmt_keys.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 12, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Slow Operations', 'ops', queries.mgmt_slow_operations.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 20, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Key Operations', 'ops', queries.mgmt_key_operations.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 20, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Heartbeat Failures', '', queries.mgmt_heartbeat_failures.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 28, w: 12, h: 8 }),
    panels.timeSeries.DBPanelsSettings('Compacted Keys', '', queries.mgmt_compacted_keys.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 28, w: 12, h: 8 }),
  ]),

  g.panel.row.new('Hosted Clusters Serving Node stats - $namespace')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('namespace')
  + g.panel.row.withPanels([
    panels.timeSeries.genericGraphLegendPanel('Serving Node CPU Basic', 'percent', queries.nodeCPU.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('Serving Node Memory', 'bytes', queries.nodeMemory.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('Suricata CPU(Running on Serving node)', 'percent', queries.suricataCPU.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 18, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('Suricata Memory(Running on Serving node)', 'bytes', queries.suricataMemory.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 18, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('OneAgent CPU Usage', 'percent', queries.dynaactivegateCPU.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 18, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('OneAgent Memory Usage', 'bytes', queries.dynaoneagentMem.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 18, w: 12, h: 8 }),
  ]),

  g.panel.row.new('Hosted Clusters Serving Node stats - $namespace')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('namespace')
  + g.panel.row.withPanels([
    panels.stat.hostedControlPlaneStats('Hosted Cluster Cloud Infrastructure', '', queries.infrastructure.query(), 'P1BA917A37525EDF3', { x: 0, y: 0, w: 8, h: 4 }),
    panels.stat.hostedControlPlaneStats('Hosted Cluster Cloud Region', '', queries.region.query(), 'P1BA917A37525EDF3', { x: 8, y: 0, w: 8, h: 4 }),
    panels.stat.hostedControlPlaneStats('Hosted Cluster OCP Version', '', queries.ocp_version.query(), 'P1BA917A37525EDF3', { x: 16, y: 0, w: 8, h: 4 }),
    panels.timeSeries.genericGraphLegendPanel('Hosted Control Plane CPU', 'percent', queries.hostedControlPlaneCPU.query(), 'PF55DCC5EC58ABF5A', { x: 0, y: 12, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('Hosted Control Plane Memory', 'bytes', queries.hostedControlPlaneMemory.query(), 'PF55DCC5EC58ABF5A', { x: 12, y: 12, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('request duration - 99th quantile', '', queries.request_duration_99th_quantile.query(), OBO, { x: 0, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('request rate - by instance', '', queries.request_rate_by_instance.query(), OBO, { x: 8, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('request duration - 99th quantile - by resource', '', queries.request_duration_99th_quantile_by_resource.query(), OBO, { x: 16, y: 20, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('request duration - 99th quantile', '', queries.request_rate_by_resource.query(), OBO, { x: 0, y: 30, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('request duration - read vs write', '', queries.request_duration_read_write.query(), OBO, { x: 8, y: 30, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('request rate - read vs write', '', queries.request_rate_read_write.query(), OBO, { x: 16, y: 30, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('requests dropped rate', '', queries.requests_dropped_rate.query(), OBO, { x: 0, y: 40, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('requests terminated rate', '', queries.requests_terminated_rate.query(), OBO, { x: 8, y: 40, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('requests status rate', '', queries.requests_status_rate.query(), OBO, { x: 16, y: 40, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('long running requests', '', queries.long_running_requests.query(), OBO, { x: 0, y: 50, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('requests in flight', '', queries.request_in_flight.query(), OBO, { x: 8, y: 50, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('p&f - requests rejected', '', queries.pf_requests_rejected.query(), OBO, { x: 16, y: 50, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('response size - 99th quantile', '', queries.response_size_99th_quartile.query(), OBO, { x: 0, y: 60, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('p&f - request queue length', '', queries.pf_request_queue_length.query(), OBO, { x: 8, y: 60, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('p&f - request wait duration - 99th quantile', '', queries.pf_request_wait_duration_99th_quartile.query(), OBO, { x: 16, y: 60, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('p&f - request execution duration', '', queries.pf_request_execution_duration.query(), OBO, { x: 0, y: 70, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('p&f - request dispatch rate', '', queries.pf_request_dispatch_rate.query(), OBO, { x: 8, y: 70, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('p&f - concurrency limit by priority level', '', queries.pf_concurrency_limit.query(), OBO, { x: 16, y: 70, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelRightSide('p&f - pending in queue', '', queries.pf_pending_in_queue.query(), OBO, { x: 0, y: 80, w: 8, h: 8 }),
  ]),
  g.panel.row.new('Hosted Clusters ETCD General Resource Usage - $namespace')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withRepeat('namespace')
  + g.panel.row.withPanels([
    panels.timeSeries.genericGraphLegendPanel('Disk WAL Sync Duration', 's', queries.disk_wal_sync_duration.query(), OBO, { x: 0, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('Disk Backend Sync Duration', 's', queries.disk_backend_sync_duration.query(), OBO, { x: 12, y: 2, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('% DB Space Used', 'percent', queries.percent_db_used.query(), OBO, { x: 0, y: 10, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('DB Left capacity (with fragmented space)', 'bytes', queries.db_capacity_left.query(), OBO, { x: 8, y: 10, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('DB Size Limit (Backend-bytes)', 'bytes', queries.db_size_limit.query(), OBO, { x: 16, y: 10, w: 8, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('DB Size', 'bytes', queries.db_size.query(), OBO, { x: 0, y: 18, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanel('gRPC network traffic', 'Bps', queries.grpc_traffic.query(), OBO, { x: 12, y: 18, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Active Streams', '', queries.active_streams.query(), OBO, { x: 0, y: 26, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Snapshot duration', 's', queries.snapshot_duration.query(), OBO, { x: 12, y: 26, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Raft Proposals', '', queries.raft_proposals.query(), OBO, { x: 0, y: 34, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Number of leader changes seen', '', queries.num_leader_changes.query(), OBO, { x: 12, y: 34, w: 12, h: 8 }),
    panels.stat.etcd_has_leader('Etcd has a leader?', '', queries.etcd_has_leader.query(), OBO, { x: 0, y: 42, w: 6, h: 2 }),
    panels.stat.mgmt_num_failed_proposals('Total number of failed proposals seen', '', queries.num_failed_proposals.query(), OBO, { x: 6, y: 42, w: 6, h: 2 }),
    panels.timeSeries.genericGraphLegendPanelList('Leader Elections Per Day', '', queries.leader_elections_per_day.query(), OBO, { x: 0, y: 44, w: 12, h: 6 }),
    panels.timeSeries.genericGraphLegendPanelList('Keys', '', queries.keys.query(), OBO, { x: 12, y: 44, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Slow Operations', 'ops', queries.slow_operations.query(), OBO, { x: 0, y: 52, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Key Operations', 'ops', queries.key_operations.query(), OBO, { x: 12, y: 52, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Heartbeat Failures', '', queries.heartbeat_failures.query(), OBO, { x: 0, y: 60, w: 12, h: 8 }),
    panels.timeSeries.genericGraphLegendPanelList('Compacted Keys', '', queries.compacted_keys.query(), OBO, { x: 12, y: 60, w: 12, h: 8 }),
  ]),
])
