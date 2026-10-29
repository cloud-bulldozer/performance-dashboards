package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
)

type dashboardDef struct {
	name            string
	category        string
	builder         func() *dashboard.DashboardBuilder
	metricsProfiles func() []namedProfile
}

const (
	defaultOutputDir              = "rendered"
	renderingOutputDir            = "rendered/for-rendering"
	renderingPanelHeightReduction = 2
)

type renderOptions struct {
	hideLegends        bool
	compactPanelHeight bool
}

var dashboards = []dashboardDef{
	{"vegeta-wrapper", "General", buildVegetaDashboard, nil},
	{"uperf-perf", "General", buildUperfDashboard, nil},
	{"ocp-performance", "General", buildOCPPerformanceDashboard, buildOCPProfiles},
	{"ocp-performance-collected", "collected", buildOCPCollectedDashboard, nil},
	{"ocp-performance-cudns", "General", buildOCPPerformanceCUDNsDashboard, buildOCPCUDNsProfiles},
	{"ocp-performance-cudns-collected", "collected", buildOCPPerformanceCUDNsCollectedDashboard, nil},
	{"etcd-on-cluster", "General", buildEtcdDashboard, buildEtcdProfiles},
	{"etcd-on-cluster-collected", "collected", buildEtcdCollectedDashboard, nil},
	{"ovn-dashboard", "General", buildOVNDashboard, nil},
	{"api-performance-overview", "General", buildAPIPerformanceDashboard, buildAPIProfiles},
	{"api-performance-overview-collected", "collected", buildAPICollectedDashboard, nil},
	{"node", "General", buildNodeDashboard, nil},
	{"node-comparison", "General", buildNodeComparisonDashboard, buildNodeComparisonProfiles},
	{"node-cpu-comparison", "General", buildNodeCPUComparisonDashboard, buildNodeCPUComparisonProfiles},
}

func envDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	mergeOutput := flag.String("merge", "", "Merge input YAML files (metrics profiles or prometheus rules) into this output path (positional args are inputs)")
	deployFlag := flag.Bool("deploy", false, "Deploy rendered dashboards to Grafana")
	loopFlag := flag.Bool("loop", false, "Run deploy in a loop (sidecar mode)")
	loopInterval := flag.Duration("loop-interval", 60*time.Second, "Interval between deploy loops")
	grafanaURL := flag.String("grafana-url", envDefault("GRAFANA_URL", ""), "Grafana URL (e.g. http://admin:pass@localhost:3000)")
	inputDir := flag.String("input-dir", envDefault("INPUT_DIR", ""), "Directory with pre-rendered JSON (skips rendering)")
	outputDir := flag.String("output-dir", envDefault("OUTPUT_DIR", defaultOutputDir), "Directory to write rendered dashboard JSON")
	gitCommitHash := flag.String("git-commit-hash", envDefault("GIT_COMMIT_HASH", ""), "Git commit hash to append to dashboard tags")
	hideLegends := flag.Bool("hide-legends", false, "Hide legends on every rendered panel")
	rendering := flag.Bool("rendering", false, "Render compact, legend-free dashboards for screenshots")
	flag.Parse()

	if *mergeOutput != "" {
		if err := mergeFiles(flag.Args(), *mergeOutput); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
		return
	}

	if *inputDir == "" {
		renderOptions := renderOptions{hideLegends: *hideLegends}
		if *rendering {
			renderOptions.hideLegends = true
			renderOptions.compactPanelHeight = true
			if !flagWasProvided("output-dir") && os.Getenv("OUTPUT_DIR") == "" {
				*outputDir = renderingOutputDir
			}
		}
		renderDashboards(*outputDir, renderOptions)
	}

	if !*deployFlag {
		return
	}

	deployDir := *outputDir
	if *inputDir != "" {
		deployDir = *inputDir
	}

	if *grafanaURL == "" {
		fmt.Fprintln(os.Stderr, "error: --grafana-url or GRAFANA_URL is required for deploy")
		os.Exit(1)
	}

	d := newDeployer(*grafanaURL, deployDir, *gitCommitHash)

	for {
		if err := d.deploy(); err != nil {
			if !*loopFlag {
				log.Fatalf("deploy error: %v", err)
			}
			log.Printf("deploy error: %v", err)
		} else {
			log.Println("deploy complete")
			if !*loopFlag {
				break
			}
		}
		log.Printf("sleeping %s before next sync...", *loopInterval)
		time.Sleep(*loopInterval)
	}
}

func flagWasProvided(name string) bool {
	provided := false
	flag.Visit(func(f *flag.Flag) {
		if f.Name == name {
			provided = true
		}
	})
	return provided
}

func renderDashboards(outputDir string, options renderOptions) {
	for _, d := range dashboards {
		jsonBytes := buildDashboardToJson(d, options)

		dir := filepath.Join(outputDir, d.category)
		createDir(dir)
		outPath := filepath.Join(dir, d.name+".json")
		writeFile(outPath, jsonBytes)

		if d.metricsProfiles != nil {
			for _, p := range d.metricsProfiles() {
				metricProfilesDir := filepath.Join(outputDir, "metrics")
				createDir(metricProfilesDir)
				writeFile(filepath.Join(metricProfilesDir, d.name+p.suffix+".yaml"), p.g.Generate())

				ruleSuffix := strings.Replace(p.suffix, "-metrics", "-rules", 1)
				rulesDir := filepath.Join(outputDir, "rules")
				createDir(rulesDir)
				writeFile(filepath.Join(rulesDir, d.name+ruleSuffix+".yaml"), p.g.GenerateRules(d.name))
			}
		}
	}
}

