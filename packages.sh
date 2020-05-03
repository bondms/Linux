#!/bin/bash

set -eux
set -o pipefail

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
sudo apt install bs1770gain || exit $?
