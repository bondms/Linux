#!/bin/bash

set -eu
set -o pipefail

USER_ARCHIVE_DIR_PATH="${HOME}/Archive/${USER}"

find "${USER_ARCHIVE_DIR_PATH}" -regextype posix-basic -type d -regex "^${USER_ARCHIVE_DIR_PATH}\/[[:digit:]]\{8\}-[[:digit:]]\{6\}$" |
    sort --reverse |
    xargs --no-run-if-empty du --si --max-depth=0

echo -----

find "${USER_ARCHIVE_DIR_PATH}" -regextype posix-basic -type d -regex "^${USER_ARCHIVE_DIR_PATH}\/[[:digit:]]\{8\}-[[:digit:]]\{6\}$" |
    sort --reverse |
    xargs --max-args 1 --no-run-if-empty du --si --max-depth=0
