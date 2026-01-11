#!/usr/bin/env bash
set -euo pipefail

IFACE=$(ip route | awk '/default/ {print $5; exit}')

echo "[+] Enabling Wake-on-LAN on $IFACE"

sudo ethtool -s "$IFACE" wol g

sudo tee /etc/systemd/system/wol.service >/dev/null <<EOF
[Unit]
Description=Enable Wake-on-LAN
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/ethtool -s $IFACE wol g

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now wol.service

echo "[✓] Wake-on-LAN enabled"
