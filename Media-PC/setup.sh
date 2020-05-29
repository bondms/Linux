#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

sudo apt update || exit $?
sudo apt full-upgrade || exit $?

sudo apt install rpi-eeprom || exit $?
sudo apt install bs1770gain || exit $?
sudo apt install feh || exit $?
sudo apt install sox libsox-fmt-all || exit $?
sudo apt install xscreensaver || exit $?

sudo rpi-eeprom-update || exit $?

sudo apt autoremove || exit $?
sudo apt-get autoclean || exit $?

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit $?

if [[ ! -h /etc/asound.conf ]]
then
    # Downmix all audio output from stereo to mono.
    # https://www.tinkerboy.xyz/raspberry-pi-downmixing-from-stereo-to-mono-sound-output/
    # The device number in `hw:N` is determined from the output of `cat /proc/asound/modules`.
    ln --symbolic --verbose -- "${HERE}/MonoAudio/asound.conf" /etc/. || exit $?
    echo *** Reboot for mono audio downmix to take effect ***
fi
