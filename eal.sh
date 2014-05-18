#!/bin/bash
source ceal.sh
clear

title "Ewancoder Arch Linux Installation script\nVersion $version"
warn "Before proceeding, MAKE SURE that\n\t1) You've FORMATTED your partitions as needed (fdisk + mkfs.ext4), optional. All partitions will be mounted automatically\n\t2) You've changed all constants in 'ceal.sh' file"
source ceal.sh

mess "Automount all partitions and create fstab"
echo "# /etc/fstab: static file system information" > fstab
for (( i = 0; i < ${#devices[@]}; i++ )); do
    mess "Create folder /mnt${mounts[$i]}"
    mkdir -p /mnt${mounts[$i]}
    mess "Mount ${devices[$i]} to /mnt${mounts[$i]}"
    mount ${devices[$i]} /mnt${mounts[$i]}
    mess "Add fstab ${descriptions[$i]} partition entry '${devices[$i]}\t${mounts[$i]}\t${types[$i]}\t${options[$i]}\t${dumps[$i]}\t${passes[$i]}'"
    echo -e "\n#${descriptions[$i]} partition\n${devices[$i]}\t${mounts[$i]}\t${types[$i]}\t${options[$i]}\t${dumps[$i]}\t${passes[$i]}" >> fstab
done

mess "Forming mirrorlist"
for i in "${mirrors[@]}"
do
    mess "Place $i in mirrorlist"
    grep -A 1 --no-group-separator $i /etc/pacman.d/mirrorlist >> mirrorlist
done
mess "Move new mirrorlist to /etc/pacman.d/mirrorlist"
mv mirrorlist /etc/pacman.d/mirrorlist
mess "Update pacman packages list"
pacman -Syy

mess "Install base-system"
pacstrap /mnt base base-devel

mess "Move fstab to /mnt/etc/fstab"
mv fstab /mnt/etc/fstab

mess "Copy all scripts to /mnt/"
cp *eal* /mnt/
mess "Go to chroot"
arch-chroot /mnt /eal-chroot.sh
mess "Unmount all within /mnt"
umount -R /mnt

warn "After [REBOOT] run ./peal.sh to continue"
reboot
