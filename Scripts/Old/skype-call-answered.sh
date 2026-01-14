#!/bin/bash

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

"${HERE}/music-pause.sh"
"${HERE}/audio-output-headset.sh"
