package main

import (
	"fmt"
	"os"
	"sort"

	"gopkg.in/yaml.v3"
)

type profileEntry struct {
	Query        string `yaml:"query"`
	MetricName   string `yaml:"metricName"`
	Instant      bool   `yaml:"instant,omitempty"`
	CaptureStart bool   `yaml:"captureStart,omitempty"`
}

// mergeProfileFiles merges and deduplicates metrics profile YAML files.
// Deduplication key is metricName. Output is sorted alphabetically.
func mergeProfileFiles(inputs []string, output string) error {
	if len(inputs) == 0 {
		return fmt.Errorf("no input files specified")
	}

	seen := map[string]struct{}{}
	var merged []profileEntry

	for _, path := range inputs {
		data, err := os.ReadFile(path)
		if err != nil {
			return fmt.Errorf("reading %s: %w", path, err)
		}
		var entries []profileEntry
		if err := yaml.Unmarshal(data, &entries); err != nil {
			return fmt.Errorf("parsing %s: %w", path, err)
		}
		for _, e := range entries {
			if _, dup := seen[e.MetricName]; dup {
				continue
			}
			seen[e.MetricName] = struct{}{}
			merged = append(merged, e)
		}
	}

	sort.Slice(merged, func(i, j int) bool {
		return merged[i].MetricName < merged[j].MetricName
	})

	out, err := yaml.Marshal(merged)
	if err != nil {
		return fmt.Errorf("marshaling: %w", err)
	}
	if err := os.WriteFile(output, out, 0o644); err != nil {
		return fmt.Errorf("writing %s: %w", output, err)
	}
	fmt.Printf("wrote %s (%d entries from %d files)\n", output, len(merged), len(inputs))
	return nil
}
