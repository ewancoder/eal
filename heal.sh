#!/bin/bash
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
chroot /arch /root/eal.sh

mess "Unmount all within /arch"
umount -R /arch
