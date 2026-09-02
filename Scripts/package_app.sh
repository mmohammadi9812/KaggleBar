#!/bin/bash
set -e

# ---------------------------------------------------------------------------
# Package the KaggleBar SwiftUI menu-bar app into a signed .app bundle.
# Extracted from the original build.sh so the Makefile can delegate to it.
# Flags:
#   --dmg       Also produce a KaggleBar.dmg installer (requires create-dmg).
#   --no-open   Do not launch the app after packaging.
# ---------------------------------------------------------------------------

APP_NAME="KaggleBar"
BUNDLE_DIR="$APP_NAME.app/Contents"
MACOS_DIR="$BUNDLE_DIR/Macos"
RESOURCES_DIR="$BUNDLE_DIR/Resources"

echo "==> Building release binary via Swift Package Manager..."
swift build -c release

echo "==> Creating macOS App Bundle ($APP_NAME.app)..."
rm -rf "$APP_NAME.app"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy binary
cp ".build/release/$APP_NAME" "$MACOS_DIR/"

# Copy resources (icons, logos, etc.)
if [ -d "Sources/$APP_NAME/Resources" ]; then
    cp -r "Sources/$APP_NAME/Resources/"* "$RESOURCES_DIR/"
fi

# Create Info.plist (LSUIElement keeps it exclusively in the menu bar — no Dock icon)
cat << PLIST > "$BUNDLE_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.local.kagglebar</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
PLIST

# Ad-hoc sign the app bundle
echo "==> Code-signing bundle (ad-hoc)..."
codesign --force --deep --sign - "$APP_NAME.app"

# Create DMG if --dmg flag is provided
if [ "$1" == "--dmg" ] || [ "$2" == "--dmg" ]; then
    echo "==> Creating DMG installer ($APP_NAME.dmg)..."
    rm -f "$APP_NAME.dmg"

    if ! command -v create-dmg &>/dev/null; then
        echo "==> Installing create-dmg..."
        brew install create-dmg
    fi

    create-dmg \
      --volname "$APP_NAME" \
      --window-pos 200 150 \
      --window-size 540 360 \
      --icon-size 120 \
      --icon "$APP_NAME.app" 140 170 \
      --hide-extension "$APP_NAME.app" \
      --app-drop-link 400 170 \
      "$APP_NAME.dmg" \
      "$APP_NAME.app"

    echo "==> Created $APP_NAME.dmg successfully!"
fi

echo "==> Build complete!"

# Open only in non-CI interactive environments without --no-open
if [ -z "$CI" ] && [ "$1" != "--no-open" ] && [ "$2" != "--no-open" ]; then
    echo "==> Launching $APP_NAME.app..."
    open "$APP_NAME.app"
fi
