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
      + timeSeries.datasource.withUid('$Datasource1')
      + timeSeries.standardOptions.withUnit(unit)
      + timeSeries.gridPos.withX(gridPos.x)
      + timeSeries.gridPos.withY(gridPos.y)
      + timeSeries.gridPos.withH(gridPos.h)
      + timeSeries.gridPos.withW(gridPos.w)
      + custom.withDrawStyle('line')
      + custom.withLineInterpolation('linear')
      + custom.withBarAlignment(0)
      + custom.withFillOpacity(10)
      + custom.withGradientMode('none')
      + custom.withSpanNulls(false)
      + custom.withPointSize(5)
      + custom.withSpanNulls(false)
      + custom.stacking.withGroup('A')
      + custom.stacking.withMode('none')
      + custom.withShowPoints('never')
      + timeSeries.queryOptions.withTimeFrom(null)
      + timeSeries.queryOptions.withTimeShift(null)
      + timeSeries.panelOptions.withTransparent(true),

    tps_report(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + custom.withLineWidth(2)
      + options.tooltip.withMode('multi')
      + options.legend.withShowLegend(false)
      + options.legend.withDisplayMode('list')
      + options.legend.withPlacement('bottom'),


    avg_tps(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.legend.withShowLegend(true)
      + options.legend.withDisplayMode('table')
      + options.legend.withCalcs([
        'mean',
        'max',
        'min',
      ])
      + options.legend.withPlacement('bottom')
      + custom.withDrawStyle('bars')
      + custom.withLineInterpolation('linear'),
  },

  heatmap: {
    local heatmap = g.panel.heatmap,
    local custom = heatmap.fieldConfig.defaults.custom,
    local options = heatmap.options,

    base(title, unit, targets, gridPos):
      heatmap.new(title)
      + heatmap.queryOptions.withTargets(targets)
      + heatmap.datasource.withType('elasticsearch')
      + heatmap.datasource.withUid('$Datasource1')
      + heatmap.standardOptions.withUnit(unit)
      + heatmap.gridPos.withX(gridPos.x)
      + heatmap.gridPos.withY(gridPos.y)
      + heatmap.gridPos.withH(gridPos.h)
      + heatmap.gridPos.withW(gridPos.w)
      + custom.scaleDistribution.withType('linear')
      + custom.hideFrom.withLegend(false)
      + custom.hideFrom.withTooltip(false)
      + custom.hideFrom.withViz(false)
      + options.withCalculate(true)
      + options.yAxis.withAxisPlacement('left')
      + options.yAxis.withReverse(false)
      + options.yAxis.withUnit('ms')
      + options.rowsFrame.withLayout('auto')
      + options.color.HeatmapColorOptions.withMode('scheme')
      + options.color.HeatmapColorOptions.withFill('dark-orange')
      + options.color.HeatmapColorOptions.withScale('exponential')
      + options.color.HeatmapColorOptions.withExponent(0.5)
      + options.color.HeatmapColorOptions.withScheme('Oranges')
      + options.color.HeatmapColorOptions.withSteps(128)
      + options.color.HeatmapColorOptions.withReverse(false)
      + options.withCellGap(2)
      + options.filterValues.FilterValueRange.withLe(1e-9)
      + options.tooltip.withShow(false)
      + options.tooltip.withYHistogram(false)
      + options.legend.withShow(true)
      + options.exemplars.withColor('rgba(255,0,255,0.7)')
      + options.withShowValue('never')
      + heatmap.panelOptions.withTransparent(true),
  },

  table: {
    local table = g.panel.table,
    local custom = table.fieldConfig.defaults.custom,
    local options = table.options,

    base(title, targets, gridPos):
      table.new(title)
      + table.queryOptions.withTargets(targets)
      + table.datasource.withType('elasticsearch')
      + table.datasource.withUid('$Datasource1')
      + table.gridPos.withX(gridPos.x)
      + table.gridPos.withY(gridPos.y)
      + table.gridPos.withH(gridPos.h)
      + table.gridPos.withW(gridPos.w)
      + options.withShowHeader(true)
      + options.footer.TableFooterOptions.withShow(false)
      + options.footer.TableFooterOptions.withReducer('sum')
      + options.footer.TableFooterOptions.withCountRows(false)
      + custom.withAlign('auto')
      + custom.withInspect(false)
      + table.panelOptions.withTransparent(true)
      + table.queryOptions.withTimeFrom(null)
      + table.queryOptions.withTimeShift(null)
      + table.standardOptions.color.withMode('thresholds')
      + table.queryOptions.withTransformations([
        {
          id: 'seriesToColumns',
          options: {
            reducers: [],
          },
        },
      ])
      + table.standardOptions.withOverrides([
        {
          matcher: {
            id: 'byName',
            options: 'Average latency_ms',
          },
          properties: [
            {
              id: 'displayName',
              value: 'Avg latency',
            },
            {
              id: 'decimals',
              value: '2',
            },
            {
              id: 'custom.align',
              value: null,
            },
          ],
        },
        {
          matcher: {
            id: 'byName',
            options: 'Average tps',
          },
          properties: [
            {
              id: 'displayName',
              value: 'Avg TPS',
            },
            {
              id: 'decimals',
              value: '2',
            },
            {
              id: 'custom.align',
              value: null,
            },
          ],
        },
      ]),
  },
}
