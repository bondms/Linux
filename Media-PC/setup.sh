#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

sudo apt update || exit $?
sudo apt full-upgrade || exit $?

sudo apt install rpi-eeprom || exit $?
sudo apt install feh || exit $?
sudo apt install sox libsox-fmt-all || exit $?
sudo apt install xscreensaver || exit $?

# rgain dependencies
sudo apt-get install gstreamer1.0-python3-plugin-loader python3-mutagen || exit $?

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
    sudo ln --symbolic --verbose -- "${HERE}/MonoAudio/asound.conf" /etc/. || exit $?
    echo "*** Reboot for mono audio downmix to take effect ***"
fi

[[ -d "${HERE}/../../rgain" ]] ||
    git clone --depth 1 --branch 1.0.0 --verbose -- https://github.com/chaudum/rgain.git "${HERE}/../../rgain" || exit $?
[[ -h "${HERE}/../../rgain/scripts/rgain3" ]] ||
    ln --symbolic --verbose -- "../rgain3" "${HERE}/../../rgain/scripts/." || exit $?

find "${HOME}/Desktop/." -name "wget-log*" -delete || exit $?
