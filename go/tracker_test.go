package main

import (
	"regexp"
	"testing"

	mg "github.com/afcollins/metrics-generator/pkg/metrics"
	"gopkg.in/yaml.v3"
)

type metricDef struct {
	MetricName string `yaml:"metricName"`
	Query      string `yaml:"query"`
}

func parseProfile(t *testing.T, g *mg.Generator) []metricDef {
	t.Helper()
	b, err := g.Generate()
	if err != nil {
		t.Fatalf("Generate: %v", err)
	}
	var defs []metricDef
	if err := yaml.Unmarshal(b, &defs); err != nil {
		t.Fatalf("yaml.Unmarshal: %v", err)
	}
	return defs
}

// ---------------------------------------------------------------------------
// extractRawMetrics unit tests
// ---------------------------------------------------------------------------

func TestExtractRawMetrics(t *testing.T) {
	cases := []struct {
		name string
		expr string
		want []string
		bad  []string
	}{
		{
			name: "simple metric",
			expr: `container_cpu_usage_seconds_total{}`,
			want: []string{"container_cpu_usage_seconds_total"},
		},
		{
			name: "rate expression with grafana interval",
			expr: `rate(container_cpu_usage_seconds_total{namespace=~"$Namespace"}[$interval])`,
			want: []string{"container_cpu_usage_seconds_total"},
			bad:  []string{"interval", "namespace", "Namespace"},
		},
		{
			name: "string literal with hyphen does not split",
			expr: `kube_pod_info{namespace="openshift-monitoring"}`,
			want: []string{"kube_pod_info"},
			bad:  []string{"openshift", "monitoring"},
		},
		{
			name: "camelCase metric name",
			expr: `node_memory_MemAvailable_bytes{}`,
			want: []string{"node_memory_MemAvailable_bytes"},
			bad:  []string{"em", "vailable_bytes", "MemAvailable"},
		},
		{
			name: "binary expression with by clause",
			expr: `sum(node_cpu_seconds_total{}) by (namespace, node, instance)`,
			want: []string{"node_cpu_seconds_total"},
			bad:  []string{"namespace", "node", "instance"},
		},
		{
			name: "group_left join does not leak label names",
			expr: `kube_pod_info{} * on (pod) group_left(node) kube_node_role{}`,
			want: []string{"kube_pod_info", "kube_node_role"},
			bad:  []string{"pod", "node", "on"},
		},
		{
			name: "promql functions excluded",
			expr: `histogram_quantile(0.99, sum(rate(ovnkube_controller_pod_creation_latency_seconds_bucket{}[2m])) by (le))`,
			want: []string{"ovnkube_controller_pod_creation_latency_seconds_bucket"},
			bad:  []string{"histogram_quantile", "sum", "rate", "by", "le"},
		},
		{
			name: "uppercase metric name ALERTS",
			expr: `topk(10,sum(ALERTS{severity!="none"}) by (alertname, severity))`,
			want: []string{"ALERTS"},
			bad:  []string{"alertname", "severity", "topk", "sum", "by"},
		},
		{
			name: "label_values extracts metric not label arg",
			expr: `label_values(etcd_cluster_version, pod)`,
			want: []string{"etcd_cluster_version"},
			bad:  []string{"label_values", "pod"},
		},
		{
			name: "label_values with label selector strips label name arg",
			expr: `label_values(kube_node_role{role="master"}, node)`,
			want: []string{"kube_node_role"},
			bad:  []string{"label_values", "node", "role"},
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := extractRawMetrics(tc.expr)
			gotSet := make(map[string]bool, len(got))
			for _, m := range got {
				gotSet[m] = true
			}
			for _, w := range tc.want {
				if !gotSet[w] {
					t.Errorf("want %q in result, got %v", w, got)
				}
			}
			for _, b := range tc.bad {
				if gotSet[b] {
					t.Errorf("unwanted %q found in result %v", b, got)
				}
			}
		})
	}
}

// ---------------------------------------------------------------------------
// rawTracker integration tests
// ---------------------------------------------------------------------------

