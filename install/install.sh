#!/usr/bin/env bash

set -e

INSTALL_DIR="/opt/linux-bash-tools"
BIN_DIR="/usr/local/bin"

echo "[*] Creating install directory..."
sudo mkdir -p "$INSTALL_DIR"

echo "[*] Copying tools..."
sudo cp -r ../tools "$INSTALL_DIR/"

echo "[*] Setting executable permissions..."
sudo find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo "[*] Creating symlinks..."
for script in $(find "$INSTALL_DIR/tools/core" -type f -name "*.sh"); do
    name=$(basename "$script" .sh)
    sudo ln -sf "$script" "$BIN_DIR/$name"
done

echo "[+] Installation complete."
