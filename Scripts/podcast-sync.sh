#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

gpg --decrypt -- "${HERE}/podcast-sync-secrets.sh.gpg" | \
  while read command
  do
    if [[ "#" == "${command}" ]]
    then
      ${command}
    fi
  done

SOURCE="https://twit.memberfulcontent.com/rss/9054?auth=${AUTH}"
TARGET="remote:Podcasts/sn.rss"

curl "${SOURCE}" | rclone rcat "${TARGET}" || exit 1
