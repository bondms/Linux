#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

BACKUP="$(readlink -e "${HERE}/Backup")"
[[ -d "${BACKUP}" ]] || exit $?

for NAME in Documents Downloads Images Music Pictures Playlists Videos VirtualMachines
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

sudo cp --force --verbose -- "${HERE}/Startup/kernel-purge-all-old.sh" /usr/local/sbin/. || exit $?
sudo chown --verbose root.root /usr/local/sbin/kernel-purge-all-old.sh || exit $?
sudo chmod --verbose 755 /usr/local/sbin/kernel-purge-all-old.sh || exit $?

sudo cp --force --verbose -- "${HERE}/Startup/kernel-purge.sh" /usr/local/sbin/. || exit $?
sudo chown --verbose root.root /usr/local/sbin/kernel-purge.sh || exit $?
sudo chmod --verbose 755 /usr/local/sbin/kernel-purge.sh || exit $?

EXISTING_RC_LOCAL=/etc/rc.local
NEW_RC_LOCAL="${HERE}/Startup/rc.local"
if [[ -e "${EXISTING_RC_LOCAL}" ]]
then
  diff -- "${EXISTING_RC_LOCAL}" "${NEW_RC_LOCAL}" || exit $?
else
  sudo cp --force --verbose -- "${NEW_RC_LOCAL}" "${EXISTING_RC_LOCAL}" || exit $?
  sudo chown --verbose root.root "${EXISTING_RC_LOCAL}" || exit $?
  sudo chmod --verbose 755 "${EXISTING_RC_LOCAL}" || exit $?
fi

sudo apt update || exit $?
sudo apt-get dist-upgrade || exit $?

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
sudo apt install jmtpfs || exit $?
sudo apt install exfat-utils || exit $?
sudo apt install tofrodos || exit $?
sudo snap install skype --classic || exit $?
sudo apt install 2to3 || exit $?
sudo apt install python3-mutagen || exit $?
sudo apt install symlinks || exit $?

sudo apt-get autoremove || exit $?
sudo apt-get autoclean || exit $?

if [[ ! -d "${HOME}/.bash-git-prompt" ]]
then
    git clone https://github.com/magicmonty/bash-git-prompt.git "${HOME}/.bash-git-prompt" --depth=1 || exit $?
fi
