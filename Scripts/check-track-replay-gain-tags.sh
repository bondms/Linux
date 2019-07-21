#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?
[[ -d "${1}" ]] || exit $?

HERE="$(readlink -e "$(dirname "${0}")")"
[[ -d "${HERE}" ]] || exit $?

find "${1}" -type f -iname "*.mp3" -print0 | bash -c "
    while read -r -d $'\0' F
    do
        \"${HERE}/track-replay-gain.sh\" \"\${F}\" || exit 255
        echo \"\$F\"
    done" || exit $?
