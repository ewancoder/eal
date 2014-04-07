#!/bin/bash
source ceal.sh
clear

title "Post- Ewancoder Arch Linux Installation script\nVersion 1.5, 2014"

mess "Add group 'fuse'"
groupadd fuse
mess "Add user $username"
useradd -m -g users -G fuse -s /bin/bash $username
mess "Add user $username2"
useradd -m -g users -G fuse -s /bin/bash $username2

messpause "Setup your user ($username) password [MANUAL]"
passwd $username
messpause "Setup second user ($username2) password [MANUAL]"
passwd $username2

if [ $netctl -eq 1 ]
then
    mess "Copy ethernet-static template"
    cp /etc/netctl/examples/ethernet-static /etc/netctl/
    mess "Configure network by using sed"
    sed -i "s/eth0/$interface/" /etc/netctl/ethernet-static
    sed -i "s/^Address=.*/Address=('$ip\/24')/" /etc/netctl/ethernet-static
    sed -i "s/192.168.1.1/192.168.100.1/" /etc/netctl/ethernet-static
    mess "Enable and start netctl ethernet-static"
    netctl enable ethernet-static
    netctl start ethernet-static
else
    mess "Activate DHCPCD"
    systemctl enable dhcpcd
    systemctl start dhcpcd
fi

mess "Create folder /mnt/cloud"
mkdir /mnt/cloud
mess "Create folder /mnt/backup"
mkdir /mnt/backup
mess "Mount cloud"
mount $cloud /mnt/cloud
mess "Mount backup"
mount $backup /mnt/backup
#mess "Make cloud owner is $username"
#chown $username:users /mnt/cloud
#mess "Make backup owner is $username"
#chown $username:users /mnt/backup
#mess "Make 770 for cloud (need to write from lft)"
#chmod 770 /mnt/cloud
ln -fs /mnt/cloud/Dropbox /home/$username/Dropbox
ln -fs /mnt/cloud/Copy /home/$username/Copy
ln -fs /mnt/cloud/Copy /home/$username2/Copy
mess "Write cloud & backup partitions into fstab"
echo -e "# Cloud partition\n$cloud\t/mnt/cloud\t$clfs\t$clparams\t0\t2\n\n# Backup partition\n$backup\t/mnt/backup\t$bafs\t$baparams\t0\t2" >> /etc/fstab

mess "Edit (visudo) sudoers file via awk"
awk '/root ALL/{print;print "'$username' ALL=(ALL) ALL";next}1' /etc/sudoers > lsudoers
awk '/'$username' ALL/{print;print "'$username2' ALL=(ALL) ALL";next}1' lsudoers > lsudoers2
awk '/'$username' ALL/{print;print "'$username' ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm";next}1' lsudoers2 > lsudoers3
mess "Move created by awk sudoers file to /etc/sudoers"
mv lsudoers3 /etc/sudoers && rm lsudoers*

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
reboot
