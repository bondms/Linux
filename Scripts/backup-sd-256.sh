#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Archive/bondms"
TARGET="sd-256"
TARGET_LINK="${HOME}/Backup/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/Backup"
LOGFILE="${HOME}/Backup/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_NAME="timestamp.txt"
TIMESTAMP_PATH="${TARGET_DIR}/${TIMESTAMP_NAME}"

# Remove any timestamp file that's been restored from a backup.
rm --force --verbose "${SOURCE}/${TIMESTAMP_NAME}" || exit 1

[[ -h "${TARGET_LINK}" ]] || exit 1
[[ -d "${TARGET_DIR}" ]] || exit 1

rm --force --verbose "${TIMESTAMP_PATH}" || exit 1
rsync \
    --archive \
    --hard-links \
    --verbose \
    --human-readable \
    --itemize-changes \
    --sparse \
    --delete --delete-excluded \
    -- \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit 1

date +%Y%m%d-%H%M%S > "${TIMESTAMP_PATH}" || exit 1
sync --file-system "${TIMESTAMP_PATH}" || exit 1

echo The remainder of this script is not intended to be executed automatically but rather to serve as documentation. || exit 1
#
# sudo fdisk /dev/mmcblk0
# * "create a new empty DOS partition table" (option 'o').
# * "add a new partition" (option 'n').
# * "write table to disk and exit" (option 'w').
# sudo mkfs.ext4 -L "BackupSd256" /dev/mmcblk0p1 || exit 1
# sudo mkdir /media/bondms/BackupSd256/Backup || exit 1
# sudo chown bondms.bondms /media/bondms/BackupSd256/Backup/ || exit 1
