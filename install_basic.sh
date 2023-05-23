#!/bin/bash
set -e

echo "Enter a name for this Computer:"
read HOSTNAME
echo "Enter a name for the non-root user:"
read NON_ROOT_USER
echo "Enter a password for this user and root (same):"
read -s PASSWORD

# Update system clock
timedatectl set-ntp true

# Partition the disk (replace dev/nvme0 with your disk identifier)
# Example partitioning: EFI (ESP) + root (/) partitions
parted /dev/nvme0n1 mklabel gpt
parted /dev/nvme0n1 mkpart primary fat32 1MiB 512MiB
parted /dev/nvme0n1 set 1 esp on
parted /dev/nvme0n1 mkpart primary ext4 512MiB 100%

# Format partitions
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2

# Mount the partitions
mount /dev/nvme0n1p2 /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Install essential packages
pacstrap /mnt base linux linux-firmware base base-devel --noconfirm
pacstrap /mnt plasma-desktop plasma-wayland-session sddm konsole dolphin plasma-nm kscreen --noconfirm

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the newly installed system
arch-chroot /mnt /bin/bash <<EOF

    # Set the system time zone
    ln -sf /usr/share/zoneinfo/Australia/Sydney /etc/localtime
    hwclock --systohc

    # Set locale
    sed -i 's/#en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=en_AU.UTF-8" > /etc/locale.conf

    # Set hostname
    echo $HOSTNAME > /etc/hostname
    echo "127.0.0.1	localhost" > /etc/hosts
    echo "::1		localhost" >> /etc/hosts
    echo "127.0.1.1	$HOSTNAME" >> /etc/hosts

    # Set root password
    echo "Set the root password:"
    echo "root:$PASSWORD" | chpasswd

    # Create non-root user
    useradd -m $NON_ROOT_USER
    echo "jarrod:$PASSWORD" | chpasswd
    usermod -aG wheel,audio,video,storage $NON_ROOT_USER

    # Add the 'wheel' group to the sudoers file
    sed -i '/^# %wheel ALL=(ALL:ALL) ALL$/s/^# //' /etc/sudoers

    # Install and configure bootloader (replace dev/nvme0n1 with your disk identifier)
    bootctl --path=/boot install
    echo "default arch" > /boot/loader/loader.conf
    echo "timeout 5" >> /boot/loader/loader.conf
    echo "editor 0" >> /boot/loader/loader.conf
    echo "title Arch Linux" > /boot/loader/entries/arch.conf
    echo "linux /vmlinuz-linux" >> /boot/loader/entries/arch.conf
    echo "initrd /initramfs-linux.img" >> /boot/loader/entries/arch.conf
    echo "options root=dev/nvme0n1p2 rw" >> /boot/loader/entries/arch.conf


    echo "Installing other applications"
    pacman -S --needed --noconfirm networkmanager vim firefox git

    # Enable and start services
    systemctl enable sddm
    systemctl enable NetworkManager

    # Exit chroot
    exit
EOF

# Unmount partitions and reboot
umount -R /mnt
reboot

