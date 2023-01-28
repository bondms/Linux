#!/bin/bash

# TODO:
# - Recover from a failed power-on (e.g. if power switched off).
# - Allow multiple and/or repeating schedules.
# - Warn about powering down when recording in progress.
# - Warn about scheduled power-down when logged in.

set -eux || exit 1
set -o pipefail || exit 1

[[ $# -ge 2 ]] || exit 1
START_TIME=$1 ; shift
END_TIME=$1 ; shift

while [[ $# -gt 0 ]]
do
    case "${1}" in
        "power-on") POWER_ON=1 ;;
        "power-off" ) POWER_OFF=1 ;;
        "overwrite" ) OVERWRITE=1 ;;
        * ) echo "Unknown argument: $1" >&2 ; exit 1 ;;
    esac
    shift
done

ROUNDED_START_TIME=$(date --date="${START_TIME}" +"%F %R")
ROUNDED_END_TIME=$(date --date="${END_TIME}" +"%F %R")

AT_START_TIME=$(date --date="${ROUNDED_START_TIME}" +"%R %F")

START_EPOCH=$(date --date="${ROUNDED_START_TIME}" +"%s")
END_EPOCH=$(date --date="${ROUNDED_END_TIME}" +"%s")

DURATION_SECONDS=$(( END_EPOCH - START_EPOCH ))
DURATION_MINUTES=$(( DURATION_SECONDS / 60 ))
[[ "${DURATION_MINUTES}" -ge 1 ]] || exit 1
[[ "${DURATION_MINUTES}" -le 1440 ]] || exit 1

if [[ -d "/home/${USER}-unencrypted/Recordings" ]]
then
    # Use unencrypted folder for cases where use may not have logged on to decrypt home folder.
    TARGET_DIR="/home/${USER}-unencrypted/Recordings"
else
    # Media PC is always on and logged in, so home folder should always be accessible
    TARGET_DIR="${HOME}/Recordings"
fi
[[ -d "${TARGET_DIR}" ]] || exit 1

if [[ -n "${OVERWRITE:-}" ]]
then
    TARGET="${TARGET_DIR}/radio-varna.mp3"
    CLOBBER="--clobber"
else
    TARGET_DATE=$(date --date="${ROUNDED_START_TIME}" --iso-8601=date)
    [[ -n "${TARGET_DATE}" ]] || exit 1
    TARGET="${TARGET_DIR}/radio-varna-${TARGET_DATE}.mp3"
    [[ ! -e "${TARGET}" ]] || exit 1
    CLOBBER="--no-clobber"
fi

RECORD_CMD="sox ${CLOBBER} --type mp3 http://broadcast.masters.bg:8000/live \"${TARGET}\" trim 0 ${DURATION_SECONDS}"

pushd "${TARGET_DIR}" || exit 1

at -M "${AT_START_TIME}" << EOF || exit 1
${RECORD_CMD}
EOF

if [[ -n "${POWER_OFF:-}" ]]
then
    DURATION_FOR_SHUTDOWN=$(( DURATION_MINUTES + 1 ))
    [[ "${DURATION_FOR_SHUTDOWN}" -ge 2 ]] || exit 1
    sudo at -M "${AT_START_TIME}" << EOF || exit 1
shutdown "+${DURATION_FOR_SHUTDOWN}"
EOF
    sudo atq
else
    atq
fi

popd

if [[ -n "${POWER_ON:-}" ]]
then
    WAKE_TIME_EPOCH=$(( START_EPOCH - (4 * 60) ))
    NOW_EPOCH=$(date +"%s")
    [[ "${WAKE_TIME_EPOCH}" -gt "${NOW_EPOCH}" ]] || exit 1
    WAKE_TIME=$(date --date="@${WAKE_TIME_EPOCH}" +"%F %T")
    sudo rtcwake --mode no --date "${WAKE_TIME}"
fi
