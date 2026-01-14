#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit 1
[[ -f "$1" ]] || exit 1

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

# Automatic replay gain in SoX doesn't appear to be supported
# for mp3 files, so disable it (for all files) and manually
# apply ReplayGain.
play "$1" --replay-gain off gain "$("${HERE}/track-replay-gain.sh" "$1")"
