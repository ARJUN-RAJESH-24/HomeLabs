#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing Jellyfin"

sudo apt update
sudo apt install -y jellyfin

sudo systemctl enable --now jellyfin

echo "[+] Jellyfin running on port 8096"
echo "[✓] Visit: http://<server-ip>:8096"
