#!/bin/bash

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

bash "${HERE}/audio-ctl.sh" "Built-in Audio" "output:hdmi-stereo+input:analog-stereo" || exit 1
