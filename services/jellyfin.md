# Jellyfin Service

## Purpose
Jellyfin provides local media streaming inside the LAN.
It is optional and **not required** for core server operation.

## Data Location
- Media root: `/srv/data/media`
- Config: `/var/lib/jellyfin`
- Cache: `/var/cache/jellyfin`

## Network
- Port: `8096/tcp`
- Access: LAN only
- No port forwarding
- No cloud dependency

## Startup
```bash
sudo systemctl enable --now jellyfin

## Health Check
systemctl status jellyfin
ss -tulpn | grep 8096

Backup Policy

Media files: backed up via rsync

Jellyfin config: optional backup

Cache is never backed up

Failure Policy

If Jellyfin fails:

Do nothing unless media access is required

Server remains fully functional without it

Notes

Jellyfin must never:

Fill the OS disk

Block boot

Be required for SSH access