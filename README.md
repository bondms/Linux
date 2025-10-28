# README

## Status

![Super-Linter](https://github.com/bondms/Linux/workflows/Super-Linter/badge.svg)

## General
Configure a Debian 13 (Trixie) Desktop system.

1. On the system to be re-installed:
    1. Download the latest Debian live Gnome image, e.g. from [here](https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.1.0-amd64-gnome.iso).
    1. Create bootable installation media from a live image, e.g.
        * `cp ~/Images/Debian/debian-live-13.1.0-amd64-gnome.iso /dev/sdb`
    1. Reboot and access the boot menu, e.g. pressing F7 during statup.
    1. Boot into the live image.
    1. Use `blkdiscard` to erase the old system, e.g.
        * `sudo blkdiscard --force /dev/sda`
    1. Reboot again and run the installer.
1. On the freshly installed system:
    1. Enable `sudo` for the user, e.g. for user `bondms`:
        1. `su -`
        1. `usermod -aG sudo bondms`
        1. Confirm with: `getent group sudo`
        1. Reboot.
    1. `mkdir --parents -v -- ~/Archive`
    1. `cp -aiv /media/bondms/BackupSsd/ ~/Archive/bondms/`
    1. `cp -aiv ~/Archive/bondms/latest/ ~/Backup/`
    1. `~/Backup/Documents/Archive/Programming/Git/Linux/setup.sh`
1. Setup tasks:
    * Disable local document search.
    * Log-off old sessions and delete old session tokens.
    * Confugure RClone remote:
        * `rclone config`
    * Replace GitHub SSH certificates.
    * Re-sync GitHub repos locally.
    * etc.

## Media-PC
[Configure a Raspberry PI 4 media system](Media-PC/README.md).
