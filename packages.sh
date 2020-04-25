#!/bin/bash

set -eux
set -o pipefail

sudo apt update || exit $?

sudo apt install geany || exit $?
sudo apt install synaptic || exit $?
sudo apt install chromium-browser || exit $?
sudo apt install git || exit $?
sudo apt install meld || exit $?
