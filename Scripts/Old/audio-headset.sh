#!/bin/bash

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

bash "${HERE}/audio-ctl.sh" "Clear Chat Comfort USB Headset" "output:analog-stereo+input:analog-mono" || exit 1
