#!/bin/bash
source ceal.sh

mess -t "Prepare live-cd"
if ! which unsquashfs > /dev/null || ! which curl > /dev/null; then
    mess "Install squashfs-tools"
    if which pacman > /dev/null; then
        pacman -S --noconfirm squashfs-tools curl
    elif which apt-get > /dev/null; then
        apt-get -y install squashfs-tools curl
    fi
fi

mkdir -p /sfs
if ! [ "$temp" == "" ]; then
    mount $temp /sfs
fi
if ! [ -f root-image.fs.sfs ] && ! [ -f /sfs/squashfs-root/root-image.fs ]; then
    mess "Download root live-cd image"
    curl -o root-image.fs.sfs $iso
fi
if ! [ -f /sfs/squashfs-root/root-image.fs ]; then
    mess "Unsquash root live-cd image"
    unsquashfs -d /sfs/squashfs-root root-image.fs.sfs
fi
mess "Live-cd placed to /sfs/squashfs-root/root-image.fs"

mess -t "Prepare chroot-environment"
mess "Make /arch folder"
mkdir -p /arch
mess "Mount all needed things to /arch"
mount -o loop /sfs/squashfs-root/root-image.fs /arch
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
umount /arch/proc
umount /arch/sys
umount /arch/dev/pts
umount /arch/dev
umount /arch
