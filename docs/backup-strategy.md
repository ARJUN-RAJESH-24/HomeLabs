# Backup Strategy

## Layers
1. rsync — data backups
2. Timeshift — OS snapshots (limited scope)

## Data
- `/srv/data` is backed up
- Excludes caches, temp files

## Timeshift
- rsync mode
- Snapshot device: HDD
- OS only (not data)

## Rule
Backups must be:
- restorable
- explainable
- deletable
