#!/bin/bash
source ceal.sh

cp -r /mnt/backup/Arch/* ~/
#NEED TO DO SMTH ABOUT spool/cron/ewancoder FILE

mess "Change shell to /bin/zsh for $username user"
chsh -s /bin/zsh $username

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

mess "Install Copy Agent"
curl -O https://copy.com/install/linux/Copy.tgz
tar xvf Copy.tgz
mv copy ctemp
rm *.tgz
mv ctemp/x86_64 .copy
rm -r ctemp
sudo ln -fs ~/.copy/CopyAgent /usr/bin/copy

mess "Remove files"
#WARNING IT WILL DELETE ANY LOCAL SCRIPTS I HAVE IN A SYSTEM. NEED TO RENAME ALL EXTENSIONS TO *.eal
rm *.sh

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
