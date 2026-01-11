# Storage Layout

## Disks
- `/dev/sda` — OS (ext4)
- `/dev/sdb` — Data (ext4)

## Mounts
- `/srv/data` → primary data
- `/srv/data/backup` → backup target
- `/backup` → bind mount to support tools expecting `/backup`

## Rules
- OS disk must never fill due to backups
- Backups always land on HDD
- No snapshots of `/srv/data` unless explicitly planned
