#!/bin/bash

set -euo pipefail

FORMULA_NAME="${1:-srl}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FORMULA_PATH="${REPO_ROOT}/Formula/${FORMULA_NAME}.rb"

if [[ ! -f "$FORMULA_PATH" ]]; then
    echo "Formula not found: $FORMULA_PATH"
    exit 1
fi

HOMEPAGE=$(grep -E '^\s+homepage ' "$FORMULA_PATH" | sed 's/.*"\(.*\)"/\1/')
REPO_OWNER=$(echo "$HOMEPAGE" | sed -E 's|https?://github.com/([^/]+)/.*|\1|')
REPO_NAME=$(echo "$HOMEPAGE" | sed -E 's|https?://github.com/[^/]+/([^/]*).*|\1|')

if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Failed to extract GitHub owner/repo from homepage: $HOMEPAGE"
    exit 1
fi

echo "Formula:  $FORMULA_NAME"
echo "Repo:     $REPO_OWNER/$REPO_NAME"

API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"

TARBALL_FILE=""

cleanup() {
    if [[ -n "$TARBALL_FILE" && -f "$TARBALL_FILE" ]]; then
        echo "Cleaning up downloaded file..."
        rm -f "$TARBALL_FILE"
    fi
}

trap cleanup EXIT ERR

echo "Fetching latest release from GitHub API..."
API_RESPONSE=$(curl -s -w "\n%{http_code}" "$API_URL" 2>/dev/null) || {
    echo "Failed to connect to GitHub API"
    exit 1
}

HTTP_CODE=$(echo "$API_RESPONSE" | tail -n1)
JSON_BODY=$(echo "$API_RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" != "200" ]]; then
    echo "GitHub API returned HTTP $HTTP_CODE"
    exit 1
fi

LATEST_TAG=$(echo "$JSON_BODY" | jq -r '.tag_name // empty')

if [[ -z "$LATEST_TAG" || "$LATEST_TAG" == "null" ]]; then
    echo "Failed to parse latest tag from API response"
    exit 1
fi

echo "Found latest version: $LATEST_TAG"

TARBALL_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tarball/${LATEST_TAG}"
TARBALL_FILE="/tmp/${FORMULA_NAME}-${LATEST_TAG}.tar.gz"

echo "Downloading tarball..."
if ! curl -sL "$TARBALL_URL" -o "$TARBALL_FILE"; then
    echo "Failed to download tarball from $TARBALL_URL"
    exit 1
fi

echo "Computing SHA256..."
if command -v shasum >/dev/null 2>&1; then
    NEW_SHA=$(shasum -a 256 "$TARBALL_FILE" | cut -d' ' -f1)
else
    NEW_SHA=$(sha256sum "$TARBALL_FILE" | cut -d' ' -f1)
fi

echo "New SHA256: $NEW_SHA"

echo "Updating formula file..."

URL_LINE=$(grep -n '^\s*url ' "$FORMULA_PATH" | head -n1 | cut -d: -f1)
SHA_LINE=$(grep -n '^\s*sha256 ' "$FORMULA_PATH" | head -n1 | cut -d: -f1)

sed -i.bak "${URL_LINE}s|url \".*\"|url \"${TARBALL_URL}\"|" "$FORMULA_PATH"
sed -i.bak "${SHA_LINE}s|sha256 \"[a-f0-9]\{64\}\"|sha256 \"${NEW_SHA}\"|" "$FORMULA_PATH"

rm -f "${FORMULA_PATH}.bak"

echo ""
echo "Formula updated successfully!"
echo ""
echo "Changes made:"
echo "  URL:     $TARBALL_URL"
echo "  SHA256:  $NEW_SHA"

TARBALL_FILE=""
