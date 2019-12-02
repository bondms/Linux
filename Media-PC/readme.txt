Installing Raspbian (as per https://www.raspberrypi.org/documentation/installation/installing-images/linux.md):
# dd bs=4M if=2019-09-26-raspbian-buster-full.img of=/dev/mmcblk0 status=progress conv=fsync
* Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
* Configure networking.
* Install packages for bs1770gain, sox (all free formats), ...
* Download Linux-master.zip from Github and expand to home folder (i.e. to create ~/Linux-master/...
* Copy Desktop shortcut files.
* Copy Music, Pictures, Playlists, ...
* Fix gnome-mpv video player (from https://github.com/celluloid-player/celluloid/issues/364):
---
I am sharing this YouTube video (https://www.youtube.com/watch?v=9Kafn5xJIgc), which has reproduced the exact same case.
In that video, it is said to disable 3 checkboxes in Preferences, though just disabling checkbox for Enable MPRIS support works for me.
---
* Consider enabling auto-updates including the firmware/boot-loader (from https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md):
---
sudo apt update
sudo apt full-upgrade
sudo apt install rpi-eeprom
---
and (from https://www.raspberrypi.org/forums/viewtopic.php?t=111794):
---
There is a better option though. If you install cron-apt, you can have updates download automatically but not install. This way you don't have problems with unattended updates not knowing whether to replace configuration files that have been changed in the update. You can also set it up to e-mail you when it runs so you know if there are any updates. When you go to run "sudo apt-get upgrade" it doesn't take as long because the updates have already been downloaded and you just need to run the install part.
---
