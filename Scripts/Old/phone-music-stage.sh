#!/bin/bash

set -eux || exit 1
set -o pipefail || exit 1

[[ $# -eq 0 ]] || exit 1
SOURCEDIR="${HOME}/Backup/Playlists/MarkAndJoli"
[[ -d "${SOURCEDIR}" ]] || exit 1
TARGETDIR="${HOME}/Temp/PhoneMusic"
[[ ! -e "${TARGETDIR}" ]] || exit 1

find -L "${SOURCEDIR}" -type f -iname "*.mp3" -print0 | bash -c "
    set -eux || exit 1
    set -o pipefail || exit 1
    while read -r -d $'\0' F
    do
        echo \"Input file: \${F}\"
        BASENAME=\$(basename \"\${F}\")
        [[ -n \${BASENAME} ]] || exit 1
        DIRNAME=\$(dirname \"\${F}\")
        [[ -n \${DIRNAME} ]] || exit 1
        OUTPUTDIR=${TARGETDIR}/\${DIRNAME}
        [[ -n \${OUTPUTDIR} ]] || exit 1
        OUTPUT=\${OUTPUTDIR}/\${BASENAME}
        [[ -n \${OUTPUT} ]] || exit 1
        mkdir --parent --verbose \"\${OUTPUTDIR}\" || exit 1
        GAIN=\$(track-replay-gain.sh \"\$F\")
        [[ -n \${GAIN} ]] || exit 1
        sox --replay-gain off \"\${F}\" \"\${OUTPUT}\" gain \${GAIN}
    done" || exit 1
