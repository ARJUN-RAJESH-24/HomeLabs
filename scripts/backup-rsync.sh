#!/bin/bash
set -e

SRC="/srv/data/"
DEST="/backup/daily/"
LOG="/var/log/homelab-backup.log"

echo "=== Backup started: $(date) ===" >> $LOG
rsync -avh --delete "$SRC" "$DEST" >> $LOG 2>&1
echo "=== Backup finished: $(date) ===" >> $LOG
