#!/bin/bash

[[ $# -eq 1 ]] || exit 1

pactl unload-module module-remap-sink || true
pactl load-module module-remap-sink sink_name=mono master="$1" channels=2 channel_map=mono,mono || exit 1
pactl set-default-sink mono || exit 1
