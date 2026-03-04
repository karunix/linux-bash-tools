#!/usr/bin/env bash

set -e

INSTALL_DIR="/opt/linux-bash-tools"
BIN_DIR="/usr/local/bin"

echo "[*] Creating install directory..."
sudo mkdir -p "$INSTALL_DIR"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[*] Copying tools..."
sudo cp -r "$REPO_ROOT/tools" "$INSTALL_DIR/"
sudo cp "$REPO_ROOT/VERSION" "$INSTALL_DIR/"

echo "[*] Creating symlinks..."
for script in $(find "$INSTALL_DIR/tools/core" -type f -name "*.sh"); do
    name=$(basename "$script" .sh)
    sudo ln -sf "$script" "$BIN_DIR/$name"
done

echo "[+] Installation complete."
