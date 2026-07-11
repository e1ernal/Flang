#!/usr/bin/env bash
#
# Build a distributable zip for Flang: builds the app in Release configuration,
# then zips Flang.app with ditto.
#
# Ships as a plain zip instead of a DMG — a DMG's own Finder icon can't survive
# a plain HTTP download (no custom-icon extended attribute round trip through
# GitHub Releases), while an app bundle's icon is ordinary file content
# (Info.plist + AppIcon.icns/Assets.car) that comes through in a zip just
# fine. Same approach as Ice (github.com/jordanbaird/Ice) and other menu-bar
# utilities. `ditto -c -k --keepParent` (not Finder's Compress or `zip -r`)
# preserves the code signature and resource forks.
#
# The build is unsigned beyond the project's default ad-hoc signing — this
# project has no Apple Developer Program membership yet (see _local/SPEC.md
# section 9, "Платный трек"). Gatekeeper will show its usual "unidentified
# developer" warning on first launch; README documents the one-time
# right-click-Open workaround.
#
# Usage:
#   Scripts/make-zip.sh
#
# Output: build/Flang-<version>.zip
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/build"
DERIVED_DATA="$BUILD_DIR/DerivedData"

rm -rf "$DERIVED_DATA"
mkdir -p "$BUILD_DIR"

echo "Building Flang (Release)..."
xcodebuild -project "$REPO_ROOT/Flang.xcodeproj" \
  -scheme Flang \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA" \
  build

APP_PATH="$DERIVED_DATA/Build/Products/Release/Flang.app"
if [ ! -d "$APP_PATH" ]; then
  echo "error: build did not produce $APP_PATH" >&2
  exit 1
fi

VERSION="$(defaults read "$APP_PATH/Contents/Info" CFBundleShortVersionString)"
ZIP_PATH="$BUILD_DIR/Flang-$VERSION.zip"
rm -f "$ZIP_PATH"

echo "Packaging $ZIP_PATH..."
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Done: $ZIP_PATH"
