package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
)

type deployer struct {
	grafanaURL    string
	inputDir      string
	gitCommitHash string
	folderMap     map[string]int // folder title -> folder id
}

func newDeployer(grafanaURL, inputDir, gitCommitHash string) *deployer {
	return &deployer{
		grafanaURL:    strings.TrimRight(grafanaURL, "/"),
		inputDir:      inputDir,
		gitCommitHash: gitCommitHash,
		folderMap:     make(map[string]int),
	}
}

func (d *deployer) deploy() error {
	if err := d.fetchFolders(); err != nil {
		return fmt.Errorf("fetching folders: %w", err)
	}

	dashboards, err := d.discoverDashboards()
	if err != nil {
		return fmt.Errorf("discovering dashboards: %w", err)
	}

	for folderID, files := range dashboards {
		for _, f := range files {
			if err := d.uploadDashboard(f, folderID); err != nil {
				return fmt.Errorf("uploading %s: %w", f, err)
			}
		}
	}
	return nil
}

func (d *deployer) fetchFolders() error {
	resp, err := http.Get(d.grafanaURL + "/api/folders")
	if err != nil {
		return fmt.Errorf("GET /api/folders: %w", err)
	}
	defer resp.Body.Close()

	var folders []struct {
		ID    int    `json:"id"`
		Title string `json:"title"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&folders); err != nil {
		return fmt.Errorf("decoding folders: %w", err)
	}

	for _, f := range folders {
		d.folderMap[f.Title] = f.ID
	}
	return nil
}

func (d *deployer) discoverDashboards() (map[int][]string, error) {
	result := make(map[int][]string)

	err := filepath.Walk(d.inputDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() || !strings.HasSuffix(path, ".json") {
			return nil
		}

		rel, _ := filepath.Rel(d.inputDir, path)
		parts := strings.SplitN(rel, string(filepath.Separator), 2)

		var folderName string
		if len(parts) == 2 {
			folderName = parts[0]
		} else {
			folderName = "General"
		}

		folderID, err := d.ensureFolder(folderName)
		if err != nil {
			return err
		}
		result[folderID] = append(result[folderID], path)
		return nil
	})
	return result, err
}

func (d *deployer) ensureFolder(name string) (int, error) {
	if name == "General" {
		return 0, nil
	}
	if id, ok := d.folderMap[name]; ok {
		return id, nil
	}
	return d.createFolder(name)
}

func (d *deployer) createFolder(name string) (int, error) {
	body, _ := json.Marshal(map[string]string{
		"title": name,
		"uid":   uuid.New().String(),
	})

	resp, err := http.Post(d.grafanaURL+"/api/folders", "application/json", bytes.NewReader(body))
	if err != nil {
		return 0, fmt.Errorf("POST /api/folders: %w", err)
	}
	defer resp.Body.Close()

	var result struct {
		ID int `json:"id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return 0, fmt.Errorf("decoding create-folder response: %w", err)
	}

	d.folderMap[name] = result.ID
	return result.ID, nil
}

func (d *deployer) uploadDashboard(jsonPath string, folderID int) error {
	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return err
	}

	var dash map[string]interface{}
	if err := json.Unmarshal(data, &dash); err != nil {
		return fmt.Errorf("parsing %s: %w", jsonPath, err)
	}

	// Remove id and set a stable uid derived from the title so Grafana
	// upserts instead of creating duplicates on each sync.
	delete(dash, "id")
	if title, ok := dash["title"].(string); ok && title != "" {
		dash["uid"] = uuid.NewSHA1(uuid.NameSpaceDNS, []byte(title)).String()
	}

	if d.gitCommitHash != "" {
		tags, _ := dash["tags"].([]interface{})
		dash["tags"] = append(tags, d.gitCommitHash)
	}

	payload, _ := json.Marshal(map[string]interface{}{
		"dashboard": dash,
		"folderId":  folderID,
		"overwrite": false,
	})

	resp, err := http.Post(d.grafanaURL+"/api/dashboards/db", "application/json", bytes.NewReader(payload))
	if err != nil {
		return fmt.Errorf("POST /api/dashboards/db: %w", err)
	}
	defer resp.Body.Close()

	title, _ := dash["title"].(string)

	if resp.StatusCode == http.StatusPreconditionFailed {
		log.Printf("skipped %q (already exists)", title)
		return nil
	}
	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("status %d: %s", resp.StatusCode, string(body))
	}

	log.Printf("deployed %q to folder %d", title, folderID)
	return nil
}
