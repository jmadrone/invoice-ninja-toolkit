#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$REPO_ROOT/VERSION"
VERSION=$(cat "$VERSION_FILE")

OUT="invoice-ninja-toolkit-${VERSION}.zip"

cd "$REPO_ROOT"
zip -r "$OUT" scripts systemd docs VERSION README.md LICENSE .gitignore

echo "Created $OUT"
