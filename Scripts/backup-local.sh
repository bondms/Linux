#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup"
TARGET="local"
TARGET_LINK="${SOURCE}/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/${USER}"
LOGFILE="${SOURCE}/BackupLogs/rsync-${TARGET}.log"

find "${SOURCE}" \! -path "${SOURCE}/BackupTargets/*" -xtype l || exit 1
[[ -z "$(find "${SOURCE}" \! -path "${SOURCE}/BackupTargets/*" -xtype l \! -name "bazel-*" \! -name "jsoncpp.cpp")" ]] || exit 1

TARGET_DIR="${TARGET_DIR}/latest"

[[ -h "${TARGET_LINK}" ]] || exit 1
[[ -d "${TARGET_DIR}" ]] || exit 1

find "${SOURCE}" -type f -name "*~" -printf "Deleting: %p\n" -delete ||
    exit 1

find "${SOURCE}" -mount \( -type f -o -type d \) \
\( \
  \( ! \( -user bondms -group bondms \) -execdir chown -v bondms.bondms {} + \) , \
  \( -perm /go=rwx -execdir chmod -v go-rwx {} + \) \
\) || exit 1

rsync \
    --archive \
    --checksum \
    --human-readable \
    --itemize-changes \
    --progress \
    --sparse \
    --verbose \
    --delete --delete-excluded \
    --exclude "/BackupLogs/" \
    --exclude "/Images/Debian/" \
    --exclude "/Images/Ubuntu/" \
    --exclude "/Images/RaspberryPi/" \
    --exclude "/Images/Windows/" \
    --exclude ".git/" \
    --exclude "bazel-*" \
    --exclude "bin/" \
    --exclude "decompressed/" \
    --exclude "int/" \
    --exclude "target/" \
    --exclude "thirdparty/" \
    --exclude "*.pyc" \
    -- \
    "${SOURCE}/" "${TARGET_DIR}/" 2>&1 | tee "${LOGFILE}" || exit 1
