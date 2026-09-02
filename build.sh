#!/bin/bash
set -e

# build.sh — thin wrapper around the packaging script.
# Usage:
#   ./build.sh            # build + bundle + launch
#   ./build.sh --dmg      # also produce a DMG installer
#   ./build.sh --no-open  # build + bundle, do not launch
#
# Delegates to Scripts/package_app.sh which contains the full packaging logic.
./Scripts/package_app.sh "$@"
