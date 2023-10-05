#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit 1
VERSION=$1
[[ -n "${VERSION}" ]] || exit 1
echo "About to uninstall: ${VERSION}"

(
    trap "sudo --remove-timestamp" EXIT || exit 1

    sudo apt-get --yes purge "$(apt-cache pkgnames | grep -E -e "^linux\-headers\-${VERSION}\-" -e "^linux\-image\-${VERSION}\-")" ||
        exit 1

    sudo rm --force --recursive --verbose "/lib/modules/${VERSION}-server" ||
        exit 1
) || exit 1
