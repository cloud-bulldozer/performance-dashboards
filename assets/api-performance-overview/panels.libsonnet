local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
    timeSeries: {
       local timeSeries = g.panel.timeSeries,
        local custom = timeSeries.fieldConfig.defaults.custom,
        local options = timeSeries.options,

        base(title, unit, targets, gridPos):
            timeSeries.new(title)
            + timeSeries.queryOptions.withTargets(targets)
            + timeSeries.datasource.withType('prometheus')
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
            + custom.stacking.withGroup("A")
            + custom.stacking.withMode("none")
            + custom.withShowPoints('never'),

        withCommonAggregations(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.legend.withCalcs([
                'lastNotNull'
            ])
            + options.legend.withShowLegend(true)
            + options.legend.withDisplayMode('table')
            + options.legend.withPlacement('right')
            + options.tooltip.withMode('multi'),

        withReadWriteSettings(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.tooltip.withMode('multi')
            + options.legend.withShowLegend(true)
            + options.legend.withDisplayMode('list')
            + options.legend.withPlacement('bottom')
            + options.tooltip.withMode('multi'),
            
        withRequestWaitDurationAggregations(title, unit, targets, gridPos):
            self.withCommonAggregations(title, unit, targets, gridPos)
            + options.legend.withCalcs([
                'mean',
                'max',
                'lastNotNull'
            ])  
    }
}