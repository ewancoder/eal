#!/bin/bash
source ceal.sh
clear

head -n 14 peal.txt

if [ $netctl -eq 1 ]
then
    mess "See /sys/class/net interfaces"
    ls -la /sys/class/net
    mess "Copy ethernet-static template"
    cp /etc/netctl/examples/ethernet-static /etc/netctl/
    messpause "Configure network (edit ethernet-static file) [MANUAL]"
    $edit /etc/netctl/ethernet-static
    mess "Enable and start netctl ethernet-static"
    netctl enable ethernet-static
    netctl start ethernet-static
else
    mess "Temporary start DHCPCD"
    dhcpcd
fi

mess "Add group 'fuse'"
groupadd fuse
mess "Add user $username"
useradd -m -g users -G fuse -s /bin/bash $username

mess "Install sudo"
pacman -S --noconfirm sudo
mess "Edit (visudo) sudoers file via awk"
awk '/root ALL/{print;print "'$username' ALL=(ALL) ALL";next}1' /etc/sudoers > lsudoers
mess "Move created by awk sudoers file to /etc/sudoers"
mv lsudoers /etc/sudoers
messpause "Setup your user ($username) password [MANUAL]"
passwd $username
mess "Move all scripts except peal.sh to /home/$username/ and remove peal.sh"
rm peal.sh && mv peal* ceal.sh /home/$username/
mess "CD into /home/$username/ folder"
cd /home/$username/
mess "Add $username NOPASSWD line to sudoers file"
echo "$username ALL = NOPASSWD: ALL" >> /etc/sudoers
mess "Run peal-user.sh as $username user"
su - $username -c ./peal-user.sh
mess "Remove $username NOPASSWD line from sudoers file"
sed '/'$username' ALL = NOPASSWD: ALL/d' /etc/sudoers > sudoers
mv sudoers /etc/sudoers

warn "Read ~/.dotfiles/.eal/peal-user.sh for further instructions after [REBOOT] in X server"
mess "Reboot"
reboot
