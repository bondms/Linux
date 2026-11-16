#!/bin/bash

set -eux
set -o pipefail

USER_ARCHIVE_DIR_PATH="${HOME}/Archive/${USER}"

[[ -z $(find "${USER_ARCHIVE_DIR_PATH}" -type d ! -perm -u=w) ]] || exit 1

find "${USER_ARCHIVE_DIR_PATH}" -mindepth 1 -maxdepth 1 -type d -regextype posix-basic -regex "^${USER_ARCHIVE_DIR_PATH}\/[[:digit:]]\{8\}-[[:digit:]]\{6\}$" |
    LC_ALL=C sort --reverse |
    awk '{ if ( (NR > 5) && ((NR % 2) == 0) ) { print } } END { if ( (NR > 5) && ((NR % 2) != 0) ) { print } }' |
    xargs --no-run-if-empty rm --recursive --verbose || exit 1
