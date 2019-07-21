#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?
[[ -f "$1" ]] || exit $?

# Automatic replay gain in SoX doesn't appear to be supported
# for mp3 files, so disable it (for all files) and manually
# apply ReplayGain.
play "$1" --replay-gain off gain $(track-replay-gain.sh "$1") channels 1
