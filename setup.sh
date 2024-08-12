#!/bin/bash

# For Debian, enable sudo for user, e.g. for bondms:
# `su -`
# `usermod -aG sudo bondms`
# Confirm: `getent group sudo`
# `sudo visudo`
# Add entry for user similar as for root:
# bondms ALL=(ALL:ALL) ALL
# Confirm: `su - bondms`
# Confirm: `sudo whoami`

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit 1

[[ ! -d "/home/pi" ]] || exit 1
[[ -f /etc/debian_version ]] || grep -F "Ubuntu" /etc/lsb-release || exit 1

BACKUP="$(readlink -e "${HERE}/Backup")"
[[ -d "${BACKUP}" ]] || exit 1

for NAME in Documents Downloads Images Music Pictures Playlists Podcasts Videos VirtualMachines
do
    [[ -d "${BACKUP}/${NAME}" ]] || exit 1

    if [[ -d "${HOME}/${NAME}" && ! -h "${HOME}/${NAME}" ]]
    then
        rmdir --verbose "${HOME}/${NAME}" || exit 1
    fi

    [[ -h "${HOME}/${NAME}" ]] ||
        ln --symbolic --verbose -- "${BACKUP}/${NAME}" "${HOME}/." || exit 1
done

UNENCRYPTED_DIR="/home/${USER}-unencrypted"
sudo mkdir --verbose --parents -- "${UNENCRYPTED_DIR}" || exit 1
sudo chmod 700 --verbose -- "${UNENCRYPTED_DIR}" || exit 1
sudo chown "${USER}.${USER}" -- "${UNENCRYPTED_DIR}" || exit 1

[[ -h "${HOME}/Unencrypted" ]] ||
    ln --symbolic --verbose -- "${UNENCRYPTED_DIR}" "${HOME}/Unencrypted" || exit 1

mkdir --verbose --parents -- "${UNENCRYPTED_DIR}/VirtualDisks" || exit 1
[[ -h "${HOME}/VirtualMachines/VirtualDisks" ]] ||
    ln --symbolic --verbose -- "${UNENCRYPTED_DIR}/VirtualDisks" "${HOME}/VirtualMachines/." || exit 1

for NAME in Desktop SparseImages Recordings
do
    mkdir --verbose --parents -- "${UNENCRYPTED_DIR}/${NAME}" || exit 1

    if [[ -d "${HOME}/${NAME}" && ! -h "${HOME}/${NAME}" ]]
    then
        rmdir --verbose "${HOME}/${NAME}" || exit 1
    fi

    [[ -h "${HOME}/${NAME}" ]] ||
        ln --symbolic --verbose -- "${UNENCRYPTED_DIR}/${NAME}" "${HOME}/." || exit 1

done

mkdir --verbose --parents -- "${BACKUP}/BackupLogs" || exit 1

mkdir --verbose --parents -- "${HOME}/Mount" || exit 1
mkdir --parents --verbose -- "${HOME}/Temp" || exit 1

if [[ ! -h "${HOME}/Git" ]]
then
    PARENT="$(dirname "${HERE}")"
    [[ "Git" == "$(basename "${PARENT}")" ]] || exit 1
    ln --symbolic --verbose -- "${PARENT}" "${HOME}/." || exit 1
fi

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit 1

[[ -h "${HOME}/RamDisk" ]] ||
    ln --symbolic --verbose -- "/dev/shm/${USER}" "${HOME}/RamDisk" || exit 1

[[ -h "${HOME}/tmp" ]] ||
    ln --symbolic --verbose -- "/tmp/${USER}" "${HOME}/tmp" || exit 1

sudo cp --verbose -- "${HERE}/Startup/free-space-check.sh" /usr/local/bin/. || exit 1
sudo chown --verbose root.root /usr/local/bin/free-space-check.sh || exit 1
sudo chmod --verbose 755 /usr/local/bin/free-space-check.sh || exit 1

EXISTING_RC_LOCAL=/etc/rc.local
NEW_RC_LOCAL="${HERE}/Startup/rc.local"
if [[ -e "${EXISTING_RC_LOCAL}" ]]
then
  diff -- "${EXISTING_RC_LOCAL}" "${NEW_RC_LOCAL}" || exit 1
