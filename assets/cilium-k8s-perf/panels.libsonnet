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
            + custom.stacking.withMode("none")
            + custom.withShowPoints('never'),
        
        withCiliumAgg(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom')
            + options.legend.withDisplayMode('table')
            + options.legend.withCalcs([
                  'mean',
                  'max'
                ]),
        
        withClusterAgg(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom')
            + options.legend.withDisplayMode('table')
            + options.legend.withCalcs([])
    },

    stat: {
        local stat = g.panel.stat,
        local options = stat.options,

        base(title, unit, targets, gridPos):
            stat.new(title)
            + stat.datasource.withType('prometheus')
            + stat.datasource.withUid('$Datasource')
            + stat.standardOptions.withUnit(unit)
            + stat.queryOptions.withTargets(targets)
            + stat.gridPos.withX(gridPos.x)
            + stat.gridPos.withY(gridPos.y)
            + stat.gridPos.withH(gridPos.h)
            + stat.gridPos.withW(gridPos.w)
            + options.withJustifyMode("auto")
            + options.withGraphMode("area")
            + options.text.withTitleSize(12),

        withclusterAgg(title, unit, targets, gridPos):
            self.base(title, unit, targets, gridPos)
            + options.reduceOptions.withCalcs([
                'last',
            ])
            + stat.standardOptions.thresholds.withSteps([]),
    }
}