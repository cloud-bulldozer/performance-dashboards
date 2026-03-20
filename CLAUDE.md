# Performance Dashboards - Claude Code Context

## Project Overview

This repo defines Grafana dashboards for performance testing (OpenShift, network benchmarks, etc.). Dashboards were originally built with **Jsonnet + grafonnet** and rendered to JSON via `make build`. We are migrating them to **Go** using the [grafana-foundation-sdk](https://github.com/grafana/grafana-foundation-sdk) Go builders.

## Go Migration (`go/` directory)

### Structure
- `go/main.go` — Entry point with dashboard registry (`[]dashboardDef{name, category, builderFunc}`). Writes JSON to `go/rendered/<category>/<name>.json`.
- `go/helpers.go` — Shared Elasticsearch aggregation helpers only (union type wrappers that are too verbose to inline: `dateHistogramBucketAgg`, `termsBucketAgg`, `avgMetric`, `sumMetric`, `countMetric`, etc.).
- `go/vegeta.go` — Vegeta Wrapper dashboard (ES queries, 3 timeseries + 1 table).
- `go/uperf.go` — UPerf dashboard (ES queries with Sum/Count metrics and inline scripts).
- `go/ocp_performance.go` — OpenShift Performance dashboard (Prometheus queries, 10 rows, ~100 panels, stat panels, interval variable, row repeat).
- `go/go.mod` — Uses local replace directive pointing to `/Users/ancollin/go/src/github.com/grafana/grafana-foundation-sdk/go`.

### Migrated Dashboards
1. **vegeta-wrapper** (General) — ES/timeseries/table
2. **uperf-perf** (General) — ES/timeseries/table with Sum metrics and scripts
3. **ocp-performance** (General) — Prometheus/timeseries/stat/rows with repeat

### Conventions
- Panel and variable construction stays **inline** in each dashboard file. Do not create helper structs that abstract away the builder pattern.
- Shared helpers are limited to ES aggregation type wrappers (genuinely verbose due to union type wrapping).
- Each dashboard file has its own local panel helpers (e.g., `ocpGenericLegend`, `vegetaTimeSeries`) matching the panel variants from the jsonnet assets.
- Use `make build` (with `source ~/.venv/performance-dashboards/bin/activate`) to build jsonnet dashboards for comparison.

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
