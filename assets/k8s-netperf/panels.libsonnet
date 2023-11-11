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
      + table.datasource.withUid('$datasource')
      + table.panelOptions.withRepeat("profile")
      + table.panelOptions.withRepeatDirection("h")
      + table.standardOptions.color.withMode("thresholds")
      + table.queryOptions.withTargets(targets)
      + table.gridPos.withX(gridPos.x)
      + table.gridPos.withY(gridPos.y)
      + table.gridPos.withH(gridPos.h)
      + table.gridPos.withW(gridPos.w)
      + table.queryOptions.withTransformations([
        {
          "id": "organize",
          "options": {
            "excludeByName": {
              "Average latency": true,
              "ltcyMetric.keyword": true,
              "tputMetric.keyword": true
            },
            "indexByName": {
              "Average": 10,
              "hostNetwork": 8,
              "ltcyMetric.keyword": 7,
              "messageSize": 3,
              "metadata.clusterName.keyword": 1,
              "metadata.platform.keyword": 5,
              "metadata.workerNodesType.keyword": 9,
              "profile.keyword": 2,
              "service": 6,
              "tputMetric.keyword": 4,
              "uuid.keyword": 0
            },
            "renameByName": {
              "Average": "Throughput",
              "Average latency": "P99 latency",
              "ltcyMetric.keyword": "",
              "metadata.clusterName.keyword": "clusterName",
              "metadata.platform.keyword": "Platform",
              "metadata.workerNodesType.keyword": "workers",
              "profile.keyword": "Profile",
              "uuid.keyword": "uuid"
            }
          }
        }
      ])
      + table.standardOptions.withOverrides([
        {
          "matcher": {
            "id": "byName",
            "options": "Average"
          },
          "properties": [
            {
              "id": "unit",
              "value": "Mbits"
            }
          ]
        },
        {
          "matcher": {
            "id": "byName",
            "options": "messageSize"
          },
          "properties": [
            {
              "id": "unit",
              "value": "bytes"
            }
          ]
        }
      ])
      + options.withCellHeight("sm")
      + options.withFooter({
          "countRows": false,
          "fields": "",
          "reducer": [
            "sum"
          ],
          "show": false
        })
      + options.withSortBy([
          {
            "desc": true,
            "displayName": "ea7b29d7-8991-4752-a0d4-e26446d34915 TCP_STREAM 4096 Mb/s AWS"
          }
        ]),

    withLatencyOverrides(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + table.queryOptions.withTransformations([
        {
          "id": "organize",
          "options": {
            "excludeByName": {
              "Average latency": true,
              "ltcyMetric.keyword": true,
              "tputMetric.keyword": true
            },
            "indexByName": {
              "Average": 8,
              "hostNetwork": 6,
              "messageSize": 3,
              "metadata.clusterName.keyword": 1,
              "metadata.platform.keyword": 4,
              "metadata.workerNodesType.keyword": 7,
              "profile.keyword": 2,
              "service": 5,
              "uuid.keyword": 0
            },
            "renameByName": {
              "Average": "P99 latency",
              "Average latency": "P99 latency",
              "ltcyMetric.keyword": "",
              "metadata.clusterName.keyword": "clusterName",
              "metadata.platform.keyword": "Platform",
              "metadata.workerNodesType.keyword": "workers",
              "profile.keyword": "Profile",
              "uuid.keyword": "uuid"
            }
          }
        }
      ])
      + table.standardOptions.withOverrides([
        {
          "matcher": {
            "id": "byName",
            "options": "Average"
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
            "options": "messageSize"
          },
          "properties": [
            {
              "id": "unit",
              "value": "bytes"
            }
          ]
        }
      ]),
  },

  timeSeries: {
    local timeSeries = g.panel.timeSeries,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local options = timeSeries.options,

    base(title, targets, gridPos):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.panelOptions.withRepeat("messageSize")
      + timeSeries.panelOptions.withRepeatDirection("h")
      + timeSeries.datasource.withType('elasticsearch')
      + timeSeries.datasource.withUid('$datasource')
      + timeSeries.gridPos.withX(gridPos.x)
      + timeSeries.gridPos.withY(gridPos.y)
      + timeSeries.gridPos.withH(gridPos.h)
      + timeSeries.gridPos.withW(gridPos.w)
      + custom.withLineWidth(2)
      + custom.withGradientMode("hue")
      + custom.withShowPoints("always")
      + custom.withPointSize(10)
      + custom.withSpanNulls(true)
      + custom.withFillOpacity(0)
      + custom.withScaleDistribution({
          "type": "log",
          "log": 2
        })
      + custom.withAxisCenteredZero(false)
      + custom.withHideFrom({
          "tooltip": false,
          "viz": false,
          "legend": false
        })
      + custom.withAxisGridShow(true)
      + custom.withLineStyle({
          "fill": "solid"
        })
      + options.tooltip.withMode('single')
      + options.tooltip.withSort('none')
      + options.legend.withShowLegend(true)
      + options.legend.withPlacement('bottom')
      + options.legend.withDisplayMode('table')
      + options.legend.withCalcs(['lastNotNull'])
      + timeSeries.standardOptions.withOverrides([
      {
        "matcher": {
          "id": "byFrameRefID",
          "options": "A"
        },
        "properties": [
          {
            "id": "unit",
            "value": "µs"
          }
        ]
      }
    ]),

    withThroughputOverrides(title, targets, gridPos):
      self.base(title, targets, gridPos)
      + options.legend.withSortBy("Last *")
      + options.legend.withPlacement('right')
      + options.legend.withSortDesc(false)
      + timeSeries.standardOptions.withOverrides([
      {
        "matcher": {
          "id": "byFrameRefID",
          "options": "A"
        },
        "properties": [
          {
            "id": "unit",
            "value": "Mbits"
          }
        ]
      }
    ]),
  },
}