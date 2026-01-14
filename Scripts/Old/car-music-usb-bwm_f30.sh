#!/bin/bash

# Supports BWM F30 with 32 Gb storage device.

set -eux
set -o pipefail

[[ $# -eq 0 ]] || exit 1

# Use uppercase and limit to 11 characters (including the "-nnn" suffix).
NAME="BMW-USB"

IMAGES_DIR="/home/bondms-unencrypted/SparseImages"
[[ -d "${IMAGES_DIR}" ]] || exit 1

PLAYLIST_STAGE_DIR="${HOME}/RamDisk/${NAME}/Playlists"
[[ ! -e "${PLAYLIST_STAGE_DIR}" ]] || exit 1

IMAGE_PATH="${IMAGES_DIR}/${NAME}.img"
if [[ ! -e "${IMAGE_PATH}" ]]
then
    # Make the image file a little smaller than the real disk so there's no chance
    # of trying to overfill the real disk.
    truncate -s 30GB "${IMAGE_PATH}" || exit 1
    mkfs.vfat -n "${NAME}" "${IMAGE_PATH}" || exit 1
fi
[[ -f "${IMAGE_PATH}" ]] || exit 1

MOUNT_ROOT_DIR="${HOME}/Mount"
[[ -d "${MOUNT_ROOT_DIR}" ]] || exit 1

MOUNT_DIR="${MOUNT_ROOT_DIR}/${NAME}"
mkdir --verbose --parents -- "${MOUNT_DIR}" || exit 1

if mountpoint "${MOUNT_DIR}"
then
    echo "Directory \"${MOUNT_DIR}\" is already a mountpoint." >&2 || exit 1
    exit 1
fi

sudo mount -o uid=${UID} "${IMAGE_PATH}" "${MOUNT_DIR}" || exit 1

###

PODCASTS_PARENT_DIR="${HOME}/Backup"
PODCASTS_SUBDIR_NAME="Podcasts"
PODCASTS_SOURCE_DIR="${PODCASTS_PARENT_DIR}/${PODCASTS_SUBDIR_NAME}"
[[ -d "${PODCASTS_SOURCE_DIR}" ]] || exit 1

mkdir --parents --verbose -- "${MOUNT_DIR}/${PODCASTS_SUBDIR_NAME}" || exit 1
rsync \
    --recursive \
    --checksum \
    --verbose \
    --delete \
    --human-readable \
    --progress \
    --itemize-changes \
    -- \
    "${PODCASTS_SOURCE_DIR}/." \
    "${MOUNT_DIR}/${PODCASTS_SUBDIR_NAME}/." ||
        exit 1

###

MUSIC_PARENT_DIR="${HOME}"
MUSIC_SUBDIR_NAME="Music"
MUSIC_SOURCE_DIR="${MUSIC_PARENT_DIR}/${MUSIC_SUBDIR_NAME}"
[[ -d "${MUSIC_SOURCE_DIR}" ]] || exit 1

mkdir --parents --verbose -- "${MOUNT_DIR}/${MUSIC_SUBDIR_NAME}" || exit 1
rsync \
    --recursive \
    --checksum \
    --verbose \
    --delete \
    --human-readable \
    --progress \
    --itemize-changes \
    -- \
    "${MUSIC_SOURCE_DIR}/." \
    "${MOUNT_DIR}/${MUSIC_SUBDIR_NAME}/." ||
        exit 1

###

PLAYLIST_SOURCE_DIR="${HOME}/Playlists"
[[ -d "${PLAYLIST_SOURCE_DIR}" ]] || exit 1

PLAYLIST_SOURCE_DIR_SANITIZED="$(readlink --canonicalize-existing "${PLAYLIST_SOURCE_DIR}")"
[[ -d "${PLAYLIST_SOURCE_DIR_SANITIZED}" ]] || exit 1

mkdir --verbose --parents -- "${PLAYLIST_STAGE_DIR}" || exit 1

find "${PLAYLIST_SOURCE_DIR}/." \
    -mindepth 1 -maxdepth 1 \
    -type d \
    -print0 |
    bash -c "
        set -eux
        set -o pipefail
        while read -r -d $'\0' F
        do
            PLAYLIST_NAME=\"\$(basename \"\$F\")\"
            [[ -n \"\${PLAYLIST_NAME}\" ]] || exit \$?
            TARGET_PLAYLIST=\"${PLAYLIST_STAGE_DIR}/\${PLAYLIST_NAME}.m3u\"
            find -L \"\$F\" \
            -type f \
            -print0 |
            xargs --null --max-args=1 --no-run-if-empty readlink --canonicalize-existing |
            python -c \"
import os.path
import sys
for i in iter(sys.stdin):
    i = i.rstrip('\n')
    print(os.path.relpath(i, start=sys.argv[1]))
\" \"${PLAYLIST_SOURCE_DIR_SANITIZED}\" |
            sort --numeric-sort |
            uniq |
            tr '/' '\\\\' |
            todos |
            tee \"\${TARGET_PLAYLIST}\" || exit \$?
        done" || exit 1

PLAYLIST_TARGET_DIR="${MOUNT_DIR}/Playlists"
mkdir --parents --verbose -- "${PLAYLIST_TARGET_DIR}" || exit 1
rsync \
    --recursive \
    --checksum \
    --verbose \
    --delete \
    --human-readable \
    --progress \
    --itemize-changes \
    -- \
    "${PLAYLIST_STAGE_DIR}/." \
    "${PLAYLIST_TARGET_DIR}/." ||
        exit 1

echo The remainder of this script is not intended to be executed automatically but rather to serve as documentation. || exit 1
#
# sudo fdisk /dev/sdb # Create partition table table with a single primary "W95 FAT32" (type 'c') partition.
# sudo mkfs.vfat -n "${NAME}-nnn" /dev/sdb1 || exit 1
# rsync-vfat-{quick,verify} --delete -- "${MOUNT_DIR}/." "/media/${USER}/${NAME}/." || exit 1
# sync --file-system "/media/${USER}/${NAME}/." || exit 1
# sudo umount "${MOUNT_DIR}/" || exit 1
# umount "/media/${USER}/${NAME}/" || exit 1
