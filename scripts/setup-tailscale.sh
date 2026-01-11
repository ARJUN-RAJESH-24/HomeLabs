#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing Tailscale"

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg \
  | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list \
  | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt update
sudo apt install -y tailscale

sudo systemctl enable --now tailscaled

echo "[!] Run manually:"
echo "    sudo tailscale up"
