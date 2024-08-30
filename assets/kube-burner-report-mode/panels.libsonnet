local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  table: {
    local table = g.panel.table,
    local options = table.options,

    base(title, unit, targets, gridPos):
      table.new(title)
      + table.datasource.withType('elasticsearch')
      + table.datasource.withUid('$Datasource')
      + table.standardOptions.withUnit(unit)
      + table.queryOptions.withTargets(targets)
      + table.gridPos.withX(gridPos.x)
      + table.gridPos.withY(gridPos.y)
      + table.gridPos.withH(gridPos.h)
      + table.gridPos.withW(gridPos.w),

    withPagination(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.footer.TableFooterOptions.withEnablePagination(true),

    withBenchmarkOverview(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              _id: true,
              _index: true,
              _type: true,
              benchmark: false,
              clustertype: true,
              endDate: true,
              end_date: true,
              highlight: true,
              'jobConfig.cleanup': true,
              'jobConfig.errorOnVerify': true,
              'jobConfig.jobIterationDelay': true,
              'jobConfig.jobIterations': false,
              'jobConfig.jobPause': true,
              'jobConfig.maxWaitTimeout': true,
              'jobConfig.namespace': true,
              'jobConfig.namespaced': true,
              'jobConfig.namespacedIterations': false,
              'jobConfig.objects': true,
              'jobConfig.preLoadPeriod': true,
              'jobConfig.verifyObjects': true,
              'jobConfig.waitFor': true,
              'jobConfig.waitForDeletion': true,
              'jobConfig.waitWhenFinished': true,
              k8sVersion: true,
              metricName: true,
              ocp_version: true,
              platform: false,
              sdn_type: false,
              sort: true,
              timestamp: true,
              total_nodes: false,
              uuid: false,
              workload: true,
              workload_nodes_count: true,
              workload_nodes_type: true,
            },
            indexByName: {
              _id: 1,
              _index: 2,
              _type: 3,
              benchmark: 5,
              clusterName: 8,
              endDate: 9,
              highlight: 6,
              infraNodesCount: 20,
              infraNodesType: 21,
              k8sVersion: 10,
              masterNodesType: 16,
              metricName: 13,
              ocpVersion: 11,
              passed: 15,
              platform: 12,
              sdnType: 14,
              sort: 7,
              timestamp: 0,
              totalNodes: 17,
              uuid: 4,
              workerNodesCount: 18,
              workerNodesType: 19,
            },
            renameByName: {
              _type: '',
              clusterName: 'Cluster',
              elapsedTime: 'Elapsed time',
              endDate: '',
              infraNodesCount: 'infra count',
              infraNodesType: 'infra type',
              infra_nodes_count: 'Infra nodes',
              infra_nodes_type: 'Infra flavor',
              'jobConfig.burst': 'Burst',
              'jobConfig.cleanup': '',
              'jobConfig.errorOnVerify': 'errorOnVerify',
              'jobConfig.jobIterationDelay': 'jobIterationDelay',
              'jobConfig.jobIterations': 'Iterations',
              'jobConfig.jobPause': 'jobPause',
              'jobConfig.jobType': 'Job Type',
              'jobConfig.maxWaitTimeout': 'maxWaitTImeout',
              'jobConfig.name': 'Name',
              'jobConfig.namespace': 'namespacePrefix',
              'jobConfig.namespaced': '',
              'jobConfig.namespacedIterations': 'Namespaced iterations',
              'jobConfig.objects': '',
              'jobConfig.podWait': 'podWait',
              'jobConfig.preLoadImages': 'Preload Images',
              'jobConfig.preLoadPeriod': '',
              'jobConfig.qps': 'QPS',
              'jobConfig.verifyObjects': '',
              k8sVersion: 'k8s version',
              k8s_version: 'k8s version',
              masterNodesType: 'master type',
              master_nodes_count: 'Master nodes',
              master_nodes_type: 'Masters flavor',
              metricName: '',
              ocpVersion: 'OCP version',
              passed: 'Passed',
              platform: 'Platform',
              result: 'Result',
              sdnType: 'SDN',
              sdn_type: 'SDN',
              timestamp: '',
              totalNodes: 'total nodes',
              total_nodes: 'Total nodes',
              uuid: 'UUID',
              workerNodesCount: 'worker count',
              workerNodesType: 'worker type',
              worker_nodes_count: 'Worker nodes',
              worker_nodes_type: 'Workers flavor',
              workload: '',
              workload_nodes_count: 'Workload nodes',
              workload_nodes_type: 'Workload flavor',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byName',
            options: 'passed',
          },
          properties: [
            {
              id: 'custom.cellOptions',
              value: {
                mode: 'basic',
                type: 'color-background',
              },
            },
          ],
        },
      ])
      + table.standardOptions.withMappings([
        {
          options: {
            passed: {
              color: 'green',
              index: 0,
            },
          },
          type: 'value',
        },
      ])
      + table.standardOptions.thresholds.withSteps([
        {
          color: 'green',
          value: null,
        },
      ]),

    withGarbageCollection(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              _id: true,
              _index: true,
              _type: true,
              highlight: true,
              'jobConfig.churnDelay': true,
              'jobConfig.churnDuration': true,
              'jobConfig.churnPercent': true,
              'jobConfig.cleanup': true,
              'jobConfig.errorOnVerify': true,
              'jobConfig.iterationsPerNamespace': true,
              'jobConfig.jobIterationDelay': true,
              'jobConfig.jobIterations': false,
              'jobConfig.jobPause': true,
              'jobConfig.jobType': true,
              'jobConfig.maxWaitTimeout': true,
              'jobConfig.name': false,
              'jobConfig.namespace': true,
              'jobConfig.namespaceLabels.pod-security.kubernetes.io/audit': true,
              'jobConfig.namespaceLabels.pod-security.kubernetes.io/enforce': true,
              'jobConfig.namespaceLabels.pod-security.kubernetes.io/warn': true,
              'jobConfig.namespaceLabels.security.openshift.io/scc.podSecurityLabelSync': true,
              'jobConfig.namespaced': true,
              'jobConfig.namespacedIterations': true,
              'jobConfig.objects': true,
              'jobConfig.podWait': true,
              'jobConfig.preLoadImages': true,
              'jobConfig.preLoadPeriod': true,
              'jobConfig.verifyObjects': true,
              'jobConfig.waitFor': true,
              'jobConfig.waitForDeletion': true,
              'jobConfig.waitWhenFinished': true,
              'metadata.cloud-bulldozer': true,
              'metadata.k8sVersion': true,
              'metadata.ocpMajorVersion': true,
              'metadata.ocpVersion': true,
              'metadata.platform': true,
              'metadata.sdnType': true,
              'metadata.totalNodes': true,
              metricName: true,
              sort: true,
              timestamp: false,
              uuid: false,
            },
            indexByName: {
              _id: 2,
              _index: 3,
              _type: 4,
              elapsedTime: 8,
              highlight: 19,
              'jobConfig.burst': 7,
              'jobConfig.churnDelay': 20,
              'jobConfig.churnDuration': 21,
              'jobConfig.churnPercent': 22,
              'jobConfig.cleanup': 11,
              'jobConfig.errorOnVerify': 12,
              'jobConfig.iterationsPerNamespace': 23,
              'jobConfig.jobIterations': 9,
              'jobConfig.jobType': 10,
              'jobConfig.maxWaitTimeout': 13,
              'jobConfig.name': 5,
              'jobConfig.namespace': 14,
              'jobConfig.preLoadImages': 24,
              'jobConfig.preLoadPeriod': 25,
              'jobConfig.qps': 6,
              'jobConfig.verifyObjects': 15,
              'jobConfig.waitForDeletion': 16,
              'jobConfig.waitWhenFinished': 17,
              'metadata.k8sVersion': 26,
              'metadata.ocpMajorVersion': 27,
              'metadata.ocpVersion': 28,
              'metadata.platform': 29,
              'metadata.sdnType': 30,
              'metadata.totalNodes': 31,
              metricName: 18,
              sort: 32,
              timestamp: 1,
              uuid: 0,
              version: 33,
            },
            renameByName: {
              _type: '',
              elapsedTime: 'Elapsed time',
              elapsedTimeNs: 'Elapsed Time',
              endTimestamp: '',
              highlight: '',
              'jobConfig.burst': 'Burst',
              'jobConfig.churn': 'Churn',
              'jobConfig.churnDelay': '',
              'jobConfig.churnDeletionStrategy': 'Churn Deletion strategy',
              'jobConfig.cleanup': '',
              'jobConfig.errorOnVerify': 'errorOnVerify',
              'jobConfig.iterationsPerNamespace': 'iterationsPerNs',
              'jobConfig.jobIterationDelay': 'jobIterationDelay',
              'jobConfig.jobIterations': 'Iterations',
              'jobConfig.jobPause': 'jobPause',
              'jobConfig.jobType': 'Job Type',
              'jobConfig.maxWaitTimeout': 'maxWaitTImeout',
              'jobConfig.name': 'Name',
              'jobConfig.namespace': 'namespacePrefix',
              'jobConfig.namespaceLabels.pod-security.kubernetes.io/audit': '',
              'jobConfig.namespaced': '',
              'jobConfig.namespacedIterations': 'Namespaced iterations',
              'jobConfig.objects': '',
              'jobConfig.podWait': 'podWait',
              'jobConfig.preLoadImages': 'Preload Images',
              'jobConfig.preLoadPeriod': '',
              'jobConfig.qps': 'QPS',
              'jobConfig.verifyObjects': '',
              'metadata.ocpMajorVersion': 'Major version',
              'metadata.platform': 'Platform',
              metricName: '',
              timestamp: 'Date',
              uuid: 'UUID',
              version: 'Kube-burner version',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byName',
            options: 'Elapsed time',
          },
          properties: [
            {
              id: 'unit',
              value: 's',
            },
          ],
        },
        {
          matcher: {
            id: 'byName',
            options: 'Elapsed Time',
          },
          properties: [
            {
              id: 'unit',
              value: 'ns',
            },
          ],
        },
      ])
      + table.standardOptions.thresholds.withSteps([
        {
          color: 'green',
          value: null,
        },
        {
          color: 'red',
          value: 80,
        },
      ]),
  },

  barGauge: {
    local bargauge = g.panel.barGauge,
    local options = bargauge.options,

    base(title, unit, targets, gridPos):
      bargauge.new(title)
      + bargauge.queryOptions.withTargets(targets)
      + bargauge.datasource.withType('elasticsearch')
      + bargauge.datasource.withUid('$Datasource')
      + bargauge.standardOptions.withUnit(unit)
      + bargauge.gridPos.withX(gridPos.x)
      + bargauge.gridPos.withY(gridPos.y)
      + bargauge.gridPos.withH(gridPos.h)
      + bargauge.gridPos.withW(gridPos.w)
      + options.withOrientation('horizontal')
      + options.withDisplayMode('gradient')
      + options.withValueMode('color')
      + options.withShowUnfilled(true)
      + options.withMinVizWidth(0)
      + options.withMinVizHeight(10)
      + options.text.withTitleSize(12),

    withnodeCPUUsage(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + bargauge.panelOptions.withRepeat('node_roles')
      + bargauge.standardOptions.withMin(0)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ]),

    withnodeMemoryUsage(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + bargauge.panelOptions.withRepeat('node_roles')
      + bargauge.standardOptions.withMin(5)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ])
      + bargauge.standardOptions.color.withFixedColor('dark-red')
      + bargauge.standardOptions.color.withMode('palette-classic'),

    withP99PodReadyLatency(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + bargauge.standardOptions.withMin(0)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ])
      + bargauge.standardOptions.color.withMode('palette-classic'),

    etcdCPUusage(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.withMinVizHeight(0)
      + options.withMinVizWidth(10)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ])
      + bargauge.standardOptions.color.withMode('palette-classic'),


  },

  barChart: {
    local barchart = g.panel.barChart,
    local options = barchart.options,
    local custom = barchart.fieldConfig.defaults.custom,

    base(title, unit, targets, gridPos):
      barchart.new(title)
      + barchart.datasource.withType('elasticsearch')
      + barchart.datasource.withUid('$Datasource')
      + barchart.standardOptions.withUnit(unit)
      + barchart.queryOptions.withTargets(targets)
      + barchart.gridPos.withX(gridPos.x)
      + barchart.gridPos.withY(gridPos.y)
      + barchart.gridPos.withH(gridPos.h)
      + barchart.gridPos.withW(gridPos.w),

    BarchartOptionSettings(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.legend.withDisplayMode('list')
      + options.legend.withPlacement('bottom')
      + options.legend.withShowLegend(true)
      + options.withOrientation('horizontal')
      + options.withBarWidth(0.97)
      + options.withGroupWidth(0.7),

    ReadOnlyAPIrequestP99latency(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withLog(2)
      + custom.scaleDistribution.withType('log'),


    maxClusterCPUusageRatio(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withType('linear'),

    etcdScaleDistribution(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withLog(10)
      + custom.scaleDistribution.withType('log'),

    etcdroundtrip(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withLog(10)
      + custom.scaleDistribution.withType('log')
      + barchart.standardOptions.color.withMode('continuous-RdYlGr'),

    ComponentRepeatPanelsBlue(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withLog(2)
      + custom.scaleDistribution.withType('log')
      + barchart.standardOptions.color.withMode('fixed')
      + barchart.standardOptions.color.withFixedColor('blue'),

    ComponentRepeatPanelsRed(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withLog(2)
      + custom.scaleDistribution.withType('log')
      + barchart.standardOptions.color.withMode('fixed')
      + barchart.standardOptions.color.withFixedColor('red'),

    ComponentRepeatPanelsYellow(title, unit, targets, gridPos):
      self.BarchartOptionSettings(title, unit, targets, gridPos)
      + custom.scaleDistribution.withLog(2)
      + custom.scaleDistribution.withType('log')
      + barchart.standardOptions.color.withMode('fixed')
      + barchart.standardOptions.color.withFixedColor('yellow'),


  },

  timeSeries: {
    local timeSeries = g.panel.timeSeries,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local options = timeSeries.options,

    base(title, unit, targets, gridPos, maxPoints):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.queryOptions.withMaxDataPoints(maxPoints)
      + timeSeries.datasource.withType('elasticsearch')
      + timeSeries.datasource.withUid('$Datasource')
      + timeSeries.standardOptions.withUnit(unit)
      + timeSeries.gridPos.withX(gridPos.x)
      + timeSeries.gridPos.withY(gridPos.y)
      + timeSeries.gridPos.withH(gridPos.h)
      + timeSeries.gridPos.withW(gridPos.w)
      + custom.withSpanNulls(true)
      + custom.withFillOpacity(10)
      + options.tooltip.withMode('multi')
      + options.tooltip.withSort('desc')
      + options.legend.withShowLegend(true)
      + options.legend.withPlacement('bottom')
      + options.legend.withDisplayMode('table'),

    withCommonAggregations(title, unit, targets, gridPos, maxPoints):
      self.base(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'mean',
        'max',
        'min',
      ]),

    withMeanMax(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'mean',
        'max',
      ]),

    sortByMean(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + options.legend.withSortBy('Mean')
      + options.legend.withSortDesc(true),

    sortByMax(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'max',
        'mean',
      ])
      + options.legend.withSortBy('Max')
      + options.legend.withSortDesc(true),

    sortByMeanCommon(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withSortBy('Mean')
      + options.legend.withSortDesc(true),

  },


}
