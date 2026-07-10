#!/usr/bin/env bash
#
# Build a distributable DMG for Flang: builds the app in Release configuration,
# then packages it into a "drag Flang.app into Applications" DMG via create-dmg.
#
# The build is unsigned beyond the project's default ad-hoc signing — this
# project has no Apple Developer Program membership yet (see _local/SPEC.md
# section 9, "Платный трек"). Gatekeeper will show its usual "unidentified
# developer" warning on first launch; README documents the one-time
# right-click-Open workaround.
#
# Requires: create-dmg (brew install create-dmg).
#
# Usage:
#   Scripts/make-dmg.sh
#
# Output: build/Flang-<version>.dmg
#
set -euo pipefail

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "error: create-dmg not found. Install it with: brew install create-dmg" >&2
  exit 1
fi

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
DMG_PATH="$BUILD_DIR/Flang-$VERSION.dmg"
rm -f "$DMG_PATH"

echo "Packaging $DMG_PATH..."
create-dmg \
  --volname "Flang $VERSION" \
  --window-size 540 380 \
  --icon-size 128 \
  --icon "Flang.app" 140 170 \
  --app-drop-link 400 170 \
  --hide-extension "Flang.app" \
  "$DMG_PATH" \
  "$APP_PATH"

echo "Done: $DMG_PATH"
