package main

import (
	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
	"github.com/grafana/grafana-foundation-sdk/go/prometheus"
	mg "github.com/afcollins/metrics-generator/pkg/metrics"
)

// panelTracker is implemented by any type that registers panel queries and returns panel targets.
// Row builder functions accept panelTracker so tracker implementations can be swapped
// without changing call sites.
type panelTracker interface {
	track(name string, query *mg.Query, legend string) *prometheus.DataqueryBuilder
	trackRaw(name string, expr string, legend string) *prometheus.DataqueryBuilder
	trackVarQuery(expr string) dashboard.StringOrMap
}

// namedProfile pairs a filename suffix with a populated Generator.
type namedProfile struct {
	suffix string
	g      *mg.Generator
}
