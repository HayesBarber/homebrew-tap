#!/bin/bash

set -euo pipefail

REPO_OWNER="HayesBarber"
REPO_NAME="spaced-repetition-learning"
FORMULA_PATH="Formula/srl.rb"
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
TARBALL_FILE="/tmp/srl-${LATEST_TAG}.tar.gz"

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
OLD_URL=$(grep -E '^\s*url\s+' "$FORMULA_PATH" | head -n1)
OLD_SHA=$(grep -E '^\s*sha256\s+' "$FORMULA_PATH" | head -n1)

sed -i.bak "s|url \"https://api.github.com/repos/.*/tarball/.*\"|url \"${TARBALL_URL}\"|" "$FORMULA_PATH"
sed -i.bak "s|sha256 \"[a-f0-9]\{64\}\"|sha256 \"${NEW_SHA}\"|" "$FORMULA_PATH"

rm -f "${FORMULA_PATH}.bak"

echo ""
echo "Formula updated successfully!"
echo ""
echo "Changes made:"
echo "  URL:     $TARBALL_URL"
echo "  SHA256:  $NEW_SHA"

TARBALL_FILE=""
