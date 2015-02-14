#!/bin/bash
cd `dirname "$BASH_SOURCE"`
source ceal.sh
mess -t "Mount all partitions and create fstab"
mess "Create local fstab file (prepare)"
echo "# /etc/fstab: static file system information" > fstab
for (( i = 0; i < ${#device[@]}; i++ )); do
    if [ ! "${type[$i]}" == "swap" ]; then
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
if [ ! -d /run/shm ]; then
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
cp makepkg.patch /mnt/root/
mess "Go to arch-chroot and execute peal.sh"
mount --bind /run /mnt/run #Supposedly fixing grub errors problem
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
