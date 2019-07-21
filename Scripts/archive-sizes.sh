#!/bin/bash

set -eu
set -o pipefail

ARCHIVE_DIR_PATH="${HOME}/Archive"

find "${ARCHIVE_DIR_PATH}/${USER}" -regextype posix-basic -type d -regex "^${ARCHIVE_DIR_PATH}/${USER}\/[[:digit:]]\{8\}-[[:digit:]]\{6\}$" |
    sort --reverse |
    xargs --no-run-if-empty du --si --max-depth=0
