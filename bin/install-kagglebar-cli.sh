#!/bin/bash
set -e

# Installs the KaggleBar CLI binary to ~/.local/bin (or /usr/local/bin).

BINARY=".build/release/KaggleBarCLI"

if [ ! -f "$BINARY" ]; then
    echo "==> KaggleBarCLI binary not found, building release..."
    swift build -c release --target KaggleBarCLI
fi

# Prefer /usr/local/bin (on PATH by default), fall back to ~/.local/bin
if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
fi

cp "$BINARY" "$INSTALL_DIR/kagglebar"
chmod +x "$INSTALL_DIR/kagglebar"

echo "==> Installed kagglebar CLI to $INSTALL_DIR/kagglebar"

if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo "==> Note: $INSTALL_DIR is not in your PATH. Add it with:"
    echo "    echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.zshrc  # or ~/.bash_profile"
fi
