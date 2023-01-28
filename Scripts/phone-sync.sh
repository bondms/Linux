#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 0 ]]

# Use uppercase and limit to 15 characters (including the "-nnn" suffix).
NAME="PHONE-SYNC"

IMAGES_DIR="/home/bondms-unencrypted/SparseImages"
[[ -d "${IMAGES_DIR}" ]] || exit $?

PLAYLIST_STAGE_DIR="${HOME}/RamDisk/Playlists"
[[ ! -e "${PLAYLIST_STAGE_DIR}" ]] || exit $?

IMAGE_PATH="${IMAGES_DIR}/${NAME}.img"
if [[ ! -e "${IMAGE_PATH}" ]]
then
    # Make the image file around half the size of the entire phone's storage so
    # there's no chance of trying to overfill the real disk.
    truncate -s 64GB "${IMAGE_PATH}" || exit $?
    mkfs.exfat -n "${NAME}" "${IMAGE_PATH}" || exit $?
fi
[[ -f "${IMAGE_PATH}" ]] || exit $?

MOUNT_DIR="${HOME}/Mount"
[[ -d "${MOUNT_DIR}" ]] || exit $?

if mountpoint "${MOUNT_DIR}"
then
    echo "Directory \"${MOUNT_DIR}\" is already a mountpoint." >&2 || exit $?
    exit 1
fi

sudo mount -o uid=${UID} "${IMAGE_PATH}" "${MOUNT_DIR}" || exit $?

###

PICTURES_SUBDIR_NAME="Pictures"
PICTURES_SOURCE_DIR="${HOME}/${PICTURES_SUBDIR_NAME}"
[[ -d "${PICTURES_SOURCE_DIR}" ]] || exit $?
PICTURES_TARGET_DIR="${MOUNT_DIR}/${PICTURES_SUBDIR_NAME}"

mkdir --parents --verbose -- "${MOUNT_DIR}/${PICTURES_SUBDIR_NAME}" || exit $?
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
        exit $?

###

PODCASTS_SUBDIR_NAME="Podcasts"
PODCASTS_SOURCE_DIR="${HOME}/${PODCASTS_SUBDIR_NAME}"
[[ -d "${PODCASTS_SOURCE_DIR}" ]] || exit $?
PODCASTS_TARGET_DIR="${MOUNT_DIR}/Audio/${PODCASTS_SUBDIR_NAME}"

mkdir --parents --verbose -- "${PODCASTS_TARGET_DIR}" || exit $?
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
        exit $?

###

MUSIC_SUBDIR_NAME="Music"
MUSIC_SOURCE_DIR="${HOME}/${MUSIC_SUBDIR_NAME}"
[[ -d "${MUSIC_SOURCE_DIR}" ]] || exit $?
MUSIC_TARGET_DIR="${MOUNT_DIR}/Audio/${MUSIC_SUBDIR_NAME}"

mkdir --parents --verbose -- "${MUSIC_TARGET_DIR}" || exit $?
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
        exit $?

###

PLAYLISTS_SUBDIR_NAME="Playlists"
PLAYLIST_SOURCE_DIR="${HOME}/${PLAYLISTS_SUBDIR_NAME}"
[[ -d "${PLAYLIST_SOURCE_DIR}" ]] || exit $?
REAL_PLAYLIST_SOURCE_DIR="$(realpath "${PLAYLIST_SOURCE_DIR}")"
PLAYLIST_PARENT_DIR="$(dirname "${REAL_PLAYLIST_SOURCE_DIR}")"

mkdir --verbose -- "${PLAYLIST_STAGE_DIR}" || exit $?

PLAYLIST_TARGET_DIR="${MOUNT_DIR}/Audio"
mkdir --parents --verbose -- "${PLAYLIST_TARGET_DIR}" || exit $?

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
        done" || exit $?

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
        exit $?

echo The remainder of this script is not intended to be executed automatically but rather to serve as documentation. || exit $?
#
# # Enable "Use USB to" "Transfer files" option on the phone after connecting USB.
# # Eject the phone from File Manager (otherwise jmtpfs will core dump).
# jmtpfs "${HOME}/Phone/" || exit $?
# for TARGET in Pictures Podcasts Music Playlists
# do
#     mkdir --parents --verbose -- "${HOME}/Phone/xxx/${TARGET}" || exit $?
#     rsync-jmtpfs-verify \
#         --delete \
#         -- \
#         "${MOUNT_DIR}/${TARGET}/." "${HOME}/Phone/xxx/${TARGET}/." ||
#             exit $?
# done
# sync --file-system "${HOME}/Phone/xxx/." || exit $?
# sudo umount "${MOUNT_DIR}/" || exit $?
# fusermount -u "${HOME}/Phone/" || exit $?
# # Disable "Use USB to" "Transfer files" option on the phone.
