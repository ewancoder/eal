source ceal.sh

#Home folder

mess "Canto configuration - .canto folder"
link .canto

mess "All things configurations - .config folder"
link .config

mess "Devilspie config - .devilspie folder"
link .devilspie

mess "Irssi config - .irssi folder"
link .irssi

mess "Oh-my-zsh submodule - .oh-my-zsh folder"
link .oh-my-zsh

mess "Vim configuration - .vim folder"
link .vim

mess "Wmii configuration - .wmii-hg folder"
link .wmii-hg

mess "Use pulseaudio instead of alsa - .asoundrc"
link .asoundrc

mess "GTK Bookmarks config - .gtk-bookmarks"
link .gtk-bookmarks

mess "GTK icons theme config - ~/.gtkrc-2.0"
link .gtkrc-2.0

mess "Xinitrc config - .xinitrc"
link .xinitrc

mess "Terminal colors, fonts & urls - .Xresources"
link .Xresources

mess "Autostarting X server - .zprofile"
link .zprofile

mess "ZSH configuration to use oh-my-zsh - .zshrc"
link .zshrc

#Scripts

mess "Baconf script"
sudo ln -fs ~/.dotfiles/scripts/baconf /usr/bin/

mess "DropBox ScreenShoter - /usr/bin/dbss"
sudo ln -fs ~/.dotfiles/scripts/dbss /usr/bin/

mess "Feed the beast Minecraft - /usr/bin/ftb"
sudo ln -fs ~/.dotfiles/scripts/ftb /usr/bin/

mess "Wallpaper changer - /usr/bin/pic"
sudo ln -fs ~/.dotfiles/scripts/pic /usr/bin/

mess "Reboot & poweroff scripts"
sudo ln -fs ~/.dotfiles/scripts/reboot /usr/bin/
sudo ln -fs ~/.dotfiles/scripts/poweroff /usr/bin/

mess "gpart"
sudo ln -fs ~/.dotfiles/scripts/gpart /usr/bin/

#/etc folder

#Bitlbee - later

mess "Grub image + resolution configuration - /etc/default folder"
foldlink "default"

mess "Grub's grub.d scripts - /etc/grub.d folder"
foldlink "grub.d"
sudo chmod -x /etc/grub.d/10_linux

#pulse - later

mess "Autologin config - systemd folder"
foldlink "systemd"

mess "Keyboard layouts configuration - /etc/X11 folder"
foldlink "X11"

mess "System standard locale - /etc/locale.conf"
sudo ln -fs /etc/.dotfiles/locale.conf /etc/locale.conf

mess "Uncommented locales - /etc/locale.gen"
sudo ln -fs /etc/.dotfiles/locale.gen /etc/locale.gen

mess "Pacman configuration (multilib support) - /etc/pacman.conf"
sudo ln -fs /etc/.dotfiles/pacman.conf /etc/pacman.conf

mess "Encfs automount config - /etc/security/pam_mount.conf.xml & /etc/pam.d/system-auth files"
sudo ln -fs /etc/.dotfiles/pam.d\;system-auth /etc/pam.d/system-auth
sudo ln -fs /etc/.dotfiles/security\;pam_mount.conf.xml /etc/security/pam_mount.conf.xml
sudo ln -fs /etc/.dotfiles/security\;time.conf /etc/security/time.conf

#BACONF folders

mess "Deluge config directory"
balink deluge .config/deluge

mess "Libreoffice config directory"
balink libreoffice .config/libreoffice

mess "Thunar config directory"
balink Thunar .config/Thunar

mess "xfce4 (thunar) config directory"
balink xfce4 .config/xfce4

mess ".local/share/applications all mimetypes directory"
mkdir -p ~/.local/share
sudo mkdir -p /home/$username2/.local/share
sudo chown -R $username2:users /home/$username2/.local
balink applications .local/share/applications

mess ".xboomx database directory"
balink .xboomx .xboomx


mess "chromium folder"
balink chromium .config/chromium

mess "Anki folder"
balink Anki Anki

mess "Crontab"
sudo rm -r /var/spool/cron
sudo cp -r /mnt/backup/Arch/cron /var/spool/cron

#LFT configuration

mess "LFT wmiirc configuration"
sudo cp /mnt/backup/Arch/lft-wmiirc /home/$username2/.wmii-hg/wmiirc
sudo chown $username2:users /home/$username2/.wmii-hg/wmiirc
