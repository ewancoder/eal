#!/bin/bash
source ceal.sh

#TEMPORARY HERE
mess "Link all I need to link"
for l in "${links[@]}"
do
    ln -fs $l
done
mess "Copy all I need to copy"
for c in "${cps[@]}"
do
    cp $c
done
#DO AFTER ACTUAL MERGING ALL STUFF FROM DOTFILES
mess "Exec what I need to exec"
for e in "${execs[@]}"
do
    $e
done

#BACONF folders

cp -r /mnt/backup/Arch/* ~/

mess "chromium folder"
cp -r /mnt/backup/Arch/chromium ~/.config/chromium
sudo ln -fs ~/.config/chromium /root/.config/chromium

mess "Deluge config directory"
balink deluge .config/deluge

mess "Libreoffice config directory"
balink libreoffice .config/libreoffice

mess "MC panels config"
cp /mnt/backup/Arch/panels.ini ~/.config/mc/panels.ini
sudo cp /mnt/backup/Arch/panels.ini /home/$username2/.config/mc/panels.ini
sudo chown $username2:users /home/$username2/.config/mc/panels.ini

mess "Thunar config directory"
balink Thunar .config/Thunar

mess "xfce4 (thunar) config directory"
balink xfce4 .config/xfce4

mess "kalu history"
cp -r /mnt/backup/Arch/kalu-news.conf ~/.config/kalu/news.conf
sudo cp /mnt/backup/Arch/kalu-news.conf /home/$username2/.config/kalu/news.conf
sudo chown $username2:users /home/$username2/.config/kalu/news.conf

mess ".local/share/applications all mimetypes directory"
mkdir -p ~/.local/share
sudo mkdir -p /home/$username2/.local/share
sudo chown -R $username2:users /home/$username2/.local
balink applications .local/share/applications

mess ".xboomx database directory"
balink .xboomx .xboomx

mess ".zsh_history history file"
cp -r /mnt/backup/Arch/.zsh_history ~/.zsh_history

mess "Anki folder"
balink Anki Anki

mess "Crontab"
sudo rm -rf /var/spool/cron
sudo cp -r /mnt/backup/Arch/cron /var/spool/cron
sudo chown ewancoder:users /var/spool/cron/ewancoder
