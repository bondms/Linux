#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

if [[ -e "${HOME}/podcast-sync-secrets.sh" ]]
then
  AUTH=$(cat -- "${HOME}/podcast-sync-secrets.sh" |
    while read -r line
    do
      if [[ "AUTH=" == "${line:0:5}" ]]
      then
        echo "${line:5}"
      fi
    done) || exit 1
else
  AUTH=$(gpg --decrypt -- "${HERE}/podcast-sync-secrets.sh.gpg" |
    while read -r line
    do
      if [[ "AUTH=" == "${line:0:5}" ]]
      then
        echo "${line:5}"
      fi
    done) || exit 1
fi
[[ -n "${AUTH}" ]] || exit 1

NAME="sn.rss"
SOURCE="https://twit.memberfulcontent.com/rss/9054?auth=${AUTH}"
INTERMEDIATE_DIR="${HOME}/RamDisk/Podcasts"
INTERMEDIATE_FILE="${INTERMEDIATE_DIR}/${NAME}"
TARGET_DIR="remote:Podcasts"

trap 'find "${INTERMEDIATE_DIR}" -delete' EXIT || exit 1
mkdir --parents --verbose "${INTERMEDIATE_DIR}" || exit 1

curl "${SOURCE}" > "${INTERMEDIATE_FILE}" || exit 1

rclone \
    --verbose \
    --human-readable \
    --checksum \
    sync "${INTERMEDIATE_DIR}/" "${TARGET_DIR}/" || exit 1
