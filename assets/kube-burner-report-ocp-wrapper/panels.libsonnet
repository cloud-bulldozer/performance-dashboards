local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
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

    withCommonAggregationsRightPlacement(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withPlacement('right'),

    meanWithRightLegend(title, unit, targets, gridPos, maxPoints):
      self.base(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'mean',
      ])
      + options.legend.withPlacement('right'),

    withMeanMax(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'mean',
        'max',
      ]),

    withMinMax(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'max',
        'min',
      ]),

    sortByMeanCommon(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withSortBy('Mean')
      + options.legend.withSortDesc(true),

    sortByMaxCommon(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withSortBy('Max')
      + options.legend.withSortDesc(true),

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

    sortByMin(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withSortBy('Min')
      + options.legend.withSortDesc(false),

    meanWithRightLegendCommons(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'mean',
        'max',
        'lastNotNull',
      ])
      + options.legend.withPlacement('right')
      + options.legend.withSortBy('Mean')
      + options.legend.withSortDesc(true),

    maxMeanWithRightLegend(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'mean',
        'max',
      ])
      + options.legend.withPlacement('right'),

    minMaxWithRightLegend(title, unit, targets, gridPos, maxPoints):
      self.withMinMax(title, unit, targets, gridPos, maxPoints)
      + options.legend.withPlacement('right'),

    sortMaxWithRightLegend(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'lastNotNull',
        'max',
      ])
      + options.legend.withPlacement('right')
      + options.legend.withSortBy('Max')
      + options.legend.withSortDesc(true),

    maxWithRightLegend(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'lastNotNull',
        'max',
      ])
      + options.legend.withPlacement('right'),

    allWithRightLegend(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'max',
        'min',
        'firstNotNull',
        'lastNotNull',
      ])
      + options.legend.withPlacement('right'),

    maxWithBottomLegend(title, unit, targets, gridPos, maxPoints):
      self.withCommonAggregations(title, unit, targets, gridPos, maxPoints)
      + options.legend.withCalcs([
        'max',
        'lastNotNull',
      ])
      + options.legend.withSortBy('Max')
      + options.legend.withSortDesc(true),

    workerCPUCustomOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + options.legend.withPlacement('right')
      + timeSeries.standardOptions.withOverrides([
        {
          __systemRef: 'hideSeriesFrom',
          matcher: {
            id: 'byNames',
            options: {
              mode: 'exclude',
              names: [
                'user',
                'system',
                'softirq',
                'iowait',
                'irq',
              ],
              prefix: 'All except:',
              readOnly: true,
            },
          },
          properties: [
            {
              id: 'custom.hideFrom',
              value: {
                legend: false,
                tooltip: false,
                viz: true,
              },
            },
          ],
        },
      ]),

    kupeApiCustomOverrides(title, unit, targets, gridPos, maxPoints):
      self.sortByMax(title, unit, targets, gridPos, maxPoints)
      + options.tooltip.withMode('multi')
      + options.legend.withSortDesc(false)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byRegexp',
            options: '/Rss.*/',
          },
          properties: [
            {
              id: 'custom.showPoints',
              value: 'always',
            },
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
      ]),
    kupeApiAverageCustomOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byRegexp',
            options: '/Rss.*/',
          },
          properties: [
            {
              id: 'custom.showPoints',
              value: 'auto',
            },
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
        {
          __systemRef: 'hideSeriesFrom',
          matcher: {
            id: 'byNames',
            options: {
              mode: 'exclude',
              names: [
                'Avg CPU kube-apiserver',
              ],
              prefix: 'All except:',
              readOnly: true,
            },
          },
          properties: [
            {
              id: 'custom.hideFrom',
              value: {
                legend: false,
                tooltip: false,
                viz: true,
              },
            },
          ],
        },
      ]),
    activeKubeControllerManagerOverrides(title, unit, targets, gridPos, maxPoints):
      self.sortByMax(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byRegexp',
            options: '/Rss.*/',
          },
          properties: [
            {
              id: 'custom.showPoints',
              value: 'always',
            },
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
      ]),
    kubeSchedulerUsageOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byRegexp',
            options: '/Rss.*/',
          },
          properties: [
            {
              id: 'custom.showPoints',
              value: 'always',
            },
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
      ]),
    etcd99thNetworkPeerRTOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byRegexp',
            options: '/.*Logical.*/',
          },
          properties: [
            {
              id: 'unit',
              value: 'decbytes',
            },
            {
              id: 'custom.axisPlacement',
              value: 'hidden',
            },
          ],
        },
      ]),
    etcdResouceUtilizationOverrides(title, unit, targets, gridPos, maxPoints):
      self.sortByMaxCommon(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byRegexp',
            options: '/Rss.*/',
          },
          properties: [
            {
              id: 'custom.showPoints',
              value: 'always',
            },
            {
              id: 'unit',
              value: 'bytes',
            },
          ],
        },
      ]),
    etcd99thDiskWalLatencyOverrides(title, unit, targets, gridPos, maxPoints):
      self.sortByMean(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.thresholds.withMode('absolute')
      + custom.withThresholdsStyle({
        mode: 'line+area',
      })
      + timeSeries.standardOptions.thresholds.withSteps([
        {
          color: 'transparent',
          value: null,
        },
        {
          color: 'red',
          value: 0.01,
        },
      ])
      + timeSeries.standardOptions.color.withMode('palette-classic'),
    etcd99thCommitLatencyOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + timeSeries.standardOptions.thresholds.withMode('absolute')
      + custom.withThresholdsStyle({
        mode: 'line+area',
      })
      + timeSeries.standardOptions.thresholds.withSteps([
        {
          color: 'transparent',
          value: null,
        },
        {
          color: 'red',
          value: 0.02,
        },
      ])
      + timeSeries.standardOptions.color.withMode('palette-classic'),
    readOnlyAPIRequestp99ResourceOverrides(title, unit, targets, gridPos, maxPoints):
      self.sortByMax(title, unit, targets, gridPos, maxPoints)
      + custom.withThresholdsStyle({
        mode: 'line+area',
      })
      + timeSeries.standardOptions.thresholds.withSteps([
        {
          color: 'transparent',
          value: null,
        },
        {
          color: 'red',
          value: 1,
        },
      ]),
    readOnlyAPIRequestp99NamespaceOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + custom.withThresholdsStyle({
        mode: 'line+area',
      })
      + timeSeries.standardOptions.thresholds.withSteps([
        {
          color: 'transparent',
          value: null,
        },
        {
          color: 'red',
          value: 5,
        },
      ]),
    readOnlyAPIRequestp99ClusterOverrides(title, unit, targets, gridPos, maxPoints):
      self.withMeanMax(title, unit, targets, gridPos, maxPoints)
      + custom.withThresholdsStyle({
        mode: 'line+area',
      })
      + timeSeries.standardOptions.thresholds.withSteps([
        {
          color: 'transparent',
          value: null,
        },
        {
          color: 'red',
          value: 30,
        },
      ]),
    readOnlyAPIRequestp99MutatingOverrides(title, unit, targets, gridPos, maxPoints):
      self.sortByMax(title, unit, targets, gridPos, maxPoints)
      + custom.withThresholdsStyle({
        mode: 'line+area',
      })
      + timeSeries.standardOptions.thresholds.withSteps([
        {
          color: 'transparent',
          value: null,
        },
        {
          color: 'red',
          value: 1,
        },
      ]),
  },
  stat: {
    local stat = g.panel.stat,
    local options = stat.options,

    base(title, unit, targets, gridPos):
      stat.new(title)
      + stat.datasource.withType('elasticsearch')
      + stat.datasource.withUid('$Datasource')
      + stat.standardOptions.withUnit(unit)
      + stat.queryOptions.withTargets(targets)
      + stat.gridPos.withX(gridPos.x)
      + stat.gridPos.withY(gridPos.y)
      + stat.gridPos.withH(gridPos.h)
      + stat.gridPos.withW(gridPos.w)
      + options.withJustifyMode('center'),

    withMeanCalcs(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.reduceOptions.withCalcs([
        'mean',
      ]),

    withLastNotNullCalcs(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ]),

    withFieldSummary(title, unit, field, targets, gridPos):
      self.withLastNotNullCalcs(title, unit, targets, gridPos)
      + options.reduceOptions.withFields(field),

    withMeanThresholds(title, unit, targets, gridPos):
      self.withMeanCalcs(title, unit, targets, gridPos)
      + stat.standardOptions.thresholds.withMode('absolute')
      + stat.standardOptions.thresholds.withSteps([{ value: null, color: 'green' }, { value: 5000, color: 'red' }])
      + stat.standardOptions.color.withMode('palette-classic'),
  },
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

    withAlerts(title, unit, targets, gridPos):
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
              metricName: true,
              sort: true,
              uuid: true,
            },
            indexByName: {},
            renameByName: {
              _type: 'Desciption',
              severity: 'Severity',
              timestamp: 'Timestamp',
            },
          },
        },
      ]),

    withLatencyTableOverrides(title, unit, targets, gridPos):
      self.withPagination(title, unit, targets, gridPos)
      + table.options.withSortBy([
        {
          desc: true,
          displayName: 'Initialized',
        },
      ])
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {},
            indexByName: {},
            renameByName: {
              'Average containersReadyLatency': 'ContainersReady',
              'Average initializedLatency': 'Initialized',
              'Average podReadyLatency': 'Ready',
              'Average schedulingLatency': 'Scheduling',
              'namespace.keyword': 'Namespace',
              'podName.keyword': 'Pod',
            },
          },
        },
      ])
      + table.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byName',
            options: 'nodeName.keyword',
          },
          properties: [
            {
              id: 'custom.width',
              value: 412,
            },
          ],
        },
      ]),

    withPlatformOverview(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              _id: true,
              _index: true,
              _type: true,
              clustertype: true,
              elapsedTime: true,
              endDate: true,
              endTimestamp: true,
              highlight: true,
              'jobConfig.burst': true,
              'jobConfig.churnDelay': true,
              'jobConfig.churnDeletionStrategy': true,
              'jobConfig.churnDuration': true,
              'jobConfig.churnPercent': true,
              'jobConfig.cleanup': true,
              'jobConfig.errorOnVerify': true,
              'jobConfig.iterationsPerNamespace': true,
              'jobConfig.jobIterationDelay': true,
              'jobConfig.jobIterations': true,
              'jobConfig.jobPause': true,
              'jobConfig.jobType': true,
              'jobConfig.maxWaitTimeout': true,
              'jobConfig.name': true,
              'jobConfig.namespace': true,
              'jobConfig.namespaced': true,
              'jobConfig.namespacedIterations': true,
              'jobConfig.objects': true,
              'jobConfig.preLoadImages': true,
              'jobConfig.preLoadPeriod': true,
              'jobConfig.qps': true,
              'jobConfig.verifyObjects': true,
              'jobConfig.waitFor': true,
              'jobConfig.waitForDeletion': true,
              'jobConfig.waitWhenFinished': true,
              k8sVersion: true,
              metricName: true,
              ocpMajorVersion: true,
              ocpVersion: true,
              sort: true,
              timestamp: true,
              version: true,
              workload: true,
              churnStartTimestamp: true,
              churnEndTimestamp: true,
              publish: true,
              ipsecMode: true,
            },
            indexByName: {
              timestamp: 0,
              _id: 1,
              _index: 2,
              _type: 3,
              uuid: 4,
              highlight: 5,
              sort: 6,
              clusterName: 7,
              k8sVersion: 8,
              ocpVersion: 9,
              platform: 10,
              region: 11,
              metricName: 12,
              sdnType: 13,
              passed: 14,
              masterNodesType: 15,
              totalNodes: 16,
              workerNodesCount: 17,
              churnEndTimestamp: 18,
              churnStartTimestamp: 19,
              clusterType: 20,
              controlPlaneArch: 21,
              elapsedTime: 22,
              endTimestamp: 23,
              ipsecMode: 24,
              'jobConfig.burst': 25,
              'jobConfig.churnDelay': 26,
              'jobConfig.churnDeletionStrategy': 27,
              'jobConfig.churnDuration': 28,
              'jobConfig.churnPercent': 29,
              'jobConfig.cleanup': 30,
              'jobConfig.errorOnVerify': 31,
              'jobConfig.iterationsPerNamespace': 32,
              'jobConfig.jobIterations': 33,
              'jobConfig.jobType': 34,
              'jobConfig.maxWaitTimeout': 35,
              'jobConfig.name': 36,
              'jobConfig.namespace': 37,
              'jobConfig.namespacedIterations': 38,
              'jobConfig.preLoadImages': 39,
              'jobConfig.preLoadPeriod': 40,
              'jobConfig.qps': 41,
              'jobConfig.verifyObjects': 42,
              'jobConfig.waitForDeletion': 43,
              'jobConfig.waitWhenFinished': 44,
              masterNodesCount: 45,
              ocpMajorVersion: 46,
              publish: 47,
              version: 48,
              workerArch: 49,
            },
            renameByName: {
              _index: '',
              _type: '',
              clusterName: 'Cluster',
              elapsedTime: '',
              endDate: '',
              infraNodesCount: 'infra count',
              infraNodesType: 'infra type',
              k8sVersion: 'k8s version',
              masterNodesType: 'master type',
              metricName: '',
              ocpVersion: 'OCP version',
              passed: 'Passed',
              platform: 'Platform',
              result: 'Result',
              sdnType: 'SDN',
              timestamp: '',
              totalNodes: 'total nodes',
              uuid: 'UUID',
              version: '',
              workerNodesCount: 'worker count',
              workerNodesType: 'worker type',
              workload: '',
              region: 'Region',
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

    withJobSummary(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          id: 'organize',
          options: {
            excludeByName: {
              _id: true,
              _index: true,
              _type: true,
              endTimestamp: true,
              highlight: true,
              'jobConfig.churnDelay': true,
              'jobConfig.churnDuration': true,
              'jobConfig.churnPercent': true,
              'jobConfig.cleanup': true,
              'jobConfig.errorOnVerify': true,
              'jobConfig.iterationsPerNamespace': true,
              'jobConfig.jobIterationDelay': true,
              'jobConfig.jobPause': true,
              'jobConfig.jobType': true,
              'jobConfig.maxWaitTimeout': true,
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
              k8sVersion: true,
              metricName: true,
              ocpMajorVersion: true,
              ocpVersion: true,
              platform: true,
              sdnType: true,
              sort: true,
              totalNodes: true,
              churnStartTimestamp: true,
              churnEndTimestamp: true,
              clusterName: true,
              clusterType: true,
              controlPlaneArch: true,
              ipsecMode: true,
              masterNodesCount: true,
              masterNodesType: true,
              publish: true,
              region: true,
              workerArch: true,
              workerNodesCount: true,
              passed: true,
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
              k8sVersion: 26,
              metricName: 18,
              ocpMajorVersion: 27,
              ocpVersion: 28,
              platform: 29,
              sdnType: 30,
              sort: 32,
              timestamp: 1,
              totalNodes: 31,
              uuid: 0,
              version: 33,
            },
            renameByName: {
              _type: '',
              elapsedTime: 'Elapsed time',
              endTimestamp: 'End date',
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
              value: 'ns',
            },
          ],
        },
      ]),
  },
}
