#!/bin/bash

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

"${HERE}/link-cp.sh" "$@" || exit 1
rm -v -v "$1" || exit 1
