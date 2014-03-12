source ceal.sh

#Home folder (~)
printf "Home folder (~) links\n\n"

#Files

echo "Canto configuration file ~/.canto/conf.py file"
mkdir -p ~/.canto
ln -fs ~/.dotfiles/.canto/conf.py ~/.canto/conf.py
echo

echo "Wmii ~/.wmii-hg/wmiirc file"
mkdir -p ~/.wmii-hg
ln -fs ~/.dotfiles/.wmii-hg/wmiirc ~/.wmii-hg/wmiirc
echo

echo "Alsa to pulseaudio config ~/.asoundrc file"
ln -fs ~/.dotfiles/.asoundrc ~/.asoundrc
echo

echo "GTK Bookmarks config ~/.gtk-bookmarks file"
ln -fs ~/.dotfiles/.gtk-bookmarks ~/.gtk-bookmarks
echo

echo "GTK theme icons config ~/.gtkrc-2.0 file"
ln -fs ~/.dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0
echo

echo "Vim configuration file ~/.vimrc file"
ln -fs ~/.dotfiles/.vimrc ~/.vimrc
echo

echo "Xinitrc config .xinitrc file"
ln -fs ~/.dotfiles/.xinitrc ~/.xinitrc
echo

echo "Xresources config .Xresources file"
ln -fs ~/.dotfiles/.Xresources ~/.Xresources
echo

echo "ZSH config for autostarting X server - .zprofile file"
ln -fs ~/.dotfiles/.zprofile ~/.zprofile
echo

echo "ZSH configuration to use oh-my-zsh - .zshrc file"
ln -fs ~/.dotfiles/.zshrc ~/.zshrc
echo

#Folders

echo "Dunst, Kalu & Xfe configs ~/.config/{dunst,kalu,xfe} folders"
mkdir -p ~/.config
ln -fs ~/.dotfiles/.config/{dunst,kalu,xfe} ~/.config/
echo

echo "Devilspie daemon (for transparency) ~/.devilspie folder"
ln -fs ~/.dotfiles/.devilspie ~/.devilspie
echo

echo "Irssi config + scripts ~/.irssi folder"
ln -fs ~/.dotfiles/.irssi ~/.irssi
echo

echo "Oh-my-zsh ~/.oh-my-zsh folder"
ln -fs ~/.dotfiles/.oh-my-zsh ~/.oh-my-zsh
echo

echo "Vim ~/.vim folder"
ln -fs ~/.dotfiles/.vim ~/.vim
echo

#Scripts
printf "Scripts from .dotfiles/scripts to /usr/bin/\n\n"

echo "DropBox ScreenShoter - /usr/bin/dbss"
sudo ln -fs ~/.dotfiles/scripts/dbss /usr/bin/
echo

echo "Feed the beast Minecraft - /usr/bin/ftb"
sudo ln -fs ~/.dotfiles/scripts/ftb /usr/bin/
echo

#/etc folder
printf "/etc folder links\n\n"

#Files

echo "Bitlbee config /etc/bitlbee/bitlbee.conf file"
sudo mkdir -p /etc/bitlbee
sudo ln -fs /etc/.dotfiles/bitlbee/bitlbee.conf /etc/bitlbee/bitlbee.conf
echo

echo "Grub image + resolution configuration /etc/default/grub file"
sudo mkdir -p /etc/default
sudo ln -fs /etc/.dotfiles/default/grub /etc/default/grub
echo

echo "Grub's grub.d scripts + uncheck execute option on 10_linux script /etc/grub.d/(10_archlinux, 30_os-prober files as links)"
sudo mkdir -p /etc/grub.d
sudo ln -fs /etc/.dotfiles/grub.d/10_archlinux /etc/grub.d/10_archlinux
sudo ln -fs /etc/.dotfiles/grub.d/30_os-prober /etc/grub.d/30_os-prober
sudo chmod -x /etc/grub.d/10_linux
echo

echo "Pulseaudio flat volumes configuration /etc/pulse/daemon.conf file"
sudo mkdir -p /etc/pulse
sudo ln -fs /etc/.dotfiles/pulse/daemon.conf /etc/pulse/daemon.conf
echo

echo "Keyboard layouts configuration /etc/X11/xorg.conf.d/20-keyboard-layout.conf file"
sudo mkdir -p /etc/X11/xorg.conf.d
sudo ln -fs /etc/.dotfiles/X11/xorg.conf.d/20-keyboard-layout.conf /etc/X11/xorg.conf.d/20-keyboard-layout.conf
echo

echo "System standard locale /etc/locale.conf file"
sudo ln -fs /etc/.dotfiles/locale.conf /etc/locale.conf
echo

echo "Uncommented locales /etc/locale.gen file"
sudo ln -fs /etc/.dotfiles/locale.gen /etc/locale.gen
echo

echo "Pacman configuration - multilib support - /etc/pacman.conf file"
sudo ln -fs /etc/.dotfiles/pacman.conf /etc/pacman.conf
echo

#Folders

echo "Autologin config /etc/systemd/system/getty@tty1.service.d folder"
sudo mkdir -p /etc/systemd/system
sudo ln -fs /etc/.dotfiles/systemd/system/getty@tty1.service.d /etc/systemd/system/getty@tty1.service.d
echo
