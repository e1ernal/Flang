#!/usr/bin/env bash
#
# Build a distributable DMG for Flang: builds the app in Release configuration,
# then packages it into a "drag Flang.app into Applications" DMG via dmgbuild.
#
# The build is unsigned beyond the project's default ad-hoc signing — this
# project has no Apple Developer Program membership yet (see _local/SPEC.md
# section 9, "Платный трек"). Gatekeeper will show its usual "unidentified
# developer" warning on first launch; README documents the one-time
# right-click-Open workaround.
#
# Uses dmgbuild (not create-dmg): create-dmg positions the Finder icons via
# AppleScript, which needs an interactive "allow this app to control Finder"
# permission prompt — a dead end in any non-interactive/headless context.
# dmgbuild writes the .DS_Store layout directly, no Finder automation needed.
#
# The window background (Scripts/dmg-assets/) matches the app's own design
# system instead of dmgbuild's generic built-in arrow — regenerate it with
# Scripts/make-dmg-background.py if you change the layout below.
#
# Requires: dmgbuild (pip3 install --user dmgbuild).
#
# Usage:
#   Scripts/make-dmg.sh
#
# Output: build/Flang-<version>.dmg
#
set -euo pipefail

if ! python3 -c "import dmgbuild" >/dev/null 2>&1; then
  echo "error: dmgbuild not found. Install it with: pip3 install --user dmgbuild" >&2
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

VOLUME_ICON="$APP_PATH/Contents/Resources/AppIcon.icns"
BACKGROUND="$REPO_ROOT/Scripts/dmg-assets/background.png"

SETTINGS_PATH="$BUILD_DIR/dmg_settings.py"
cat > "$SETTINGS_PATH" <<PYEOF
app = "$APP_PATH"
appname = "Flang.app"

format = "UDZO"
files = [app]
symlinks = {"Applications": "/Applications"}
icon = "$VOLUME_ICON"

icon_locations = {
    appname: (140, 170),
    "Applications": (400, 170),
}

window_rect = ((200, 200), (540, 380))
icon_size = 128
text_size = 14
background = "$BACKGROUND"
PYEOF

echo "Packaging $DMG_PATH..."
python3 -m dmgbuild -s "$SETTINGS_PATH" "Flang $VERSION" "$DMG_PATH"

echo "Done: $DMG_PATH"
