#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ceal.sh

mess -t "Mount all partitions and create fstab"
mess "Create local fstab file (prepare)"
echo "# /etc/fstab: static file system information" > fstab
for (( i = 0; i < ${#device[@]}; i++ )); do
    mess "Create folder /mnt${mount[$i]}"
    mkdir -p /mnt${mount[$i]}
    mess "Add ${device[$i]} in fstab mounted to /mnt${mount[$i]}"
    echo -e "\n# ${description[$i]} partition\n${device[$i]}\t${mount[$i]}\t${type[$i]}\t${option[$i]}\t${dump[$i]}\t${pass[$i]}" >> fstab
done
mess "Create /etc/fstab based on local fstab for mounting"
awk '$2~"^/"{$2="/mnt"$2}1' fstab > /etc/fstab
mess "Mount all from /etc/fstab"
mount -a

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
mess "Create /run/shm if not exist [for debian systems]"
if ! [ -d /run/shm ]; then
    mkdir /run/shm
fi
mess "Install base-system"
pacstrap /mnt base base-devel
mess "Move previously created fstab to /mnt/etc/fstab"
mv fstab /mnt/etc/fstab

mess -t "Chroot to system"
mess "Create root folder (just in case)"
mkdir -p /mnt/root
mess "Copy {ceal,peal}.sh to /mnt/root"
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
