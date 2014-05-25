#!/bin/bash
source ceal.sh

mess "Configure git user.name"
git config --global user.name $gitname
mess "Configure git user.email"
git config --global user.email $gitemail
mess "Configure git merge.tool"
git config --global merge.tool $gittool
mess "Configure git core.editor"
git config --global core.editor $giteditor
#NEED FOR RUNNING GIT FROM ROOT
mess "Make link to .gitconfig for /root user"
sudo ln -s ~/.gitconfig /root/

#These won't install if merged earlier
mess "Merge pulseaudio instead of alsa (pulseaudio won't install if merged earlier) - /etc/pulse folder"
foldlink "pulse"
mess "Merge bitlbee config (bitlbee won't install if merged earlier) - /etc/bitlbee folder"
foldlink "bitlbee"
#If merged earlier, pam_mount moves config and creates default one
mess "Merge pam_mount.conf.xml"
sudo ln -fs /etc/.dotfiles/security\;pam_mount.conf.xml /etc/security/pam_mount.conf.xml
mess "Merge dnsmasq.conf"
sudo ln -fs /etc/.dotfiles/dnsmasq.conf /etc/dnsmasq.conf
mess "Merge /etc/hostapd folder"
foldlink "hostapd"
#This is managed after actual canto installation :)
filename=/usr/lib/python3.4/site-packages/canto_next/feed.py
sudo sed -i "/from .tag import alltags/afrom .hooks import call_hook" $filename
sudo sed -i "/item\[key\] = olditem/aplaceforbreak" $filename
sudo sed -i "/placeforbreak/aplaceforelse" $filename
sudo sed -i "/placeforelse/aplaceforcall" $filename
sudo sed -i 's/placeforbreak/                    break/g' $filename
sudo sed -i 's/placeforelse/            else:/g' $filename
sudo sed -i 's/placeforcall/                call_hook("daemon_new_item", \[self, item\])/g' $filename

mess "Fix dead acute error in Compose-keys X11 file :)"
sudo sed -i "s/dead_actute/dead_acute/g" /usr/share/X11/locale/en_US.UTF-8/Compose

mess "Change bitlbee folder owner to bitlbee:bitlbee"
sudo mkdir -p /var/lib/bitlbee
sudo chown -R bitlbee:bitlbee /var/lib/bitlbee
mess "Enable bitlbee"
sudo systemctl enable bitlbee
#sudo systemctl start bitlbee
mess "Enable preload"
sudo systemctl enable preload
#sudo systemctl start preload
mess "Enable cronie"
sudo systemctl enable cronie
#sudo systemctl start cronie
mess "Enable deluged & deluge-web"
sudo systemctl enable deluged
sudo systemctl enable deluge-web
mess "Enable hostapd"
sudo systemctl enable hostapd.service
mess "Enable dnsmasq"
sudo systemctl enable dnsmasq.service
mess "Change shell to /bin/zsh for $username & $username2 users"
sudo chsh -s /bin/zsh $username
sudo chsh -s /bin/zsh $username2
mess "Activate fuse (modprobe)"
sudo modprobe fuse
mess "Detect sensors (lm_sensors)"
sudo sensors-detect --auto

mess "Install Copy Agent"
curl -O https://copy.com/install/linux/Copy.tgz
tar xvf Copy.tgz
mv copy ctemp
rm *.tgz
mv ctemp/x86_64 .copy
rm -r ctemp
sudo ln -fs ~/.copy/CopyAgent /usr/bin/copy

mess "Download and place canadian icon into /usr/share/gxkb/flags/ca(fr).png"
curl -o /usr/share/gxkb/flags/ca\(fr\).png http://files.softicons.com/download/web-icons/flags-icons-by-gosquared/png/24x24/Canada.png
#curl -O http://files.softicons.com/download/web-icons/flags-icons-by-gosquared/png/24x24/Canada.png
#sudo mv Canada.png /usr/share/gxkb/flags/ca\(fr\).png

mess "Remove files"
#WARNING IT WILL DELETE ANY LOCAL SCRIPTS I HAVE IN A SYSTEM. NEED TO RENAME ALL EXTENSIONS TO *.eal
sudo rm *.sh

mess "Create regular directories (~/Downloads/*)"
mkdir -p ~/Downloads/Chrome\ Downloads
ln -fs /mnt/backup/Downloads/Torrents ~/Downloads/Torrents
ln -fs /mnt/backup/Downloads/Downloading ~/Downloads/Downloading
ln -fs /mnt/backup/Downloads/Completed ~/Downloads/Completed

mess "BundleInstall - vim installing plugins"
vim +BundleInstall +qall

messpause "Change password for irssi config freenode autocmd [MANUAL]"
cp ~/.irssi/config_sample ~/.irssi/config
vim ~/.irssi/config

exit
