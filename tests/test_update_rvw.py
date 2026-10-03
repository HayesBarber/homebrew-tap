"""Run from the repository root:

python3 -m unittest discover -s tests -v
"""

import copy
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from urllib.error import HTTPError, URLError

SCRIPT = Path(__file__).resolve().parent.parent / "scripts" / "update-rvw.py"
SPEC = importlib.util.spec_from_file_location("update_rvw", SCRIPT)
updater = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(updater)
SHA = "a" * 64
RELEASE = {
    "tag_name": "v1.0.0-beta.4",
    "assets": [{"name": "Rvw-1.0.0-beta.4.zip", "digest": "sha256:" + SHA}],
}
CASK = (
    'cask "rvw" do\r\n'
    '  version "1.0.0-beta.3" # Keep this comment\r\n'
    '  sha256 "' + "b" * 64 + '"\r\n'
    '  url "https://example.com/Rvw-#{version}.zip"\r\n'
    "end\r\n"
).encode()


class UpdateTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.cask = Path(self.directory.name) / "rvw.rb"
        self.cask.write_bytes(CASK)
        self.cask.chmod(0o644)
        self.path_patch = patch.object(updater, "CASK_PATH", self.cask)
        self.path_patch.start()
        self.addCleanup(self.path_patch.stop)

    def run_main(self, release=RELEASE, args=None):
        with patch.object(updater, "fetch_release", return_value=release), patch(
            "sys.stdout", new_callable=io.StringIO
        ), patch("sys.stderr", new_callable=io.StringIO):
            return updater.main(args or [])

    def test_update_preserves_other_content_and_mode(self):
        self.assertEqual(self.run_main(), 0)
        expected = CASK.replace(b"1.0.0-beta.3", b"1.0.0-beta.4").replace(
            b"b" * 64, SHA.encode()
        )
        self.assertEqual(self.cask.read_bytes(), expected)
        self.assertEqual(self.cask.stat().st_mode & 0o777, 0o644)
        self.assertEqual(list(self.cask.parent.iterdir()), [self.cask])

    def test_current_cask_is_not_written(self):
        self.assertEqual(self.run_main(), 0)
        with patch.object(updater, "atomic_write") as write:
            self.assertEqual(self.run_main(), 0)
            write.assert_not_called()

    def test_dry_run(self):
        with patch.object(updater, "atomic_write") as write:
            self.assertEqual(self.run_main(args=["--dry-run"]), 0)
            write.assert_not_called()
        self.assertEqual(self.cask.read_bytes(), CASK)

    def test_invalid_releases_leave_cask_unchanged(self):
        cases = [None, {}, {"tag_name": "../bad"}, {"tag_name": "1.0.0"}]
        for digest in (None, "", "sha256:abc", "sha512:" + SHA, "sha256:" + "g" * 64):
            release = copy.deepcopy(RELEASE)
            release["assets"][0]["digest"] = digest
            cases.append(release)
        for assets in (
            [],
            None,
            [RELEASE["assets"][0]] * 2,
            [{"name": "Rvw-1.0.0-beta.4.zip.sha256", "digest": "sha256:" + SHA}],
        ):
            cases.append(dict(RELEASE, assets=assets))
        cases.extend([dict(RELEASE, draft=True), dict(RELEASE, prerelease=True)])
        for release in cases:
            with self.subTest(release=release):
                self.assertEqual(self.run_main(release), 1)
                self.assertEqual(self.cask.read_bytes(), CASK)

    def test_invalid_cask_declarations_leave_file_unchanged(self):
        for content in (
            CASK.replace(b'  version "1.0.0-beta.3" # Keep this comment\r\n', b""),
            CASK + b'  version "2.0.0"\r\n',
            CASK.replace(b'  sha256 "' + b"b" * 64 + b'"', b"  sha256 :no_check"),
            CASK + b'  sha256 "' + b"c" * 64 + b'"\r\n',
        ):
            with self.subTest(content=content):
                self.cask.write_bytes(content)
                self.assertEqual(self.run_main(), 1)
                self.assertEqual(self.cask.read_bytes(), content)

    def test_api_errors_leave_cask_unchanged(self):
        errors = [
            HTTPError(updater.API_URL, 403, "Forbidden", {}, None),
            URLError("Connection failed"),
            TimeoutError("Timed out"),
        ]
        for error in errors:
            with self.subTest(error=error), patch.object(
                updater, "urlopen", side_effect=error
            ), patch("sys.stderr", new_callable=io.StringIO):
                self.assertEqual(updater.main([]), 1)
                self.assertEqual(self.cask.read_bytes(), CASK)

    def test_atomic_replace_failure_leaves_cask_unchanged(self):
        with patch.object(
            updater.os, "replace", side_effect=OSError("Cannot replace file")
        ):
            self.assertEqual(self.run_main(), 1)
        self.assertEqual(self.cask.read_bytes(), CASK)
        self.assertEqual(list(self.cask.parent.iterdir()), [self.cask])

    def test_uppercase_digest_is_normalized(self):
        release = copy.deepcopy(RELEASE)
        release["assets"][0]["digest"] = "sha256:" + SHA.upper()
        self.assertEqual(updater.release_values(release), ("1.0.0-beta.4", SHA))

    def test_api_request(self):
        with patch.dict("os.environ", {"GITHUB_TOKEN": "test-token"}), patch.object(
            updater, "urlopen", return_value=io.BytesIO(json.dumps(RELEASE).encode())
        ) as request:
            self.assertEqual(updater.fetch_release(), RELEASE)
        args, kwargs = request.call_args
        self.assertEqual(args[0].full_url, updater.API_URL)
        self.assertEqual(args[0].get_header("Authorization"), "Bearer test-token")
        self.assertEqual(kwargs["timeout"], 30)

    def test_invalid_json(self):
        with patch.object(updater, "urlopen", return_value=io.BytesIO(b"not JSON")):
            with self.assertRaisesRegex(ValueError, "invalid JSON"):
                updater.fetch_release()


if __name__ == "__main__":
    unittest.main()
