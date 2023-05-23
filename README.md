# arch_installer

## Basic Install

`install_basic.sh` should setup everything for a very basic Arch + KDE installation. Enough to login to a desktop at least. It will ask for a hostname, username, and password then everything after that should be `--noconfirm` and eventually reboot into KDE.
It may also ask if it's OK to wipe the disk depending on whats on it. Double check the right device is used (hardcoded to /dev/nvme0n1)

You will need an internet connection to perform the installation. If you have ethernet then it should already work. If you want to use WiFi then follow the `iwctl` instructions below.
```
$ iwctl
# list the network interfaces. For me it was wlan0
$ station device list
# Connect to a WiFI network
$ station wlan0 connect "SSID NAME"
# ctrl+D to exit
```

tested on a 2018 Macbook Pro 14-inch


## Post Install


## Incomplete

encrypted_partition.sh and arch-chroot-bootstrap.sh are unused and incomplete.
The next iteration of these was to add 2 luks keys to the crypt partition.
1. the one you type in
2. on that is stored in /root and copied into the initramfs img

The problem with this is that the img is stored on the unencrypted partition.
The laptop I was testing on does not have a TPM module so I skipped the encryption for it.
