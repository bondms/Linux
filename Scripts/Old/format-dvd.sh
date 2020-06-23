#!/bin/sh

err_msg ()
{
    echo "$(basename "$0"): Error: $*" >&2
    exit 1
}

if ! which mkudffs
then
    sudo apt-get install udftools || err_msg "Failed to install package."

    # Installing this package seemed to break the symlinks. Fix them,
    if ! [ -e /dev/cdrom ]
    then
        sudo ln -sv sr0 /dev/cdrom || err_msg "Failed to create cdrom symlink."
    fi

    if ! [ -e /dev/dvd ]
    then
        sudo ln -sv sr0 /dev/cdrom || err_msg "Failed to create dvd symlink."
    fi
fi

if [ $# -ne 1 ]
then
    err_msg "Usage: $0 <label>"
fi

LABEL="$1"
echo "Formatting /dev/dvd with label: ${LABEL}"

mkudffs --utf8 --media-type=dvdram --lvid="${LABEL}" --vid="${LABEL}" --vsid="${LABEL}" --fsid="${LABEL}" /dev/dvd ||
    err_msg "Failed to format."
