#!/bin/sh

err_msg ()
{
    echo "$(basename "$0"): Error: "$@"" >&2
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

IMAGE="${VERSION}.hdd"

if ! [ -e "${FOLDER}/${IMAGE}" ]
then
    err_msg "No differencing disk to commit."
fi

echo "${VERSION}" | grep -F "." > /dev/null || TOP=1
if [ -n "${TOP}" ]
then
    err_msg "Cannot commit top-level disk."
fi

CHILDREN=$(find "${FOLDER}" -name "${VERSION}.*.hdd")
if [ -n "${CHILDREN}" ]
then
    err_msg "Cannot commit image that has children."
fi

PARENTVERSION=$(echo "${VERSION}" | awk -F "." '{ for ( i = 1 ; i < NF - 1 ; i++ ) { printf("%s.", $i) } printf("%s", $(NF-1)) }')
PARENTIMAGE="${PARENTVERSION}.hdd"

SIBLINGS=$(find "${FOLDER}" -name "${PARENTVERSION}.*.hdd" ! -name "${IMAGE}")
if [ -n "${SIBLINGS}" ]
then
    err_msg "Cannot commit image that has siblings."
fi

echo "Committing"
/bin/ls -l --si "${FOLDER}/${IMAGE}"
echo "to parent"
/bin/ls -l --si "${FOLDER}/${PARENTIMAGE}"

chmod u+w "${FOLDER}/${IMAGE}" || err_msg "Failed to write-enable disk."

chmod u+w "${FOLDER}/${PARENTIMAGE}" || err_msg "Failed to write-enable parent disk."

qemu-img commit "${FOLDER}/${IMAGE}" || err_msg "Failed to commit changes."

echo "Commited to parent"
/bin/ls -l --si "${FOLDER}/${PARENTIMAGE}"

chmod a-w "${FOLDER}/${PARENTIMAGE}" || err_msg "Failed to write-protect parent disk."

rm "${FOLDER}/${IMAGE}" || err_msg "Failed to delete child disk."
