#!/bin/bash

HERE=$(readlink -e "$(dirname "$0")")
[[ -d "$HERE" ]] || exit $?

"${HERE}/link-cp.sh" "$@" || exit $?
rm -v -v "$1" || exit $?
