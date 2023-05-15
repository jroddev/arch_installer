#!/bin/bash
set -e

# Identify the correct device from your system with `lsblk`
DISK="/dev/nvme0n1"
ESP_SIZE="512MB"
CRYPT_NAME="cryptroot"
PBKDF2_ITERATIONS=10000

echo "Creating the EFI System Partition (ESP)"
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary fat32 1MiB $ESP_SIZE
parted -s $DISK set 1 esp on

echo "Creating the Linux Root Partition"
parted -s $DISK mkpart primary ext4 $ESP_SIZE 100%

echo "Enter a passphrase for LUKS container:"
read -s PASSPHRASE

echo "Seting up Luks2 on ${DISK}p2"
echo $PASSPHRASE | cryptsetup luksFormat --type luks2 --pbkdf pbkdf2 --iter-time $PBKDF2_ITERATIONS --label $CRYPT_NAME --batch-mode ${DISK}p2
echo "Opening Luks Crypt"
echo $PASSPHRASE | cryptsetup open --batch-mode ${DISK}p2 $CRYPT_NAME

echo "Format Crypt Partition with ext4"
mkfs.ext4 /dev/mapper/$CRYPT_NAME
echo "Mount Linux Root to /mnt"
mount /dev/mapper/$CRYPT_NAME /mnt

echo "Format ${DISK}p1 EPS with fat32"
mkdir -p /mnt/boot/efi
mkfs.fat -F32 ${DISK}p1
mount ${DISK}p1 /mnt/boot/efi

echo "PacStrapping /mnt"
pacstrap -i /mnt base base-devel linux linux-firmware

echo "Generating the file system table at /mnt/etc/fstab"
genfstab -U -p /mnt >> /mnt/etc/fstab

echo "arch-chroot into /mnt"
arch-chroot /mnt

echo "Setting root password to the crypt passphrase"
echo "root:$PASSPHRASE" | chpasswd

echo "Add encrypt to /etc/mkinitcpio.conf HOOKS"
sed -i 's/HOOKS=.*/HOOKS="base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck"/' /etc/mkinitcpio.conf
mkinitcpio -p linux

echo "Adding cryptdevice details to /etc/default/grub"
pacman -S grub efibootmgr
sed -i 's/#GRUB_ENABLE_CRYPTODISK=y/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=${DISK}p2:cryptroot"/' /etc/default/grub
grub-install --recheck --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
grub-mkconfig --output /boot/grub/grub.cfg

exit
echo "System is now setup. Reboot to login to the system"
