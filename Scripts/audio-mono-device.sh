#!/bin/bash

set -eux
set -o pipefail

[[ $# -eq 1 ]] || exit 1

pactl unload-module module-remap-sink || exit 1
pactl load-module module-remap-sink sink_name=mono master="$1" channels=1 master_channel_map=mono channel_map=mono remix=no || exit 1
pactl set-default-sink mono || exit 1
