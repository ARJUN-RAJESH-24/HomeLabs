# Reboot Recovery Runbook

Steps to verify system health after reboot.
uptime
df -h
free -h
journalctl -p 3 -n 20
