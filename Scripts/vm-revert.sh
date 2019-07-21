#!/bin/sh

err_msg ()
{
    echo "`basename $0`: Error: $@" >&2
    exit 1
}

while [ -n "$1" ]
do
    case "$1" in
    ("-folder") FOLDER="$2" ; shift ;;
    ("-version") VERSION="$2" ; shift ;;
    (*) err_msg "Unexpected argument: $1" ;;
    esac
    shift
done

if [ -z "${FOLDER}" ]
then
    err_msg "No folder supplied."
fi

if [ -z "${VERSION}" ]
then
    err_msg "No version supplied."
fi

CHILDREN=`find "${FOLDER}" -name "${VERSION}.*.hdd"`
if [ -n "${CHILDREN}" ]
then
    err_msg "Revert children first."
fi

IMAGE="${VERSION}.hdd"

if [ -e "${FOLDER}/${IMAGE}" ]
then
    rm --verbose "${FOLDER}/${IMAGE}"
    if [ $? -ne 0 ]
    then
      err_msg "Failed to delete disk."
    fi
else
    err_msg "No disk to revert."
fi
