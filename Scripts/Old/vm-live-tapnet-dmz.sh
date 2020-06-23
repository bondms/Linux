#!/bin/bash

# The DMZ network is not served by DHCP.
# To access the internet, configure the following static IP parameters:
# IPv4 address: 172.18.x.x (e.g. 172.18.1.1)
# netmask: 255.255.0.0
# gateway: 172.18.0.1
# DNS: As appropriate. May be found in /etc/resolv.conf (e.g. for Virgin Broadband: 194.168.4.100,194.168.8.100)

LOCATION=$(dirname "$0")
if ! echo "${LOCATION}" | grep -E -e "^/" > /dev/null
then
    LOCATION=$(pwd)/${LOCATION}
fi

err_msg ()
{
    echo "$(basename "$0"): Error: $*" >&2
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
ONE=$((RANDOM % 100))
TWO=$((RANDOM % 100))
THREE=$((RANDOM % 100))
MACADDRNIC="${ONE}:${TWO}:${THREE}"

MACADDR="${MACADDROUI}:${MACADDRNIC}"
echo "Using MAC address: ${MACADDR}"

SMP=$(grep "^processor[[:space:]]:[[:space:]][[:digit:]]*$" /proc/cpuinfo | sort -u | wc -l)
echo "Using automatic SMP: ${SMP}"
CORES=$(grep "^cpu cores[[:space:]]:[[:space:]][[:digit:]]*$" /proc/cpuinfo | head -n 1 | cut -f 2 -d ":" | grep -o -P "(?<=^[[:space:]])[[:digit:]]*$")
echo "Using automatic cores: ${CORES}"
SOCKETS=$(grep "^physical id[[:space:]]:[[:space:]][[:digit:]]*$" /proc/cpuinfo | sort -u | wc -l)
echo "Using automatic sockets: ${SOCKETS}"

sudo kvm \
    -cdrom "${IMAGE}" \
    -cpu host \
    -m 4096 \
    -net nic,macaddr=${MACADDR},model=virtio -net tap,script=/usr/local/bin/qemu-ifup-dmz,downscript=/usr/local/bin/qemu-ifdown-dmz \
    -no-quit \
    -runas "$(whoami)" \
    -smp "${SMP},cores=${CORES},sockets=${SOCKETS}" \
    -soundhw all \
    -usb -usbdevice tablet \
    "$@"
