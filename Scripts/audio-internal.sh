#!/bin/bash

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "$HERE" ]] || exit $?

bash "${HERE}/audio-ctl.sh" "Built-in Audio" "output:analog-stereo+input:analog-stereo" || exit $?
