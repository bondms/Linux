#!/bin/bash

set -eux
set -o pipefail

SOURCE="remote:Docs"
TARGET_DIR="${HOME}/Documents/GoogleDocs"
LOGFILE="${HOME}/Backup/BackupLogs/rsync-googledocs.log"
TIMESTAMP_PATH="${HOME}/Backup/BackupLogs/rsync-googledocs-timestamp.txt"

# TODO: Investigate use of `--checksum`. Doesn't seem to detect changes.
rclone \
    --links \
    --verbose \
    --human-readable \
    sync \
    "${SOURCE}/" "${TARGET_DIR}/" 2>&1 | tee "${LOGFILE}" || exit 1
date --utc --iso-8601=seconds > "${TIMESTAMP_PATH}" || exit 1
