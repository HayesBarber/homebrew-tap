#!/usr/bin/env python3
"""Update the rvw cask from the latest GitHub release."""

import argparse
import json
import os
from pathlib import Path
import re
import stat
import sys
import tempfile
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

API_URL = "https://api.github.com/repos/HayesBarber/rvw/releases/latest"
CASK_PATH = Path(__file__).resolve().parent.parent / "Casks" / "rvw.rb"
TAG_PATTERN = re.compile(
    r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"
    r"(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
)


def fetch_release():
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "homebrew-tap-update-rvw",
    }
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = "Bearer " + token
    try:
        with urlopen(Request(API_URL, headers=headers), timeout=30) as response:
            release = json.load(response)
    except HTTPError as error:
        raise ValueError("GitHub API returned HTTP {}".format(error.code)) from error
    except URLError as error:
        raise ValueError(
            "Cannot connect to GitHub API: {}".format(error.reason)
        ) from error
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        raise ValueError("GitHub API returned invalid JSON") from error
    return release


def release_values(release):
    if not isinstance(release, dict):
        raise ValueError("GitHub API returned an invalid release")
    tag = release.get("tag_name")
    if not isinstance(tag, str) or not TAG_PATTERN.fullmatch(tag):
        raise ValueError(
            "Release tag must use vMAJOR.MINOR.PATCH with optional suffixes"
        )
    if release.get("draft") or release.get("prerelease"):
        raise ValueError("GitHub Latest returned a draft or prerelease")
    version = tag[1:]
    name = "Rvw-{}.zip".format(version)
    assets = release.get("assets")
    if not isinstance(assets, list):
        raise ValueError("Release assets are absent or invalid")
    matches = [
        asset
        for asset in assets
        if isinstance(asset, dict) and asset.get("name") == name
    ]
    if len(matches) != 1:
        raise ValueError("Release must contain exactly one {} asset".format(name))
    digest = matches[0].get("digest")
    if not isinstance(digest, str) or not re.fullmatch(
        r"sha256:[0-9a-fA-F]{64}", digest
    ):
        raise ValueError("{} has an absent or invalid SHA-256 digest".format(name))
    return version, digest[7:].lower()


def replace_values(content, version, sha256):
    for field, value in (("version", version), ("sha256", sha256)):
        declarations = list(
            re.finditer(r"^[ \t]*" + field + r"\b[^\r\n]*", content, re.MULTILINE)
        )
        if len(declarations) != 1:
            raise ValueError(
                "Cask must contain exactly one {} declaration".format(field)
            )
        declaration = declarations[0]
        quoted = re.fullmatch(
            r"[ \t]*" + field + r'[ \t]+"([^"\r\n]*)"[ \t]*(?:#.*)?',
            declaration.group(),
        )
        if quoted is None:
            raise ValueError(
                "Cask {} declaration must contain one quoted value".format(field)
            )
        start = declaration.start() + quoted.start(1)
        end = declaration.start() + quoted.end(1)
        content = content[:start] + value + content[end:]
    return content


def atomic_write(path, content):
    mode = stat.S_IMODE(path.stat().st_mode)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(
            dir=path.parent, prefix=".rvw-", delete=False
        ) as file:
            temporary = Path(file.name)
            file.write(content)
            file.flush()
            os.fsync(file.fileno())
            os.fchmod(file.fileno(), mode)
        os.replace(temporary, path)
    finally:
        if temporary is not None and temporary.exists():
            temporary.unlink()


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dry-run", action="store_true", help="Show values without changing the cask"
    )
    args = parser.parse_args(argv)
    try:
        original = CASK_PATH.read_bytes()
        version, sha256 = release_values(fetch_release())
        updated = replace_values(original.decode("utf-8"), version, sha256).encode(
            "utf-8"
        )
        print('version "{}"'.format(version))
        print('sha256 "{}"'.format(sha256))
        if updated == original:
            print("The rvw cask is current.")
        elif args.dry_run:
            print("Dry run: the rvw cask was not changed.")
        else:
            atomic_write(CASK_PATH, updated)
            print("The rvw cask was updated.")
    except (ValueError, OSError) as error:
        print("Error: {}".format(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
