ln -fs /mnt/cloud/Mega/Backup/ewancoder.zsh-theme /home/$main/.oh-my-zsh/themes/
rsync -a /mnt/cloud/Mega/Backup/Arch/$main /var/spool/cron/
mkinitcpio -p linux
grub-mkconfig -o /boot/grub/grub.cfg
ln -fs /mnt/backup/Downloads /home/$main/
ln -fs /mnt/cloud/* /home/$main/
mkdir -p /home/$main/.config
mkdir -p /root/.config
ln -fs /home/$main/.config/mc /root/.config/
ln -fs /home/$main/.gitconfig /root/
ln -fs /home/$main/.mtoolsrc /root/
ln -fs /home/$main/.vim /root/
ln -fs /home/$main/.oh-my-zsh /root/
ln -fs /home/$main/.zshrc /root/
ln -fs /home/$main/.zsh_aliases /root/
ln -fs /usr/share/gxkb/flags/fr.png /usr/share/gxkb/flags/ca\(fr\).png
ln -fs /mnt/cloud/Mega/Backup/Arch/spell /home/$main/.vim/
ln -fs /mnt/cloud/Mega/Backup/Arch/Popcorn-Time /home/$main/.config/
mkdir -p /mnt/data /media
chown $main:users /mnt/{data,windows}