func TestRawTrackerOCPDashboard(t *testing.T) {
	g := &mg.Generator{}
	buildOCPDashboard(&rawTracker{g: g, seen: map[string]struct{}{}})
	defs := parseProfile(t, g)

	if len(defs) == 0 {
		t.Fatal("rawTracker produced no metrics")
	}

	byName := make(map[string]metricDef, len(defs))
	for _, d := range defs {
		byName[d.MetricName] = d
	}

	// Known real metrics must be present.
	mustHave := []string{
		"container_cpu_usage_seconds_total",
		"container_memory_rss",
		"node_memory_MemAvailable_bytes",
		"node_cpu_seconds_total",
		"kube_node_status_condition",
		"kube_pod_status_phase",
	}
	for _, m := range mustHave {
		if _, ok := byName[m]; !ok {
			t.Errorf("expected metric %q missing from raw profile", m)
		}
	}

	// Known garbage tokens must not appear.
	mustNotHave := []string{
		"namespace", "container", "node", "pod", "instance", "le",
		"interval", "em", "vailable_bytes", "eady", "ending",
		"openshift", "monitoring",
	}
	for _, bad := range mustNotHave {
		if _, ok := byName[bad]; ok {
			t.Errorf("garbage token %q found in raw profile", bad)
		}
	}

	// Every metric name and query must be 1:1 (rawTracker registers metric as its own query).
	for _, d := range defs {
		if d.MetricName != d.Query {
			t.Errorf("rawTracker entry not 1:1: metricName=%q query=%q", d.MetricName, d.Query)
		}
	}
}

func TestRawTrackerNoDuplicates(t *testing.T) {
	g := &mg.Generator{}
	buildOCPDashboard(&rawTracker{g: g, seen: map[string]struct{}{}})
	defs := parseProfile(t, g)

	seen := map[string]int{}
	for _, d := range defs {
		seen[d.MetricName]++
	}
	for name, count := range seen {
		if count > 1 {
			t.Errorf("metric %q appears %d times in raw profile (want 1)", name, count)
		}
	}
}

func TestOCPDashboardNoStaleDeclarations(t *testing.T) {
	g := &mg.Generator{}
	buildOCPDashboard(&rawTracker{g: g, seen: map[string]struct{}{}})
	defs := parseProfile(t, g)

	inProfile := make(map[string]struct{}, len(defs))
	for _, d := range defs {
		inProfile[d.MetricName] = struct{}{}
	}

	var missing []string
	for _, metric := range ocpDashboardMetrics {
		if _, ok := inProfile[string(metric)]; !ok {
			missing = append(missing, string(metric))
		}
	}
	for _, m := range missing {
		t.Errorf("metric %q declared in ocpDashboardMetrics but not found in any panel query", m)
	}
}

// grafanaVarInQuery matches $VarName (Grafana template variables) but not $1/$2 (regex back-refs).
var grafanaVarInQuery = regexp.MustCompile(`\$[a-zA-Z_]`)

// ---------------------------------------------------------------------------
// queryTracker integration tests
// ---------------------------------------------------------------------------

func TestQueryTrackerNoGrafanaVars(t *testing.T) {
	g := &mg.Generator{}
	buildOCPDashboard(&queryTracker{g: g})
	defs := parseProfile(t, g)

	if len(defs) == 0 {
		t.Fatal("queryTracker produced no metrics")
	}

	for _, d := range defs {
		if grafanaVarInQuery.MatchString(d.Query) {
			t.Errorf("Grafana variable in query for %q: %s", d.MetricName, d.Query)
		}
	}
}

func TestRawTrackerEtcdVariableQueryMetrics(t *testing.T) {
	g := &mg.Generator{}
	buildEtcdDash(&rawTracker{g: g, seen: map[string]struct{}{}})
	defs := parseProfile(t, g)

	byName := make(map[string]metricDef, len(defs))
	for _, d := range defs {
		byName[d.MetricName] = d
	}

	// etcd_cluster_version is only in the variable query, not any panel.
	if _, ok := byName["etcd_cluster_version"]; !ok {
		t.Error("etcd_cluster_version missing from raw profile (only in variable query)")
	}

	// Known label names must not appear as metric entries.
	for _, bad := range []string{"pod", "label_values"} {
		if _, ok := byName[bad]; ok {
			t.Errorf("garbage token %q found in etcd raw profile", bad)
		}
	}
}

func TestQueryTrackerNoDuplicates(t *testing.T) {
	g := &mg.Generator{}
	buildOCPDashboard(&queryTracker{g: g})
	defs := parseProfile(t, g)

	seen := map[string]int{}
	for _, d := range defs {
		seen[d.MetricName]++
	}
	for name, count := range seen {
		if count > 1 {
			t.Errorf("metric %q appears %d times in aggregated profile (want 1)", name, count)
		}
	}
}
