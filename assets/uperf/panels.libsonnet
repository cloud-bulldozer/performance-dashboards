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
      + custom.withSpanNulls(false)
      + options.tooltip.withMode('multi')
      + options.tooltip.withSort('none')
      + options.legend.withShowLegend(true)
      + timeSeries.queryOptions.withTimeFrom(null)
      + timeSeries.queryOptions.withTimeShift(null)
      + timeSeries.panelOptions.withTransparent(true),

    uperfPerformance(title, unit, targets, gridPos):
      self.base(title, unit, targets, gridPos)
      + options.legend.withCalcs([
        'mean',
        'max',
      ])
      + options.legend.withShowLegend(true)
      + options.legend.withDisplayMode('table')
      + options.legend.withPlacement('bottom')
      + custom.withLineWidth(1)
      + custom.withFillOpacity(10)
      + custom.withPointSize(5)
      + custom.withSpanNulls(true)
      + custom.withShowPoints('never'),
  },

  table: {
    local table = g.panel.table,
    local custom = table.fieldConfig.defaults.custom,
    local options = table.options,

    base(title, targets, gridPos):
      table.new(title)
      + table.queryOptions.withTargets(targets)
      + table.datasource.withType('elasticsearch')
      + table.datasource.withUid('$Datasource')
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
            options: 'message_size',
          },
          properties: [
            {
              id: 'unit',
              value: '',
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
            options: 'Average norm_byte',
          },
          properties: [
            {
              id: 'unit',
              value: 'bps',
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
            options: 'Average norm_ops',
          },
          properties: [
            {
              id: 'unit',
              value: 'none',
            },
            {
              id: 'decimals',
              value: '0',
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
            options: 'Average norm_ltcy',
          },
          properties: [
            {
              id: 'unit',
              value: 'µs',
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
            options: 'Count',
          },
          properties: [
            {
              id: 'displayName',
              value: 'Sample count',
            },
            {
              id: 'unit',
              value: 'short',
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
