package main

import (
	"regexp"
	"strings"

	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
)

// profileInterval is substituted for $interval in metrics profile queries.
const profileInterval = mg.Rate2m

var grafanaVarRe = regexp.MustCompile(`,?\s*\w+[=!~]+=?"[^"]*\$[^"]*"`)

func stripGrafanaVars(expr string) string {
	clean := grafanaVarRe.ReplaceAllString(expr, "")
	clean = strings.ReplaceAll(clean, "{}", "")
	clean = strings.ReplaceAll(clean, "$interval", string(profileInterval))
	return clean
}

// queryTracker implements panelTracker. Registers aggregated PromQL queries in a Generator.
// When useMetricNames is true, panel targets use the registered metric name as the query
// expression — for dashboards that visualize already-collected metrics.
type queryTracker struct {
	g              *mg.Generator
	useMetricNames bool
	seen           map[string]struct{} // dedup by stripped query; prevents role-variant tripling
}

func (t *queryTracker) add(name, stripped string) {
	if t.g == nil {
		return
	}
	if t.seen == nil {
		t.seen = map[string]struct{}{}
	}
	if _, dup := t.seen[stripped]; dup {
		return
	}
	t.seen[stripped] = struct{}{}
	t.g.Add(name, stripped)
}

func (t *queryTracker) track(name string, query *mg.Query, legend string) *prometheus.DataqueryBuilder {
	t.add(name, stripGrafanaVars(query.String()))
	if t.useMetricNames {
		return promQuery(name, legend)
	}
	return promQuery(query.String(), legend)
}

func (t *queryTracker) trackVarQuery(expr string) dashboard.StringOrMap {
	return dashboard.StringOrMap{String: cog.ToPtr(expr)}
}

func (t *queryTracker) trackRaw(name string, expr string, legend string) *prometheus.DataqueryBuilder {
	t.add(name, stripGrafanaVars(expr))
	if t.useMetricNames {
		return promQuery(name, legend)
	}
	return promQuery(expr, legend)
}
