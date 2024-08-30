local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local annotation = g.dashboard.annotation;

{
  run_start_timestamp:
    annotation.withName('Run Start Time')
    + annotation.withDatasource('$Datasource2')
    + annotation.withEnable(true)
    + annotation.withIconColor('#5794F2')
    + annotation.withHide(false)
    + annotation.target.withTags([])
    + annotation.withType('tags'),

  sample_start_timestamp:
    annotation.withName('Sample Start Time')
    + annotation.withDatasource('$Datasource2')
    + annotation.withEnable(false)
    + annotation.withIconColor('#B877D9')
    + annotation.withHide(false)
    + annotation.target.withTags([])
    + annotation.withType('tags'),
}
