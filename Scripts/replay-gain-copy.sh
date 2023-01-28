#!/bin/bash

set -eux || exit 1
set -o pipefail || exit 1

[[ $# -eq 2 ]] || exit 1
SOURCE=$1
[[ -f "${SOURCE}" ]] || exit 1
TARGET=$2
[[ ! -e "${TARGET}" ]] || exit 1

HERE="$(readlink -e "$(dirname "${0}")")"
[[ -d "${HERE}" ]] || exit 1

GAIN="$("${HERE}/track-replay-gain.sh" "${SOURCE}")"
[[ -n "${GAIN}" ]] || exit 1

sox --replay-gain off "${SOURCE}" "${TARGET}" gain "${GAIN}" || exit 1
