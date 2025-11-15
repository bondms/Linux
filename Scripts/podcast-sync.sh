#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

AUTH=$(gpg --decrypt -- "${HERE}/podcast-sync-secrets.sh.gpg" |
  while read line
  do
    if [[ "AUTH=" == "${line:0:5}" ]]
    then
      echo "${line:5}"
    fi
  done) || exit 1

[[ -n "${AUTH}" ]] || exit 1

SOURCE="https://twit.memberfulcontent.com/rss/9054?auth=${AUTH}"
TARGET="remote:Podcasts/sn.rss"

curl "${SOURCE}" | rclone rcat "${TARGET}" || exit 1
