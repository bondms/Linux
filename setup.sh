#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

BACKUP="$(readlink -e "${HERE}/Backup")"
[[ -d "${BACKUP}" ]] || exit $?

for NAME in Documents Downloads Images Music Pictures Playlists Podcasts Videos VirtualMachines
do
    [[ -d "${BACKUP}/${NAME}" ]] || exit $?

    if [[ -d "${HOME}/${NAME}" && ! -h "${HOME}/${NAME}" ]]
    then
        rmdir --verbose "${HOME}/${NAME}" || exit $?
    fi

    [[ -h "${HOME}/${NAME}" ]] ||
        ln --symbolic --verbose -- "${BACKUP}/${NAME}" "${HOME}/." || exit $?
done

UNENCRYPTED_DIR="/home/${USER}-unencrypted"
sudo mkdir --verbose --parents -- "${UNENCRYPTED_DIR}" || exit $?
sudo chmod 700 --verbose -- "${UNENCRYPTED_DIR}" || exit $?
sudo chown "${USER}.${USER}" -- "${UNENCRYPTED_DIR}" || exit $?

[[ -h "${HOME}/Unencrypted" ]] ||
    ln --symbolic --verbose -- "${UNENCRYPTED_DIR}" "${HOME}/Unencrypted" || exit $?

mkdir --verbose --parents -- "${UNENCRYPTED_DIR}/VirtualDisks" || exit $?
[[ -h "${HOME}/VirtualMachines/VirtualDisks" ]] ||
    ln --symbolic --verbose -- "${UNENCRYPTED_DIR}/VirtualDisks" "${HOME}/VirtualMachines/." || exit $?

for NAME in Desktop SparseImages Recordings
do
    mkdir --verbose --parents -- "${UNENCRYPTED_DIR}/${NAME}" || exit $?

    if [[ -d "${HOME}/${NAME}" && ! -h "${HOME}/${NAME}" ]]
    then
        rmdir --verbose "${HOME}/${NAME}" || exit $?
    fi

    [[ -h "${HOME}/${NAME}" ]] ||
        ln --symbolic --verbose -- "${UNENCRYPTED_DIR}/${NAME}" "${HOME}/." || exit $?

done

mkdir --verbose --parents -- "${BACKUP}/BackupLogs" || exit $?

mkdir --verbose --parents -- "${HOME}/Mount" || exit $?
mkdir --verbose --parents -- "${HOME}/Phone" || exit $?
mkdir --parents --verbose -- "${HOME}/Temp" || exit $?

if [[ ! -h "${HOME}/Git" ]]
then
    PARENT="$(dirname "${HERE}")"
    [[ "Git" == "$(basename "${PARENT}")" ]] || exit $?
    ln --symbolic --verbose -- "${PARENT}" "${HOME}/." || exit $?
fi

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit $?

if [[ ! -h "${HOME}/.profile" ]]
then
    mv --no-clobber -- "${HOME}/.profile" "${HOME}/.profile.orig" || exit $?
fi
[[ -h "${HOME}/.profile" ]] ||
    ln --symbolic --verbose --force -- "${HERE}/Shell/.profile" "${HOME}/." || exit $?

[[ -h "${HOME}/RamDisk" ]] ||
    ln --symbolic --verbose -- "/dev/shm/${USER}" "${HOME}/RamDisk" || exit $?

[[ -h "${HOME}/tmp" ]] ||
    ln --symbolic --verbose -- "/tmp/${USER}" "${HOME}/tmp" || exit $?

sudo cp --force --verbose -- "${HERE}/Startup/free-space-check.sh" /usr/local/bin/. || exit $?
sudo chown --verbose root.root /usr/local/bin/free-space-check.sh || exit $?
sudo chmod --verbose 755 /usr/local/bin/free-space-check.sh || exit $?

EXISTING_RC_LOCAL=/etc/rc.local
NEW_RC_LOCAL="${HERE}/Startup/rc.local"
if [[ -e "${EXISTING_RC_LOCAL}" ]]
then
  diff -- "${EXISTING_RC_LOCAL}" "${NEW_RC_LOCAL}" || exit $?
else
  sudo cp --verbose -- "${NEW_RC_LOCAL}" "${EXISTING_RC_LOCAL}" || exit $?
  sudo chown --verbose root.root "${EXISTING_RC_LOCAL}" || exit $?
  sudo chmod --verbose 755 "${EXISTING_RC_LOCAL}" || exit $?
fi

