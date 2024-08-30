local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
{
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
      + options.withJustifyMode('auto')
      + options.withGraphMode('area')
      + options.text.withTitleSize(12)
      + stat.standardOptions.color.withMode('thresholds')
      + options.withColorMode('none')
      + options.withColorMode('value'),

    genericstatLegendPanel(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + stat.options.reduceOptions.withCalcs([
        'last',
      ]),

    genericstatThresoldPanel(title, unit, targets, gridPos):
      self.genericstatLegendPanel(title, unit, targets, gridPos)
      + stat.standardOptions.thresholds.withSteps([
        {
          color: 'green',
          value: null,
        },
        {
          color: 'orange',
          value: 0,
        },
        {
          color: 'green',
          value: 1,
        },
      ])
      + options.withTextMode('name'),

    genericstatThresoldOVNControllerPanel(title, unit, targets, gridPos):
      self.genericstatLegendPanel(title, unit, targets, gridPos)
      + stat.standardOptions.thresholds.withSteps([
        {
          color: 'green',
          value: null,
        },
      ])
      + options.withTextMode('auto'),
  },

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
      + custom.withDrawStyle('line')
      + custom.withLineInterpolation('linear')
      + custom.withBarAlignment(0)
      + custom.withLineWidth(1)
      + custom.withFillOpacity(10)
      + custom.withGradientMode('none')
      + custom.withSpanNulls(false)
      + custom.withPointSize(5)
      + custom.withSpanNulls(false)
      + custom.stacking.withMode('none')
      + custom.withShowPoints('never')
      + options.tooltip.withMode('multi')
      + options.tooltip.withSort('desc')
      + options.legend.withShowLegend(true)
      + options.legend.withPlacement('bottom'),

    genericTimeSeriesLegendPanel(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.legend.withCalcs([
        'mean',
        'max',
      ])
      + options.legend.withDisplayMode('table'),


  },
}
