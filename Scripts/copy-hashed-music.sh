#!/bin/bash

# Copies files from SOURCE to TARGET:
# - Only .mp3 files are copied.
# - Files are copied in a random order and hashed names so that they will play randomly on devices
#   that use either name or filesystem ordering. A hash (rather than a random) name is used so that
#   the same file will always have the same name, allowing copies to be performed in multiple sessions
#   without creating duplicate copies of the same song with different names.
# - Symbolic links are dereferenced (so that playlists can be copied to other devices).
# - On first error (to handle, for example, lack of space on target device) partially copied file is cleaned up and copying aborts.
# - Uses base-36 to shorten filenames. Base-36 offers a larger alphabet than base-16 (the default output of the sha checksum)
#   but is still case in-sensitive, maintaining compatibility with VFAT.

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "$HERE" ]] || exit 1

[[ $# -eq 2 ]] || exit 1
SOURCE=$1
TARGET=$2
[[ -d $SOURCE ]] || exit 1
[[ -d $TARGET ]] || exit 1

find -L "$SOURCE" \
    -type f \
    -iname "*.mp3" \
    -print0 |
    sort --random-sort --zero-terminated |
    bash -c "
        while read -r -d $'\0' F
        do
            EXT=\$(echo \"\$F\" | grep --only-matching '[^\.]*$')
            BASE=\$(openssl dgst -sha1 \"\$F\" | grep --perl-regexp --only-matching \"(?<=\= )[^\= ]*$\")
            BASE=\$(python \"${HERE}/base16to36.py\" \"\$BASE\")
            cp --dereference --no-clobber --verbose \
                \"\$F\" \"$TARGET/\$BASE.\$EXT\" ||
                {
                    rm --force --verbose \"$TARGET/\$BASE.\$EXT\"
                    exit 255
                }
        done
        " || exit 1
