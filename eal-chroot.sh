#!/bin/bash
source ceal.sh

mess "Set hostname ($hostname)"
echo $hostname > /etc/hostname

mess "Set local timezone ($timezone)"
ln -s /usr/share/zoneinfo/$timezone /etc/localtime

mess "Install grub to /boot"
pacman -S --noconfirm grub
mess "Install grub to $mbr mbr"
grub-install --target=i386-pc --recheck $mbr
mess "Install os-prober"
pacman -S --noconfirm os-prober
mess "Make grub config"
grub-mkconfig -o /boot/grub/grub.cfg

mess "Move scripts to /root so you could run it right after reboot"
mv *.sh /root/

messpause "Setup ROOT password [MANUAL]"
passwd

mess "Exit chroot"
exit
