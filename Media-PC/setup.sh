#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
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

# Install vim early so that it's easier make fixes if anything fails later.
sudo apt install --assume-yes vim || exit 1

# sudo apt install --assume-yes at || exit 1
sudo apt install --assume-yes feh || exit 1
sudo apt install --assume-yes rpi-eeprom || exit 1
sudo apt install --assume-yes sox libsox-fmt-all || exit 1
sudo apt install --assume-yes xscreensaver || exit 1

# Playing DVDs.
sudo apt install --assume-yes libdvd-pkg libavcodec-extra mpv || exit 1

# rgain dependencies.
sudo apt install --assume-yes gstreamer1.0-python3-plugin-loader python3-mutagen || exit 1

# Configure packages.
sudo rpi-eeprom-update || exit 1
sudo dpkg-reconfigure libdvd-pkg || exit 1

# Clean up.
sudo apt autoremove || exit 1
sudo apt-get autoclean || exit 1

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit 1
[[ -h "${HOME}/.bash_aliases_local" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases_local" "${HOME}/." || exit 1

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
