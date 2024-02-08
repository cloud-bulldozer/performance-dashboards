local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
    timeSeries: {
        local timeSeries = g.panel.timeSeries,
        local custom = timeSeries.fieldConfig.defaults.custom,
        local options = timeSeries.options,

        base(title, datasource,unit, targets, gridPos):
            timeSeries.new(title)
            + timeSeries.queryOptions.withTargets(targets)
            + timeSeries.datasource.withType('elasticsearch')
            + timeSeries.datasource.withUid(datasource)
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
            + custom.withLineWidth(2),

        overallThroughputPerYCSB(title, datasource, unit, targets, gridPos):
            self.base(title, datasource, unit, targets, gridPos)
            + options.legend.withDisplayMode('table')
            + options.legend.withPlacement('right')
            + custom.withDrawStyle('bars')
            + custom.withFillOpacity(100)
            + custom.withPointSize(4)
            + custom.withShowPoints('never')
            + options.legend.withCalcs([
                'sum'
            ]),

        LatancyofEachWorkloadPerYCSBOperation(title, datasource, unit, targets, gridPos):
            self.base(title, datasource, unit, targets, gridPos)
            + options.legend.withDisplayMode('list')
            + options.legend.withPlacement('bottom')
            + custom.withFillOpacity(100)
            + custom.withPointSize(4)
            + custom.withDrawStyle('bars')
            + custom.withShowPoints('never'),

        latency90percReportedFromYCSB(title, datasource, unit, targets, gridPos):
            self.base(title, datasource, unit, targets, gridPos)
            + custom.withDrawStyle('points')
            + custom.withFillOpacity(20)
            + options.legend.withDisplayMode('list')
            + options.legend.withPlacement('bottom')
            + options.legend.withCalcs([])
            + custom.withPointSize(4)
            + custom.withShowPoints('always'),

        throughputOvertimePhase(title, datasource, unit, targets, gridPos):
            self.base(title, datasource, unit, targets, gridPos)
            + custom.withDrawStyle('line')
            + custom.withFillOpacity(20)
            + custom.withPointSize(5)
            + options.legend.withDisplayMode('list')
            + options.legend.withPlacement('bottom')
            + options.legend.withCalcs([])
            + custom.withShowPoints('never'),
    },

    table: {
        local table = g.panel.table,
        local custom = table.fieldConfig.defaults.custom,
        local options = table.options,

        base(title, datasource, targets, gridPos):
            table.new(title)
            + table.queryOptions.withTargets(targets)
            + table.datasource.withType('elasticsearch')
            + table.datasource.withUid(datasource)
            + table.gridPos.withX(gridPos.x)
            + table.gridPos.withY(gridPos.y)
            + table.gridPos.withH(gridPos.h)
            + table.gridPos.withW(gridPos.w)
            + custom.cellOptions.TableSparklineCellOptions.withTransform('timeseries_to_columns')
            + options.withShowHeader(true)
            + options.sortBy.withDesc(true),
    },
}