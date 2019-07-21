#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit $?

ROOT_DIR="$1"
[[ -d "${ROOT_DIR}" ]] || exit $?

find "${ROOT_DIR}" -depth -mindepth 1 -print0 | bash -c "
    set -eux
    set -o pipefail
    while read -r -d $'\0' CURRENT_PATH
    do
        CURRENT_BASE=\$(basename \"\${CURRENT_PATH}\")
        [[ -n \"\${CURRENT_BASE}\" ]] || exit \$?

        DIR=\$(dirname \"\${CURRENT_PATH}\")
        [[ -d \"\${DIR}\" ]] || exit \$?

        [[ -e \"\${DIR}/\${CURRENT_BASE}\" ]] || exit \$?

        NEW_BASE=\$(echo \"\${CURRENT_BASE}\" | sed --expression='{s/[\?:]/_/g ; s/\\.\$//}')
        [[ -n \${NEW_BASE} ]] || exit \$?

        if [[ \"\${NEW_BASE}\" == \"\${CURRENT_BASE}\" ]]
        then
            continue
        fi

        NEW_PATH=\"\${DIR}/\${NEW_BASE}\"
        [[ ! -e \"\${NEW_PATH}\" ]] || exit \$?

        mv --verbose --interactive --no-target-directory \"\${CURRENT_PATH}\" \"\${NEW_PATH}\" || exit \$?
    done"
