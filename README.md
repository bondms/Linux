# README

## Status

![Super-Linter](https://github.com/bondms/Linux/workflows/Super-Linter/badge.svg)

## General
Configure a Debian 13 (Trixie) Desktop system.

1. On the system to be re-installed:
    1. Download the latest Debian live Gnome image, e.g. from [here](https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-13.1.0-amd64-gnome.iso).
    1. Create bootable installation media from a live image, e.g. (replacing sdX with the appriate device name)
        * `cp ~/Images/Debian/debian-live-13.1.0-amd64-gnome.iso /dev/sdX`
    1. Reboot and access the boot menu, e.g. pressing F7 during statup.
    1. Boot into the live image.
    1. Use `blkdiscard` to erase the old system, e.g. (replacing sdX with the appropriate device name)
        * `sudo blkdiscard --force /dev/sdX`
    1. Reboot again and run the installer.
1. On the freshly installed system:
    1. `~/Backup/Documents/Archive/Programming/Git/Linux/provision.sh`
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
