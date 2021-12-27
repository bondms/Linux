Installing Raspbian (as per https://www.raspberrypi.org/documentation/installation/installing-images/linux.md):
# dd bs=4M if=2019-09-26-raspbian-buster-full.img of=/dev/mmcblk0 status=progress conv=fsync
* Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
* Don't confirm the black border, else it will remove it and then the desktop edges will be off the TV screen.
* Configure networking.
* Download Linux-master.zip from Github and expand to home folder (i.e. to create ~/Linux-master/...
* Use sync.sh to synchronise Desktop, Music, Pictures, Playlists, Podcasts, etc.
* Install disable screensaver (from xscreensaver) to turn-off screen blanking.

TODO:
* Enable auto-updates including the firmware/boot-loader (from https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md):
---

TODO:
* Picture orientation and audio levelling for external and when copying new files to internal storage.
