Installing Raspbian (as per https://www.raspberrypi.org/documentation/installation/installing-images/linux.md):
# dd bs=4M if=2019-09-26-raspbian-buster-full.img of=/dev/mmcblk0 status=progress conv=fsync
* Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
* Don't confirm the black border, else it will remove it and then the desktop edges will be off the TV screen.
* Configure networking.
* Install packages for bs1770gain, sox (player and all free formats), feh, ...
* Download Linux-master.zip from Github and expand to home folder (i.e. to create ~/Linux-master/...
* Copy Desktop shortcut files.
* Copy Music, Pictures, Playlists, ...
* Install xscreensaver and disable screensaver to turn-off screen blanking.
* Copy asound.conf to /etc/. to downmix all audio output from stereo to mono. Reboot to take effect.
  * From https://www.tinkerboy.xyz/raspberry-pi-downmixing-from-stereo-to-mono-sound-output/
  * The device number in `hw:N` is determined from the output of `cat /proc/asound/modules`.

TODO:
* Enable auto-updates including the firmware/boot-loader (from https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md):
---
sudo apt update # Update package status.
sudo apt full-upgrade # Update installed packages.
sudo apt autoremove # Remove obsoleted packages.
sudo apt install rpi-eeprom # Install bootloader updater software (Was already installed).
sudo rpi-eeprom-update # Check bootloader status (Was shown as up-to-date with latest 10 Sep 10:41:50 UTC 2019).

TODO:
* Picture orientation and audio levelling for external and when copying new files to internal storage.
* ...

TODO:
* Scripts for Radio (Varna, Fip, ...).
* Rsync pictures (after cleaning), music files & playlists.
