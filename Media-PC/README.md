# Media PC

## Raspberry PI 4 running Raspberry PI OS 11 (buster)

Install Raspberry PI OS (previously Raspbian) as per https://www.raspberrypi.com/documentation/computers/getting-started.html:
1. Main PC: `dd bs=4M if=2019-09-26-raspbian-buster-full.img of=/dev/mmcblk0 status=progress conv=fsync`
    * Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
    * Don't confirm the black border, else it will remove it and then the desktop edges will be off the TV screen.
1. Media PC: Configure networking.
1. Media PC: Download Linux-master.zip from Github and expand to home folder (i.e. to create ~/Linux-master/...
1. Media PC: Install disable screensaver (from xscreensaver) to turn-off screen blanking.
1. Main PC: Use `sync.sh` to synchronise Music, Pictures, Playlists, Podcasts, etc. to the Media PC's disk.

TODO:
* Enable auto-updates including the firmware/boot-loader (from https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md):
* Picture orientation and audio levelling for external and when copying new files to internal storage.
