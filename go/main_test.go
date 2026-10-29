package main

import (
	"encoding/json"
	"testing"
)

func TestHideLegendsInJSON(t *testing.T) {
	input := []byte(`{
  "panels": [
    {"legend": {"showLegend": true, "placement": "bottom"}},
    {"options": {"legend": {"showLegend": true}}},
    {"type": "stat"}
  ]
}`)

	output, err := hideLegendsInJSON(input)
	if err != nil {
		t.Fatalf("hideLegendsInJSON returned an error: %v", err)
	}

	var dashboardJSON map[string]any
	if err := json.Unmarshal(output, &dashboardJSON); err != nil {
		t.Fatalf("unmarshal output: %v", err)
	}
	panels := dashboardJSON["panels"].([]any)
	if got := panels[0].(map[string]any)["legend"].(map[string]any)["showLegend"]; got != false {
		t.Errorf("top-level legend showLegend = %v, want false", got)
	}
	if got := panels[1].(map[string]any)["options"].(map[string]any)["legend"].(map[string]any)["showLegend"]; got != false {
		t.Errorf("nested legend showLegend = %v, want false", got)
	}
}

func TestRenderingDashboardCompactsLegendPanels(t *testing.T) {
	input := []byte(`{
  "panels": [
    {"gridPos": {"h": 8, "y": 0}, "options": {"legend": {"showLegend": true}}},
    {"gridPos": {"h": 8, "y": 8}, "options": {"legend": {"showLegend": true}}},
    {"gridPos": {"h": 1, "y": 16}, "type": "row"}
  ]
}`)

	output, err := transformDashboardJSON(input, renderOptions{hideLegends: true, compactPanelHeight: true})
	if err != nil {
		t.Fatalf("transformDashboardJSON returned an error: %v", err)
	}

	var dashboardJSON map[string]any
	if err := json.Unmarshal(output, &dashboardJSON); err != nil {
		t.Fatalf("unmarshal output: %v", err)
	}
	panels := dashboardJSON["panels"].([]any)
	assertGridPos := func(index int, wantHeight, wantY float64) {
		t.Helper()
		gridPos := panels[index].(map[string]any)["gridPos"].(map[string]any)
		if got := gridPos["h"]; got != wantHeight {
			t.Errorf("panel %d height = %v, want %v", index, got, wantHeight)
		}
		if got := gridPos["y"]; got != wantY {
			t.Errorf("panel %d y = %v, want %v", index, got, wantY)
		}
	}
	assertGridPos(0, 6, 0)
	assertGridPos(1, 6, 6)
	assertGridPos(2, 1, 12)
	for i := 0; i < 2; i++ {
		legend := panels[i].(map[string]any)["options"].(map[string]any)["legend"].(map[string]any)
		if got := legend["showLegend"]; got != false {
			t.Errorf("panel %d legend showLegend = %v, want false", i, got)
		}
	}
}
