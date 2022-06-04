#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Archive/bondms"
TARGET="sd-128"
TARGET_LINK="${HOME}/Backup/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/Backup"
LOGFILE="${HOME}/Backup/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_NAME="timestamp.txt"
TIMESTAMP_PATH="${TARGET_DIR}/${TIMESTAMP_NAME}"

# Remove any timestamp file that's been restored from a backup.
rm --force --verbose "${SOURCE}/${TIMESTAMP_NAME}" || exit $?

[[ -h "${TARGET_LINK}" ]] || exit $?
[[ -d "${TARGET_DIR}" ]] || exit $?

rm --force --verbose "${TIMESTAMP_PATH}" || exit $?
rsync \
    --archive \
    --hard-links \
    --verbose \
    --human-readable \
    --itemize-changes \
    --checksum \
    --sparse \
    --delete --delete-excluded \
    -- \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit $?

date +%Y%m%d-%H%M%S > "${TIMESTAMP_PATH}" || exit $?
sync --file-system "${TIMESTAMP_PATH}" || exit $?
