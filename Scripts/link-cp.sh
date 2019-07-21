#!/bin/bash

[[ $# -eq 2 ]] || exit $?
[[ -h "$1" ]] || exit $?
[[ -d "$2" ]] || exit $?
ln -v -sv "$(readlink -f "$1")" "$2/." || exit $?
symlinks -c "$2/." || exit $?
