#!/bin/bash
source ceal.sh

mess "Set local timezone ($timezone)"
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

if [ $ssd -eq 1 ]
then
    mess "Set discard option for ssd in fstab"
    sed -i 's/relatime/relatime,discard/g' /etc/fstab
fi

mess "Move scripts to /root so you could run it right after reboot"
rm eal* && mv peal* ceal.sh /root/

messpause "Setup ROOT password [MANUAL]"
passwd

mess "Exit chroot"
exit
