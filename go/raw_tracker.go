package main

import (
	"regexp"

	"github.com/grafana/grafana-foundation-sdk/go/cog"
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
)

var (
	stringLiteralRe = regexp.MustCompile(`"[^"]*"`)
	labelSelectorRe = regexp.MustCompile(`\{[^}]*\}`)
	rateDurationRe  = regexp.MustCompile(`\[[^\]]*\]`)
	// strips by(...), without(...), on(...), ignoring(...), group_left(...), group_right(...)
	groupClauseRe = regexp.MustCompile(`\b(?:by|without|on|ignoring|group_left|group_right)\s*\([^)]*\)`)
)

// promFunctions is the deny-list of PromQL function names and keywords that share the
// [a-z][a-z0-9_]* pattern with Prometheus metric names.
var promFunctions = map[string]struct{}{
	"rate": {}, "irate": {}, "increase": {}, "delta": {}, "idelta": {},
	"sum": {}, "avg": {}, "max": {}, "min": {}, "count": {}, "stddev": {}, "stdvar": {},
	"topk": {}, "bottomk": {}, "count_values": {}, "quantile": {},
	"histogram_quantile": {}, "histogram_sum": {}, "histogram_count": {},
	"label_replace": {}, "label_join": {}, "label_values": {},
	"vector": {}, "scalar": {}, "absent": {}, "absent_over_time": {},
	"changes": {}, "resets": {}, "deriv": {}, "predict_linear": {},
	"time": {}, "timestamp": {},
	"day_of_month": {}, "day_of_week": {}, "days_in_month": {},
	"hour": {}, "minute": {}, "month": {}, "year": {},
	"floor": {}, "ceil": {}, "round": {}, "clamp": {}, "clamp_min": {}, "clamp_max": {},
	"exp": {}, "ln": {}, "log2": {}, "log10": {}, "sqrt": {}, "abs": {}, "sgn": {},
	"sort": {}, "sort_desc": {},
	"avg_over_time": {}, "min_over_time": {}, "max_over_time": {}, "sum_over_time": {},
	"count_over_time": {}, "stdvar_over_time": {}, "stddev_over_time": {},
	"last_over_time": {}, "present_over_time": {}, "quantile_over_time": {},
	"by": {}, "without": {}, "on": {}, "ignoring": {},
	"group_left": {}, "group_right": {}, "bool": {}, "offset": {},
	"and": {}, "or": {}, "unless": {}, "inf": {}, "nan": {},
}

// knownLabels is a deny-list of common Prometheus label names that are never
// metric names. Used to suppress false positives from label_values(metric, label).
var knownLabels = map[string]struct{}{
	"pod": {}, "node": {}, "device": {}, "namespace": {},
	"instance": {}, "le": {}, "alertname": {}, "severity": {},
}

var identRe = regexp.MustCompile(`[a-zA-Z][a-zA-Z0-9_]*`)

// extractRawMetrics returns all unique raw Prometheus metric names in expr,
// excluding PromQL function names, keywords, and known label names.
func extractRawMetrics(expr string) []string {
	clean := stripGrafanaVars(expr)
	clean = stringLiteralRe.ReplaceAllString(clean, "")
	clean = labelSelectorRe.ReplaceAllString(clean, "")
	clean = rateDurationRe.ReplaceAllString(clean, "")
	clean = groupClauseRe.ReplaceAllString(clean, "")

	seen := map[string]struct{}{}
	var out []string
	for _, name := range identRe.FindAllString(clean, -1) {
		if _, isFunc := promFunctions[name]; isFunc {
			continue
		}
		if _, isLabel := knownLabels[name]; isLabel {
			continue
		}
		if _, dup := seen[name]; dup {
			continue
		}
		seen[name] = struct{}{}
		out = append(out, name)
	}
	return out
}

// rawTracker implements panelTracker. Extracts raw Prometheus metric names from every
// tracked expression and registers them 1:1 in a Generator.
type rawTracker struct {
	g    *mg.Generator
	seen map[string]struct{}
}

func (t *rawTracker) track(_ string, query *mg.Query, legend string) *prometheus.DataqueryBuilder {
	t.register(query.String())
	return promQuery(query.String(), legend)
}

func (t *rawTracker) trackRaw(_ string, expr string, legend string) *prometheus.DataqueryBuilder {
	t.register(expr)
	return promQuery(expr, legend)
}

func (t *rawTracker) trackVarQuery(expr string) dashboard.StringOrMap {
	t.register(expr)
	return dashboard.StringOrMap{String: cog.ToPtr(expr)}
}

func (t *rawTracker) register(expr string) {
	for _, name := range extractRawMetrics(expr) {
		if _, seen := t.seen[name]; seen {
			continue
		}
		t.seen[name] = struct{}{}
		t.g.Add(name, name)
	}
}
