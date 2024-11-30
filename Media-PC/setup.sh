#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit 1

[[ -d "/home/pi" ]] || exit 1
[[ -f /etc/debian_version ]] || exit 1

[[ -d "${HERE}/Desktop" ]] || exit 1
if [[ -d "${HOME}/Desktop" && ! -h "${HOME}/Desktop" ]]
then
    rmdir --verbose "${HOME}/Desktop" || exit 1
fi
[[ -h "${HOME}/Desktop" ]] ||
    ln --symbolic --verbose -- "${HERE}/Desktop" "${HOME}/." || exit 1
[[ -h "${HOME}/Desktop/R.Varna recorded.mp3" ]] ||
    ln --symbolic --verbose -- "${HOME}/Recordings/radio-varna.mp3" "${HOME}/Desktop/R.Varna recorded.mp3" || exit 1

sudo apt update || exit 1
sudo apt full-upgrade || exit 1

sudo apt install --assume-yes rpi-eeprom || exit 1
sudo apt install --assume-yes feh || exit 1
sudo apt install --assume-yes sox libsox-fmt-all || exit 1
sudo apt install --assume-yes xscreensaver || exit 1
sudo apt install --assume-yes at || exit 1

# rgain dependencies
sudo apt install --assume-yes gstreamer1.0-python3-plugin-loader python3-mutagen || exit 1

# EEPROM updates seem to be broken. rapsi-config only configures the default, not the latest.
# Consider commenting the following line until there a resolution for that.
sudo rpi-eeprom-update || exit 1

sudo apt autoremove || exit 1
sudo apt-get autoclean || exit 1

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit 1

if [[ ! -e /etc/pulse/default.pa.orig ]]
then
    # Downmix audio output from stereo to mono for HDMI.
    # https://askubuntu.com/questions/17791/can-i-downmix-stereo-audio-to-mono
    # https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-remap-sink
    # The device name (master) is determined from the output of `pacmd list-sinks`.
    # Test with `speaker-test -c 2 -t sine` and/or https://www.youtube.com/watch?v=6TWJaFD6R2s
    # Play sound through multiple output devices.
    # https://askubuntu.com/questions/78174/play-sound-through-two-or-more-outputs-devices
    # https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/#module-combine-sink
    grep -Fv "sink_name=hdmi_mono" /etc/pulse/default.pa || exit 1
    grep -Fv "set-default-sink hdmi_mono" /etc/pulse/default.pa || exit 1
    sudo cp --archive --interactive --verbose /etc/pulse/default.pa{,.orig} || exit 1
    echo "load-module module-remap-sink sink_name=hdmi_mono master=alsa_output.platform-fef00700.hdmi.hdmi-stereo channels=2 channel_map=mono,mono" | sudo tee --append /etc/pulse/default.pa || exit 1
    echo "set-default-sink hdmi_mono" | sudo tee --append /etc/pulse/default.pa || exit 1
    echo "*** Reboot for audio configuration to take effect ***"
fi

[[ -d "${HERE}/../../rgain3" ]] ||
    git clone --depth 1 --branch 1.0.0 --verbose -- https://github.com/chaudum/rgain3.git "${HERE}/../../rgain3" || exit 1
[[ -h "${HERE}/../../rgain3/scripts/rgain3" ]] ||
    ln --symbolic --verbose -- "../rgain3" "${HERE}/../../rgain3/scripts/." || exit 1

# Configure recording for time-shifted playback of Radio Varna
mkdir --verbose --parents -- "${HOME}/Recordings" || exit 1
crontab - << EOF || exit 1
# Record Radio Varna from 10:20 to 13:00 (2h40m) on Sundays.
# Log both stdout and stderr, and retry on failure.
20 10 * * sun sox --show-progress --clobber --type mp3 http://broadcast.masters.bg:8000/live "${HOME}/Recordings/radio-varna.mp3" trim 0 2:40:00 > "${HOME}/Recordings/radio-varna.log" 2>&1 || sox --show-progress --clobber --type mp3 http://broadcast.masters.bg:8000/live "${HOME}/Recordings/radio-varna.mp3" trim 0 2:40:00 >> "${HOME}/Recordings/radio-varna.log" 2>&1
EOF

echo "*** SUCCESS ***"
