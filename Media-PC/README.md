# Media PC

## Raspberry PI 4 running Raspberry PI OS (64-bit, Debian version 12/Bookwork)

1. Main PC: Create a Raspberry PI OS (previously Raspbian) image using the Raspberry Pi Imager as per [Raspberry Pi OS](https://www.raspberrypi.com/software/):
* For the PI 4, the 64-bit Raspberry PI OS is preferred.
* Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
* Provide the Wi-Fi password to the Imager so that it doesn't need to be entered on the Pi.
1. Media PC: Download Linux-main.zip from GitHub and expand to home folder (i.e. to create ~/Linux-main/...): `cd && unzip ~/Downloads/Linux-main.zip`
1. Media PC: Run:
    * `~/Linux-main/Media-PC/setup.sh`.
1. Perform initial setup:
    * `sudo raspi-config`
        * Enable HDMI output vs. headphones.
        * Enable 4Kp60 HDMI video.
        * Select the latest bootloader version.
        * [Select PipeWire vs. PulseAudio audio.]
        * Perform update.
1. Check bootloader eeprom update has been applied before re-running setup script:
    * `sudo rpi-eeprom-update`
    * `~/Linux-main/Media-PC/setup.sh`
1. Media PC: Once xscreensaver has been installed, disable the screensaver from the screensaver application available on the application menu.
1. Media PC: Pair Bluetooth device(s).
1. Main PC: Use `./sync.sh` to synchronise Music, Pictures, Playlists, Podcasts, etc. to the Media PC's disk.
