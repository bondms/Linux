#!/bin/bash

HERE="$(readlink -f "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

git config --list --global | sort > "${HERE}/global_settings.txt" || exit $?
