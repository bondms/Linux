#!/bin/bash

err_msg ()
{
    echo "`basename $0`: Error: $@" >&2
    exit 1
}

# Start with basic command-line.
CMDLINE="kvm -no-quit -usb -device usb-tablet"

# When launching as root, drop priveledges once running.
DROPPRIV=1

while [ -n "$1" ] && [ -z "${PASSTHROUGH}" ]
do
    case "$1" in
    ("-cdrom") CDROM="$2" ; shift ;;
    ("-cores") CORES="$2" ; shift ;;
    ("-folder") FOLDER="$2" ; shift ;;
    ("-isolate") ISOLATE=1 ;;
    ("-localtime") LOCALTIME=1 ;;
    ("-nooptimise") NOOPTIMISE=1 ;;
    ("-nosound") NOSOUND=1 ;;
    ("-novirtio") NOVIRTIO=1 ;;
    ("-ram") RAM="$2" ; shift ;;
    ("-smp") SMP="$2" ; shift ;;
    ("-snapshot") SNAPSHOT=1 ;;
    ("-sockets") SOCKETS="$2" ; shift ;;
    ("-usb") ROOT=1 ; DROPPRIV= ;;
    ("-usbdev") ROOT=1 ; USBDEV="$2" ; shift ;;
    ("-version") VERSION="$2" ; shift ;;
    ("--") PASSTHROUGH=1 ;;
    (*) err_msg "Unexpected argument: $1" ;;
    esac
    shift
done

if [ -z "${NOOPTIMISE}" ]
then
    echo "Using optimal CPU flags."
    CMDLINE="${CMDLINE} -cpu host"
else
    echo "Using basic CPU features."
fi

if [ -n "${CDROM}" ]
then
    if ! [ -f "${CDROM}" ]
    then
        err_msg "Failed to locate CD-ROM image file: ${CDROM}"
    fi
    CMDLINE="${CMDLINE} -cdrom ${CDROM}"
    echo "Attaching CD-ROM: ${CDROM}"
fi

if [ -z "${FOLDER}" ]
then
    err_msg "No folder supplied."
fi

if [ -n "${LOCALTIME}" ]
then
    CMDLINE="${CMDLINE} -localtime"
    echo "Using local time"
else
    echo "Using UTC time"
fi

if [ -n "${PASSTHROUGH}" ]
then
    echo "Passing through: $@"
    CMDLINE="${CMDLINE} $@"
fi

if [ -z "${RAM}" ]
then
    RAM="4096"
    echo "Using default RAM size: ${RAM}"
else
    echo "Using specified RAM size: ${RAM}"
fi
CMDLINE="${CMDLINE} -m ${RAM}"

if [ -n "${ROOT}" ]
then
    echo "Running as root."
    CMDLINE="sudo ${CMDLINE}"
    if [ -n "${DROPPRIV}" ]
    then
         CMDLINE="${CMDLINE} -runas `whoami`"
    fi
fi

if [ -z "${SMP}" ]
then
    SMP=`cat /proc/cpuinfo | grep "^processor[[:space:]]:[[:space:]][[:digit:]]*$" | sort -u | wc -l`
    echo "Using automatic SMP: ${SMP}"
else
    if [ "${SMP}" -eq "0" ]
    then
        echo "Not using SMP."
    else
        echo "Using specified SMP: ${SMP}"
    fi
fi

if [ -z "${CORES}" ]
then
    if [ -n "${SMP}" ] && [ "${SMP}" -ne 0 ]
    then
        CORES=`cat /proc/cpuinfo | grep "^cpu cores[[:space:]]:[[:space:]][[:digit:]]*$" | head -n 1 | cut -f 2 -d ":" | grep -o -P "(?<=^[[:space:]])[[:digit:]]*$"`
        echo "Using automatic cores: ${CORES}"
    else
        echo "No need to calculate cores (SMP is disabled)."
    fi
else
    echo "Using specified cores: ${CORES}"
fi

if [ -z "${SOCKETS}" ]
then
    if [ -n "${SMP}" ] && [ "${SMP}" -ne 0 ]
    then
        SOCKETS=`cat /proc/cpuinfo | grep "^physical id[[:space:]]:[[:space:]][[:digit:]]*$" | sort -u | wc -l`
        echo "Using automatic sockets: ${SOCKETS}"
    else
        echo "No need to calculate sockets (SMP is disabled)."
    fi
else
    echo "Using specified sockets: ${SOCKETS}"
fi

