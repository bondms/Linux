#!/bin/bash

HERE=$(readlink -e "$(dirname "$0")")
[[ -d "$HERE" ]] || exit 1

"${HERE}/link-cp.sh" "$@" || exit 1
rm -v -v "$1" || exit 1
