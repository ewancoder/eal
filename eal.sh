#!/bin/bash
source ceal.sh
clear

title "Ewancoder Arch Linux Installation script\nVersion $version"
warn "Before executing script, MAKE SURE that\n\t1) You've mounted your partitions to /mnt and formatted them as needed (fdisk + mkfs.ext4 + mount)\n\t2) You've changed all constants in 'ceal.sh' file"
source ceal.sh

if [ $fauto -eq 1 ]
then
    warn "Now will be performed formatting of $devices devices and then automounting to /mnt. Is that right? [CONTINUE]"
    for (( i = 0; i < ${#fdevices[@]}; i++ )); do
        mess "Format ${fdevices[$i]} in ${ffs[$i]}"
        ${ffs[$i]} ${fdevices[$i]}
        mess "Mount ${fdevices[$i]} to ${fmount[$i]}"
        mkdir -p ${fmount[$i]}
        mount ${fdevices[$i]} ${fmount[$i]}
        mess "Delete lost+found folder"
        rm -r ${fmount[$i]}/lost*
    done
fi

mess "Copy all scripts to /mnt/"
cp *eal* /mnt/

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

mess "Generate fstab"
genfstab -U -p /mnt >> /mnt/etc/fstab

mess "Go to chroot"
arch-chroot /mnt /eal-chroot.sh
mess "Unmount all within /mnt"
umount -R /mnt

warn "After [REBOOT] run ./peal.sh to continue"
reboot
