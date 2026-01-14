#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit 1
[[ -d "$1" ]] || exit 1

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

trap '' INT || exit 1

find -L "$1" -type f -iname "*.mp3" -print0 |
    sort --zero-terminated --random-sort |
    xargs --null --no-run-if-empty -I{} "${HERE}/play-with-track-replay-gain.sh" '{}'
