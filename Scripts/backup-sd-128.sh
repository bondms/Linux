#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Archive"
TARGET="sd-128"
TARGET_LINK="${SOURCE}/BackupTargets/${TARGET}"
TARGET_DIR="${TARGET_LINK}/backup"
LOGFILE="${SOURCE}/BackupLogs/rsync-${TARGET}.log"

[[ -h "${TARGET_LINK}" ]] || exit $?
[[ -d "${TARGET_DIR}" ]] || exit $?

rsync \
    --archive \
    --hard-links \
    --verbose \
    --human-readable \
    --itemize-changes \
    --checksum \
    --sparse \
    --delete --delete-excluded \
    "${SOURCE}/" "${TARGET_DIR}/" | tee "${LOGFILE}" || exit $?
