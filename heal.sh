#!/bin/bash
source ceal.sh
mess -t "Installing needed software"
if which unsquashfs > /dev/null && which curl > /dev/null; then
    mess "Both squashfs-tools and curl are installed, skipping..."
else
    mess "Install squashfs-tools and curl"
    if which pacman > /dev/null; then
        pacman -Syy
        pacman -S --noconfirm squashfs-tools curl
    elif which apt-get > /dev/null; then
        apt-get update
        apt-get -y install squashfs-tools curl
    else
        mess -w "Package manager is neither 'pacman' nor 'apt-get'. Can't install tools. Please, make sure that 'squashfs-tools' and 'curl' packages are installed."
    fi
fi

mess -t "Prepare Arch linux ROOTFS"
mkdir -p /sfs
if [ ! "$temp" == "" ]; then
    mess "Mount $temp temporary partition for unsquashing live-cd (must have 1G+ free space)"
    mount $temp /sfs
fi
if ! [ -f root-image.fs.sfs -o -f /sfs/squashfs-root/airootfs.img ]; then
    mess "Download root live-cd image"
    curl -o root-image.fs.sfs $iso
fi
if [ ! -f /sfs/squashfs-root/airootfs.img ]; then
    mess "Unsquash root live-cd image to /sfs/squashfs-root/root-image.fs"
    unsquashfs -d /sfs/squashfs-root root-image.fs.sfs
else
    mess "Root live-cd image already exists at /sfs/squashfs-root/root-image.fs"
fi

mess -t "Prepare chroot-environment"
mess "Make /arch folder"
mkdir -p /arch
mess "Mount all needed things to /arch"
mount -o loop /sfs/squashfs-root/airootfs.img /arch
mount -t proc none /arch/proc
mount -t sysfs none /arch/sys
mount -o bind /dev /arch/dev
mount -o bind /dev/pts /arch/dev/pts
cp -L /etc/resolv.conf /arch/etc

mess -t "Chroot into live-cd environment and execute eal.sh (start regular installation)"
mess "Copy eal folder to /arch/eal"
cp -r . /arch/eal
mess "Chroot into /arch and execute /eal/eal.sh"
chroot /arch /eal/eal.sh
mess "Remove /eal folder"
rm -rf /eal
