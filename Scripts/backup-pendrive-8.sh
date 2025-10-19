#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup"
TARGET="pendrive-8"
TARGET_LINK="${SOURCE}/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/Backup"
LOGFILE="${SOURCE}/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_NAME="timestamp.txt"
TIMESTAMP_PATH="${TARGET_DIR}/${TIMESTAMP_NAME}"

# Remove any timestamp file that's been restored from a backup.
rm --force --verbose "${SOURCE}/${TIMESTAMP_NAME}" || exit 1

find "${SOURCE}" \! -path "${SOURCE}/BackupTargets/*" -xtype l || exit 1
[[ -z "$(find "${SOURCE}" \! -path "${SOURCE}/BackupTargets/*" -xtype l \! -name "bazel-*" \! -name "jsoncpp.cpp")" ]] || exit 1

[[ -h "${TARGET_LINK}" ]] || exit 1
[[ -d "${TARGET_DIR}" ]] || exit 1

find "${SOURCE}" -type f -name "*~" -printf "Deleting: %p\n" -delete ||
    exit 1

find "${SOURCE}" -mount \( -type f -o -type d \) \
\( \
  \( ! \( -user bondms -group bondms \) -execdir chown -v bondms.bondms {} + \) , \
  \( -perm /go=rwx -execdir chmod -v go-rwx {} + \) \
\) || exit 1

date "+Started: %Y%m%d-%H%M%S" > "${TIMESTAMP_PATH}" || exit 1
rsync \
    --archive \
    --verbose \
    --human-readable \
    --itemize-changes \
    --checksum \
    --sparse \
    --delete --delete-excluded \
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
    -- \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit 1
date "+Completed: %Y%m%d-%H%M%S" >> "${TIMESTAMP_PATH}" || exit 1
sync --file-system "${TIMESTAMP_PATH}" || exit 1
