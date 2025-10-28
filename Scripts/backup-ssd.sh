#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Archive/bondms"
TARGET="ssd"
TARGET_LINK="${HOME}/Backup/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/Backup"
LOGFILE="${HOME}/Backup/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_NAME="timestamp.txt"
TIMESTAMP_PATH="${TARGET_DIR}/${TIMESTAMP_NAME}"

# Remove any timestamp file that's been restored from a backup.
rm --force --verbose "${SOURCE}/${TIMESTAMP_NAME}" || exit 1

[[ -h "${TARGET_LINK}" ]] || exit 1
[[ -d "${TARGET_DIR}" ]] || exit 1

rsync \
    --archive \
    --checksum \
    --hard-links \
    --human-readable \
    --itemize-changes \
    --progress \
    --sparse \
    --verbose \
    --delete --delete-excluded \
    -- \
    "${SOURCE}/" "${TARGET_DIR}/" 2>&1 | tee "${LOGFILE}" || exit 1

date --utc --iso-8601=seconds > "${TIMESTAMP_PATH}" || exit 1
sync --file-system "${TIMESTAMP_PATH}" || exit 1
