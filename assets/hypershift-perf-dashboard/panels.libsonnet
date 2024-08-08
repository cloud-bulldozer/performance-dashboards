local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
    stat: {
        local stat = g.panel.stat,
        local options = stat.options,

        base(title, unit, targets, datasource, gridPos):
            stat.new(title)
            + stat.datasource.withType('prometheus')
            + stat.datasource.withUid(datasource)
            + stat.standardOptions.withUnit(unit)
            + stat.queryOptions.withTargets(targets)
            + stat.gridPos.withX(gridPos.x)
            + stat.gridPos.withY(gridPos.y)
            + stat.gridPos.withH(gridPos.h)
            + stat.gridPos.withW(gridPos.w)
            + options.withJustifyMode("auto")
            + options.withGraphMode("none")
            + options.text.withTitleSize(12),

        m_infrastructure(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('name')
            + options.withColorMode('value')
            + stat.standardOptions.thresholds.withSteps([{
                    "color": "green",
                    "value": null
                }])
            + options.withJustifyMode('auto'),

        m_region(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('name')
            + options.withColorMode('value')
            + stat.standardOptions.thresholds.withSteps([{
                    "color": "green",
                    "value": null
                }])
            + options.withJustifyMode('auto'),
        
        m_ocp_version(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('name')
            + options.withColorMode('value')
            + stat.standardOptions.thresholds.withSteps([{
                    "color": "green",
                    "value": null
                }])
            + options.withJustifyMode('auto'),

        num_hosted_cluster(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('auto')
            + options.withColorMode('value')
            + options.withJustifyMode('auto')
            + stat.standardOptions.thresholds.withSteps([{
                    "color": "green",
                    "value": null
                }])
            + options.reduceOptions.withCalcs([
                'max',
            ]),

        current_namespace_count(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('auto')
            + options.withColorMode('value')
            + options.withJustifyMode('auto')
            + stat.standardOptions.thresholds.withSteps([])
            + stat.standardOptions.thresholds.withMode('absolute')
            + options.reduceOptions.withCalcs([
                'last',
            ]),
        
        current_node_count(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('auto')
            + options.withColorMode('value')
            + options.withJustifyMode('auto')
            + options.withGraphMode('area')
            + stat.standardOptions.thresholds.withSteps([])
            + stat.standardOptions.thresholds.withMode('absolute')
            + options.reduceOptions.withCalcs([
                'last',
            ]),

        current_pod_count(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('auto')
            + options.withColorMode('value')
            + options.withJustifyMode('auto')
            + options.withGraphMode('area')
            + stat.standardOptions.thresholds.withSteps([])
            + stat.standardOptions.thresholds.withMode('absolute')
            + options.reduceOptions.withCalcs([
                'last',
            ]),

        etcd_has_leader(title, unit, targets, datasource, gridPos): 
            self.base(title, unit, targets, datasource, gridPos)
            + options.withOrientation('horizontal')
            + options.withColorMode('none')
            + stat.standardOptions.withMappings([
                {
                    "type": "value",
                    "options": {
                        "0": {
                        "text": "NO"
                        },
                        "1": {
                        "text": "YES"
                        }
                }
                }
            ]),

        mgmt_num_failed_proposals(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withOrientation('horizontal')
            + options.withColorMode('none')
            + options.withTextMode('auto')
            + options.withGraphMode('none')
            + options.withJustifyMode('auto'),

        hostedControlPlaneStats(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.withTextMode('name')
            + options.withColorMode('value')
            + options.withJustifyMode('auto')
            + options.withGraphMode('none')
            + stat.standardOptions.thresholds.withSteps([{
                    "color": "green",
                    "value": null
                }]),
    },

    timeSeries: {
        local timeSeries = g.panel.timeSeries,
        local custom = timeSeries.fieldConfig.defaults.custom,
        local options = timeSeries.options,

        base(title, unit, targets, datasource, gridPos):
            timeSeries.new(title)
            + timeSeries.queryOptions.withTargets(targets)
            + timeSeries.datasource.withType('prometheus')
            + timeSeries.datasource.withUid(datasource)
            + timeSeries.standardOptions.withUnit(unit)
            + timeSeries.gridPos.withX(gridPos.x)
            + timeSeries.gridPos.withY(gridPos.y)
            + timeSeries.gridPos.withH(gridPos.h)
            + timeSeries.gridPos.withW(gridPos.w)
            + custom.withSpanNulls(false)
            + custom.withFillOpacity(25)
            + options.legend.withShowLegend(true),

        managementClustersStatsTimeseriesSettings(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.legend.withPlacement('bottom')
            + options.legend.withDisplayMode('table')
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + custom.withDrawStyle('line')
            + custom.withLineInterpolation('linear')
            + options.legend.withDisplayMode('table')
            + options.legend.withCalcs([
                'mean',
                'max'
            ]),  

        mgmt(title, unit, targets, datasource, gridPos): 
            self.base(title, unit, targets, datasource, gridPos)
            + options.legend.withDisplayMode('table')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom')
            + options.legend.withCalcs([
                'mean',
                'max'
            ])
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withSortBy('max'),

        DBPanelsSettings(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.legend.withDisplayMode('list')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom')
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('none'),

        genericGraphLegendPanel(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.legend.withDisplayMode('table')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom')
            + options.legend.withCalcs([
                'mean',
                'max'
            ])
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withSortBy('max'),

        genericGraphLegendPanelRightSide(title, unit, targets, datasource, gridPos): 
            self.base(title, unit, targets, datasource, gridPos)
            + options.legend.withDisplayMode('table')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('right')
            + options.legend.withCalcs([
                'lastNotNull',
            ])
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withSortBy('max'),

        genericGraphLegendPanelList(title, unit, targets, datasource, gridPos):
            self.base(title, unit, targets, datasource, gridPos)
            + options.legend.withDisplayMode('list')
            + options.legend.withShowLegend(true)
            + options.legend.withPlacement('bottom')
            + options.legend.withCalcs([
                'lastNotNull',
            ])
            + options.tooltip.withMode('multi')
            + options.tooltip.withSort('desc')
            + options.legend.withSortBy('max'),
    },
}