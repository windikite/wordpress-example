#!/usr/bin/env bash
set -euo pipefail

# where to mirror into
DEST=static-site

echo "🧹 Cleaning old export…"
rm -rf "${DEST}"

echo "🔄 Starting mirror from http://localhost:8080 → ./${DEST}/"
wget --mirror \
     --adjust-extension \
     --convert-links \
     --page-requisites \
     --no-parent \
     --directory-prefix="${DEST}" \
     http://localhost:8080/

echo "✅ Export complete! Files in ./${DEST}/"
