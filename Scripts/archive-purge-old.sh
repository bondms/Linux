#!/bin/bash

set -eux
set -o pipefail

ARCHIVE_DIR_PATH="${HOME}/Archive"

find "${ARCHIVE_DIR_PATH}/${USER}" -mindepth 1 -maxdepth 1 -type d -regextype posix-basic -regex "^${ARCHIVE_DIR_PATH}/${USER}\/[[:digit:]]\{8\}-[[:digit:]]\{6\}$" |
    LC_ALL=C sort --reverse |
    awk '{ if ( (NR > 5) && ((NR % 2) == 0) ) { print } } END { if ( (NR > 5) && ((NR % 2) != 0) ) { print } }' |
    xargs --no-run-if-empty rm --recursive --verbose || exit 1
