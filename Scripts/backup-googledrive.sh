#!/bin/bash

set -eux
set -o pipefail

SOURCE="${HOME}/Backup"
TARGET_ROOT="remote"
TARGET_DIR="${TARGET_ROOT}:Backup"
LOGFILE="${SOURCE}/BackupLogs/rsync-googledrive.log"
TIMESTAMP_PATH="${TARGET_ROOT}:backup-timestamp.txt"

find "${SOURCE}" -type f -name "*~" -printf "Deleting: %p\n" -delete ||
    exit 1

find "${SOURCE}" -mount \( -type f -o -type d \) \
\( \
  \( ! \( -user bondms -group bondms \) -execdir chown -v bondms.bondms {} + \) , \
  \( -perm /go=rwx -execdir chmod -v go-rwx {} + \) \
\) || exit 1

rclone mkdir "${TARGET_DIR}" || exit 1
rclone \
    --links \
    --verbose \
    --human-readable \
    --checksum \
    --delete-excluded \
    --exclude "/BackupLogs/" \
    --exclude "/Documents/Archive/Motoring/Ursula/200801 Polestar 2 press kit UK.zip" \
    --exclude "/Documents/Archive/Programming/Git/" \
    --exclude "/Downloads/" \
    --exclude "/Images/" \
    --exclude "/Music/AudioCDs/" \
    --exclude "/Music/Other/" \
    --exclude "/Music/Rhythmbox/" \
    --exclude "/Music/SavedRecordings/" \
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
    "${SOURCE}/" "${TARGET_DIR}/" 2>&1 | tee "${LOGFILE}" || exit 1
date --utc --iso-8601=seconds | rclone rcat "${TIMESTAMP_PATH}" || exit 1
