#!/bin/bash

echo "Enter a password for the root user:"
read -s PASSPHRASE

echo "Setting root password"
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

echo "System is now setup. exit and reboot to login to the system"
