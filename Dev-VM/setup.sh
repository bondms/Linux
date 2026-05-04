#!/bin/bash

set -eux
set -o pipefail

HERE="$(readlink --canonicalize-existing "$(dirname "${BASH_SOURCE[0]}")")"
[[ -d "${HERE}" ]] || exit 1

[[ ! -d "/home/pi" ]] || exit 1
[[ -f /etc/debian_version ]] || grep -F "Ubuntu" /etc/lsb-release || exit 1
[[ ! -d "${HOME}/Archive" ]] || exit 1

mkdir --parents --verbose -- "${HOME}/Temp" || exit 1

[[ -h "${HOME}/.bash_aliases" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases" "${HOME}/." || exit 1
[[ -h "${HOME}/.bash_aliases_local" ]] ||
    ln --symbolic --verbose -- "${HERE}/Shell/.bash_aliases_local" "${HOME}/." || exit 1

[[ -h "${HOME}/RamDisk" ]] ||
    ln --symbolic --verbose -- "/dev/shm/${USER}" "${HOME}/RamDisk" || exit 1

[[ -h "${HOME}/tmp" ]] ||
    ln --symbolic --verbose -- "/tmp/${USER}" "${HOME}/tmp" || exit 1

sudo cp --verbose -- "${HERE}/../Startup/free-space-check.sh" /usr/local/bin/. || exit 1
sudo chown --verbose root.root /usr/local/bin/free-space-check.sh || exit 1
sudo chmod --verbose 755 /usr/local/bin/free-space-check.sh || exit 1

EXISTING_RC_LOCAL=/etc/rc.local
NEW_RC_LOCAL="${HERE}/../Startup/rc.local"
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
NEW_CODE_CONFIG="${HERE}/../Code/settings.json"
if [[ -e "${EXISTING_CODE_CONFIG}" ]]
then
  diff -- "${EXISTING_CODE_CONFIG}" "${NEW_CODE_CONFIG}" || exit 1
else
  sudo cp --verbose -- "${NEW_CODE_CONFIG}" "${EXISTING_CODE_CONFIG}" || exit 1
  sudo chown --verbose bondms.bondms -- "${EXISTING_CODE_CONFIG}" || exit 1
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

# sudo apt install --assume-yes at || exit 1
which adb || sudo apt install --assume-yes adb android-sdk-platform-tools-common || exit 1
which black || sudo apt install --assume-yes black || exit 1
which gcc || sudo apt install --assume-yes build-essential || exit 1
which cargo || sudo apt install --assume-yes cargo rustfmt || exit 1
which clang || sudo apt install --assume-yes clang clang-format clang-tidy || exit 1
which cmake || sudo apt install --assume-yes cmake || exit 1
which curl || sudo apt install --assume-yes curl || exit 1
which git || sudo apt install --assume-yes git || exit 1
which jhead || sudo apt install --assume-yes jhead || exit 1
# sudo apt install --assume-yes latexdraw || exit 1
which meld || sudo apt install --assume-yes meld || exit 1
which npm || sudo apt install --assume-yes npm || exit 1
which python || sudo apt install --assume-yes python-is-python3 || exit 1
which mutagen-inspect || sudo apt install --assume-yes python3-mutagen || exit 1
which todos || sudo apt install --assume-yes tofrodos || exit 1
which sqlite3 || sudo apt install --assume-yes sqlite3 unixodbc-dev || exit 1
which symlinks || sudo apt install --assume-yes symlinks || exit 1
which wget || sudo apt install --assume-yes wget || exit 1

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

type -a code || (
    pushd "${HOME}/RamDisk/" || exit 1
    wget --trust-server-names -- https://go.microsoft.com/fwlink/?LinkID=760868 || exit 1
    popd || exit 1
    sudo apt install --assume-yes "${HOME}/"RamDisk/code_*_amd64.deb || exit 1
    rm -- "${HOME}/RamDisk/"code_*_amd64.deb || exit 1
) || exit 1

echo "*** SUCCESS ***"
