# Media PC

## Raspberry PI 4 running Raspberry PI OS (64-bit, Debian version 13/Trixie)

1. Main PC: Erase the SD card:
    * `sudo blkdiscard -f /dev/mmcblk0`
1. Main PC: Create a Raspberry PI OS (previously Raspbian) image using the Raspberry Pi Imager as per [Raspberry Pi OS](https://www.raspberrypi.com/software/). There's no need to download an ISO first, the Imager will do that:
* For the PI 4 (Model B), the 64-bit Raspberry PI OS is preferred.
* Don't worry that this creates a small root partition. On first boot it will be expanded to fill the available space.
* Provide the Wi-Fi password to the Imager so that it doesn't need to be entered on the Pi.
1. Clone "Linux" Git repo:
    * `git clone --filter=blob:none https://github.com/bondms/Linux.git "${HOME}/Linux"`
1. Media PC: Run:
    * `~/Linux/Media-PC/setup.sh`.
1. Media PC: Perform initial setup:
    * `sudo raspi-config`
1. Main PC: Use `./sync.sh` to synchronise Music, Pictures, Playlists, Podcasts, etc. to the Media PC's disk.
1. Media PC: Pair Bluetooth device(s).
1. Media PC: Update clock time display format to show seconds.
    * Right click the taskbar clock and choose "Configure Plugin...".
    * From `man date`, change time format from `%R` to `%R:%S`.
1. Media PC: From Control Center, choose "Set Defaults" "For Large Screens" under "Defaults".
1. Media PC: Decrypt secrets of podcast-sync to home folder.

## Links

* [FIP](https://www.radiofrance.fr/fip)
* [GitHub](https://github.com/bondms/Linux)
* [Google Drive](https://drive.google.com/)
* [Playlists](https://music.youtube.com/browse/UCoCiiKnKx09fG6EnurQDy0A)
* [Radio Varna](https://binar.bg/radio-varna/)
* [Stereo test](https://youtu.be/6TWJaFD6R2s?si=SeF6gn_TzVnGVoJe)
* [YouTube](https://www.youtube.com/)
* [YouTube Music](https://music.youtube.com/)
