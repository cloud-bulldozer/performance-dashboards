local panels = import '../../assets/etcd-on-cluster-dashboard/panels.libsonnet';
local queries = import '../../assets/etcd-on-cluster-dashboard/queries.libsonnet';
local variables = import '../../assets/etcd-on-cluster-dashboard/variables.libsonnet';
local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('etcd-cluster-info dashboard')
+ g.dashboard.time.withFrom('now-1h')
+ g.dashboard.time.withTo('now')
+ g.dashboard.withTimezone('utc')
+ g.dashboard.timepicker.withRefreshIntervals(['5s', '10s', '30s', '1m', '5m', '15m', '30m', '1h', '2h', '1d'])
+ g.dashboard.timepicker.withTimeOptions(['5m', '15m', '1h', '6h', '12h', '24h', '2d', '7d', '30d'])
+ g.dashboard.withRefresh('')
+ g.dashboard.withEditable(false)
+ g.dashboard.graphTooltip.withSharedCrosshair()
+ g.dashboard.withVariables([
  variables.Datasource,
  variables.etcd_pod,
])

+ g.dashboard.withPanels([
  g.panel.row.new('General Resource Usage')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.generalUsageAgg('CPU usage', 'percent', queries.CPUUsage.query(), { x: 0, y: 1, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('Memory usage', 'bytes', queries.memoryUsage.query(), { x: 12, y: 1, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('Disk WAL Sync Duration', 's', queries.diskWalSyncDuration.query(), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('Disk Backend Sync Duration', 's', queries.diskBackendCommitDuration.query(), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('Etcd container disk writes', 'Bps', queries.etcdContainerDiskWrites.query(), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('DB Size', 'bytes', queries.dbSize.query(), { x: 12, y: 16, w: 12, h: 8 }),
  ]),

  g.panel.row.new('Compact/Defrag Detailed')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.histogramStatsRightHand('Compaction Duration sum', 'none', queries.compactionDurationSum.query(), { x: 0, y: 0, w: 8, h: 8 }, 'sum'),
    panels.timeSeries.histogramStatsRightHand('Defrag Duration sum', 'none', queries.defragDurationSum.query(), { x: 8, y: 0, w: 8, h: 8 }, 'count'),
    panels.timeSeries.histogramStatsRightHand('vmstat major page faults', 'none', queries.nodeVmstatPgmajfault.query(), { x: 16, y: 0, w: 8, h: 8 }, 'count'),
  ]),

  g.panel.row.new('WAL fsync Duration Detailed')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.generalUsageAgg('WAL fsync Duration p99', 's', queries.diskWalSyncDuration.query(), { x: 0, y: 0, w: 8, h: 8 }),
    panels.timeSeries.histogramStatsRightHand('WAL fsync Duration sum', 'none', queries.diskWalSyncDurationSum.query(), { x: 8, y: 0, w: 8, h: 8 }, 'sum'),
    panels.timeSeries.histogramStatsRightHand('WAL fsync Duration count', 'none', queries.diskWalSyncDurationCount.query(), { x: 16, y: 0, w: 8, h: 8 }, 'count'),
  ]),

  g.panel.row.new('Backend Commit Duration Detailed')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.generalUsageAgg('Backend Commit Duration', 's', queries.diskBackendCommitDuration.query(), { x: 0, y: 0, w: 8, h: 8 }),
    panels.timeSeries.histogramStatsRightHand('Backend Commit Duration sum', 'none', queries.diskBackendCommitDurationSum.query(), { x: 8, y: 0, w: 8, h: 8 }, 'sum'),
    panels.timeSeries.histogramStatsRightHand('Backend Commit Duration count', 'none', queries.diskBackendCommitDurationCount.query(), { x: 16, y: 0, w: 8, h: 8 }, 'count'),
  ]),

  g.panel.row.new('Network Usage')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.generalUsageAgg('Container network traffic', 'Bps', queries.containerNetworkTraffic.query(), { x: 0, y: 1, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('p99 peer to peer latency', 's', queries.p99PeerToPeerLatency.query(), { x: 12, y: 1, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('Peer network traffic', 'Bps', queries.peerNetworkTraffic.query(), { x: 0, y: 8, w: 12, h: 8 }),
    panels.timeSeries.generalUsageAgg('gRPC network traffic', 'Bps', queries.gRPCNetworkTraffic.query(), { x: 12, y: 8, w: 12, h: 8 }),
    panels.timeSeries.withoutCalcsAgg('Active Streams', '', queries.activeStreams.query(), { x: 0, y: 16, w: 12, h: 8 }),
    panels.timeSeries.withoutCalcsAgg('Snapshot duration', 's', queries.snapshotDuration.query(), { x: 12, y: 16, w: 12, h: 8 }),
  ]),

  g.panel.row.new('DB Info per Member')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.withoutCalcsAgg('% DB Space Used', 'percent', queries.dbSpaceUsed.query(), { x: 0, y: 8, w: 8, h: 8 }),
    panels.timeSeries.withoutCalcsAgg('DB Left capacity (with fragmented space)', 'bytes', queries.dbLeftCapacity.query(), { x: 8, y: 8, w: 8, h: 8 }),
    panels.timeSeries.withoutCalcsAgg('DB Size Limit (Backend-bytes)', 'bytes', queries.dbSizeLimit.query(), { x: 16, y: 8, w: 8, h: 8 }),
  ]),

  g.panel.row.new('General Info')
  + g.panel.row.withGridPos({ x: 0, y: 14, w: 24, h: 1 })
  + g.panel.row.withCollapsed(true)
  + g.panel.row.withPanels([
    panels.timeSeries.GeneralInfo('Raft Proposals', '', queries.raftProposals.query(), { x: 0, y: 1, w: 12, h: 8 }),
    panels.timeSeries.GeneralInfo('Number of leader changes seen', '', queries.numberOfLeaderChangesSeen.query(), { x: 12, y: 1, w: 12, h: 8 }),
    panels.stat.etcdLeader('Etcd has a leader?', 'none', queries.etcdHasALeader.query(), { x: 0, y: 8, w: 6, h: 2 }),
    panels.stat.failedProposalsSeen('Total number of failed proposals seen', 'none', queries.totalNumberOfProposalsSeen.query(), { x: 6, y: 8, w: 6, h: 2 }),
    panels.timeSeries.GeneralInfo('Keys', 'short', queries.keys.query(), { x: 12, y: 12, w: 12, h: 8 }),
    panels.timeSeries.GeneralInfo('Leader Elections Per Day', 'short', queries.leaderElectionsPerDay.query(), { x: 0, y: 12, w: 12, h: 6 }),
    panels.timeSeries.GeneralInfo('Slow Operations', 'ops', queries.slowOperations.query(), { x: 0, y: 20, w: 12, h: 8 }),
    panels.timeSeries.GeneralInfo('Key Operations', 'ops', queries.keyOperations.query(), { x: 12, y: 20, w: 12, h: 8 }),
    panels.timeSeries.generalCounter('Heartbeat Failures', 'short', queries.heartBeatFailure.query(), { x: 0, y: 28, w: 12, h: 8 }),
    panels.timeSeries.GeneralInfo('Compacted Keys', 'short', queries.compactedKeys.query(), { x: 12, y: 28, w: 12, h: 8 }),
  ]),

])
