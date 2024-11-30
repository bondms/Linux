# Media PC

## Raspberry PI 4 running Raspberry PI OS

1. Main PC: Create a Raspberry PI OS (previously Raspbian) image using the Raspberry Pi Imager as per [Raspberry Pi OS](https://www.raspberrypi.com/software/):
* For the PI 4, the 64-bit Raspberry PI OS is preferred.
* Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
* Provide the Wi-Fi password to the Imager so that it doesn't need to be entered on the Pi.
1. Media PC: Download Linux-main.zip from GitHub and expand to home folder (i.e. to create ~/Linux-main/...
1. Media PC: Run `Media-PC/setup.sh`.
1. Media PC: Once xscreensaver has been installed, disable the screensaver from the screensaver application available on the application menu.
1. Media PC: Pair Bluetooth device(s).
1. Main PC: Use `Media-PC/sync.sh` to synchronise Music, Pictures, Playlists, Podcasts, etc. to the Media PC's disk.
