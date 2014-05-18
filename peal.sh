#!/bin/bash
source ceal.sh
clear

title "Post- Ewancoder Arch Linux Installation script\nVersion $version"

mess "Add group 'fuse'"
groupadd fuse
for i in "${users[@]}"
do
    mess "Add user $i"
    useradd -m -g users -G fuse -s /bin/bash $i
    messpause "Setup user ($i) password [MANUAL]"
    passwd $i
done

if [ $netctl -eq 1 ]
then
    mess "Copy ethernet-static template"
    cp /etc/netctl/examples/ethernet-static /etc/netctl/
    mess "Configure network by using sed"
    sed -i "s/eth0/$interface/" /etc/netctl/ethernet-static
    sed -i "s/^Address=.*/Address=('$ip\/24')/" /etc/netctl/ethernet-static
    sed -i "s/192.168.1.1/$dns/" /etc/netctl/ethernet-static
    mess "Enable and start netctl ethernet-static"
    netctl enable ethernet-static
    netctl start ethernet-static
else
    mess "Enable and start dhcpcd"
    systemctl enable dhcpcd
    dhcpcd
    warn "Wait several seconds and try to ping something at another tty, then if network is ready, press [RETURN]"
fi

mess "Create mount folders /mnt/cloud & /mnt/backup"
mkdir /mnt/cloud
mkdir /mnt/backup
mess "Mount folders /mnt/cloud & /mnt/backup"
mount $cloud /mnt/cloud
mount $backup /mnt/backup
mess "Make Dropbox & Copy links to home folder"
ln -fs /mnt/cloud/Dropbox /home/$username/Dropbox
ln -fs /mnt/cloud/Copy /home/$username/Copy
ln -fs /mnt/cloud/Copy /home/$username2/Copy
mess "Write cloud & backup partitions into fstab"
echo -e "# Cloud partition\n$cloud\t/mnt/cloud\t$clfs\t$clparams\t0\t2\n\n# Backup partition\n$backup\t/mnt/backup\t$bafs\t$baparams\t0\t2\n\n" >> /etc/fstab

mess "Edit (visudo) sudoers file via awk"
awk '/root ALL/{print;print "'$username' ALL=(ALL) ALL";next}1' /etc/sudoers > lsudoers
awk '/root ALL/{print;print "'$username' ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0";next}1' lsudoers > lsudoers2
awk '/'$username' ALL/{print;print "'$username2' ALL=(ALL) ALL";next}1' lsudoers > lsudoers3
awk '/'$username' ALL/{print;print "'$username' ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm";next}1' lsudoers3 > lsudoers4
mess "Move created by awk sudoers file to /etc/sudoers"
mv lsudoers4 /etc/sudoers && rm lsudoers*

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
