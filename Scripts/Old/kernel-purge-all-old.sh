#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "$HERE" ]] || exit 1

VERSIONRE="[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+-[[:digit:]]+"
PREFIX="vmlinuz-"
SUFFIXRE="-generic(-pae)?"
NAMERE="${PREFIX}${VERSIONRE}${SUFFIXRE}"
FOLDER="/boot/"

find "${FOLDER}" -maxdepth 1 -regextype posix-extended -regex "^${FOLDER}${NAMERE}$" -printf "%p\n" |
    grep --perl-regexp --only-matching "(?<=^${FOLDER}${PREFIX})${VERSIONRE}${SUFFIXRE}$" |
    awk -F "[.-]" '{ printf "%05d.%05d.%05d.%05d\t%s.%s.%s-%s\n", $1, $2, $3, $4, $1, $2, $3, $4 }' |
    sort --reverse |
    awk -F "\t" '{ printf "%s\n", $2 }' |
    awk '{ if ( NR > 2 ) { print } }' |
    xargs --no-run-if-empty "${HERE}/kernel-purge.sh" ||
    exit $?
