#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink -e "$(dirname "$0")")"
[[ -d "${HERE}" ]] || exit $?

for NAME in Documents Downloads Images Music Pictures Playlists Videos VirtualMachines
do
    # This script is intended to be run from Backup root (e.g. via a symlink).
    [[ -d "${HERE}/${NAME}" ]] || exit $?

    if [[ -d "${HOME}/${NAME}" && ! -h "${HOME}/${NAME}" ]]
    then
        rmdir --verbose "${HOME}/${NAME}" || exit $?
    fi

    [[ -h "${HOME}/${NAME}" ]] ||
        ln --symbolic --verbose -- "${HERE}/${NAME}" "${HOME}/." || exit $?
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

mkdir --verbose --parents -- "${HERE}/BackupLogs" || exit $?

mkdir --verbose --parents -- "${HOME}/Mount" || exit $?
mkdir --parents --verbose -- "${HOME}/Temp" || exit $?

[[ -h "${HOME}/Git" ]] ||
    ln --symbolic --verbose -- "${HERE}/Documents/Archive/Programming/Git" "${HOME}/." || exit $?

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit $?

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
