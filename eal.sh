#!/bin/bash
source ceal.sh
clear

warn "Before executing script, MAKE SURE that\n\t1) You've mounted your partitions to /mnt and formatted them as needed (fdisk + mkfs.ext4 + mount)\n\t2) You've changed ALL constants in 'ceal.sh' file (Constants Ewancoder Arch Linux), especially - grub installation device"
source ceal.sh

mess "Copy all scripts to /mnt/"
cp *eal* /mnt/

mess "Place Belarus on the first place"
grep -B 0 -C 1 Belarus /etc/pacman.d/mirrorlist > mirrorlist
mess "Place United States/Kingdom next"
grep -B 0 -C 1 United /etc/pacman.d/mirrorlist >> mirrorlist
mess "Place Denmark next"
grep -B 0 -C 1 Denmark /etc/pacman.d/mirrorlist >> mirrorlist
mess "Place France next"
grep -B 0 -C 1 France /etc/pacman.d/mirrorlist >> mirrorlist
mess "Place Russia next"
grep -B 0 -C 1 Russia /etc/pacman.d/mirrorlist >> mirrorlist
mess "Cut '--' lines from mirrorlist"
sed '/--/d' mirrorlist > templist
mess "Move new mirrorlist to /etc/pacman.d/mirrorlist"
mv templist /etc/pacman.d/mirrorlist
mess "Update pacman packages list"
pacman -Syy

mess "Install base-system"
pacstrap /mnt base base-devel

mess "Generate fstab"
genfstab -U -p /mnt >> /mnt/etc/fstab

mess "Go to chroot"
arch-chroot /mnt /eal-chroot.sh
mess "Unmount all within /mnt"
umount -R /mnt

warn "After [REBOOT] run ./peal.sh to continue (post-ewancoder-arch-linux install)"
mess "Reboot"
reboot
