package main

import (
	"os"
	"path/filepath"
	"testing"

	"gopkg.in/yaml.v3"
)

func writeProfileFile(t *testing.T, dir string, name string, entries []profileEntry) string {
	t.Helper()
	data, err := yaml.Marshal(entries)
	if err != nil {
		t.Fatalf("marshal: %v", err)
	}
	path := filepath.Join(dir, name)
	if err := os.WriteFile(path, data, 0o644); err != nil {
		t.Fatalf("write %s: %v", path, err)
	}
	return path
}

func readMergedFile(t *testing.T, path string) []profileEntry {
	t.Helper()
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read %s: %v", path, err)
	}
	var entries []profileEntry
	if err := yaml.Unmarshal(data, &entries); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	return entries
}

func TestMergeProfileFiles_BasicMerge(t *testing.T) {
	dir := t.TempDir()
	a := writeProfileFile(t, dir, "a.yaml", []profileEntry{
		{Query: "foo", MetricName: "foo"},
		{Query: "bar", MetricName: "bar"},
	})
	b := writeProfileFile(t, dir, "b.yaml", []profileEntry{
		{Query: "baz", MetricName: "baz"},
	})
	out := filepath.Join(dir, "merged.yaml")

	if err := mergeProfileFiles([]string{a, b}, out); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	got := readMergedFile(t, out)
	if len(got) != 3 {
		t.Fatalf("want 3 entries, got %d: %v", len(got), got)
	}
}

func TestMergeProfileFiles_Deduplicated(t *testing.T) {
	dir := t.TempDir()
	a := writeProfileFile(t, dir, "a.yaml", []profileEntry{
		{Query: "foo", MetricName: "foo"},
		{Query: "bar", MetricName: "bar"},
	})
	b := writeProfileFile(t, dir, "b.yaml", []profileEntry{
		{Query: "bar", MetricName: "bar"}, // duplicate
		{Query: "baz", MetricName: "baz"},
	})
	out := filepath.Join(dir, "merged.yaml")

	if err := mergeProfileFiles([]string{a, b}, out); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	got := readMergedFile(t, out)
	if len(got) != 3 {
		t.Fatalf("want 3 entries after dedup, got %d: %v", len(got), got)
	}

	seen := map[string]int{}
	for _, e := range got {
		seen[e.MetricName]++
	}
	for name, count := range seen {
		if count > 1 {
			t.Errorf("metric %q appears %d times (want 1)", name, count)
		}
	}
}

func TestMergeProfileFiles_SortedAlphabetically(t *testing.T) {
	dir := t.TempDir()
	a := writeProfileFile(t, dir, "a.yaml", []profileEntry{
		{Query: "zzz", MetricName: "zzz"},
		{Query: "aaa", MetricName: "aaa"},
	})
	b := writeProfileFile(t, dir, "b.yaml", []profileEntry{
		{Query: "mmm", MetricName: "mmm"},
	})
	out := filepath.Join(dir, "merged.yaml")

	if err := mergeProfileFiles([]string{a, b}, out); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	got := readMergedFile(t, out)
	want := []string{"aaa", "mmm", "zzz"}
	for i, e := range got {
		if e.MetricName != want[i] {
			t.Errorf("entry[%d] = %q, want %q", i, e.MetricName, want[i])
		}
	}
}

func TestMergeProfileFiles_PreservesInstantAndCaptureStart(t *testing.T) {
	dir := t.TempDir()
	a := writeProfileFile(t, dir, "a.yaml", []profileEntry{
		{Query: "foo", MetricName: "foo", Instant: true, CaptureStart: true},
	})
	out := filepath.Join(dir, "merged.yaml")

	if err := mergeProfileFiles([]string{a}, out); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	got := readMergedFile(t, out)
	if len(got) != 1 {
		t.Fatalf("want 1 entry, got %d", len(got))
	}
	if !got[0].Instant {
		t.Error("Instant field not preserved")
	}
	if !got[0].CaptureStart {
		t.Error("CaptureStart field not preserved")
	}
}

func TestMergeProfileFiles_NoInputs(t *testing.T) {
	dir := t.TempDir()
	out := filepath.Join(dir, "merged.yaml")

	if err := mergeProfileFiles(nil, out); err == nil {
		t.Fatal("expected error for empty inputs, got nil")
	}
}

func TestMergeProfileFiles_MissingInput(t *testing.T) {
	dir := t.TempDir()
	out := filepath.Join(dir, "merged.yaml")

	if err := mergeProfileFiles([]string{"/nonexistent/file.yaml"}, out); err == nil {
		t.Fatal("expected error for missing input file, got nil")
	}
}

func TestMergeProfileFiles_RealDashboardOutputs(t *testing.T) {
	ocpRaw := "rendered/General/ocp-performance-raw-metrics.yaml"
	etcdRaw := "rendered/General/etcd-on-cluster-dashboard-raw-metrics.yaml"
	for _, f := range []string{ocpRaw, etcdRaw} {
		if _, err := os.Stat(f); err != nil {
			t.Skipf("rendered output not found (%s), run go run . first", f)
		}
	}

	out := filepath.Join(t.TempDir(), "combined-raw.yaml")
	if err := mergeProfileFiles([]string{ocpRaw, etcdRaw}, out); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	got := readMergedFile(t, out)
	if len(got) == 0 {
		t.Fatal("merged file is empty")
	}

	// No duplicates.
	seen := map[string]int{}
	for _, e := range got {
		seen[e.MetricName]++
	}
	for name, count := range seen {
		if count > 1 {
			t.Errorf("duplicate in merged output: %q appears %d times", name, count)
		}
	}

	// Entries from both files must survive.
	byName := make(map[string]struct{}, len(got))
	for _, e := range got {
		byName[e.MetricName] = struct{}{}
	}
	mustHave := []string{
		"container_cpu_usage_seconds_total", // OCP
		"node_cpu_seconds_total",            // OCP
		"etcd_server_has_leader",            // etcd
		"etcd_mvcc_db_total_size_in_bytes",  // etcd
	}
	for _, m := range mustHave {
		if _, ok := byName[m]; !ok {
			t.Errorf("expected metric %q missing from merged output", m)
		}
	}
}
