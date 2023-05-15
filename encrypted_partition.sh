#!/bin/bash

# Identify the correct device from your system with `lsblk`
DISK="/dev/nvme0n1"
ESP_SIZE="512MB"
CRYPT_NAME="cryptroot"
PBKDF2_ITERATIONS=10000

# Create ESP partition
# ef00 is the partition type guide reserved for ESP
echo "Creating the EFI System Partition (ESP)"
# sgdisk -n 1:0:+ESP_SIZE -t 1:ef00 -c 1:"EFI System Partition" $DISK
parted -s $DISK mklabel gpt
parted -s $DISK mkpart primary fat32 1MiB $ESP_SIZE
parted -s $DISK set 1 esp on

# Create root partition
echo "Creating the Linux Root Partition"
# sgdisk -n 2:0:0 -t 2:8300 -c 2:"Arch Linux Root" $DISK
parted -s $DISK mkpart primary ext $ESP_SIZE 100%

# Prompt for LUKs passphrase
echo "Enter a passphrase for LUKS container:"
read -s PASSPHRASE

echo "Seting up Luks2 on ${DISK}p2"
echo $PASSPHRASE | cryptsetup luksFormat --type luks2 --pbkdf pbkdf2 --iter-time $PBKDF2_ITERATIONS --label $CRYPT_NAME --batch-mode ${DISK}p2
echo "Opening Luks Crypt"
echo $PASSPHRASE | cryptsetup open --batch-mode ${DISK}p2 $CRYPT_NAME

echo "Format Crypt Partition with ext4"
mkfs.ext4 /dev/mapper/$CRYPT_NAME
echo "Mount Linux Root to /mnt"
mount dev/mapper/cryptroot /mnt

echo "Format ${DISK}p1 EPS with fat32"
mkdir -p /mnt/boot
mkfs.fat -F32 ${DISK}p1
mount ${DISK}p1 /mnt/boot
