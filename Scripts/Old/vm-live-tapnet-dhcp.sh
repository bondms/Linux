#!/bin/bash

LOCATION=`dirname $0`
if ! echo "${LOCATION}" | grep -E -e "^/" > /dev/null
then
    LOCATION=`pwd`/${LOCATION}
fi

err_msg ()
{
    echo "`basename $0`: Error: $@" >&2
    exit 1
}

if [ $# -lt 1 ]
then
    err_msg "No image supplied."
fi
IMAGE=$1
shift

# Fixed Organizationally Unique Identifier (OUI) part:
MACADDROUI="52:54:00"

# Random Network Interface Controller (NIC) Specific part:
ONE=$((${RANDOM}%100))
TWO=$((${RANDOM}%100))
THREE=$((${RANDOM}%100))
MACADDRNIC="${ONE}:${TWO}:${THREE}"

MACADDR="${MACADDROUI}:${MACADDRNIC}"
echo "Using MAC address: ${MACADDR}"

SMP=`cat /proc/cpuinfo | grep "^processor[[:space:]]:[[:space:]][[:digit:]]*$" | sort -u | wc -l`
echo "Using automatic SMP: ${SMP}"
CORES=`cat /proc/cpuinfo | grep "^cpu cores[[:space:]]:[[:space:]][[:digit:]]*$" | head -n 1 | cut -f 2 -d ":" | grep -o -P "(?<=^[[:space:]])[[:digit:]]*$"`
echo "Using automatic cores: ${CORES}"
SOCKETS=`cat /proc/cpuinfo | grep "^physical id[[:space:]]:[[:space:]][[:digit:]]*$" | sort -u | wc -l`
echo "Using automatic sockets: ${SOCKETS}"

sudo kvm \
    -cdrom "${IMAGE}" \
    -cpu host \
    -m 4096 \
    -net nic,macaddr=${MACADDR},model=virtio -net tap,script=/usr/local/bin/qemu-ifup-dhcp,downscript=/usr/local/bin/qemu-ifdown-dhcp \
    -no-quit \
    -runas `whoami` \
    -smp "${SMP},cores=${CORES},sockets=${SOCKETS}" \
    -soundhw all \
    -usb -usbdevice tablet \
    $@

