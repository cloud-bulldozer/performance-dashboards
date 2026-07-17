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

type ruleEntry struct {
	Record string `yaml:"record"`
	Expr   string `yaml:"expr"`
}

type ruleGroup struct {
	Name  string      `yaml:"name"`
	Rules []ruleEntry `yaml:"rules"`
}

type rulesFile struct {
	Groups []ruleGroup `yaml:"groups"`
}

// mergeFiles merges and deduplicates YAML files, auto-detecting format
// (metrics profile or prometheus rules). Dedup key is metricName / record.
// Output sorted alphabetically.
func mergeFiles(inputs []string, output string) error {
	if len(inputs) == 0 {
		return fmt.Errorf("no input files specified")
	}

	data, err := os.ReadFile(inputs[0])
	if err != nil {
		return fmt.Errorf("reading %s: %w", inputs[0], err)
	}
	var probe rulesFile
	if err := yaml.Unmarshal(data, &probe); err == nil && len(probe.Groups) > 0 {
		return mergeRulesFiles(inputs, output)
	}
	return mergeProfileFiles(inputs, output)
}

// mergeProfileFiles merges and deduplicates metrics profile YAML files.
// Deduplication key is metricName. Output is sorted alphabetically.
func mergeProfileFiles(inputs []string, output string) error {
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

// mergeRulesFiles merges and deduplicates prometheus rules YAML files.
// Deduplication key is record name. Output sorted alphabetically, single group named "merged".
func mergeRulesFiles(inputs []string, output string) error {
	seen := map[string]struct{}{}
	var merged []ruleEntry

	for _, path := range inputs {
		data, err := os.ReadFile(path)
		if err != nil {
			return fmt.Errorf("reading %s: %w", path, err)
		}
		var rf rulesFile
		if err := yaml.Unmarshal(data, &rf); err != nil {
			return fmt.Errorf("parsing %s: %w", path, err)
		}
		for _, g := range rf.Groups {
			for _, r := range g.Rules {
				if _, dup := seen[r.Record]; dup {
					continue
				}
				seen[r.Record] = struct{}{}
				merged = append(merged, r)
			}
		}
	}

	sort.Slice(merged, func(i, j int) bool {
		return merged[i].Record < merged[j].Record
	})

	out, err := yaml.Marshal(rulesFile{
		Groups: []ruleGroup{{Name: "merged", Rules: merged}},
	})
	if err != nil {
		return fmt.Errorf("marshaling: %w", err)
	}
	if err := os.WriteFile(output, out, 0o644); err != nil {
		return fmt.Errorf("writing %s: %w", output, err)
	}
	fmt.Printf("wrote %s (%d rules from %d files)\n", output, len(merged), len(inputs))
	return nil
}
