#!/bin/bash

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "$HERE" ]] || exit $?

bash "${HERE}/audio-ctl.sh" "Clear Chat Comfort USB Headset" "output:analog-stereo+input:analog-mono" || exit $?
