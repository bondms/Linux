#!/bin/bash

# TODO:
# - Recover from a failed power-on (e.g. if power switched off).
# - Allow multiple and/or repeating schedules.
# - Warn about powering down when recording in progress.
# - Warn about scheduled power-down when logged in.

set -eux || exit $?
set -o pipefail || exit $?

[[ $# -ge 2 ]] || exit $?
START_TIME=$1 ; shift
END_TIME=$1 ; shift

while [[ $# -gt 0 ]]
do
    case "${1}" in
        "power-on") POWER_ON=1 ;;
        "power-off" ) POWER_OFF=1 ;;
        * ) echo "Unknown argument: $1" >&2 ; exit 1 ;;
    esac
    shift
done

ROUNDED_START_TIME=$(date --date="${START_TIME}" +"%F %R")
ROUNDED_END_TIME=$(date --date="${END_TIME}" +"%F %R")

AT_START_TIME=$(date --date="${ROUNDED_START_TIME}" +"%R %F")
AT_END_TIME=$(date --date="${ROUNDED_END_TIME}" +"%R %F")

START_EPOCH=$(date --date="${ROUNDED_START_TIME}" +"%s")
END_EPOCH=$(date --date="${ROUNDED_END_TIME}" +"%s")

TARGET_DATE=$(date --date="${ROUNDED_START_TIME}" --iso-8601=date)
[[ -n "${TARGET_DATE}" ]] || exit $?

DURATION_MINUTES=$(( (${END_EPOCH} - ${START_EPOCH}) / 60 ))
[[ "${DURATION_MINUTES}" -ge 1 ]] || exit $?
[[ "${DURATION_MINUTES}" -le 1440 ]] || exit $?

TARGET_DIR="/home/${USER}-unencrypted/Recordings"
[[ -d "${TARGET_DIR}" ]] || exit $?

TARGET="${TARGET_DIR}/radio-varna-${TARGET_DATE}.mp3"
[[ ! -e "${TARGET}" ]] || exit $?

RECORD_CMD="sox --type mp3 http://broadcast.masters.bg:8000/live \"${TARGET}\""

pushd "${TARGET_DIR}" || exit $?

at -M "${AT_START_TIME}" << EOF || exit $?
${RECORD_CMD}
EOF

at -M "${AT_END_TIME}" << EOF || exit $?
pkill --exact --full "${RECORD_CMD}"
EOF

if [[ -n "${POWER_OFF:-}" ]]
then
    DURATION_FOR_SHUTDOWN=$(( ${DURATION_MINUTES} + 1 ))
    [[ "${DURATION_FOR_SHUTDOWN}" -ge 2 ]] || exit $?
    sudo at -M "${AT_START_TIME}" << EOF || exit $?
shutdown "+${DURATION_FOR_SHUTDOWN}"
EOF
    sudo atq
else
    atq
fi

popd

if [[ -n "${POWER_ON:-}" ]]
then
    WAKE_TIME_EPOCH=$(( ${START_EPOCH} - (4 * 60) ))
    NOW_EPOCH=$(date +"%s")
    [[ "${WAKE_TIME_EPOCH}" -gt "${NOW_EPOCH}" ]] || exit $?
    WAKE_TIME=$(date --date="@${WAKE_TIME_EPOCH}" +"%F %T")
    sudo rtcwake --mode no --date "${WAKE_TIME}"
fi
