source ceal.sh

#Home folder

mess "Terminal colors, fonts & urls - .Xresources"
link .Xresources

mess "Use pulseaudio instead of alsa - .asoundrc"
link .asoundrc

mess "Canto configuration - .canto folder"
link .canto

mess "All things configurations - .config folder"
link .config

mess "Devilspie config - .devilspie folder"
link .devilspie

mess "GTK Bookmarks config - .gtk-bookmarks"
link .gtk-bookmarks

mess "GTK icons theme config - ~/.gtkrc-2.0"
link .gtkrc-2.0

mess "Irssi config - .irssi folder"
link .irssi

mess "Oh-my-zsh submodule - .oh-my-zsh folder"
link .oh-my-zsh

mess "Vim configuration - .vim folder"
link .vim

mess "Wmii configuration - .wmii-hg folder"
link .wmii-hg

mess "Xinitrc config - .xinitrc"
link .xinitrc

mess "Autostarting X server - .zprofile"
link .zprofile

mess "ZSH configuration to use oh-my-zsh - .zshrc"
link .zshrc

#Scripts

mess "DropBox ScreenShoter - /usr/bin/dbss"
sudo ln -fs ~/.dotfiles/scripts/dbss /usr/bin/

mess "Feed the beast Minecraft - /usr/bin/ftb"
sudo ln -fs ~/.dotfiles/scripts/ftb /usr/bin/

mess "Wallpaper changer - /usr/bin/pic"
sudo ln -fs ~/.dotfiles/scripts/pic /usr/bin/

mess "Reboot & poweroff scripts"
sudo ln -fs ~/.dotfiles/scripts/reboot /usr/bin/
sudo ln -fs ~/.dotfiles/scripts/poweroff /usr/bin

#/etc folder

mess "Grub image + resolution configuration - /etc/default folder"
foldlink "default"

mess "Grub's grub.d scripts - /etc/grub.d folder"
foldlink "grub.d"
sudo chmod -x /etc/grub.d/10_linux

mess "Keyboard layouts configuration - /etc/X11 folder"
foldlink "X11"

mess "System standard locale - /etc/locale.conf"
sudo ln -fs /etc/.dotfiles/locale.conf /etc/locale.conf

mess "Uncommented locales - /etc/locale.gen"
sudo ln -fs /etc/.dotfiles/locale.gen /etc/locale.gen

mess "Pacman configuration (multilib support) - /etc/pacman.conf"
sudo ln -fs /etc/.dotfiles/pacman.conf /etc/pacman.conf

mess "Autologin config - systemd folder"
foldlink "systemd"

mess "Encfs automount config - /etc/security/pam_mount.conf.xml & /etc/pam.d/system-auth files"
sudo ln -fs /etc/.dotfiles/security\;pam_mount.conf.xml /etc/security/pam_mount.conf.xml
sudo ln -fs /etc/.dotfiles/pam.d\;system-auth /etc/pam.d/system-auth

#Dropbox folder

mess "Deluge config directory"
ln -fs ~/Dropbox/.sync/Arch/deluge ~/.config/deluge
sudo cp -r ~/Dropbox/.sync/Arch/deluge /home/$username2/.config/deluge
sudo chown -R $username2:users /home/$username2/.config/deluge

mess "Libreoffice config directory"
ln -fs ~/Dropbox/.sync/Arch/libreoffice ~/.config/libreoffice
sudo cp -r ~/Dropbox/.sync/Arch/libreoffice /home/$username2/.config/libreoffice
sudo chown -R $username2:users /home/$username2/.config/libreoffice

mess ".xboomx database directory"
ln -fs ~/Dropbox/.sync/Arch/.xboomx ~/.xboomx

mess ".local/share/applications all mimetypes directory"
ln -fs ~/Dropbox/.sync/Arch/applications ~/.local/share/applications

mess "Thunar folders: xfce4 & Thunar itself"
ln -fs ~/Dropbox/.sync/Arch/Thunar ~/.config/Thunar
ln -fs ~/Dropbox/.sync/Arch/xfce4 ~/.config/xfce4

#LFT configuration

sudo ln -fs /mnt/dropbox/.sync/Arch/lft/wmiirc /home/$username2/.wmii-hg/wmiirc
