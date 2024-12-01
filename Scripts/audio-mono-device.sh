#!/bin/bash

set -eux
set -o pipefail

pactl unload-module module-stream-restore || exit 1
# pactl load-module module-stream-restore restore_device=false || exit 1

DEVICE="$(pactl list short sinks | grep -F stereo | cut -f 2)"
echo "Device: ${DEVICE}"

pactl set-default-sink "${DEVICE}" || exit 1

pactl unload-module module-remap-sink || exit 1
pactl load-module module-remap-sink sink_name=mono master="${DEVICE}" channels=1 master_channel_map=mono channel_map=mono remix=no || exit 1

pactl set-default-sink mono || exit 1
