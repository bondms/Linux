#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?
VERSION=$1
[[ -n "${VERSION}" ]] || exit $?
echo "About to uninstall: ${VERSION}"

(
    trap "sudo --remove-timestamp" EXIT || exit $?

    sudo apt-get --yes purge `apt-cache pkgnames | grep -E -e "^linux\-headers\-${VERSION}\-" -e "^linux\-image\-${VERSION}\-"` ||
        exit $?

    sudo rm --force --recursive --verbose "/lib/modules/${VERSION}-server" ||
        exit $?
) || exit $?
