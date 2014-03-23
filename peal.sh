#!/bin/bash
source ceal.sh
clear

title "Post- Ewancoder Arch Linux Installation script\nVersion 1.2, 2014"

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
mess "Set chmod to 750 for $username user to be able to read configs via another users"
chmod 750 /home/$username
mess "Add user $username2"
useradd -m -g users -G fuse -s /bin/bash $username2

mess "Create folder /mnt/cloud"
mkdir /mnt/cloud
mess "Mount cloud and add fstab entry"
mount $cloud /mnt/cloud
mess "Make cloud owner is $username"
chown $username:users /mnt/cloud
mess "Make 770 for cloud (need to write from lft)"
chmod 770 /mnt/cloud
ln -fs /mnt/cloud/Dropbox /home/$username/Dropbox
ln -fs /mnt/cloud/Copy /home/$username/Copy
ln -fs /mnt/cloud/Dropbox /home/$username2/Dropbox
ln -fs /mnt/cloud/Copy /home/$username2/Copy
echo -e "# Cloud partition\n$cloud\t/mnt/cloud\t$clfs\t$clparams\t0\t2" >> /etc/fstab

mess "Edit (visudo) sudoers file via awk"
awk '/root ALL/{print;print "'$username' ALL=(ALL) ALL";next}1' /etc/sudoers > lsudoers
awk '/'$username' ALL/{print;print "'$username2' ALL=(ALL) ALL";next}1' lsudoers > lsudoers2
awk '/'$username' ALL/{print;print "'$username' ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm";next}1' lsudoers2 > lsudoers3
mess "Move created by awk sudoers file to /etc/sudoers"
mv lsudoers3 /etc/sudoers && rm lsudoers*
messpause "Setup your user ($username) password [MANUAL]"
passwd $username
messpause "Setup second user ($username) password [MANUAL]"
passwd $username2

warn "Installation begins :)"

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
