#!/usr/bin/env bash

set -euo pipefail

REPO="https://github.com/FelixKratz/SbarLua.git"
TMP_DIR="$(mktemp -d)"
INSTALL_DIR="$HOME/.local/share/sketchybar_lua"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "==> Installing SbarLua"

# Check dependencies
if ! command -v git >/dev/null 2>&1; then
  echo "Error: git is not installed."
  exit 1
fi

if ! command -v make >/dev/null 2>&1; then
  echo "Error: make is not installed."
  echo "Install Xcode Command Line Tools with:"
  echo "  xcode-select --install"
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Error: Xcode Command Line Tools are not installed."
  echo "Run:"
  echo "  xcode-select --install"
  exit 1
fi

# Clone latest SbarLua
echo "==> Downloading latest SbarLua"
git clone --depth=1 "$REPO" "$TMP_DIR/SbarLua"

# Build and install
echo "==> Building SbarLua"
cd "$TMP_DIR/SbarLua"

make

echo "==> Installing SbarLua"
make install

# Verify installation
if [[ -d "$INSTALL_DIR" ]]; then
  echo
  echo "SbarLua installed successfully."
  echo "Install directory:"
  echo "  $INSTALL_DIR"
  echo
  echo "Installed files:"
  find "$INSTALL_DIR" -maxdepth 2 -type f -print
else
  echo
  echo "Warning: build completed, but expected directory was not found:"
  echo "  $INSTALL_DIR"
  exit 1
fi