#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup/Documents"
TARGET="sd-2"
TARGET_LINK="${HOME}/Backup/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/backup"
LOGFILE="${HOME}/Backup/BackupLogs/rsync-${TARGET}.log"
TIMESTAMP_PATH="${TARGET_DIR}/timestamp.txt"

find "${SOURCE}" -xtype l || exit $?
[[ -z "$(find "${SOURCE}" -xtype l)" ]] || exit $?

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
    --exclude ".git/" \
    --exclude "bin/" \
    --exclude "int/" \
    --exclude "thirdparty/" \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit $?

date +%Y%m%d-%H%M%S > "${TIMESTAMP_PATH}" || exit $?
sync --file-system "${TIMESTAMP_PATH}" || exit $?
