#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 0 ]]

# Use uppercase and limit to 15 characters (including the "-nnn" suffix).
NAME="PHONE-SD"

IMAGES_DIR="/home/bondms-unencrypted/SparseImages"
[[ -d "${IMAGES_DIR}" ]] || exit 1

PLAYLIST_STAGE_DIR="${HOME}/RamDisk/Playlists"
[[ ! -e "${PLAYLIST_STAGE_DIR}" ]] || exit 1

IMAGE_PATH="${IMAGES_DIR}/${NAME}.img"
if [[ ! -e "${IMAGE_PATH}" ]]
then
    # Make the image file a little smaller than the real disk so there's no chance
    # of trying to overfill the real disk.
    truncate -s 60GB "${IMAGE_PATH}" || exit 1
    mkfs.exfat -n "${NAME}" "${IMAGE_PATH}" || exit 1
fi
[[ -f "${IMAGE_PATH}" ]] || exit 1

MOUNT_DIR="${HOME}/Mount"
[[ -d "${MOUNT_DIR}" ]] || exit 1

if mountpoint "${MOUNT_DIR}"
then
    echo "Directory \"${MOUNT_DIR}\" is already a mountpoint." >&2 || exit 1
    exit 1
fi

sudo mount -o uid=${UID} "${IMAGE_PATH}" "${MOUNT_DIR}" || exit 1

###

PICTURES_PARENT_DIR="${HOME}"
PICTURES_SUBDIR_NAME="Pictures"
PICTURES_SOURCE_DIR="${PICTURES_PARENT_DIR}/${PICTURES_SUBDIR_NAME}"
[[ -d "${PICTURES_SOURCE_DIR}" ]] || exit 1

mkdir --parents --verbose -- "${MOUNT_DIR}/${PICTURES_SUBDIR_NAME}" || exit 1
rsync \
    --recursive \
    --checksum \
    --verbose \
    --delete --delete-excluded \
    --human-readable \
    --progress \
    --itemize-changes \
    --times \
    --modify-window=3601 \
    --exclude "/Favorites/" \
    --exclude "/Montage/Joli/source/" \
    --exclude "/profile.jpg" \
    --exclude "/Wallpaper/" \
    -- \
    "${PICTURES_SOURCE_DIR}/." \
    "${MOUNT_DIR}/${PICTURES_SUBDIR_NAME}/." ||
        exit 1

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
    --times \
    --modify-window=3601 \
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
    --times \
    --modify-window=3601 \
    -- \
    "${MUSIC_SOURCE_DIR}/." \
    "${MOUNT_DIR}/${MUSIC_SUBDIR_NAME}/." ||
        exit 1

###

PLAYLIST_SOURCE_DIR="${HOME}/Playlists"
[[ -d "${PLAYLIST_SOURCE_DIR}" ]] || exit 1

PLAYLIST_SOURCE_DIR_SANITIZED="$(readlink -e "${PLAYLIST_SOURCE_DIR}")"
[[ -d "${PLAYLIST_SOURCE_DIR_SANITIZED}" ]] || exit 1

mkdir --verbose -- "${PLAYLIST_STAGE_DIR}" || exit 1

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
            xargs --null --max-args=1 --no-run-if-empty readlink -e |
            python -c \"
import os.path
import sys
for i in iter(sys.stdin):
    i = i.rstrip('\n')
    print(os.path.relpath(i, sys.argv[1]))
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
    --ignore-times \
    -- \
    "${PLAYLIST_STAGE_DIR}/." \
    "${PLAYLIST_TARGET_DIR}/." ||
        exit 1

echo The remainder of this script is not intended to be executed automatically but rather to serve as documentation. || exit 1
#
# # Option 1: Remove the SD card from the phone and place directly in the laptop.
# sudo fdisk /dev/mmcblk0  # Create exfat partition (type 7).
# sudo mkfs.exfat -n "${NAME}-nnn" /dev/mmcblk0p1 || exit 1
# rsync-vfat-{quick,verify} --delete -- "${MOUNT_DIR}/." "/media/${USER}/${NAME}/." || exit 1
# sync --file-system "/media/${USER}/${NAME}/." || exit 1
# sudo umount "${MOUNT_DIR}/" || exit 1
# umount "/media/${USER}/${NAME}/" || exit 1
#
# # Option 2: Mount the SD card while it's in the phone using gvfs.
