#!/bin/bash

HERE=$(readlink -e "$(dirname "$0")")
[[ -d "$HERE" ]] || exit 1

"${HERE}/music-pause.sh"
