#!/bin/bash

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

bash "${HERE}/audio-ctl.sh" ".*Headset.*" "output:analog-stereo+input:analog-mono" || exit 1
