#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup"
TARGET="googledrive-8"
TARGET_DIR="remote:Backup/${TARGET}"
LOGFILE="${SOURCE}/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_NAME="timestamp.txt"
TIMESTAMP_PATH="${TARGET_DIR}/${TIMESTAMP_NAME}"
TESTING="--dry-run --interactive"

# Remove any timestamp file that's been restored from a backup.
rm --force --verbose "${SOURCE}/${TIMESTAMP_NAME}" || exit 1

find "${SOURCE}" -type f -name "*~" -printf "Deleting: %p\n" -delete ||
    exit 1

find "${SOURCE}" -mount \( -type f -o -type d \) \
\( \
  \( ! \( -user bondms -group bondms \) -execdir chown -v bondms.bondms {} + \) , \
  \( -perm /go=rwx -execdir chmod -v go-rwx {} + \) \
\) || exit 1

rclone delete ${TESTING} "${TIMESTAMP_PATH}" || exit 1
rclone sync ${TESTING} \
    --verbose \
    --human-readable \
    --checksum \
    --delete-excluded \
    --exclude "/BackupLogs/" \
    --exclude "/Documents/Archive/Joli/Elements/" \
    --exclude "/Documents/Archive/Motoring/Ursula/200801 Polestar 2 press kit UK.zip" \
    --exclude "/Documents/Archive/Programming/Git/Linux/Scripts/OctopusEnergyApi/data/" \
    --exclude "/Downloads/" \
    --exclude "/Images/" \
    --exclude "/Music/AudioCDs/" \
    --exclude "/Music/Other/" \
    --exclude "/Music/Rhythmbox/" \
    --exclude "/Pictures/" \
    --exclude "/Temp/" \
    --exclude "/Videos/" \
    --exclude ".git/" \
    --exclude "bazel-*" \
    --exclude "bin/" \
    --exclude "decompressed/" \
    --exclude "int/" \
    --exclude "target/" \
    --exclude "thirdparty/" \
    --exclude "*.pyc" \
    sync \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit 1

date +%Y%m%d-%H%M%S | rclone ${TESTING} cat "${TARGET_DIR}/${TIMESTAMP_NAME}" || exit 1
