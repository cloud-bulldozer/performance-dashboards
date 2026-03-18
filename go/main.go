package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/grafana/grafana-foundation-sdk/go/dashboard"
)

type dashboardDef struct {
	name     string
	category string
	builder  func() *dashboard.DashboardBuilder
}

var dashboards = []dashboardDef{
	{"vegeta-wrapper", "General", buildVegetaDashboard},
	{"uperf-perf", "General", buildUperfDashboard},
	{"ocp-performance", "General", buildOCPPerformanceDashboard},
	{"etcd-on-cluster-dashboard", "General", buildEtcdDashboard},
}

func main() {
	outputDir := "rendered"

	for _, d := range dashboards {
		built, err := d.builder().Build()
		if err != nil {
			fmt.Fprintf(os.Stderr, "error building dashboard %s/%s: %v\n", d.category, d.name, err)
			os.Exit(1)
		}

		jsonBytes, err := json.MarshalIndent(built, "", "  ")
		if err != nil {
			fmt.Fprintf(os.Stderr, "error marshaling dashboard %s/%s: %v\n", d.category, d.name, err)
			os.Exit(1)
		}

		dir := filepath.Join(outputDir, d.category)
		if err := os.MkdirAll(dir, 0o755); err != nil {
			fmt.Fprintf(os.Stderr, "error creating directory %s: %v\n", dir, err)
			os.Exit(1)
		}

		outPath := filepath.Join(dir, d.name+".json")
		if err := os.WriteFile(outPath, jsonBytes, 0o644); err != nil {
			fmt.Fprintf(os.Stderr, "error writing %s: %v\n", outPath, err)
			os.Exit(1)
		}

		fmt.Printf("wrote %s\n", outPath)
	}
}
