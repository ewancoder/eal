#!/bin/bash
source ceal.sh

mess "Make link to local timezone ($timezone)"
ln -s /usr/share/zoneinfo/$timezone /etc/localtime

mess "Set hostname ($hostname)"
echo $hostname > /etc/hostname

mess "Install grub to /boot"
pacman -S --noconfirm grub
mess "Install grub to $device mbr"
grub-install --target=i386-pc --recheck $device
mess "Install os-prober"
pacman -S --noconfirm os-prober
mess "Make grub config"
grub-mkconfig -o /boot/grub/grub.cfg

messpause "Setup root password [MANUAL]"
passwd

if [ $clearfstab -eq 0 ]
then
    messpause "Edit fstab (add 'discard' for ssd, comment /boot partition [MANUAL]"
    $edit /etc/fstab
fi

mess "Move scripts to /root so you could run it right after reboot"
rm eal* && mv peal* ceal.sh /root/
mess "Exit chroot"
exit