else
  sudo cp --verbose -- "${NEW_RC_LOCAL}" "${EXISTING_RC_LOCAL}" || exit 1
  sudo chown --verbose root.root "${EXISTING_RC_LOCAL}" || exit 1
  sudo chmod --verbose 755 "${EXISTING_RC_LOCAL}" || exit 1
fi

# Visual Studio Code settings
mkdir --parents --verbose -- "${HOME}/.config/Code/User" || exit 1
EXISTING_CODE_CONFIG="${HOME}/.config/Code/User/settings.json"
NEW_CODE_CONFIG="${HERE}/Code/settings.json"
if [[ -e "${EXISTING_CODE_CONFIG}" ]]
then
  diff -- "${EXISTING_CODE_CONFIG}" "${NEW_CODE_CONFIG}" || exit 1
else
  sudo cp --verbose -- "${NEW_CODE_CONFIG}" "${EXISTING_CODE_CONFIG}" || exit 1
  sudo chown --verbose bondms.bondms -- "${EXISTING_CODE_CONFIG}" || exit 1
fi

sudo apt update || exit 1
sudo apt full-upgrade || exit 1

# For Debian, a log-off and log-on will be required for snaps to show up in the applications.
sudo apt install --assume-yes snapd || exit 1
sudo snap refresh || exit 1

sudo apt install --assume-yes synaptic || exit 1
sudo apt install --assume-yes git || exit 1
sudo apt install --assume-yes meld || exit 1
sudo apt install --assume-yes grisbi || exit 1
sudo apt install --assume-yes build-essential || exit 1
sudo apt install --assume-yes cmake || exit 1
sudo apt install --assume-yes python-is-python3 || exit 1
sudo snap install --classic code || exit 1
sudo apt install --assume-yes feh || exit 1
sudo apt install --assume-yes sox libsox-fmt-all || exit 1
sudo apt install --assume-yes jmtpfs || exit 1
sudo apt install --assume-yes exfatprogs || exit 1
sudo apt install --assume-yes tofrodos || exit 1
sudo snap install --classic skype || exit 1
sudo apt install --assume-yes python3-mutagen || exit 1
sudo apt install --assume-yes symlinks || exit 1
sudo apt install --assume-yes jhead || exit 1
sudo apt install --assume-yes mencoder || exit 1
sudo apt install --assume-yes gimp || exit 1
sudo apt install --assume-yes clang clang-format clang-tidy || exit 1
sudo apt install --assume-yes imagemagick || exit 1
sudo apt install --assume-yes curl || exit 1
sudo apt install --assume-yes latexdraw || exit 1
sudo apt install --assume-yes npm || exit 1
sudo apt install --assume-yes at || exit 1
sudo apt install --assume-yes audacity || exit 1
sudo apt install --assume-yes ffmpeg || exit 1
sudo apt install --assume-yes rpi-imager || sudo snap install --classic rpi-imager || exit 1
sudo apt install --assume-yes black || exit 1
sudo apt install --assume-yes sqlite3 unixodbc-dev || exit 1
sudo apt install --assume-yes usb-creator-gtk || sudo apt install --assume-yes gnome-multi-writer || exit 1
sudo apt install --assume-yes rsync || exit 1

sudo npm install -g @bazel/bazelisk || exit 1

sudo apt autoremove || exit 1
sudo apt-get autoclean || exit 1

[[ -d "${HOME}/.bash-git-prompt" ]] ||
    git clone https://github.com/magicmonty/bash-git-prompt.git "${HOME}/.bash-git-prompt" --depth=1 || exit 1

git config --global core.editor "code --wait --new-window" || exit 1
git config --global core.pager "less -iM" || exit 1
git config --global user.email "34947848+bondms@users.noreply.github.com" || exit 1

[[ -d "${HERE}/../rgain3" ]] ||
    git clone --depth 1 --branch 1.0.0 --verbose -- https://github.com/chaudum/rgain3.git "${HERE}/../rgain3" || exit 1
[[ -h "${HERE}/../rgain3/scripts/rgain3" ]] ||
    ln --symbolic --verbose -- "../rgain3" "${HERE}/../rgain3/scripts/." || exit 1

pushd "${HOME}/RamDisk/" || exit 1
wget -- https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb || exit 1
popd || exit 1
sudo apt install --assume-yes "${HOME}/RamDisk/google-chrome-stable_current_amd64.deb" || exit 1
rm -- "${HOME}/RamDisk/google-chrome-stable_current_amd64.deb" || exit 1

echo "*** SUCCESS ***"
