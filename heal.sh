#!/bin/bash
set -e
source ceal.sh
clear

mess -t "Ewancoder Arch Linux HOST installation script\nVersion $version\n\nThis script is intended for installing arch linux from within your working (arch) linux. If you want to just install linux from live-cd and you're already using live-cd, just run eal.sh to start"
mess -w "Before proceeding, MAKE SURE that\n\t1) You have changed all constants in 'ceal.sh' file\n\t2) You have formatted your partitions as needed (fdisk + mkfs.ext4) and put them into 'ceal.sh' file"
source ceal.sh

mess -t "Prepare live-cd"
if [ "$(pacman -Qs squashfs-tools)" == "" ]; then
    mess "Install squashfs-tools"
    pacman -S --noconfirm squashfs-tools
fi
if ! [ -f root-image.fs.sfs ] && ! [ -d /squashfs-root ]; then
    mess "Download root live-cd image"
    curl -o root-image.fs.sfs $iso
fi
if ! [ -d /squashfs-root ]; then
    mess "Unsquash root live-cd image"
    unsquashfs -d /squashfs-root root-image.fs.sfs
fi
mess "Live-cd placed to /squashfs-root/root-image.fs"

mess -t "Prepare chroot-environment"
mess "Make /arch folder"
mkdir -p /arch
mess "Mount all needed things to /arch"
mount -o loop /squashfs-root/root-image.fs /arch
mount -t proc none /arch/proc
mount -t sysfs none /arch/sys
mount -o bind /dev /arch/dev
mount -o bind /dev/pts /arch/dev/pts
cp -L /etc/resolv.conf /arch/etc

mess -t "Chroot into live-cd environment and execute eal.sh"
mess "Copy {eal,ceal,peal}.sh scripts to /arch/root/"
cp {eal,ceal,peal}.sh /arch/root/
mess "Chroot into /arch and execute /root/eal.sh"
chroot /arch /root/eal.sh --hide

mess "Unmount all within /arch"
umount -R /arch
mess -w "This is it. You can reboot into your working system"
