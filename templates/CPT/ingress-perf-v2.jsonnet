local panels = import '../../assets/ingress-performance-ocp/panels.libsonnet';
local queries = import '../../assets/ingress-performance-ocp/queries.libsonnet';
local variables = import '../../assets/ingress-performance-ocp/variables.libsonnet';
// local gra = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local g = import '../grafonnet-lib/grafonnet/grafana.libsonnet';


g.dashboard.new('Ingress-perf')
