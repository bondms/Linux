#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -f "$(dirname "$0")")"
[[ -d "${HERE}" ]] || abort "Failed to locate script."

sudo apt update || exit $?

sudo apt install geany || exit $?
sudo apt install synaptic || exit $?
sudo apt install chromium-browser || exit $?
sudo apt install git || exit $?
sudo apt install meld || exit $?
sudo apt install grisbi || exit $?
sudo apt install build-essential || exit $?
sudo apt install cmake || exit $?
sudo apt install python-is-python3 || exit $?
sudo snap install --classic code || exit $?
sudo apt install feh || exit $?
sudo apt install sox libsox-fmt-all || exit $?

# bs1770gain from 20.04 is broken for --list. Use version from 19.10.
# sudo apt install bs1770gain || exit $?
sudo dpkg -i "${HERE}/bs1770gain_0.5.2-2_amd64.deb" || exit $?
