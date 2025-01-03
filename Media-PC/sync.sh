#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

[[ -d "/media/bondms/rootfs/home/pi" ]] || exit 1

for subdir in "Music" "Pictures" "Playlists" "Podcasts"
do
    mkdir --parents -- "/media/bondms/rootfs/home/pi/${subdir}" || exit 1
    rsync \
        --archive \
        --verbose \
        --human-readable \
        --itemize-changes \
        --checksum \
        --delete \
        --exclude "/Screenshots/" \
        -- \
        "${HOME}/${subdir}/." "/media/bondms/rootfs/home/pi/${subdir}/." || exit 1
done

mkdir --parents -- "/media/bondms/rootfs/home/pi/Videos/Pi/." || exit 1
rsync \
    --archive \
    --verbose \
    --human-readable \
    --itemize-changes \
    --checksum \
    --delete \
    -- \
    "${HOME}/Videos/Pi/." "/media/bondms/rootfs/home/pi/Videos/Pi/." || exit 1

sync --file-system "/media/bondms/rootfs/home/pi/." || exit 1

echo "*** SUCCESS ***"
