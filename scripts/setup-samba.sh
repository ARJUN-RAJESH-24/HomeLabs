#!/usr/bin/env bash
set -euo pipefail

SMB_CONF="/etc/samba/smb.conf"

echo "[+] Setting up Samba"

sudo tee "$SMB_CONF" >/dev/null <<EOF
[global]
   workgroup = WORKGROUP
   server string = Home Server
   security = user
   map to guest = bad user
   unix extensions = no
   smb ports = 445
   server min protocol = SMB2

[Family]
   path = /srv/data
   browseable = yes
   read only = no
   valid users = arjun
EOF

sudo testparm

sudo systemctl reload smbd

echo "[✓] Samba ready"
