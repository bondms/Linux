# Development Virtual Machine

## KVM/QEMU Virtual Machine running Debian 13.4.0-amd64 (Trixie)

1. On the freshly installed system:
    1. Enable `sudo` for the user, e.g. for user `bondms`:
        1. `su -`
        1. `usermod -aG sudo bondms`
        1. Confirm with: `getent group sudo`
        1. Reboot.
    1. `~/Backup/Documents/Archive/Programming/Git/Linux/provision.sh`
