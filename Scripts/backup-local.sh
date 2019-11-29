#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup"
TARGET="local"
TARGET_LINK="${SOURCE}/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/${USER}"
LOGFILE="${SOURCE}/BackupLogs/rsync-${TARGET}.log"

[[ -z "$(find -L \
    "${SOURCE}/Playlists/." \
    "${SOURCE}/Pictures/Favorites/." \
    -type l)" ]] || exit $?

TARGET_DIR="${TARGET_DIR}/latest"

[[ -h "${TARGET_LINK}" ]] || exit $?
[[ -d "${TARGET_DIR}" ]] || exit $?

find "${SOURCE}" -type f -name "*~" -printf "Deleting: %p\n" -delete ||
    exit $?

find "${SOURCE}" -mount \( -type f -o -type d \) \
\( \
  \( ! \( -user bondms -group bondms \) -execdir chown -v bondms.bondms {} + \) , \
  \( -perm /go=rwx -execdir chmod -v go-rwx {} + \) \
\) || exit $?

rsync \
    --archive \
    --verbose \
    --human-readable \
    --itemize-changes \
    --sparse \
    --delete --delete-excluded \
    --exclude "/BackupLogs/" \
    --exclude "/Images/*ubuntu-*.iso" \
    --exclude "/Images/RaspberryPi/" \
    --exclude "/Temp/" \
    --exclude "/Videos/Temp/" \
    --exclude ".git/" \
    --exclude "bin/" \
    --exclude "int/" \
    --exclude "thirdparty/" \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit $?
