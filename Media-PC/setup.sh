#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

for NAME in Desktop
do
    [[ -d "${HERE}/${NAME}" ]] || exit $?

    if [[ -d "${HOME}/${NAME}" && ! -h "${HOME}/${NAME}" ]]
    then
        rmdir --verbose "${HOME}/${NAME}" || exit $?
    fi

    [[ -h "${HOME}/${NAME}" ]] ||
        ln --symbolic --verbose -- "${HERE}/${NAME}" "${HOME}/." || exit $?
done

sudo apt update || exit $?
sudo apt full-upgrade || exit $?

sudo apt install --assume-yes rpi-eeprom || exit $?
sudo apt install --assume-yes feh || exit $?
sudo apt install --assume-yes sox libsox-fmt-all || exit $?
sudo apt install --assume-yes xscreensaver || exit $?
sudo apt install --assume-yes at || exit $?

# rgain dependencies
sudo apt install --assume-yes gstreamer1.0-python3-plugin-loader python3-mutagen || exit $?

sudo rpi-eeprom-update || exit $?

sudo apt autoremove || exit $?
sudo apt-get autoclean || exit $?

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit $?

# Old versions of Raspbian used ALSA:
# if [[ ! -h /etc/asound.conf ]]
# then
#     # Downmix all audio output from stereo to mono.
#     # https://www.tinkerboy.xyz/raspberry-pi-downmixing-from-stereo-to-mono-sound-output/
#     # The device number in `hw:N` is determined from the output of `cat /proc/asound/modules`.
#     sudo ln --symbolic --verbose -- "${HERE}/MonoAudio/asound.conf" /etc/. || exit $?
#     echo "*** Reboot for mono audio downmix to take effect ***"
# fi

# New version of Raspbian use Pulse audio:
if [[ ! -e /etc/pulse/default.pa.orig ]]
then
    # Downmix all audio output from stereo to mono.
    # https://askubuntu.com/questions/17791/can-i-downmix-stereo-audio-to-mono
    # The device name (master) is determined from the output of `pacmd list-sinks`.
    # Test with `speaker-test -c 2 -t sine` and/or https://www.youtube.com/watch?v=6TWJaFD6R2s
    grep -Fv "sink_name=mono" /etc/pulse/default.pa || exit $?
    grep -Fv "set-default-sink mono" /etc/pulse/default.pa || exit $?
    sudo cp --archive --interactive --verbose /etc/pulse/default.pa{,.orig} || exit $?
    echo "load-module module-remap-sink sink_name=mono master=alsa_output.platform-bcm2835_audio.digital-stereo channels=2 channel_map=mono,mono" | sudo tee --append /etc/pulse/default.pa || exit $?
    echo "set-default-sink mono" | sudo tee --append /etc/pulse/default.pa || exit $?
    echo "*** Reboot for mono audio downmix to take effect ***"
fi

[[ -d "${HERE}/../../rgain" ]] ||
    git clone --depth 1 --branch 1.0.0 --verbose -- https://github.com/chaudum/rgain.git "${HERE}/../../rgain" || exit $?
[[ -h "${HERE}/../../rgain/scripts/rgain3" ]] ||
    ln --symbolic --verbose -- "../rgain3" "${HERE}/../../rgain/scripts/." || exit $?

# Configure recording for time-shifted playback of Radio Varna
mkdir --verbose --parents -- "${HOME}/Recordings" || exit $?
crontab - << EOF
# Record Radio Varna from 10:20 to 13:00 (2h40m) on Sundays.
20 10 * * sun sox --clobber --type mp3 http://broadcast.masters.bg:8000/live "${HOME}/Recordings/radio-varna.mp3" trim 0 2:40:00
EOF

echo "*** SUCCESS ***"
