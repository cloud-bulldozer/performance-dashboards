import json
import logging
import os
import requests
import uuid
import time
from collections import defaultdict

logging.basicConfig(level=logging.INFO)


class GrafanaOperations:
    """
    This class is responsible for Grafana operations
    """
    def __init__(self, grafana_url: str, input_directory: str, git_commit_hash: str):
        self.grafana_url = grafana_url
        self.input_directory = input_directory
        self.git_commit_hash = git_commit_hash if git_commit_hash else ''
        self.dashboards = defaultdict(list)
        self.folder_map = dict()
        self.logger = logging.getLogger(__name__)

    def fetch_all_dashboards(self):
        """
        This method fetches all rendered dashboards
        :return:
        """
        self.get_all_folders()
        self.folder_map['General'] = None
        for root, _, files in os.walk(self.input_directory):
            folder_name = os.path.basename(root)
            json_files = [os.path.join(root, filename) for filename in files if filename.endswith(".json")]
            folder_name = "General" if (folder_name == "") else folder_name
            if folder_name in self.folder_map:
                folder_id = self.folder_map[folder_name]
            else:
                folder_id = self.create_folder(folder_name)
            self.dashboards[folder_id].extend(json_files)
    
    def get_all_folders(self):
        """
        This method gets the entire list of folders in grafana
        :return:
        """
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        try:
            response = requests.get(
                f"{self.grafana_url}/api/folders", 
                headers=headers,
            )
            response_json = response.json()
            self.folder_map = {each_folder['title']: each_folder['id'] for each_folder in response_json}
        except requests.exceptions.RequestException as e:
            raise Exception(f"Error listing folders. Message: {e}")

    def create_folder(self, folder_name):
        """
        This method creates a folder in grafana
        :return:
        """
        uid = str(uuid.uuid4())
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        try:
            response = requests.post(
                f"{self.grafana_url}/api/folders", 
                headers=headers,
                json={
                    "title": folder_name,
                    "uid": uid,
                },
            )
            response_json = response.json()
            self.folder_map[folder_name] = id
            return response_json['id']

        except requests.exceptions.RequestException as e:
            raise Exception(f"Error creating folder with name:'{self.folder_name}' and uid:'{uid}'. Message: {e}")

    def read_dashboard_json(self, json_file):
        """
        This method reads dashboard from json file
        :return:
        """
        with open(json_file, 'r') as f:
            return json.load(f)

    def create_dashboards(self):
        """
        This method creates/updates dashboard with new json
        :return:
        """
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
        }
        for folder_id, files in self.dashboards.items():
            for json_file in set(files):
                dashboard_json = self.read_dashboard_json(json_file)
                if "tags" in dashboard_json.keys():
                    dashboard_json["tags"].append(self.git_commit_hash)
                else:
                    dashboard_json["tags"] = [self.git_commit_hash]
                try:
                    response = requests.post(
                        f"{self.grafana_url}/api/dashboards/db",
                        headers=headers,
                        json={
                            "dashboard": dashboard_json,
                            "folderId": folder_id,
                            "overwrite": True,
                        },
                    )
                    if response.status_code == 200:
                        self.logger.info(f"Dashboard '{dashboard_json['title']}' created successfully in folder '{folder_id}'")
                    else:
                        raise Exception(
                            f"Failed to create dashboard '{dashboard_json['title']}' in folder '{folder_id}'. Status code: {response.status_code}. Message: {response.text}")

                except requests.exceptions.RequestException as e:
                    raise Exception(f"Error creating dashboard '{dashboard_json['title']}' in folder '{folder_id}'. Message: {e}")

if __name__ == '__main__':
    grafana_operations = GrafanaOperations(os.environ.get("GRAFANA_URL"), os.environ.get("INPUT_DIR"), os.environ.get("GIT_COMMIT_HASH"))
    grafana_operations.fetch_all_dashboards()
    grafana_operations.create_dashboards()
    while True:
        time.sleep(60)
