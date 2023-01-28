#!/bin/bash

# Copies mp3 files from SOURCE to TARGET:
# - Files are copied in a random order and assigned sequential names so that they will play (in the same) random order on devices that use either name or filesystem ordering.
# - Symbolic links are dereferenced (so that playlists can be copied to other devices).
# - Replay gain is applied.
# - Stops on first error and cleans up potentially partially copied file (e.g. when target becomes full).

set -eux || exit 1
set -o pipefail || exit 1

(( $# >= 2 && $# <= 3 )) || exit 1
SOURCE=$1
[[ -d "${SOURCE}" ]] || exit 1
TARGET=$2
[[ -d "${TARGET}" ]] || exit 1
if (( $# >= 3 )) ; then
  LIMIT=$3
else
  LIMIT=300
fi
(( LIMIT>0 && LIMIT<=600 )) || exit 1

HERE="$(readlink -e "$(dirname "${0}")")"
[[ -d "${HERE}" ]] || exit 1

find -L "${SOURCE}" -type f -iname "*.mp3" -print0 |
    sort --random-sort --zero-terminated |
    bash -c "
        while read -r -d $'\0' F
        do
            (( ++COUNT )) || exit 1
            (( COUNT <= ${LIMIT})) || exit 0
            printf -v BASE \"%08d\" \"\${COUNT}\" || exit 1
            bash \"${HERE}/replay-gain-mono-copy.sh\" \"\${F}\" \"${TARGET}/\${BASE}.mp3\" ||
                {
                    rm --force --verbose \"${TARGET}/\${BASE}.mp3\"
                    exit 255
                }
        done
        " || exit 1
