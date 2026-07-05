#!/usr/bin/env bash
#
# Import flag-icons 4x3 SVGs into the app's asset catalog with vector data
# preserved, so a single SVG renders crisply at any size (menu bar and beyond).
#
# Source: https://github.com/lipis/flag-icons (MIT). See FR-14.
#
# Usage:
#   Scripts/import-flags.sh [path-to-flags.zip | path-to-dir-with-4x3]
#
# Default source is Flang/Resources/flags.zip if present. Because that archive
# is intentionally removed from the repo after the first import (the assets live
# in the catalog, not the zip), later updates should pass a freshly downloaded
# flag-icons archive or its extracted folder.
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CATALOG="$REPO_ROOT/Flang/Resources/Assets.xcassets"
FLAGS_GROUP="$CATALOG/Flags"
SRC="${1:-$REPO_ROOT/Flang/Resources/flags.zip}"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Resolve a directory that contains a "4x3" folder of SVGs.
if [[ -f "$SRC" ]]; then
  unzip -q "$SRC" -d "$TMP"
  found="$(find "$TMP" -type d -name 4x3 -print -quit)"
  SRCDIR="$(dirname "$found")"
elif [[ -d "$SRC" ]]; then
  SRCDIR="$SRC"
else
  echo "error: source not found: $SRC" >&2
  exit 1
fi

FOURBYTHREE="$SRCDIR/4x3"
if [[ ! -d "$FOURBYTHREE" ]]; then
  echo "error: no 4x3 directory under $SRCDIR" >&2
  exit 1
fi

# Rebuild the Flags group from scratch so removed upstream flags disappear too.
# provides-namespace=false keeps asset names as the bare country code (e.g. "us").
rm -rf "$FLAGS_GROUP"
mkdir -p "$FLAGS_GROUP"
cat > "$FLAGS_GROUP/Contents.json" <<'JSON'
{
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : { "provides-namespace" : false }
}
JSON

count=0
for svg in "$FOURBYTHREE"/*.svg; do
  code="$(basename "$svg" .svg)"
  imageset="$FLAGS_GROUP/$code.imageset"
  mkdir -p "$imageset"
  cp "$svg" "$imageset/$code.svg"
  cat > "$imageset/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "$code.svg",
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 },
  "properties" : {
    "preserves-vector-representation" : true
  }
}
JSON
  count=$((count + 1))
done

echo "Imported $count flags into ${FLAGS_GROUP#"$REPO_ROOT"/}"
