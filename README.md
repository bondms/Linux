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
    1. `/media/bondms/BackupSsd/Backup/latest/Documents/Archive/Programming/Git/Linux/provision.sh`
1. Setup tasks:
    * Disable local document search.
    * Log-off old sessions and delete old session tokens.
    * Google Drive:
        * Confugure RClone remote:
            * `rclone config`
        * Fetch latest Google docs
            * `fetch-googledocs.sh`
    * GitHub:
        * Replace SSH and signing keys.
        * Re-sync repos locally.
    * Update any documents, photos, music, etc. since last full backup from partial backups.
    * etc.

### Note(s)
* Use phone USB tethering for Internet until WiFi is configured, but be sure to disable mobile data so that tethering shares the metered WiFi rather than the metered mobile data.
* Use `gnome-text-editor` or `vi` until `code` or `vim` are available.

## Media-PC
[Configure a Raspberry PI 4 media system](Media-PC/README.md).