if [ -n "${SMP}" ] && [ "${SMP}" -ne 0 ]
then
    CMDLINE="${CMDLINE} -smp ${SMP}"
    if [ -n "${CORES}" ]
    then
        CMDLINE="${CMDLINE},cores=${CORES}"
    fi
    if [ -n "${SOCKETS}" ]
    then
        CMDLINE="${CMDLINE},sockets=${SOCKETS}"
    fi
else
    if [ -n "${CORES}" ]
    then
        err_msg "Can't specify cores when SMP is disabled."
    fi
    if [ -n "${SOCKETS}" ]
    then
        err_msg "Can't specify sockets when SMP is disabled."
    fi
fi

if [ -n "${SNAPSHOT}" ]
then
    CMDLINE="${CMDLINE} -snapshot"
    echo "Running in non-persistent mode."
else
    echo "Running in persistent mode."
fi

if [ -z "${NOSOUND}" ]
then
    CMDLINE="${CMDLINE} -soundhw all"
    echo "Sound support enabled."
else
    echo "Sound support not enabled."
fi

CMDLINE="${CMDLINE} -net nic"
if [ -z "${NOVIRTIO}" ]
then
    echo "Using VirtIO NIC."
    CMDLINE="${CMDLINE},model=virtio"
fi
CMDLINE="${CMDLINE} -net user"

if [ -n "${ISOLATE}" ]
then
    echo "Isolating user-stack network."
    CMDLINE="${CMDLINE},restrict=y"
else
    echo "Connecting network."
fi

if [ -n "${USBDEV}" ]
then
    CMDLINE="${CMDLINE} -usbdevice ${USBDEV}"
    echo "Attaching USB device: ${USBDEV}"
fi

if [ -z "${VERSION}" ]
then
    err_msg "No version supplied."
fi

IMAGE="${VERSION}.hdd"

if ! [ -e "${FOLDER}/${IMAGE}" ]
then
    echo "${VERSION}" | grep -F "." > /dev/null || TOP=1
    if [ -n "${TOP}" ]
    then
        if [ -n "${SNAPSHOT}" ]
        then
            err_msg "Non-persistent mode doesn't make sense when there's no existing top-level disk."
        fi
        echo "Creating new top-level disk: ${VERSION}"

        echo qemu-img create -f qcow2 "${FOLDER}/${IMAGE}"
        qemu-img create -f qcow2 "${FOLDER}/${IMAGE}" 128G
        if [ $? -ne 0 ]
        then
            err_msg "Failed to create base disk."
        fi
    else
        if [ -n "${SNAPSHOT}" ]
        then
            err_msg "Non-persistent mode doesn't make sense when there's no existing differencing disk."
        fi
        echo "Creating new differencing disk: ${VERSION}"

        PARENTVERSION=`echo "${VERSION}" | awk -F "." '{ for ( i = 1 ; i < NF - 1 ; i++ ) { printf("%s.", $i) } printf("%s", $(NF-1)) }'`
        PARENTIMAGE="${PARENTVERSION}.hdd"

        echo "Differencing from: ${PARENTVERSION}"

        chmod a-w "${FOLDER}/${PARENTIMAGE}"
        if [ $? -ne 0 ]
        then
            err_msg "Failed to write-protect parent disk."
        fi

        # In order to use a relative path in the differencing disk for the base, we need to create the differencing disk in whilst in the target FOLDER.
        SAVEDIR="`pwd`"
        cd "${FOLDER}"
        if [ $? -ne 0 ]
        then
            err_msg "Failed to change to target FOLDER."
        fi

        qemu-img create -f qcow2 -b "./${PARENTIMAGE}" "./${IMAGE}"
        if [ $? -ne 0 ]
        then
            err_msg "Failed to create differencing disk."
        fi

        cd "${SAVEDIR}"
    fi
else
    echo "Using existing disk: ${VERSION}"

    if [ -z "${SNAPSHOT}" ]
    then
        CHILDREN=`find "${FOLDER}" -maxdepth 1 -name "${VERSION}.*.hdd"`
        if [ -n "${CHILDREN}" ]
        then
            err_msg "Cannot execute image that has children unless snapshot is specified."
        fi
    fi
fi

# Writeback caching is less safe than writethrough but is important for reasonable performance with qcow2 disk images.
CMDLINE="${CMDLINE} -drive file=${FOLDER}/${IMAGE},cache=writeback"
if [ -z "${NOVIRTIO}" ]
then
    echo "Using VirtIO storage."
    CMDLINE="${CMDLINE},if=virtio"
fi

CMDLINE="${CMDLINE} -boot menu=on"

# Execute the machine.
${CMDLINE}
