#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?
[[ -f "$1" ]] || exit $?

bs1770gain --list "${1}" 2>&1 |
    grep --only-matching --perl-regex --ignore-case "(?<=REPLAYGAIN_TRACK_GAIN: ).*" |
    grep --only-matching --perl-regex ".*(?= dB)" || exit $?
