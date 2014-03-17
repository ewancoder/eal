source ceal.sh

#Home folder
mess "Home folder (~) links"

mess "Terminal colors, fonts & urls - .Xresources"
ln -fs ~/.dotfiles/.Xresources ~/.Xresources
sudo ln -fs ~/.Xresources /root/.Xresources

mess "Use pulseaudio instead of alsa - .asoundrc"
ln -fs ~/.dotfiles/.asoundrc ~/.asoundrc
sudo ln -fs ~/.asoundrc /root/.asoundrc

mess "Canto configuration - .canto folder"
ln -fs ~/.dotfiles/.canto ~/.canto
sudo ln -fs ~/.canto /root/.canto

mess "All things configurations - .config folder"
ln -fs ~/.dotfiles/.config ~/.config
sudo ln -fs ~/.config /root/.config

mess "Devilspie config - .devilspie folder"
ln -fs ~/.dotfiles/.devilspie ~/.devilspie
sudo ln -fs ~/.devilspie /root/.devilspie

mess "GTK Bookmarks config - .gtk-bookmarks"
ln -fs ~/.dotfiles/.gtk-bookmarks ~/.gtk-bookmarks
sudo ln -fs ~/.gtk-bookmarks /root/.gtk-bookmarks

mess "GTK icons theme config - ~/.gtkrc-2.0"
ln -fs ~/.dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0
sudo ln -fs ~/.gtkrc-2.0 /root/.gtkrc-2.0

mess "Irssi config - .irssi folder"
ln -fs ~/.dotfiles/.irssi ~/.irssi
sudo ln -fs ~/.irssi /root/.irssi

mess "Oh-my-zsh submodule - .oh-my-zsh folder"
ln -fs ~/.dotfiles/.oh-my-zsh ~/.oh-my-zsh
sudo ln -fs ~/.oh-my-zsh /root/.oh-my-zsh

mess "Vim configuration - .vim folder"
ln -fs ~/.dotfiles/.vim ~/.vim
sudo ln -fs ~/.vim /root/.vim

mess "Wmii configuration - .wmii-hg folder"
ln -fs ~/.dotfiles/.wmii-hg ~/.wmii-hg
sudo ln -fs ~/.wmii-hg /root/.wmii-hg

mess "Xinitrc config - .xinitrc"
ln -fs ~/.dotfiles/.xinitrc ~/.xinitrc
sudo ln -fs ~/.xinitrc /root/.xinitrc

mess "Autostarting X server - .zprofile"
ln -fs ~/.dotfiles/.zprofile ~/.zprofile
sudo ln -fs ~/.zprofile /root/.zprofile

mess "ZSH configuration to use oh-my-zsh - .zshrc"
ln -fs ~/.dotfiles/.zshrc ~/.zshrc
sudo ln -fs ~/.zshrc /root/.zshrc

#Scripts
mess "Scripts from .dotfiles/scripts to /usr/bin/"

mess "DropBox ScreenShoter - /usr/bin/dbss"
sudo ln -fs ~/.dotfiles/scripts/dbss /usr/bin/

mess "Feed the beast Minecraft - /usr/bin/ftb"
sudo ln -fs ~/.dotfiles/scripts/ftb /usr/bin/

#/etc folder
mess "/etc folder links"

mess "Grub image + resolution configuration - /etc/default folder"
link "default"

mess "Grub's grub.d scripts - /etc/grub.d folder"
link "grub.d"
sudo chmod -x /etc/grub.d/10_linux

mess "Keyboard layouts configuration - /etc/X11 folder"
link "X11"

mess "System standard locale - /etc/locale.conf"
sudo ln -fs /etc/.dotfiles/locale.conf /etc/locale.conf

mess "Uncommented locales - /etc/locale.gen"
sudo ln -fs /etc/.dotfiles/locale.gen /etc/locale.gen

mess "Pacman configuration (multilib support) - /etc/pacman.conf"
sudo ln -fs /etc/.dotfiles/pacman.conf /etc/pacman.conf

mess "Autologin config - systemd folder"
link "systemd"

mess "Encfs automount config - /etc/security/pam_mount.conf.xml & /etc/pam.d/system-auth files"
sudo ln -fs /etc/.dotfiles/security\;pam_mount.conf.xml /etc/security/pam_mount.conf.xml
sudo ln -fs /etc/.dotfiles/pam.d\;system-auth /etc/pam.d/system-auth

#Dropbox folder
mess "Dropbox folder links"

mess "Deluge config directory"
ln -fs ~/Dropbox/.sync/Arch/deluge ~/.config/deluge

mess "Libreoffice config directory"
ln -fs ~/Dropbox/.sync/Arch/libreoffice ~/.config/libreoffice
