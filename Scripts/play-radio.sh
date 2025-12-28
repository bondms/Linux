#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit 1

pushd "${HOME}/RamDisk/" || exit 1
trap 'popd' 0 || exit 1
find "${PWD}/." -mindepth 1 -maxdepth 1 -name "wget-log*" -size 0c -delete || exit 1
trap 'find "${PWD}/." -mindepth 1 -maxdepth 1 -name "wget-log*" -size 0c -delete' 0 || exit 1
play -t mp3 "${1}" || exit 1
popd || exit 1
