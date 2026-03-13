import hashlib
import json
import os
import tempfile
import unittest
from unittest.mock import MagicMock, patch

from entrypoint import GrafanaOperations, generate_deterministic_uid


class TestGenerateDeterministicUID(unittest.TestCase):
    """Tests for the generate_deterministic_uid function."""

    def _expected_uid(self, name, prefix=""):
        hash_input = f"{prefix}{name}".encode("utf-8")
        return hashlib.sha256(hash_input).hexdigest()[:8]

    def test_returns_eight_characters(self):
        uid = generate_deterministic_uid("My Dashboard")
        self.assertEqual(len(uid), 8)

    def test_deterministic_same_input_same_output(self):
        uid1 = generate_deterministic_uid("My Dashboard", "dashboard-")
        uid2 = generate_deterministic_uid("My Dashboard", "dashboard-")
        self.assertEqual(uid1, uid2)

    def test_different_names_produce_different_uids(self):
        uid1 = generate_deterministic_uid("Dashboard A", "dashboard-")
        uid2 = generate_deterministic_uid("Dashboard B", "dashboard-")
        self.assertNotEqual(uid1, uid2)

    def test_prefix_changes_uid(self):
        uid_no_prefix = generate_deterministic_uid("MyName")
        uid_with_prefix = generate_deterministic_uid("MyName", "dashboard-")
        self.assertNotEqual(uid_no_prefix, uid_with_prefix)

    def test_dashboard_prefix_matches_expected_hash(self):
        name = "OCP Performance"
        uid = generate_deterministic_uid(name, "dashboard-")
        self.assertEqual(uid, self._expected_uid(name, "dashboard-"))

    def test_folder_prefix_matches_expected_hash(self):
        name = "General"
        uid = generate_deterministic_uid(name, "folder-")
        self.assertEqual(uid, self._expected_uid(name, "folder-"))

    def test_empty_name_returns_eight_characters(self):
        uid = generate_deterministic_uid("", "dashboard-")
        self.assertEqual(len(uid), 8)

    def test_uid_is_lowercase_hex(self):
        uid = generate_deterministic_uid("Test Dashboard", "dashboard-")
        self.assertRegex(uid, r'^[0-9a-f]{8}$')


class TestCreateDashboardsUID(unittest.TestCase):
    """Tests that create_dashboards assigns a deterministic UID derived from the dashboard title."""

    def _write_dashboard_json(self, directory, filename, content):
        path = os.path.join(directory, filename)
        with open(path, "w") as f:
            json.dump(content, f)
        return path

    def _make_grafana_ops(self):
        return GrafanaOperations(
            grafana_url="http://fake-grafana",
            input_directory="/fake/dir",
            git_commit_hash="abc123",
        )

    @patch("entrypoint.requests.post")
    def test_uid_set_from_title(self, mock_post):
        mock_post.return_value = MagicMock(status_code=200)

        ops = self._make_grafana_ops()

        with tempfile.TemporaryDirectory() as tmpdir:
            dashboard = {"title": "OCP Performance", "panels": []}
            path = self._write_dashboard_json(tmpdir, "ocp-performance.json", dashboard)
            ops.dashboards[1] = [path]
            ops.create_dashboards()

        posted_body = mock_post.call_args.kwargs["json"]
        uid_in_post = posted_body["dashboard"]["uid"]
        expected_uid = generate_deterministic_uid("OCP Performance", "dashboard-")
        self.assertEqual(uid_in_post, expected_uid)

    @patch("entrypoint.requests.post")
    def test_uid_is_deterministic_across_calls(self, mock_post):
        mock_post.return_value = MagicMock(status_code=200)

        ops = self._make_grafana_ops()

        with tempfile.TemporaryDirectory() as tmpdir:
            dashboard = {"title": "Node Metrics", "panels": []}
            path = self._write_dashboard_json(tmpdir, "node.json", dashboard)

            ops.dashboards[1] = [path]
            ops.create_dashboards()
            first_uid = mock_post.call_args.kwargs["json"]["dashboard"]["uid"]

            mock_post.reset_mock()
            ops.dashboards[1] = [path]
            ops.create_dashboards()
            second_uid = mock_post.call_args.kwargs["json"]["dashboard"]["uid"]

        self.assertEqual(first_uid, second_uid)

    @patch("entrypoint.requests.post")
    def test_different_titles_produce_different_uids(self, mock_post):
        mock_post.return_value = MagicMock(status_code=200)

        ops = self._make_grafana_ops()
        uids = []

        with tempfile.TemporaryDirectory() as tmpdir:
            for title in ("Dashboard Alpha", "Dashboard Beta"):
                dashboard = {"title": title}
                path = self._write_dashboard_json(tmpdir, f"{title}.json", dashboard)
                mock_post.reset_mock()
                ops.dashboards[1] = [path]
                ops.create_dashboards()
                uids.append(mock_post.call_args.kwargs["json"]["dashboard"]["uid"])

        self.assertNotEqual(uids[0], uids[1])

    @patch("entrypoint.requests.post")
    def test_uid_length_is_eight(self, mock_post):
        mock_post.return_value = MagicMock(status_code=200)

        ops = self._make_grafana_ops()

        with tempfile.TemporaryDirectory() as tmpdir:
            dashboard = {"title": "Short"}
            path = self._write_dashboard_json(tmpdir, "short.json", dashboard)
            ops.dashboards[1] = [path]
            ops.create_dashboards()

        uid = mock_post.call_args.kwargs["json"]["dashboard"]["uid"]
        self.assertEqual(len(uid), 8)


if __name__ == "__main__":
    unittest.main()
