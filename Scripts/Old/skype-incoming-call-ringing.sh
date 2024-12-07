#!/bin/bash

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

"${HERE}/music-pause.sh"
