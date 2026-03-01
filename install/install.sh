#!/usr/bin/env bash

set -e

INSTALL_DIR="/opt/linux-bash-tools"

echo "[*] Creating install directory..."
sudo mkdir -p "$INSTALL_DIR"

echo "[*] Copying tools..."
sudo cp -r ../tools "$INSTALL_DIR/"

echo "[*] Setting executable permissions..."
sudo find "$INSTALL_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo "[+] Installation complete."