# Visual Studio Code settings
mkdir --parents --verbose -- "${HOME}/.config/Code/User" || exit $?
EXISTING_CODE_CONFIG="${HOME}/.config/Code/User/settings.json"
NEW_CODE_CONFIG="${HERE}/Code/settings.json"
if [[ -e "${EXISTING_CODE_CONFIG}" ]]
then
  diff -- "${EXISTING_CODE_CONFIG}" "${NEW_CODE_CONFIG}" || exit $?
else
  sudo cp --verbose -- "${NEW_CODE_CONFIG}" "${EXISTING_CODE_CONFIG}" || exit $?
  sudo chown --verbose bondms.bondms -- "${EXISTING_CODE_CONFIG}" || exit $?
fi

sudo snap refresh || exit $?
sudo apt update || exit $?
sudo apt full-upgrade || exit $?

sudo apt install --assume-yes synaptic || exit $?
# Use Google's Chrome browser rather than Chromium in order to sync with Android Chrome.
# Download Google Chrome .deb file and install via right-click.
# sudo apt install --assume-yes chromium-browser || exit $?
sudo apt install --assume-yes git || exit $?
sudo apt install --assume-yes meld || exit $?
sudo apt install --assume-yes grisbi || exit $?
sudo apt install --assume-yes build-essential || exit $?
sudo apt install --assume-yes cmake || exit $?
sudo apt install --assume-yes python-is-python3 || exit $?
sudo snap install --classic code || exit $?
sudo apt install --assume-yes feh || exit $?
sudo apt install --assume-yes sox libsox-fmt-all || exit $?
# sudo apt install --assume-yes jmtpfs || exit $?
# sudo apt install --assume-yes exfat-utils || exit $?
sudo apt install --assume-yes tofrodos || exit $?
sudo snap install skype --classic || exit $?
# sudo apt install --assume-yes 2to3 || exit $?
sudo apt install --assume-yes python3-mutagen || exit $?
sudo apt install --assume-yes symlinks || exit $?
sudo apt install --assume-yes jhead || exit $?
sudo apt install --assume-yes mencoder || exit $?
sudo apt install --assume-yes gimp || exit $?
sudo apt install --assume-yes clang clang-format clang-tidy || exit $?
sudo apt install --assume-yes imagemagick || exit $?
sudo apt install --assume-yes curl || exit $?
sudo apt install --assume-yes latexdraw || exit $?
# sudo apt install --assume-yes python-pytest || exit $?
# sudo apt install --assume-yes python3-dev python3-bluez || exit $?
sudo apt install --assume-yes npm || exit $?
sudo apt install --assume-yes at || exit $?
sudo apt install --assume-yes audacity || exit $?
sudo apt install --assume-yes ffmpeg || exit $?

sudo npm install -g @bazel/bazelisk || exit $?

sudo apt autoremove || exit $?
sudo apt-get autoclean || exit $?

[[ -d "${HOME}/.bash-git-prompt" ]] ||
    git clone https://github.com/magicmonty/bash-git-prompt.git "${HOME}/.bash-git-prompt" --depth=1 || exit $?

git config --global core.editor "code --wait --new-window" || exit $?
git config --global core.pager "less -iM" || exit $?
git config --global user.email "34947848+bondms@users.noreply.github.com" || exit $?

[[ -d "${HERE}/../rgain" ]] ||
    git clone --depth 1 --branch 1.0.0 --verbose -- https://github.com/chaudum/rgain.git "${HERE}/../rgain" || exit $?
[[ -h "${HERE}/../rgain/scripts/rgain3" ]] ||
    ln --symbolic --verbose -- "../rgain3" "${HERE}/../rgain/scripts/." || exit $?

# sudo apt install --assume-yes dnsmasq resolvconf || exit $?
# sudo systemctl stop systemd-resolved || exit $?
# sudo systemctl disable systemd-resolved || exit $?
# sudo systemctl enable resolvconf.service || exit $?
# sudo systemctl start resolvconf.service || exit $?
# if [[ ! -e /etc/resolvconf/resolv.conf.d/head.orig ]]
# then
#     sudo cp --archive --no-clobber /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.orig || exit $?
# fi
# for ns in "8.8.8.8" "8.8.4.4" "1.1.1.1"
# do
#     grep "^nameserver ${ns}\$" /etc/resolvconf/resolv.conf.d/head && result=$? || result=$?
#     case $result in
#     0 ) ;;
#     1 ) echo "nameserver ${ns}" | sudo tee --append /etc/resolvconf/resolv.conf.d/head || exit $? ;;
#     * ) exit $? ;;
#     esac
# done
# sudo resolvconf --enable-updates || exit $?
# sudo resolvconf -u || exit $?

echo "*** SUCCESS ***"
