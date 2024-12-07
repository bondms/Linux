#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit 1
[[ -f "$1" ]] || exit 1

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

"${HERE}/replaygain" --show "${1}" 2>&1 |
    grep --only-matching --perl-regex --ignore-case "(?<=Track gain ).*" |
    grep --only-matching --perl-regex ".*(?= dB)" || exit 1
