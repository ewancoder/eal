#!/bin/bash
source ceal.sh
clear

title "Ewancoder Arch Linux Installation script\nVersion 1.5, 2014"
warn "Before executing script, MAKE SURE that\n\t1) You've mounted your partitions to /mnt and formatted them as needed (fdisk + mkfs.ext4 + mount)\n\t2) You've changed all constants in 'ceal.sh' file"
source ceal.sh

mess "Copy all scripts to /mnt/"
cp *eal* /mnt/

mess "Place $mirror1 on the first place"
grep -B 0 -C 1 $mirror1 /etc/pacman.d/mirrorlist > mirrorlist
mess "Place $mirror2 next"
grep -B 0 -C 1 $mirror2 /etc/pacman.d/mirrorlist >> mirrorlist
mess "Place $mirror3 next"
grep -B 0 -C 1 $mirror3 /etc/pacman.d/mirrorlist >> mirrorlist
mess "Place $mirror4 next"
grep -B 0 -C 1 $mirror4 /etc/pacman.d/mirrorlist >> mirrorlist
mess "Place $mirror5 next"
grep -B 0 -C 1 $mirror5 /etc/pacman.d/mirrorlist >> mirrorlist
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

warn "After [REBOOT] run ./peal.sh to continue"
reboot
