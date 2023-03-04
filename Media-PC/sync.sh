#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
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

sync --file-system "/media/bondms/rootfs/home/pi/." || exit 1

echo "*** SUCCESS ***"
