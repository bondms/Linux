#!/bin/bash

[[ $# -eq 2 ]] || exit 1
[[ -h "$1" ]] || exit 1
[[ -d "$2" ]] || exit 1
ln -v -sv "$(readlink -f "$1")" "$2/." || exit 1
symlinks -c "$2/." || exit 1
