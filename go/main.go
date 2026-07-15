package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
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

var dashboards = []dashboardDef{
	{"vegeta-wrapper", "General", buildVegetaDashboard, nil},
	{"uperf-perf", "General", buildUperfDashboard, nil},
	{"ocp-performance", "General", buildOCPPerformanceDashboard, buildOCPProfiles},
	{"ocp-performance-collected", "General", buildOCPCollectedDashboard, nil},
	{"etcd-on-cluster-dashboard", "General", buildEtcdDashboard, buildEtcdProfiles},
	{"ovn-dashboard", "General", buildOVNDashboard, nil},
	{"api-performance-overview", "General", buildAPIPerformanceDashboard, nil},
	{"node", "General", buildNodeDashboard, nil},
}

func envDefault(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func main() {
	mergeOutput := flag.String("merge", "", "Merge input profile YAML files into this output path (positional args are inputs)")
	deployFlag := flag.Bool("deploy", false, "Deploy rendered dashboards to Grafana")
	loopFlag := flag.Bool("loop", false, "Run deploy in a loop (sidecar mode)")
	loopInterval := flag.Duration("loop-interval", 60*time.Second, "Interval between deploy loops")
	grafanaURL := flag.String("grafana-url", envDefault("GRAFANA_URL", ""), "Grafana URL (e.g. http://admin:pass@localhost:3000)")
	inputDir := flag.String("input-dir", envDefault("INPUT_DIR", ""), "Directory with pre-rendered JSON (skips rendering)")
	outputDir := flag.String("output-dir", envDefault("OUTPUT_DIR", "rendered"), "Directory to write rendered dashboard JSON")
	gitCommitHash := flag.String("git-commit-hash", envDefault("GIT_COMMIT_HASH", ""), "Git commit hash to append to dashboard tags")
	flag.Parse()

	if *mergeOutput != "" {
		if err := mergeProfileFiles(flag.Args(), *mergeOutput); err != nil {
			fmt.Fprintf(os.Stderr, "error: %v\n", err)
			os.Exit(1)
		}
		return
	}

	if *inputDir == "" {
		renderDashboards(*outputDir)
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

func renderDashboards(outputDir string) {
	for _, d := range dashboards {
		jsonBytes := buildDashboardToJson(d)

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

func buildDashboardToJson(d dashboardDef) []byte {
	built, err := d.builder().Build()
	if err != nil {
		fmt.Fprintf(os.Stderr, "error building dashboard %s/%s: %v\n", d.category, d.name, err)
	}

	jsonBytes, err := json.MarshalIndent(built, "", "  ")
	if err != nil {
		fmt.Fprintf(os.Stderr, "error marshaling dashboard %s/%s: %v\n", d.category, d.name, err)
	}
	return jsonBytes
}
