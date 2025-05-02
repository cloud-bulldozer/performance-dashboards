local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  row: {
    local row = g.panel.row,

    base(title, repeat, gridPos):
      row.new(title)
      + row.withRepeat(repeat)
      + row.gridPos.withX(gridPos.x)
      + row.gridPos.withY(gridPos.y)
      + row.gridPos.withH(gridPos.h)
      + row.gridPos.withW(gridPos.w),
  },

  table: {
    local table = g.panel.table,
    local options = table.options,

    base(title, targets, gridPos):
      table.new(title)
      + table.datasource.withType('elasticsearch')
      + table.datasource.withUid('$Datasource')
      + table.panelOptions.withRepeat('profile')
      + table.panelOptions.withRepeatDirection('h')
      + table.standardOptions.color.withMode('thresholds')
      + table.queryOptions.withTargets(targets)
      + table.gridPos.withX(gridPos.x)
      + table.gridPos.withY(gridPos.y)
      + table.gridPos.withH(gridPos.h)
      + table.gridPos.withW(gridPos.w)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              'Average latency': true,
              'ltcyMetric.keyword': true,
              'tputMetric.keyword': true,
            },
            indexByName: {
              Average: 10,
              hostNetwork: 8,
              'ltcyMetric.keyword': 7,
              messageSize: 3,
              'metadata.clusterName.keyword': 1,
              'metadata.platform.keyword': 5,
              'metadata.workerNodesType.keyword': 9,
              'profile.keyword': 2,
              service: 6,
              'tputMetric.keyword': 4,
              'uuid.keyword': 0,
            },
            renameByName: {
              Average: 'Throughput',
              'Average latency': 'P99 latency',
              'ltcyMetric.keyword': '',
              'metadata.clusterName.keyword': 'clusterName',
              'metadata.platform.keyword': 'Platform',
              'metadata.workerNodesType.keyword': 'workers',
              'profile.keyword': 'Profile',
              'uuid.keyword': 'uuid',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byName',
            options: 'Average',
          },
          properties: [
            {
              id: 'unit',
              value: 'Mbits',
            },
          ],
        },
        {
          matcher: {
            id: 'byName',
            options: 'messageSize',
          },
          properties: [
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
      ])
      + options.withCellHeight('sm')
      + options.withFooter({
        countRows: false,
        fields: '',
        reducer: [
          'sum',
        ],
        show: false,
      })
      + options.withSortBy([
        {
          desc: true,
          displayName: 'ea7b29d7-8991-4752-a0d4-e26446d34915 TCP_STREAM 4096 Mb/s AWS',
        },
      ]),
    workloadSummary(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              _id: true,
              _index: true,
              _type: true,
              'clientCPU.idleCPU': true,
              'clientCPU.ioCPU': true,
              'clientCPU.irqCPU': true,
              'clientCPU.niceCPU': true,
              'clientCPU.softCPU': true,
              'clientCPU.stealCPU': true,
              'clientCPU.systemCPU': true,
              'clientCPU.userCPU': true,
              'clientNodeLabels.beta.kubernetes.io/arch': true,
              'clientNodeLabels.beta.kubernetes.io/instance-type': true,
              'clientNodeLabels.beta.kubernetes.io/os': true,
              'clientNodeLabels.failure-domain.beta.kubernetes.io/region': true,
              'clientNodeLabels.failure-domain.beta.kubernetes.io/zone': true,
              'clientNodeLabels.hypershift.openshift.io/managed': true,
              'clientNodeLabels.hypershift.openshift.io/nodePool': true,
              'clientNodeLabels.kubernetes.io/arch': true,
              'clientNodeLabels.kubernetes.io/hostname': true,
              'clientNodeLabels.kubernetes.io/os': true,
              'clientNodeLabels.node-role.kubernetes.io/worker': true,
              'clientNodeLabels.node.kubernetes.io/instance-type': true,
              'clientNodeLabels.node.openshift.io/os_id': true,
              'clientNodeLabels.topology.ebs.csi.aws.com/zone': true,
              'clientNodeLabels.topology.kubernetes.io/region': true,
              'clientNodeLabels.topology.kubernetes.io/zone': true,
              clientPods: true,
              confidence: true,
              driver: true,
              highlight: true,
              hostNetwork: true,
              latency: true,
              'local': true,
              ltcyMetric: true,
              messageSize: true,
              'metadata.ipsec': true,
              'metadata.k8sVersion': true,
              'metadata.kernel': true,
              'metadata.masterNodesCount': true,
              'metadata.masterNodesType': true,
              'metadata.metricName': true,
              'metadata.mtu': true,
              'metadata.ocpShortVersion': true,
              'metadata.totalNodes': true,
              parallelism: true,
              profile: true,
              samples: true,
              'serverCPU.idleCPU': true,
              'serverCPU.ioCPU': true,
              'serverCPU.irqCPU': true,
              'serverCPU.niceCPU': true,
              'serverCPU.softCPU': true,
              'serverCPU.stealCPU': true,
              'serverCPU.systemCPU': true,
              'serverCPU.userCPU': true,
              'serverNodeLabels.beta.kubernetes.io/arch': true,
              'serverNodeLabels.beta.kubernetes.io/instance-type': true,
              'serverNodeLabels.beta.kubernetes.io/os': true,
              'serverNodeLabels.failure-domain.beta.kubernetes.io/region': true,
              'serverNodeLabels.failure-domain.beta.kubernetes.io/zone': true,
              'serverNodeLabels.hypershift.openshift.io/managed': true,
              'serverNodeLabels.hypershift.openshift.io/nodePool': true,
              'serverNodeLabels.kubernetes.io/arch': true,
              'serverNodeLabels.kubernetes.io/hostname': true,
              'serverNodeLabels.kubernetes.io/os': true,
              'serverNodeLabels.node-role.kubernetes.io/worker': true,
              'serverNodeLabels.node.kubernetes.io/instance-type': true,
              'serverNodeLabels.node.openshift.io/os_id': true,
              'serverNodeLabels.topology.ebs.csi.aws.com/zone': true,
              'serverNodeLabels.topology.kubernetes.io/region': true,
              'serverNodeLabels.topology.kubernetes.io/zone': true,
              serverPods: true,
              service: true,
              sort: true,
              tcpRetransmits: true,
              throughput: true,
              tputMetric: true,
              udpLossPercent: true,
            },
            indexByName: {
              uuid: 0,
              timestamp: 1,
              'metadata.platform': 2,
              'metadata.ocpVersion': 3,
              'metadata.clusterName': 4,
              'metadata.sdnType': 5,
              'metadata.infraNodesCount': 6,
              'metadata.infraNodesType': 7,
              'metadata.workerNodesCount': 8,
              'metadata.workerNodesType': 9,
              'metadata.acrossAZ': 10,
              'metadata.region': 11,
            },
            renameByName: {
              acrossAZ: 'Multi-AZ',
              'metadata.clusterName': 'Cluster Name',
              'metadata.infraNodesCount': 'Infras',
              'metadata.infraNodesType': 'Infra Type',
              'metadata.ocpVersion': 'Version',
              'metadata.platform': 'Platform',
              'metadata.region': 'Region',
              'metadata.sdnType': 'SDN',
              'metadata.workerNodesCount': 'Workers',
              'metadata.workerNodesType': 'Workers Type',
              timestamp: 'Timestamp',
              uuid: 'UUID',
            },
          },
        },
        {
          id: 'groupBy',
          options: {
            fields: {
              UUID: { aggregations: [], operation: 'groupby' },
              'Cluster Name': { aggregations: ['lastNotNull'], operation: 'aggregate' },
              'Infra Type': { aggregations: ['lastNotNull'], operation: 'aggregate' },
              Infras: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              Platform: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              Region: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              SDN: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              Timestamp: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              Version: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              Workers: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              'Workers Type': { aggregations: ['lastNotNull'], operation: 'aggregate' },
              duration: { aggregations: ['lastNotNull'], operation: 'aggregate' },
              'Multi-AZ': { aggregations: ['last'], operation: 'aggregate' },
            },
          },
        },
      ]),
    withLatencyOverrides(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              'Average latency': true,
              'ltcyMetric.keyword': true,
              'tputMetric.keyword': true,
            },
            indexByName: {
              Average: 8,
              hostNetwork: 6,
              messageSize: 3,
              'metadata.clusterName.keyword': 1,
              'metadata.platform.keyword': 4,
              'metadata.workerNodesType.keyword': 7,
              'profile.keyword': 2,
              service: 5,
              'uuid.keyword': 0,
            },
            renameByName: {
              Average: 'P99 latency',
              'Average latency': 'P99 latency',
              'ltcyMetric.keyword': '',
              'metadata.clusterName.keyword': 'clusterName',
              'metadata.platform.keyword': 'Platform',
              'metadata.workerNodesType.keyword': 'workers',
              'profile.keyword': 'Profile',
              'uuid.keyword': 'uuid',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byName',
            options: 'Average',
          },
          properties: [
            {
              id: 'unit',
              value: 'µs',
            },
          ],
        },
        {
          matcher: {
            id: 'byName',
            options: 'messageSize',
          },
          properties: [
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
      ]),
  },
  barGauge: {
    local barGauge = g.panel.barGauge,
    local custom = barGauge.fields.defaults.custom,
    local options = barGauge.options,

    base(title, targets, gridPos):
      barGauge.new(title)
      + barGauge.queryOptions.withTargets(targets)
      + barGauge.datasource.withType('elasticsearch')
      + barGauge.datasource.withUid('$Datasource')
      + barGauge.options.reduceOptions.withValues(false)
      + barGauge.options.reduceOptions.withCalcs(['lastNotNull'])
      + barGauge.options.reduceOptions.withFields('')
      + barGauge.options.withOrientation('horizontal')
      + barGauge.options.withDisplayMode('gradient')
      + barGauge.options.withValueMode('color')
      + barGauge.panelOptions.withRepeat('messageSize')
      + barGauge.standardOptions.withMin('0')
      + barGauge.standardOptions.color.withMode('palette-classic')
      + barGauge.gridPos.withX(gridPos.x)
      + barGauge.gridPos.withY(gridPos.y)
      + barGauge.gridPos.withH(gridPos.h)
      + barGauge.gridPos.withW(gridPos.w),

    withThroughput(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + barGauge.standardOptions.withUnit('Mbits'),

    withLatency(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + barGauge.standardOptions.withUnit('µs'),
  },
  timeSeries: {
    local timeSeries = g.panel.timeSeries,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local options = timeSeries.options,

    base(title, targets, gridPos):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.panelOptions.withRepeat('messageSize')
      + timeSeries.panelOptions.withRepeatDirection('h')
      + timeSeries.datasource.withType('elasticsearch')
      + timeSeries.datasource.withUid('$Datasource')
      + timeSeries.gridPos.withX(gridPos.x)
      + timeSeries.gridPos.withY(gridPos.y)
      + timeSeries.gridPos.withH(gridPos.h)
      + timeSeries.gridPos.withW(gridPos.w)
      + custom.withLineWidth(2)
      + custom.withGradientMode('hue')
      + custom.withShowPoints('always')
      + custom.withPointSize(10)
      + custom.withSpanNulls(true)
      + custom.withFillOpacity(0)
      + custom.withScaleDistribution({
        type: 'log',
        log: 2,
      })
      + custom.withAxisCenteredZero(false)
      + custom.withHideFrom({
        tooltip: false,
        viz: false,
        legend: false,
      })
      + custom.withAxisGridShow(true)
      + custom.withLineStyle({
        fill: 'solid',
      })
      + options.tooltip.withMode('single')
      + options.tooltip.withSort('none')
      + options.legend.withShowLegend(true)
      + options.legend.withPlacement('bottom')
      + options.legend.withDisplayMode('table')
      + options.legend.withCalcs(['lastNotNull'])
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byFrameRefID',
            options: 'A',
          },
          properties: [
            {
              id: 'unit',
              value: 'µs',
            },
          ],
        },
      ]),

    withThroughputOverrides(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + options.legend.withSortBy('Last *')
      + options.legend.withPlacement('right')
      + options.legend.withSortDesc(false)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byFrameRefID',
            options: 'A',
          },
          properties: [
            {
              id: 'unit',
              value: 'Mbits',
            },
          ],
        },
      ]),
  },
}
