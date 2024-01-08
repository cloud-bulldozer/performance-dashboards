local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{ 
  gauge: {
    local gauge = g.panel.gauge,
    local options = gauge.options,
    local custom = gauge.fieldConfig.defaults.custom,

    base(title, unit, targets, gridPos):
      gauge.new(title)
      + gauge.queryOptions.withTargets(targets)
      + gauge.datasource.withType('elasticsearch')
      + gauge.datasource.withUid('$Datasource')
      + gauge.standardOptions.withUnit(unit)
      + gauge.gridPos.withX(gridPos.x)
      + gauge.gridPos.withY(gridPos.y)
      + gauge.gridPos.withH(gridPos.h)
      + gauge.gridPos.withW(gridPos.w)
      + options.withOrientation('vertical')
      + options.withShowThresholdLabels(false)
      + options.withShowThresholdMarkers(true)
      + options.text.withTitleSize(12),
      
     withAvgRPS(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.reduceOptions.withCalcs([
        'stdDev'
      ])
      + options.reduceOptions.withValues(true)
      + options.reduceOptions.withFields('/^CV$/'),

      withAvgTimeThresholds(title, unit, targets, gridPos):
        self.withAvgRPS(title, unit, targets, gridPos)
        + gauge.standardOptions.thresholds.withMode("absolute")
        + gauge.standardOptions.thresholds.withSteps([{"value": null,"color": "green"}, {"value": 0.3,"color": "#EAB839"},{"value": 0.5 , "color": "red"}])
        + gauge.standardOptions.color.withMode("thresholds")
        + gauge.standardOptions.withMin(0)
        + gauge.standardOptions.withMax(1)
        + gauge.queryOptions.withTransformations([
          {
              "id": "calculateField",
              "options": {
                "alias": "CV",
                "binary": {
                  "left": "Std Dev",
                  "operator": "/",
                  "reducer": "sum",
                  "right": "Average"
                },
                "mode": "binary",
                "reduce": {
                  "reducer": "sum"
                },
                "replaceFields": false
              }
            }
        ]),
  },

  bargauge: {
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
      + options.withDisplayMode('basic')
      + options.withValueMode('color')
      + options.withShowUnfilled(true)
      + options.withMinVizWidth(0)
      + options.withMinVizHeight(10)
      + options.text.withTitleSize(12),

    withAvgRPS(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ]),

    withAvgTimeThresholds(title, unit, targets, gridPos):
      self.withAvgRPS(title, unit, targets, gridPos)
      + bargauge.standardOptions.thresholds.withMode("absolute")
      + bargauge.standardOptions.thresholds.withSteps([{"value": null,"color": "green"}, {"value": 80,"color": "red"}])
      + bargauge.standardOptions.color.withMode("palette-classic")
      + bargauge.standardOptions.withDecimals(2)
      + bargauge.standardOptions.withMin(0),  
  },

  timeSeries: {
    local timeSeries = g.panel.timeSeries,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local options = timeSeries.options,

    base(title, unit, targets, gridPos):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.datasource.withType('elasticsearch')
      + timeSeries.datasource.withUid('$Datasource')
      + timeSeries.standardOptions.withUnit(unit)
      + timeSeries.gridPos.withX(gridPos.x)
      + timeSeries.gridPos.withY(gridPos.y)
      + timeSeries.gridPos.withH(gridPos.h)
      + timeSeries.gridPos.withW(gridPos.w)
      + custom.withSpanNulls(false)
      + custom.withFillOpacity(25)
      + options.tooltip.withMode('multi')
      + options.tooltip.withSort('none')
      + options.legend.withShowLegend(true)
      + options.legend.withPlacement('bottom')
      + options.legend.withDisplayMode('table'),

    withCommonAggregations(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.legend.withCalcs([
        'mean',
        'max',
        'min'
      ]),

    withMeanReq(title, unit, targets, gridPos):
      self.withCommonAggregations(title, unit, targets, gridPos)
      + options.legend.withCalcs([
        'lastNotNull',
        'mean',
      ])
      + custom.withPointSize(9)
      + custom.withLineWidth(6)
      + custom.withDrawStyle('points')
      + custom.withAxisSoftMin(0)
      + custom.lineStyle.withFill('solid'),
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
      + options.withJustifyMode("auto")
      + options.withGraphMode("none")
      + options.text.withTitleSize(12),

    withAvgCalcs(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.reduceOptions.withCalcs([
        'lastNotNull',
      ]),
    
    withAvgThresholds(title, unit, targets, gridPos):
      self.withAvgCalcs(title, unit, targets, gridPos)
      + stat.panelOptions.withRepeat('termination')
      + stat.panelOptions.withRepeatDirection('h')
      + stat.standardOptions.thresholds.withMode("absolute")
      + stat.standardOptions.thresholds.withSteps([{"value": null,"color": "green"}, {"value": 80,"color": "red"}])
      + stat.standardOptions.color.withMode("thresholds")
      + stat.queryOptions.withTransformations([
        {
      "id": "convertFieldType",
      "options": {
        "conversions": [
          {
            "destinationType": "string",
            "targetField": "ocpMajorVersion.keyword"
          }
        ],
        "fields": {}
      }
    }]),

    withAvgTimeThresholds(title,unit,targets,gridPos):
      self.withAvgCalcs(title, unit, targets, gridPos)
      + stat.panelOptions.withRepeat('termination')
      + stat.panelOptions.withRepeatDirection('h')
      + stat.standardOptions.thresholds.withMode("absolute")
      + stat.standardOptions.thresholds.withSteps([{"value": null,"color": "green"}])
      + stat.standardOptions.color.withMode("thresholds")
      + stat.queryOptions.withTransformations([]),
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

    withTerminationRawData(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.withShowHeader(true)
      + options.withCellHeight("sm")
      + options.withFrameIndex(0)
      + options.sortBy.withDesc(false)
      + options.sortBy.withDisplayName("ocpVersion")
      + options.footer.TableFooterOptions.withShow(false)
      + options.footer.TableFooterOptions.withReducer(["sum"])
      + options.footer.TableFooterOptions.withCountRows(false)
      + options.footer.TableFooterOptions.withFields("")
      + options.footer.TableFooterOptions.withEnablePagination(false)
      + table.standardOptions.withFilterable(true)
      + table.standardOptions.withOverrides([
        {
        "matcher": {
          "id": "byName",
          "options": "Samples"
        },
        "properties": [
          {
            "id": "decimals",
            "value": 0
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Avg Lat"
        },
        "properties": [
          {
            "id": "unit",
            "value": "µs"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Concurrency"
        },
        "properties": [
          {
            "id": "decimals",
            "value": 0
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Duration"
        },
        "properties": [
          {
            "id": "unit",
            "value": "ns"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Max Lat"
        },
        "properties": [
          {
            "id": "unit",
            "value": "µs"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "P90 Lat"
        },
        "properties": [
          {
            "id": "unit",
            "value": "µs"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "P95 Lat"
        },
        "properties": [
          {
            "id": "unit",
            "value": "µs"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "P99 Lat"
        },
        "properties": [
          {
            "id": "unit",
            "value": "µs"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Avg RPS "
        },
        "properties": [
          {
            "id": "unit",
            "value": "reqps"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Requests"
        },
        "properties": [
          {
            "id": "unit",
            "value": "none"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Tuning"
        },
        "properties": [
          {
            "id": "custom.width"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "config.Delay"
        },
        "properties": [
          {
            "id": "unit",
            "value": "ns"
          }
        ]
      },
      {
        "matcher": {
          "id": "byName",
          "options": "Timeout"
        },
        "properties": [
          {
            "id": "unit",
            "value": "ns"
          }
        ]
      }
      ])
      + table.queryOptions.withTransformations([
        {
      "id": "organize",
      "options": {
        "excludeByName": {
          "_id": true,
          "_index": true,
          "_type": true,
          "avg_lat_us": true,
          "clusterName": true,
          "clusterType": true,
          "config.Delay": true,
          "config.delay": true,
          "config.duration": true,
          "config.procs": false,
          "config.samples": false,
          "config.termination": true,
          "config.tool": true,
          "haproxyVersion": true,
          "highlight": true,
          "infraNodesCount": true,
          "infraNodesType": true,
          "k8sVersion": true,
          "masterNodesCount": true,
          "masterNodesType": true,
          "max_lat_us": true,
          "metricName": true,
          "ocpMajorVersion": true,
          "ocpVersion": true,
          "otherNodesCount": true,
          "p90_lat_us": true,
          "p99_lat_us": true,
          "platform": true,
          "pods": true,
          "region": true,
          "requests": true,
          "rps_stdev": true,
          "sdnType": true,
          "sort": true,
          "stdev_lat": true,
          "timeouts": false,
          "timestamp": true,
          "tool": true,
          "totalNodes": true,
          "workerNodesCount": true,
          "workerNodesType": true
        },
        "indexByName": {
          "_id": 7,
          "_index": 8,
          "_type": 9,
          "avg_lat_us": 17,
          "clusterName": 26,
          "config.Delay": 27,
          "config.concurrency": 10,
          "config.connections": 11,
          "config.duration": 12,
          "config.path": 2,
          "config.samples": 5,
          "config.serverReplicas": 13,
          "config.termination": 3,
          "config.tool": 14,
          "config.tuningPatch": 28,
          "highlight": 15,
          "http_errors": 29,
          "infraNodesCount": 30,
          "infraNodesType": 31,
          "k8sVersion": 32,
          "masterNodesCount": 33,
          "masterNodesType": 34,
          "max_lat_us": 18,
          "metricName": 35,
          "ocpVersion": 1,
          "p90_lat_us": 19,
          "p95_lat_us": 20,
          "p99_lat_us": 21,
          "platform": 36,
          "pods": 22,
          "region": 37,
          "requests": 38,
          "rps_stdev": 23,
          "sample": 4,
          "sdnType": 39,
          "sort": 24,
          "stdev_lat": 25,
          "timeouts": 40,
          "timestamp": 6,
          "totalNodes": 41,
          "total_avg_rps": 16,
          "uuid": 0,
          "workerNodesCount": 42,
          "workerNodesType": 43
        },
        "renameByName": {
          "avg_lat_us": "Avg Lat",
          "clusterType": "",
          "config.Delay": "Delay",
          "config.RequestTimeout": "Timeout",
          "config.concurrency": "Concurrency",
          "config.connections": "Connections",
          "config.delay": "Delay",
          "config.duration": "Duration",
          "config.http2": "HTTP2",
          "config.keepalive": "Keepalive",
          "config.path": "Path",
          "config.procs": "Procs",
          "config.requestRate": "Rate",
          "config.requestTimeout": "Timeout",
          "config.samples": "Samples",
          "config.serverReplicas": "Servers",
          "config.termination": "Termination",
          "config.tuning.routers": "Routers",
          "config.tuning.threadCount": "Threads",
          "config.tuningPatch": "Tuning",
          "http_errors": "Errors",
          "max_lat_us": "Max Lat",
          "p90_lat_us": "P90 Lat",
          "p95_lat_us": "P95 Lat",
          "p99_lat_us": "P99 Lat",
          "pods": "",
          "requests": "Requests",
          "rps_stdev": "",
          "sample": "# Sample",
          "stdev_lat": "",
          "timeouts": "Timeouts",
          "totalNodes": "",
          "total_avg_rps": "Avg RPS ",
          "uuid": "UUID",
          "write_errors": ""
        }
      }
    }]),

    withWorkloadSummary(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
     + table.queryOptions.withTransformations([
      {
      "id": "groupBy",
      "options": {
        "fields": {
          "Cluster name": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Infras": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Infras type": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Masters": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Masters type": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Version": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Workers": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "Workers type": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "clusterName": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "clusterType": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "config.RequestTimeout": {
            "aggregations": [
              "lastNotNull"
            ]
          },
          "config.tool": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "haproxyVersion": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "infraNodesCount": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "infraNodesType": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "k8s version": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "ocpMajorVersion": {
            "aggregations": []
          },
          "ocpVersion": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "otherNodesCount": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "platform": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "region": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "sdnType": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "timestamp": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "totalNodes": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "uuid": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "groupby"
          },
          "version": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "workerNodesCount": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          },
          "workerNodesType": {
            "aggregations": [
              "lastNotNull"
            ],
            "operation": "aggregate"
          }
        }
      }
    },
    {
      "id": "organize",
      "options": {
        "excludeByName": {
          "_id": true,
          "_index": true,
          "_type": true,
          "avg_lat_us": true,
          "config.Delay": true,
          "config.concurrency": true,
          "config.connections": true,
          "config.duration": true,
          "config.path": true,
          "config.samples": true,
          "config.serverReplicas": true,
          "config.termination": true,
          "config.tool": true,
          "config.tuningPatch": true,
          "highlight": true,
          "http_errors": true,
          "infraNodesCount": false,
          "masterNodesType": false,
          "max_lat_us": true,
          "metricName": true,
          "otherNodesCount (lastNotNull)": true,
          "p90_lat_us": true,
          "p95_lat_us": true,
          "p99_lat_us": true,
          "platform": false,
          "pods": true,
          "region (lastNotNull)": true,
          "requests": true,
          "rps_stdev": true,
          "sample": true,
          "sort": true,
          "stdev_lat": true,
          "timeouts": true,
          "timestamp": true,
          "timestamp (lastNotNull)": false,
          "totalNodes (lastNotNull)": true,
          "total_avg_rps": true,
          "uuid": false
        },
        "indexByName": {
          "clusterName (lastNotNull)": 4,
          "clusterType (lastNotNull)": 3,
          "config.tool (lastNotNull)": 15,
          "haproxyVersion (lastNotNull)": 6,
          "infraNodesCount (lastNotNull)": 11,
          "infraNodesType (lastNotNull)": 12,
          "ocpVersion (lastNotNull)": 5,
          "otherNodesCount (lastNotNull)": 7,
          "platform (lastNotNull)": 2,
          "region (lastNotNull)": 8,
          "sdnType (lastNotNull)": 9,
          "timestamp (lastNotNull)": 1,
          "totalNodes (lastNotNull)": 10,
          "uuid": 0,
          "version (lastNotNull)": 16,
          "workerNodesCount (lastNotNull)": 13,
          "workerNodesType (lastNotNull)": 14
        },
        "renameByName": {
          "clusterName": "Cluster name",
          "clusterName (lastNotNull)": "Cluster name",
          "clusterType (lastNotNull)": "Cluster type",
          "config.tool (lastNotNull)": "Tool",
          "haproxyVersion (lastNotNull)": "HAProxy version",
          "http_errors": "",
          "infraNodesCount": "Infras",
          "infraNodesCount (lastNotNull)": "Infras",
          "infraNodesType": "Infras type",
          "infraNodesType (lastNotNull)": "Infra type",
          "k8sVersion": "k8s version",
          "masterNodesCount": "Masters",
          "masterNodesType": "Masters type",
          "ocpVersion": "Version",
          "ocpVersion (lastNotNull)": "Version",
          "otherNodesCount (lastNotNull)": "Other nodes",
          "platform (lastNotNull)": "Platform",
          "region (lastNotNull)": "Region",
          "sdnType (lastNotNull)": "SDN",
          "timestamp (lastNotNull)": "Timestamp",
          "totalNodes (lastNotNull)": "Total nodes",
          "uuid": "UUID",
          "version (lastNotNull)": "ingress-perf v",
          "workerNodesCount": "Workers",
          "workerNodesCount (lastNotNull)": "Workers",
          "workerNodesType": "Workers type",
          "workerNodesType (lastNotNull)": "Workers type"
        }
      }
    }
     ])
    },
}