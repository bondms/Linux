#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?
[[ -d "$1" ]] || exit $?

HERE=$(readlink -e "$(dirname "$0")")
[[ -d "${HERE}" ]] || exit $?

find -L "$1" -type f -iname "*.mp3" -print0 |
    sort --zero-terminated --random-sort |
    xargs --null --no-run-if-empty -I{} "${HERE}/play-with-track-replay-gain.sh" '{}'
