#!/usr/bin/env bash
set -euo pipefail

OUT="/var/log/network-baseline.txt"

{
  echo "Date: $(date)"
  echo
  ip a
  echo
  ip route
  echo
  ss -tulpn
} | sudo tee "$OUT" >/dev/null

echo "[✓] Network baseline saved to $OUT"
