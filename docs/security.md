# Security Model

## SSH
- Key-based auth only
- Password auth disabled
- Root login disabled

## Firewall
- ufw enabled
- Only required ports open:
  - 22/tcp (SSH)
  - Samba ports (LAN only)
  - NFS (LAN only)

## Philosophy
- Security via simplicity
- Fewer services > complex rules
- Everything auditable via config files
