#!/bin/bash

# Copies jpeg files from SOURCE to TARGET:
# - Files are copied in a random order and assigned sequential names so that they will play (in the same) random order on devices that use either name or filesystem ordering.
# - Symbolic links are dereferenced (so that playlists can be copied to other devices).
# - Stops on first error and cleans up potentially partially copied file (e.g. when target becomes full).

set -eux || exit $?
set -o pipefail || exit $?

[[ $# -eq 3 ]] || exit $?
SOURCE=$1
[[ -d "${SOURCE}" ]] || exit $?
TARGET=$2
[[ -d "${TARGET}" ]] || exit $?
LIMIT=$3
(( LIMIT>0 && LIMIT<=300 )) || exit $?

HERE="$(readlink -e "$(dirname "${0}")")"
[[ -d "${HERE}" ]] || exit $?

find -L "${SOURCE}" -type f -iname "*.jpg" -print0 |
    sort --random-sort --zero-terminated |
    bash -c "
        while read -r -d $'\0' F
        do
            (( ++COUNT )) || exit $?
            (( COUNT < ${LIMIT})) || exit 0
            printf -v BASE \"%08d\" \"\${COUNT}\" || exit $?
            cp --dereference --interactive --verbose -- \"\${F}\" \"${TARGET}/\${BASE}.jpg\" ||
                {
                    rm --force --verbose \"${TARGET}/\${BASE}.jpg\"
                    exit 255
                }
        done
        " || exit $?
