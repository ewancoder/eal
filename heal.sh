#!/bin/bash

clear
source ceal.sh
#Need to have squashfs-tools installed
#JUST IN CASE:
#umount -R /arch
#rm -r /squashfs-root

mess -t "This script is intended for installing arch linux from within your working (arch) linux"
mess -w "Be sure that you've changed all constants in ceal.sh (and formatted devices :D lol) because this script will automatically execute eal.sh after chrooting into live-cd"

mess "Download (or not if exists) root live-cd"
if ! [ -f $iso ]; then
    curl -o root-image.fs.sfs $iso
    iso=root-image.fs.sfs
fi
mess "Unsquash root live-cd"
unsquashfs -d /squashfs-root $iso
mess "Make /arch folder"
mkdir -p /arch
mess "Mount all needed things to /arch"
mount -o loop /squashfs-root/root-image.fs /arch
mount -t proc none /arch/proc
mount -t sysfs none /arch/sys
mount -o bind /dev /arch/dev
mount -o bind /dev/pts /arch/dev/pts
cp -L /etc/resolv.conf /arch/etc

mess "Copy {eal,peal,ceal}.sh scripts to /arch/root/"
cp {eal,peal,ceal}.sh /arch/root/
mess "Chroot into /arch and execute /arch/root/eal.sh"
chroot /arch /root/eal.sh
