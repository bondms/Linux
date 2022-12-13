#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

for subdir in "Music" "Pictures" "Playlists" "Podcasts"
do
    mkdir --parents -- "/media/bondms/rootfs/home/pi/${subdir}" || exit $?
    rsync \
        --archive \
        --verbose \
        --human-readable \
        --itemize-changes \
        --checksum \
        --delete \
        --exclude "/Screenshots/" \
        -- \
        "${HOME}/${subdir}/." "/media/bondms/rootfs/home/pi/${subdir}/." || exit $?
done

sync --file-system "/media/bondms/rootfs/home/pi/." || exit $?

echo "*** SUCCESS ***"
