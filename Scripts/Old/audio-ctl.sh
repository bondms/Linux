#!/bin/bash

[[ $# -eq 2 ]] || exit 1

DESCRIPTION=$1
echo "DESCRIPTION='${DESCRIPTION}'"

PROFILE=$2
echo "PROFILE='${PROFILE}'"

INDEXES=$(pacmd list-cards \
    | grep -P -o "(?<=^[[:space:]]{4,4}index: )[[:digit:]]+$")
echo "INDEXES='${INDEXES}'"
INDEXES_COUNT="`echo \"${INDEXES}\" | wc -l`"
echo "INDEXES_COUNT='${INDEXES_COUNT}'"

DESCRIPTIONS=$(pacmd list-cards \
    | grep -P -o "(?<=^[[:space:]]{2,2}device.description = \").+" \
    | grep -P -o ".+(?=\"$)")
echo "DESCRIPTIONS='${DESCRIPTIONS}'"
DESCRIPTIONS_COUNT="$(echo \"${DESCRIPTIONS}\" | wc -l)"
echo "DESCRIPTIONS_COUNT='${DESCRIPTIONS_COUNT}'"

(( INDEXES_COUNT == DESCRIPTIONS_COUNT )) || exit 1

POSITION=$(echo "${DESCRIPTIONS}" | awk "{ if ( \$0 == \"${DESCRIPTION}\" ) { print NR ; exit } }")
echo "POSITION='${POSITION}'"

[[ -n $POSITION ]] || exit 1

INDEX=$(echo "${INDEXES}" | head -n "${POSITION}" | tail -n 1)
echo "INDEX='${INDEX}'"

[[ -n $INDEX ]] || exit 1

for i in $INDEXES
do
    if (( i == INDEX ))
    then
        pactl set-card-profile "$i" "${PROFILE}"
    else
        pactl set-card-profile "$i" "off"
    fi
done

