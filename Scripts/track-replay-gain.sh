#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?
[[ -f "$1" ]] || exit $?

replaygain --show "${1}" 2>&1 |
    grep --only-matching --perl-regex --ignore-case "(?<=Track gain ).*" |
    grep --only-matching --perl-regex ".*(?= dB)" || exit $?
