#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

for subdir in "Music" "Pictures" "Playlists" "Podcasts"
do
    mkdir --parents -- "/media/bondms/rootfs/home/pi/${subdir}" || exit $?
    rsync --archive --human-readable --itemize-changes --checksum -- "${HOME}/${subdir}/." "/media/bondms/rootfs/home/pi/${subdir}/." || exit $?
done

echo "*** SUCCESS ***"
