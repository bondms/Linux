#!/bin/bash

# Copies mp3 files from SOURCE to TARGET:
# - Files are copied in a random order and assigned sequential names so that they will play (in the same) random order on devices that use either name or filesystem ordering.
# - Symbolic links are dereferenced (so that playlists can be copied to other devices).
# - Replay gain is applied.
# - Stops on first error and cleans up potentially partially copied file (e.g. when target becomes full).

set -eux || exit $?
set -o pipefail || exit $?

[[ $# -eq 2 ]] || exit $?
SOURCE=$1
[[ -d "${SOURCE}" ]] || exit $?
TARGET=$2
[[ -d "${TARGET}" ]] || exit $?

HERE="$(readlink -e "$(dirname "${0}")")"
[[ -d "${HERE}" ]] || exit $?

find -L "${SOURCE}" -type f -iname "*.mp3" -print0 |
    sort --random-sort --zero-terminated |
    bash -c "
        while read -r -d $'\0' F
        do
            (( ++COUNT )) || exit $?
            printf -v BASE \"%08d\" \"\${COUNT}\" || exit $?
            \"${HERE}/replay-gain-copy.sh\" \"\${F}\" \"${TARGET}/\${BASE}.mp3\" ||
                {
                    rm --force --verbose \"${TARGET}/\${BASE}.mp3\"
                    exit 255
                }
        done
        " || exit $?
