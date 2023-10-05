#!/bin/bash

set -eux
set -o pipefail

ARCHIVE_DIR_PATH="${HOME}/Archive"

SOURCE="${ARCHIVE_DIR_PATH}/${USER}/latest/"
[[ -d "${SOURCE}" ]] || exit 1

TARGET="${ARCHIVE_DIR_PATH}/${USER}/$(date '+%Y%m%d-%H%M%S')"
[[ ! -d "${TARGET}" ]] || exit 1

cp --archive --interactive --link --verbose -- "${SOURCE}" "${TARGET}" ||
    exit 1
