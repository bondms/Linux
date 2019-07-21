#!/bin/bash

set -eux
set -o pipefail

MAX_SPACE_USAGE=$(command df |
    tail --lines=+2 |
    grep -v "^/dev/loop" |
    awk '{ print $5 ; }' |
    sort --numeric-sort |
    tail --lines=1)
MAX_SPACE_USAGE="${MAX_SPACE_USAGE%\%}"
[[ -n "${MAX_SPACE_USAGE}" ]] || exit $?

[[ "${MAX_SPACE_USAGE}" -le 80 ]] || exit $?

MAX_INODE_USAGE=$(command df --inodes |
    tail --lines=+2 |
    grep -v "^/dev/loop" |
    awk '{ print $5 ; }' |
    sort --numeric-sort |
    tail --lines=1)
MAX_INODE_USAGE="${MAX_INODE_USAGE%\%}"
[[ -n "${MAX_INODE_USAGE}" ]] || exit $?

[[ "${MAX_INODE_USAGE}" -le 80 ]] || exit $?

