local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  timeSeries: {
    local timeSeries = g.panel.timeSeries,
    local fieldOverride = g.panel.timeSeries.fieldOverride,
    local custom = timeSeries.fieldConfig.defaults.custom,
    local options = timeSeries.options,
    local standardOptions = timeSeries.standardOptions,
    local byRegexp = timeSeries.standardOptions.override.byRegexp,

    generic(title, unit, targets, gridPos):
      timeSeries.new(title)
      + timeSeries.queryOptions.withTargets(targets)
      + timeSeries.datasource.withUid('$Datasource')
      + timeSeries.standardOptions.withUnit(unit)
      + timeSeries.gridPos.withX(gridPos.x)
      + timeSeries.gridPos.withY(gridPos.y)
      + timeSeries.gridPos.withH(gridPos.h)
      + timeSeries.gridPos.withW(gridPos.w)
      + custom.withSpanNulls('false')
      + options.tooltip.withMode('multi')
      + options.tooltip.withSort('desc')
      + options.legend.withDisplayMode('table'),

    genericLegend(title, unit, targets, gridPos):
      self.generic(title, unit, targets, gridPos)
      + options.legend.withShowLegend(true)
      + options.legend.withCalcs([
        'mean',
        'min',
        'max',
      ])
      + options.legend.withSortBy('Max')
      + options.legend.withSortDesc(true)
      + options.legend.withPlacement('bottom'),

    genericLegendCounter(title, unit, targets, gridPos):
      self.generic(title, unit, targets, gridPos)
      + options.legend.withShowLegend(true)
      + options.legend.withCalcs([
        'first',
        'min',
        'max',
        'last',
      ])
      + options.legend.withSortBy('Max')
      + options.legend.withSortDesc(true)
      + options.legend.withPlacement('bottom'),

    genericLegendCounterSumRightHand(title, unit, targets, gridPos):
      self.genericLegendCounter(title, unit, targets, gridPos)
      + options.legend.withDisplayMode('table')
      + options.legend.withSortBy('Max')
      + standardOptions.withOverrides([
        byRegexp.new('sum')
        + byRegexp.withProperty('custom.axisPlacement', 'right')
        + byRegexp.withProperty('custom.axisLabel', 'sum'),
      ]),
  },
  stat: {
    local stat = g.panel.stat,
    local options = stat.options,

    base(title, targets, gridPos):
      stat.new(title)
      + stat.datasource.withUid('$Datasource')
      + stat.queryOptions.withTargets(targets)
      + stat.gridPos.withX(gridPos.x)
      + stat.gridPos.withY(gridPos.y)
      + stat.gridPos.withH(gridPos.h)
      + stat.gridPos.withW(gridPos.w)
      + options.reduceOptions.withCalcs([
        'last',
      ]),
  },
}