func buildDashboardToJson(d dashboardDef, options renderOptions) []byte {
	built, err := d.builder().Build()
	if err != nil {
		fmt.Fprintf(os.Stderr, "error building dashboard %s/%s: %v\n", d.category, d.name, err)
	}

	jsonBytes, err := json.MarshalIndent(built, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error marshaling dashboard %s/%s: %v\n", d.category, d.name, err)
	}
	if options.hideLegends {
		jsonBytes, err = transformDashboardJSON(jsonBytes, options)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error hiding legends in dashboard %s/%s: %v\n", d.category, d.name, err)
		}
	}
	return jsonBytes
}

// hideLegendsInJSON changes every panel legend in a rendered dashboard without
// requiring each individual panel builder to know about the CLI setting.
func hideLegendsInJSON(jsonBytes []byte) ([]byte, error) {
	return transformDashboardJSON(jsonBytes, renderOptions{hideLegends: true})
}

func transformDashboardJSON(jsonBytes []byte, options renderOptions) ([]byte, error) {
	var dashboardJSON any
	if err := json.Unmarshal(jsonBytes, &dashboardJSON); err != nil {
		return nil, err
	}
	transformDashboardValue(dashboardJSON, options)
	if options.compactPanelHeight {
		compactDashboardGrid(dashboardJSON)
	}
	return json.MarshalIndent(dashboardJSON, "", "  ")
}

func transformDashboardValue(value any, options renderOptions) {
	transformDashboardValueInPanel(value, options, nil)
}

// transformDashboardValueInPanel carries the owning panel through nested
// objects. Grafana stores a time-series legend at panel.options.legend, while
// the panel's grid position remains on the parent object.
func transformDashboardValueInPanel(value any, options renderOptions, panel map[string]any) {
	switch v := value.(type) {
	case map[string]any:
		if _, ok := v["gridPos"].(map[string]any); ok {
			panel = v
		}
		if legend, ok := v["legend"].(map[string]any); ok && options.hideLegends {
			legend["showLegend"] = false
			if options.compactPanelHeight && panel != nil {
				shrinkPanelHeight(panel)
			}
		}
		for _, child := range v {
			transformDashboardValueInPanel(child, options, panel)
		}
	case []any:
		for _, child := range v {
			transformDashboardValueInPanel(child, options, panel)
		}
	}
}

func shrinkPanelHeight(panel map[string]any) {
	gridPos, ok := panel["gridPos"].(map[string]any)
	if !ok {
		return
	}
	if _, alreadyShrunk := gridPos["_renderingOriginalHeight"]; alreadyShrunk {
		return
	}
	height, ok := gridPos["h"].(float64)
	if !ok || height <= renderingPanelHeightReduction {
		return
	}
	gridPos["_renderingOriginalHeight"] = height
	gridPos["h"] = height - renderingPanelHeightReduction
}

// compactDashboardGrid removes the vertical space freed by shrinking panels.
// Each original grid row keeps its relative layout and intentional gaps.
func compactDashboardGrid(value any) {
	switch v := value.(type) {
	case map[string]any:
		if panels, ok := v["panels"].([]any); ok {
			compactPanels(panels)
		}
		for _, child := range v {
			compactDashboardGrid(child)
		}
	case []any:
		for _, child := range v {
			compactDashboardGrid(child)
		}
	}
}

func compactPanels(panels []any) {
	type gridRow struct {
		originalY      float64
		originalHeight float64
		compactHeight  float64
		panels         []map[string]any
	}

	rowsByY := make(map[float64]*gridRow)
	var rows []*gridRow
	for _, value := range panels {
		panel, ok := value.(map[string]any)
		if !ok {
			continue
		}
		gridPos, ok := panel["gridPos"].(map[string]any)
		if !ok {
			continue
		}
		y, yOK := gridPos["y"].(float64)
		h, hOK := gridPos["h"].(float64)
		if !yOK || !hOK {
			continue
		}
		row := rowsByY[y]
		if row == nil {
			row = &gridRow{originalY: y}
			rowsByY[y] = row
			rows = append(rows, row)
		}
		row.panels = append(row.panels, panel)
		row.compactHeight = max(row.compactHeight, h)
		if originalHeight, ok := gridPos["_renderingOriginalHeight"].(float64); ok {
			h = originalHeight
			delete(gridPos, "_renderingOriginalHeight")
		}
		row.originalHeight = max(row.originalHeight, h)
	}

	sort.Slice(rows, func(i, j int) bool { return rows[i].originalY < rows[j].originalY })
	var previousOriginalBottom, compactY float64
	for i, row := range rows {
		if i == 0 {
			compactY = row.originalY
		} else {
			compactY += max(0, row.originalY-previousOriginalBottom)
		}
		for _, panel := range row.panels {
			panel["gridPos"].(map[string]any)["y"] = compactY
		}
		previousOriginalBottom = max(previousOriginalBottom, row.originalY+row.originalHeight)
		compactY += row.compactHeight
	}
}
