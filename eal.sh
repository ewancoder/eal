#!/bin/bash
cd $(dirname "$BASH_SOURCE")
source ceal.sh
mess -t "Mount all partitions and create fstab"
mess "Create local fstab file (prepare)"
echo "# /etc/fstab: static file system information" > fstab
for (( i = 0; i < ${#device[@]}; i++ )); do
    if ! [ "${type[$i]}" == "swap" ]; then
        mess "Create folder /mnt${mount[$i]}"
        mkdir -p /mnt${mount[$i]}
        mess "Mount ${device[$i]} to /mnt${mount[$i]}"
        mount ${device[$i]} /mnt${mount[$i]}
    else
        mess "Swapon ${device[$i]}"
        swapon ${device[$i]}
    fi
    mess "Add ${device[$i]} in fstab mounted to ${mount[$i]}"
    echo -e "\n# ${description[$i]} partition\n${device[$i]}\t${mount[$i]}\t${type[$i]}\t${option[$i]}\t${dump[$i]}\t${pass[$i]}" >> fstab
done

if [ ! "$pkgsymlink" == "" -o $localinstall -eq 1 ]; then
    mess -t "Prepare local package cache"
fi
if ! [ "$pkgsymlink" == "" ]; then
    mess "Create symlink to /var/cache/pacman/pkg ($pkgsymlink)"
    rm -rf /var/cache/pacman/pkg
    ln -fs /mnt$pkgsymlink /var/cache/pacman/pkg
fi
#if [ $localinstall -eq 1 -a "`grep '\[local64\]' /etc/pacman.conf`" == "" ]; then
#    mess "Edit pacman.conf to include local repositories"
#    echo -e "[local64]\nSigLevel = PackageRequired\nServer = file:///var/cache/pacman/pkg\n[local32]\nSigLevel = PackageRequired\nServer = file:///var/cache/pacman/pkg\n[local]\nSigLevel = PackageRequired\nServer = file:///var/cache/pacman/pkg" >> /etc/pacman.conf
#fi

mess -t "Form mirrorlist & update pacman"
for i in "${mirror[@]}"; do
    mess "Place $i in mirrorlist"
    grep -i -A 1 --no-group-separator $i /etc/pacman.d/mirrorlist >> mirrorlist
done
mess "Move new mirrorlist to /etc/pacman.d/mirrorlist"
mv mirrorlist /etc/pacman.d/mirrorlist
mess "Update pacman packages list"
pacman -Syy
if [ $hostinstall -eq 1 ]; then
    mess "Initializing pacman keyring"
    pacman-key --init
    pacman-key --populate archlinux
    pacman-key --keyserver hkp://pgp.mit.edu -r B02854ED753E0F1F
fi

mess -t "Install system"
if ! [ -d /run/shm ]; then
    mess "Create /run/shm cause it doesn't exist [for debian systems]"
    mkdir /run/shm
fi
mess "Install base-system"
pacstrap /mnt base base-devel
mess "Move previously created fstab to /mnt/etc/fstab"
mv fstab /mnt/etc/fstab

mess -t "Chroot to system"
mess "Copy {ceal,peal}.sh to /mnt/root"
mkdir -p /mnt/root
cp {ceal,peal}.sh /mnt/root/
mess "Go to arch-chroot and execute peal.sh"
arch-chroot /mnt /root/peal.sh

mess "Unmount all within /mnt (unmount installed system)"
umount -R /mnt
if [ $hostinstall -eq 1 ]; then
    mess "Exiting chroot (live-cd -> host system)"
    exit
else
    mess -w "This is it. Your system is installed [REBOOT]"
    reboot
fi
