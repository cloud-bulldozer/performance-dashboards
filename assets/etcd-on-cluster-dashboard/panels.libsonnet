local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
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
            + custom.withDrawStyle("line")
            + custom.withLineInterpolation("linear")
            + custom.withBarAlignment(0)
            + custom.withLineWidth(1)
            + custom.withFillOpacity(10)
            + custom.withGradientMode("none")
            + custom.withSpanNulls(false)
            + custom.withPointSize(5)
            + custom.withSpanNulls(false)
            + custom.stacking.withMode("none")
            + custom.withShowPoints('never')
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom'),

        generalUsageAgg(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.legend.withCalcs([
                  'mean',
                  'max'
                ])
            + options.legend.withDisplayMode('table'),  

        withoutCalcsAgg(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.legend.withCalcs([])
            + options.legend.withDisplayMode('table'),

        GeneralInfoAgg(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.legend.withCalcs([
                  'mean',
                  'max'
                ])
            + options.legend.withDisplayMode('list'), 

        GeneralInfo(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.legend.withCalcs([])
            + options.legend.withDisplayMode('list'),
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
            + options.text.withTitleSize(12)
            + stat.standardOptions.color.withMode('thresholds')
            + options.withColorMode('none'),


        etcdLeader(title, unit, target, gridPos):
                self.base(title, unit, target, gridPos)
                + stat.options.reduceOptions.withCalcs([
                    'mean'
                ])
                + stat.standardOptions.withMappings({
                    "type": "value",
                    "options": {
                        "0": {
                        "text": "NO"
                        },
                        "1": {
                        "text": "YES"
                        }
                    }
                    }),

        failedProposalsSeen(title, unit, target, gridPos):
                self.base(title, unit, target, gridPos)
                + stat.options.reduceOptions.withCalcs([
                    'mean'
                ])
                + stat.standardOptions.withMappings(
                    {
                    "type": "special",
                    "options": {
                        "match": "null",
                        "result": {
                        "text": "N/A"
                        }
                    }
                    }),
    }
}