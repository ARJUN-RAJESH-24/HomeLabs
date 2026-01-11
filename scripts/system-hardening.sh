#!/usr/bin/env bash
set -euo pipefail

echo "[+] System hardening started"

# --- SSH HARDENING ---
SSHD_CONF="/etc/ssh/sshd_config"

echo "[+] Hardening SSH"

sudo sed -i \
  -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
  -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
  -e 's/^#\?UsePAM.*/UsePAM yes/' \
  "$SSHD_CONF"

sudo sshd -t
sudo systemctl restart ssh

# --- FIREWALL ---
echo "[+] Configuring UFW"

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow ssh
sudo ufw allow samba

sudo ufw --force enable

# --- FAIL2BAN ---
echo "[+] Ensuring fail2ban is active"

sudo systemctl enable --now fail2ban

# --- KERNEL NETWORK SAFETY ---
echo "[+] Applying sysctl hardening"

sudo tee /etc/sysctl.d/99-homelab.conf >/dev/null <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
EOF

sudo sysctl --system

echo "[✓] System hardening complete"
