#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup/Documents"
TARGET="sd-2"
TARGET_LINK="${HOME}/Backup/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/Backup"
LOGFILE="${HOME}/Backup/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_NAME="timestamp.txt"
TIMESTAMP_PATH="${TARGET_DIR}/${TIMESTAMP_NAME}"

# Remove any timestamp file that's been restored from a backup.
rm --force --verbose "${SOURCE}/${TIMESTAMP_NAME}" || exit $?

find "${SOURCE}" -xtype l || exit $?
[[ -z "$(find "${SOURCE}" -xtype l \! -name "bazel-*" \! -name "jsoncpp.cpp")" ]] || exit $?

[[ -h "${TARGET_LINK}" ]] || exit $?
[[ -d "${TARGET_DIR}" ]] || exit $?

find "${SOURCE}" -type f -name "*~" -printf "Deleting: %p\n" -delete ||
    exit $?

find "${SOURCE}" -mount \( -type f -o -type d \) \
\( \
  \( ! \( -user bondms -group bondms \) -execdir chown -v bondms.bondms {} + \) , \
  \( -perm /go=rwx -execdir chmod -v go-rwx {} + \) \
\) || exit $?

rm --force --verbose "${TIMESTAMP_PATH}" || exit $?
rsync \
    --archive \
    --verbose \
    --human-readable \
    --itemize-changes \
    --checksum \
    --sparse \
    --delete --delete-excluded \
    --exclude "/Archive/Motoring/Ursula/200801 Polestar 2 press kit UK.zip" \
    --exclude "/Archive/Programming/Git/Linux/Scripts/OctopusEnergyApi/data/" \
    --exclude ".git/" \
    --exclude "bazel-*" \
    --exclude "bin/" \
    --exclude "int/" \
    --exclude "thirdparty/" \
    --exclude "*.pyc" \
    -- \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit $?

date +%Y%m%d-%H%M%S > "${TIMESTAMP_PATH}" || exit $?
sync --file-system "${TIMESTAMP_PATH}" || exit $?
