#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

[[ ! -d "/home/pi" ]] || exit 1
[[ -f /etc/debian_version ]] || grep -F "Ubuntu" /etc/lsb-release || exit 1
[[ -d "${HOME}/Archive" ]] || exit 1

BACKUP="$(readlink --canonicalize-existing "${HERE}/Backup")"
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
[[ -h "${HOME}/.bash_aliases_local" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases_local" "${HOME}/." || exit 1

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

# Grisbi settings.
mkdir --parents --verbose -- "${HOME}/.config/grisbi/" || exit 1
EXISTING_GIRSBI_CONFIG="${HOME}/.config/grisbi/grisbi.conf"
NEW_GRISBI_CONFIG="${HERE}/Grisbi/grisbi.conf"
if [[ ! -e "${EXISTING_GIRSBI_CONFIG}" ]]
then
  cp --verbose -- "${NEW_GRISBI_CONFIG}" "${EXISTING_GIRSBI_CONFIG}" || exit 1
fi

# Add contrib sources.
[[ -e /etc/apt/sources.list.orig ]] || (
    sudo cp --archive --verbose /etc/apt/sources.list{,.orig} || exit 1
    sudo sed --regexp-extended --in-place 's/^deb(.*)$/deb\1 contrib/g' /etc/apt/sources.list || exit 1
) || exit 1

sudo apt update || exit 1
sudo apt full-upgrade || exit 1

# Install vim early so that it's easier make fixes if anything fails later.
which vim || sudo apt install --assume-yes vim || exit 1

which adb || sudo apt install --assume-yes adb android-sdk-platform-tools-common || exit 1
which at || sudo apt install --assume-yes at || exit 1
which audacity || sudo apt install --assume-yes audacity || exit 1
which black || sudo apt install --assume-yes black || exit 1
which gcc || sudo apt install --assume-yes build-essential || exit 1
which cargo || sudo apt install --assume-yes cargo rustfmt || exit 1
which clang || sudo apt install --assume-yes clang clang-format clang-tidy || exit 1
which cmake || sudo apt install --assume-yes cmake || exit 1
which curl || sudo apt install --assume-yes curl || exit 1
which /usr/sbin/fsck.exfat || sudo apt install --assume-yes exfatprogs || exit 1
which feh || sudo apt install --assume-yes feh || exit 1
which ffmpeg || sudo apt install --assume-yes ffmpeg || exit 1
which gimp || sudo apt install --assume-yes gimp || exit 1
which git || sudo apt install --assume-yes git || exit 1
which gnome-multi-writer || sudo apt install --assume-yes gnome-multi-writer || exit 1
which grisbi || sudo apt install --assume-yes grisbi || exit 1
which magick || sudo apt install --assume-yes imagemagick || exit 1
which jhead || sudo apt install --assume-yes jhead || exit 1
which jmtpfs || sudo apt install --assume-yes jmtpfs || exit 1
# sudo apt install --assume-yes latexdraw || exit 1
which meld || sudo apt install --assume-yes meld || exit 1
which mencoder || sudo apt install --assume-yes mencoder || exit 1
which npm || sudo apt install --assume-yes npm || exit 1
which pactl || sudo apt install --assume-yes pulseaudio-utils || exit 1
which python || sudo apt install --assume-yes python-is-python3 || exit 1
which mutagen-inspect || sudo apt install --assume-yes python3-mutagen || exit 1
which kvm || sudo apt install --assume-yes qemu-system-x86 || exit 1
which qemu-img || sudo apt install --assume-yes qemu-utils || exit 1
which rclone || sudo apt install --assume-yes rclone || exit 1
which rsync || sudo apt install --assume-yes rsync || exit 1
which sox || sudo apt install --assume-yes sox libsox-fmt-all || exit 1
which todos || sudo apt install --assume-yes tofrodos || exit 1
which sqlite3 || sudo apt install --assume-yes sqlite3 unixodbc-dev || exit 1
which symlinks || sudo apt install --assume-yes symlinks || exit 1
which synaptic || sudo apt install --assume-yes synaptic || exit 1
[[ -f /etc/systemd/timesyncd.conf ]] || sudo apt install --assume-yes systemd-timesyncd || exit 1
# which unrar || sudo apt install --assume-yes unrar-free || exit 1
which wget || sudo apt install --assume-yes wget || exit 1

# Playing DVDs.
which mpv || sudo apt install --assume-yes libdvd-pkg libavcodec-extra mpv regionset vobcopy || exit 1

# Configure packages.
sudo dpkg-reconfigure libdvd-pkg || exit 1

# Install Bazel using bazelisk Debian package from https://github.com/bazelbuild/bazelisk
# sudo apt install --assume-yes bazel-bootstrap{,-data,-source} bazel-platforms bazel-rules-cc bazel-skylib || exit 1

# Clean up.
sudo apt autoremove || exit 1
sudo apt-get autoclean || exit 1

# Configure Git.
[[ -d "${HOME}/.bash-git-prompt" ]] ||
    git clone https://github.com/magicmonty/bash-git-prompt.git "${HOME}/.bash-git-prompt" --depth=1 || exit 1
git config --global commit.gpgsign true || exit 1
git config --global core.editor "code --wait --new-window" || exit 1
git config --global core.pager "less -iM" || exit 1
git config --global init.defaultBranch "main" || exit 1
git config --global user.email "34947848+bondms@users.noreply.github.com" || exit 1

# Enable ReplayGain.
[[ -d "${HERE}/../rgain3" ]] ||
    git clone --depth 1 --branch 1.0.0 --verbose -- https://github.com/chaudum/rgain3.git "${HERE}/../rgain3" || exit 1
[[ -h "${HERE}/../rgain3/scripts/rgain3" ]] ||
    ln --symbolic --verbose -- "../rgain3" "${HERE}/../rgain3/scripts/." || exit 1

# Install packages unavailable from the main repos by downloading .deb files.

type -a code || (
    pushd "${HOME}/RamDisk/" || exit 1
    wget --trust-server-names -- https://go.microsoft.com/fwlink/?LinkID=760868 || exit 1
    popd || exit 1
    sudo apt install --assume-yes "${HOME}/"RamDisk/code_*_amd64.deb || exit 1
    rm -- "${HOME}/RamDisk/"code_*_amd64.deb || exit 1
) || exit 1

type -a google-chrome || (
    pushd "${HOME}/RamDisk/" || exit 1
    wget -- https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb || exit 1
    popd || exit 1
    sudo apt install --assume-yes "${HOME}/RamDisk/google-chrome-stable_current_amd64.deb" || exit 1
    rm -- "${HOME}/RamDisk/google-chrome-stable_current_amd64.deb" || exit 1
) || exit 1

type -a rpi-imager || (
    pushd "${HOME}/RamDisk/" || exit 1
    wget -- https://downloads.raspberrypi.com/imager/imager_latest_amd64.deb || exit 1
    popd || exit 1
    sudo apt install --assume-yes "${HOME}/RamDisk/imager_latest_amd64.deb" || exit 1
    rm -- "${HOME}/RamDisk/imager_latest_amd64.deb" || exit 1
) || exit 1

type -a zoom || (
    pushd "${HOME}/RamDisk/" || exit 1
    wget -- https://zoom.us/client/6.2.3.2056/zoom_amd64.deb || exit 1
    popd || exit 1
    sudo apt install --assume-yes "${HOME}/RamDisk/zoom_amd64.deb" || exit 1
    rm -- "${HOME}/RamDisk/zoom_amd64.deb" || exit 1
) || exit 1

echo "*** SUCCESS ***"

### Try to avoid Snaps ###

# For Debian, a log-off and log-on will be required for snaps to show up in the applications.
# sudo apt install --assume-yes snapd || exit 1
# sudo snap refresh || exit 1
# sudo snap install --classic code || exit 1
# sudo snap install --classic rpi-imager || exit 1
