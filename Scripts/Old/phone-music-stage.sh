#!/bin/bash

set -eux || exit $?
set -o pipefail || exit $?

[[ $# -eq 0 ]] || exit $?
SOURCEDIR="${HOME}/Backup/Playlists/MarkAndJoli"
[[ -d "${SOURCEDIR}" ]] || exit $?
TARGETDIR="${HOME}/Temp/PhoneMusic"
[[ ! -e "${TARGETDIR}" ]] || exit $?

find -L "${SOURCEDIR}" -type f -iname "*.mp3" -print0 | bash -c "
    set -eux || exit $?
    set -o pipefail || exit $?
    while read -r -d $'\0' F
    do
        echo \"Input file: \${F}\"
        BASENAME=\$(basename \"\${F}\")
        [[ -n \${BASENAME} ]] || exit $?
        DIRNAME=\$(dirname \"\${F}\")
        [[ -n \${DIRNAME} ]] || exit $?
        OUTPUTDIR=${TARGETDIR}/\${DIRNAME}
        [[ -n \${OUTPUTDIR} ]] || exit $?
        OUTPUT=\${OUTPUTDIR}/\${BASENAME}
        [[ -n \${OUTPUT} ]] || exit $?
        mkdir --parent --verbose \"\${OUTPUTDIR}\" || exit $?
        GAIN=\$(track-replay-gain.sh \"\$F\")
        [[ -n \${GAIN} ]] || exit $?
        sox --replay-gain off \"\${F}\" \"\${OUTPUT}\" gain \${GAIN}
    done" || exit $?
