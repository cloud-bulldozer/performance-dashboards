package main

import (
	"regexp"
	"strings"

	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
)

// profileInterval is substituted for $interval in metrics profile queries.
const profileInterval = mg.Rate2m

var grafanaVarRe = regexp.MustCompile(`,?\s*\w+[=!~]+=?"[^"]*\$[^"]*"`)
var labelValuesRe = regexp.MustCompile(`^label_values\((.+),\s*(\w+)\)$`)

func stripGrafanaVars(expr string) string {
	clean := grafanaVarRe.ReplaceAllString(expr, "")
	clean = strings.ReplaceAll(clean, "{,", "{")
	clean = strings.ReplaceAll(clean, "{}", "")
	clean = strings.ReplaceAll(clean, "$interval", string(profileInterval))
	return clean
}

func extractGrafanaVarFilters(expr string) string {
	matches := grafanaVarRe.FindAllString(expr, -1)
	if len(matches) == 0 {
		return ""
	}
	seen := map[string]struct{}{}
	var filters []string
	for _, m := range matches {
		f := strings.TrimLeft(m, ", ")
		if _, dup := seen[f]; dup {
			continue
		}
		seen[f] = struct{}{}
		filters = append(filters, f)
	}
	return "{" + strings.Join(filters, ",") + "}"
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
	expr := query.String()
	t.add(name, stripGrafanaVars(expr))
	if t.useMetricNames {
		return promQuery(name+extractGrafanaVarFilters(expr), legend)
	}
	return promQuery(expr, legend)
}

func (t *queryTracker) trackVarQuery(name string, expr string) dashboard.StringOrMap {
	if m := labelValuesRe.FindStringSubmatch(expr); m != nil {
		metricExpr, label := strings.TrimSpace(m[1]), m[2]
		t.add(name, "count("+stripGrafanaVars(metricExpr)+") by ("+label+")")
		if t.useMetricNames {
			rewritten := "label_values(" + name + ", " + label + ")"
			return dashboard.StringOrMap{String: cog.ToPtr(rewritten)}
		}
	}
	return dashboard.StringOrMap{String: cog.ToPtr(expr)}
}

func (t *queryTracker) trackRaw(name string, expr string, legend string) *prometheus.DataqueryBuilder {
	t.add(name, stripGrafanaVars(expr))
	if t.useMetricNames {
		return promQuery(name+extractGrafanaVarFilters(expr), legend)
	}
	return promQuery(expr, legend)
}
