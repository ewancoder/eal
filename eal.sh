#!/bin/bash
source ceal.sh
clear

title "Ewancoder Arch Linux installation script\nVersion $version"
warn "Before proceeding, MAKE SURE that\n\t1) You have changed all constants in 'ceal.sh' file ($edit ceal.sh)\n\t1) You have FORMATTED your partitions as needed (fdisk + mkfs.ext4) and put them into 'ceal.sh' file"
source ceal.sh

mess "Mount all partitions and create fstab"
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

mess "Prepare chroot-script for installing grub and setting root password"
echo '
source ceal.sh

mess "Install grub to /boot"
pacman -S --noconfirm grub
mess "Install grub to $mbr mbr"
grub-install --target=i386-pc --recheck $mbr
mess "Install os-prober"
pacman -S --noconfirm os-prober
mess "Make grub config"
grub-mkconfig -o /boot/grub/grub.cfg

mess "Remove script finally"
rm /root/eal-chroot.sh

messpause "Setup ROOT password [MANUAL]"
passwd

mess "Exit chroot"
exit
' > /mnt/root/eal-chroot.sh
mess "Set executable flag"
chmod +x /mnt/root/eal-chroot.sh
mess "Copy {ceal,peal}.sh to /mnt/root"
cp {ceal,peal}.sh /mnt/root/

mess "Go to chroot"
arch-chroot /mnt /eal-chroot.sh
mess "Unmount all within /mnt"
umount -R /mnt

warn "After [REBOOT] run ./peal.sh to continue"
reboot
