#!/usr/bin/env bash
set -euo pipefail

echo "===== SYSTEM HEALTH ====="
date
uptime

echo
echo "===== DISK USAGE ====="
df -h
df -ih

echo
echo "===== MOUNTS ====="
mount | grep -E "srv/data|backup" || true

echo
echo "===== SERVICES ====="
systemctl is-active ssh smbd nfs-server ufw || true

echo
echo "===== SMART STATUS ====="
sudo smartctl -H /dev/sda || true
sudo smartctl -H /dev/sdb || true

echo
echo "===== NETWORK ====="
ip a
ip route

echo
echo "===== DONE ====="
