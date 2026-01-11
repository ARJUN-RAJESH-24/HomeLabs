#!/usr/bin/env bash
set -euo pipefail

SRC="/srv/data/"
DEST="/srv/data/backup/current"
LOG="/srv/data/backup/backup-$(date +%F).log"

EXCLUDES=(
  --exclude="/backup/"
  --exclude="timeshift/"
  --exclude="*/cache/*"
  --exclude="*/tmp/*"
  --exclude="lost+found"
)

echo "===== BACKUP START $(date) =====" | tee -a "$LOG"

mkdir -p "$DEST"

rsync -aAXH \
  --numeric-ids \
  --one-file-system \
  --delete \
  --info=progress2 \
  "${EXCLUDES[@]}" \
  "$SRC" "$DEST" | tee -a "$LOG"

echo "===== BACKUP END $(date) =====" | tee -a "$LOG"
