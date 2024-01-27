#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 0 ]]

# Use uppercase and limit to 15 characters (including the "-nnn" suffix).
NAME="PHONE-SYNC"

IMAGES_DIR="/home/bondms-unencrypted/SparseImages"
[[ -d "${IMAGES_DIR}" ]] || exit 1

PLAYLIST_STAGE_DIR="${HOME}/RamDisk/${NAME}/Playlists"
[[ ! -e "${PLAYLIST_STAGE_DIR}" ]] || exit 1

IMAGE_PATH="${IMAGES_DIR}/${NAME}.img"
if [[ ! -e "${IMAGE_PATH}" ]]
then
    # Make the image file around half the size of the entire phone's storage so
    # there's no chance of trying to overfill the real disk.
    truncate -s 64GB "${IMAGE_PATH}" || exit 1
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

SYNC_DIR="${MOUNT_DIR}/Sync"
PICTURES_SUBDIR_NAME="Pictures"
PICTURES_SOURCE_DIR="${HOME}/${PICTURES_SUBDIR_NAME}"
[[ -d "${PICTURES_SOURCE_DIR}" ]] || exit 1
PICTURES_TARGET_DIR="${SYNC_DIR}/${PICTURES_SUBDIR_NAME}"

mkdir --parents --verbose -- "${SYNC_DIR}/${PICTURES_SUBDIR_NAME}" || exit 1
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
    "${PICTURES_TARGET_DIR}/." ||
        exit 1

###

PODCASTS_SUBDIR_NAME="Podcasts"
PODCASTS_SOURCE_DIR="${HOME}/${PODCASTS_SUBDIR_NAME}"
[[ -d "${PODCASTS_SOURCE_DIR}" ]] || exit 1
PODCASTS_TARGET_DIR="${SYNC_DIR}/Audio/${PODCASTS_SUBDIR_NAME}"

mkdir --parents --verbose -- "${PODCASTS_TARGET_DIR}" || exit 1
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
    "${PODCASTS_TARGET_DIR}/." ||
        exit 1

###

MUSIC_SUBDIR_NAME="Music"
MUSIC_SOURCE_DIR="${HOME}/${MUSIC_SUBDIR_NAME}"
[[ -d "${MUSIC_SOURCE_DIR}" ]] || exit 1
MUSIC_TARGET_DIR="${SYNC_DIR}/Audio/${MUSIC_SUBDIR_NAME}"

mkdir --parents --verbose -- "${MUSIC_TARGET_DIR}" || exit 1
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
    "${MUSIC_TARGET_DIR}/." ||
        exit 1

###

PLAYLISTS_SUBDIR_NAME="Playlists"
PLAYLIST_SOURCE_DIR="${HOME}/${PLAYLISTS_SUBDIR_NAME}"
[[ -d "${PLAYLIST_SOURCE_DIR}" ]] || exit 1
REAL_PLAYLIST_SOURCE_DIR="$(realpath "${PLAYLIST_SOURCE_DIR}")"
PLAYLIST_PARENT_DIR="$(dirname "${REAL_PLAYLIST_SOURCE_DIR}")"

mkdir --verbose --parents -- "${PLAYLIST_STAGE_DIR}" || exit 1

PLAYLIST_TARGET_DIR="${SYNC_DIR}/Audio"
mkdir --parents --verbose -- "${PLAYLIST_TARGET_DIR}" || exit 1

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
            realpath --relative-to \"${PLAYLIST_TARGET_DIR}\" \"${MUSIC_TARGET_DIR}/Other/silence.mp3\" |
                tr '/' '\\\\' |
                todos |
                tee \"\${TARGET_PLAYLIST}\" || exit \$?
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
\" \"${PLAYLIST_PARENT_DIR}\" |
            sort --numeric-sort |
            uniq |
            tr '/' '\\\\' |
            todos |
            tee --append \"\${TARGET_PLAYLIST}\" || exit \$?
        done" || exit 1

rsync \
    --recursive \
    --checksum \
    --verbose \
    --delete \
    --human-readable \
    --progress \
    --itemize-changes \
    --ignore-times \
    --exclude "/Music/" \
    --exclude "/Podcasts/" \
    -- \
    "${PLAYLIST_STAGE_DIR}/." \
    "${PLAYLIST_TARGET_DIR}/." ||
        exit 1

echo The remainder of this script is not intended to be executed automatically but rather to serve as documentation. || exit 1
#
# # Enable "File transfer/Android Auto" option on the phone after connecting USB.
# # Keep phone unlocked.
# PHONE_TARGET_SYNC_DIR="/run/user/$(id -u)/gvfs/mtp\:host\=Google_Pixel_6a_26271JEGR10601/Internal\ shared\ storage/Sync"
# mkdir --parents --verbose -- "${PHONE_TARGET_SYNC_DIR}" || exit 1
# rsync-jmtpfs-quick \
#     --delete \
#     -- \
#     "${SYNC_DIR}/." "${PHONE_TARGET_SYNC_DIR}/." || exit 1
# # Manually copy the playlists which don't sync over MTP.
# sync --file-system "${PHONE_TARGET_SYNC_DIR}/." || exit 1
# # Unmount phone from file manager.
# # Disable "Use USB to" "Transfer files" option on the phone.
