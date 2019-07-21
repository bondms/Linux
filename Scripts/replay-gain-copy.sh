#!/bin/bash

set -eux || exit $?
set -o pipefail || exit $?

[[ $# -eq 2 ]] || exit $?
SOURCE=$1
[[ -f "${SOURCE}" ]] || exit $?
TARGET=$2
[[ ! -e "${TARGET}" ]] || exit $?

HERE="$(readlink -e "$(dirname "${0}")")"
[[ -d "${HERE}" ]] || exit $?

GAIN="$("${HERE}/track-replay-gain.sh" "${SOURCE}")"
[[ -n "${GAIN}" ]] || exit $?

sox --replay-gain off "${SOURCE}" "${TARGET}" gain "${GAIN}" || exit $?
