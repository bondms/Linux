#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

[[ ! -d "/home/pi" ]] || exit 1
[[ -f /etc/debian_version ]] || grep -F "Ubuntu" /etc/lsb-release || exit 1
[[ ! -d "${HOME}/Archive" ]] || exit 1

mkdir --parents --verbose -- "${HOME}/Archive" || exit 1

rsync \
    --archive \
    --checksum \
    --hard-links \
    --human-readable \
    --itemize-changes \
    --progress \
    --sparse \
    --verbose \
    -- \
    /media/bondms/BackupSsd/ ~/Archive/bondms/ || exit 1

rsync \
    --archive \
    --checksum \
    --hard-links \
    --human-readable \
    --itemize-changes \
    --progress \
    --sparse \
    --verbose \
    -- \
    "${HOME}/Archive/bondms/latest/" "${HOME}/Backup/" || exit 1

"${HOME}/Backup/Documents/Archive/Programming/Git/Linux/setup.sh"
