#!/bin/bash

HERE=$(readlink -e "$(dirname "$0")")
[[ -d "$HERE" ]] || exit $?

"${HERE}/music-pause.sh"
"${HERE}/audio-output-headset.sh"
