#!/bin/bash
set -e

echo "==> Building debug binary..."
swift build

# Kill any running KaggleBar instance before relaunching
pkill -x KaggleBar || true

echo "==> Packaging app (release)..."
./Scripts/package_app.sh --no-open

echo "==> Launching KaggleBar.app..."
open KaggleBar.app
