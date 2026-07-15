# Performance Dashboards - Claude Code Context

## Project Overview

This repo defines Grafana dashboards for performance testing (OpenShift, network benchmarks, etc.). Dashboards were originally built with **Jsonnet + grafonnet** and rendered to JSON via `make build`. We are migrating them to **Go** using the [grafana-foundation-sdk](https://github.com/grafana/grafana-foundation-sdk) Go builders.

## Go Migration (`go/` directory)

### Structure

**Entry point**
- `go/main.go` — Dashboard registry (`[]dashboardDef`). Renders JSON + YAML profiles. `--merge` flag combines profile files.

**Dashboards** (one file per dashboard)
- `go/api_performance.go`
- `go/etcd.go` — Emits `-metrics.yaml` and `-raw-metrics.yaml` via tracker pattern.
- `go/node.go`
- `go/ocp_performance.go` — Also emits collected-data variant and both profile types.
- `go/ovn.go`
- `go/uperf.go`
- `go/vegeta.go`

**Tracker system** (profiles generated as build by-product)
- `go/panel_tracker.go` — `panelTracker` interface + `namedProfile` struct.
- `go/query_tracker.go` — Registers aggregated PromQL queries; strips Grafana vars; deduplicates.
- `go/raw_tracker.go` — Extracts raw metric names via regex + PromQL function deny-list; 1:1 entries.

**Utilities**
- `go/helpers.go` — ES aggregation union-type wrappers (too verbose to inline).
- `go/merge.go` — Merges + deduplicates metrics-profile YAML files; output sorted by `metricName`.
- `go/deploy.go`

**Tests**
- `go/tracker_test.go` — `extractRawMetrics` units; tracker integration tests against OCP dashboard.
- `go/merge_test.go` — `mergeProfileFiles` units + real-output integration test.

### Migrated Dashboards
1. **vegeta-wrapper** (General) — ES/timeseries/table
2. **uperf-perf** (General) — ES/timeseries/table with Sum metrics and scripts
3. **ocp-performance** (General) — Prometheus/timeseries/stat/rows with repeat
4. **ocp-performance-collected** (General) — Same panels but queries use metric names instead of raw PromQL (for use against kube-burner collected data)

### Metrics Profile Generation
The Go builder is the single source of truth for both dashboard JSON **and** kube-burner metrics-profile YAML. Profiles are emitted as a by-product of building the dashboard — no separate query list to maintain.

`dashboardDef.metricsProfiles` returns `[]namedProfile{suffix, generator}`. The render loop writes `<name><suffix>.yaml` for each. OCP performance emits two profiles:
- `ocp-performance-metrics.yaml` — aggregated PromQL queries (via `queryTracker`)
- `ocp-performance-raw-metrics.yaml` — 1:1 raw metric names (via `rawTracker`), for collecting raw data to visualize in the original dashboard

**panelTracker interface** — row builder functions accept `panelTracker` so tracker implementations can be swapped without touching call sites:
```go
type panelTracker interface {
    track(name string, query *mg.Query, legend string) *prometheus.DataqueryBuilder
    trackRaw(name string, expr string, legend string) *prometheus.DataqueryBuilder
}
```

### Conventions
- Panel and variable construction stays **inline** in each dashboard file. Do not create helper structs that abstract away the builder pattern.
- Shared helpers are limited to ES aggregation type wrappers (genuinely verbose due to union type wrapping).
- Each dashboard file has its own local panel helpers (e.g., `ocpGenericLegend`, `vegetaTimeSeries`) matching the panel variants from the jsonnet assets.
- Use `make build` (with `source ~/.venv/performance-dashboards/bin/activate`) to build jsonnet dashboards for comparison.
- Use `t.track(name, query, legend)` for all panel queries that should appear in the metrics profile.
- Use `promQuery(expr, legend)` only for secondary display-only series (e.g. per-node detail of an already-tracked aggregation, or `topk()` display filters).
- `topk(N, ...)` panels must use `promQuery` — they are not meaningful collection targets.
- Track names must be role-agnostic (no `_master`/`_worker`/`_infra` suffix) so query dedup works across repeated row variants.

### SDK Patterns & Gotchas
- **Union types are verbose**: `StringOrMap{String: cog.ToPtr("...")}`, `StringOrArrayOfString{String: &val}`, `BoolOrFloat64{Bool: cog.ToPtr(true)}`. This is because the SDK is auto-generated from Grafana's JSON schema.
- **Interval variables** need `Current` and `Options` explicitly set (Grafana won't populate them from `query` alone). Use the `intervalOption(val)` helper.
- **Row GridPos W must be > 0**: The SDK validates this even though jsonnet allows `w: 0`.
- **`$Datasource` vs `${Datasource}`**: Both are valid Grafana syntax; the SDK produces the braces form.
- **`DatasourceVariableBuilder` has no `Refresh` method** — just omit it.
- **`FieldColorModeIdThresholds`** lives in the `dashboard` package, not `common`.
- **Expected diff categories** between jsonnet and Go output: `schemaVersion`, auto-generated `id` fields, `pluginVersion`, `repeatDirection`, `transparent: false`, `overrides: []`, per-target datasource refs, `annotations: {}`, `fiscalYearStartMonth`.

### Remaining Dashboards to Migrate
Check `templates/` directory for the full list. ~13 dashboards remain after OCP Performance.

## Build & Test
```bash
# Build Go dashboards
cd go && go run .

# Build jsonnet dashboards (for comparison)
source ~/.venv/performance-dashboards/bin/activate && make build

# Compare outputs
diff <(jq -S . rendered/General/<name>.json) <(jq -S . go/rendered/General/<name>.json)
```
