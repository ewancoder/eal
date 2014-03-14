source ceal.sh

#Home folder
mess "Home folder (~) links"

mess "Terminal colors, fonts & urls - .Xresources"
ln -fs ~/.dotfiles/.Xresources ~/.Xresources

mess "Use pulseaudio instead of alsa - .asoundrc"
ln -fs ~/.dotfiles/.asoundrc ~/.asoundrc

mess "Canto configuration - .canto folder"
ln -fs ~/.dotfiles/.canto ~/.canto

mess "All things configurations - .config folder"
ln -fs ~/.dotfiles/.config ~/.config

mess "Devilspie config - .devilspie folder"
ln -fs ~/.dotfiles/.devilspie ~/.devilspie

mess "GTK Bookmarks config - .gtk-bookmarks"
ln -fs ~/.dotfiles/.gtk-bookmarks ~/.gtk-bookmarks

mess "GTK icons theme config - ~/.gtkrc-2.0"
ln -fs ~/.dotfiles/.gtkrc-2.0 ~/.gtkrc-2.0

mess "Irssi config - .irssi folder"
ln -fs ~/.dotfiles/.irssi ~/.irssi

mess "Oh-my-zsh submodule - .oh-my-zsh folder"
ln -fs ~/.dotfiles/oh-my-zsh ~/oh-my-zsh

mess "Vim configuration - .vim folder"
ln -fs ~/.dotfiles/.vim ~/.vim

mess "Wmii configuration - .wmii-hg folder"
ln -fs ~/.dotfiles/.wmii-hg ~/.wmii-hg

mess "Xinitrc config - .xinitrc"
ln -fs ~/.dotfiles/.xinitrc ~/.xinitrc

mess "Autostarting X server - .zprofile"
ln -fs ~/.dotfiles/.zprofile ~/.zprofile

mess "ZSH configuration to use oh-my-zsh - .zshrc"
ln -fs ~/.dotfiles/.zshrc ~/.zshrc

#Scripts
mess "Scripts from .dotfiles/scripts to /usr/bin/"

mess "DropBox ScreenShoter - /usr/bin/dbss"
sudo ln -fs ~/.dotfiles/scripts/dbss /usr/bin/

mess "Feed the beast Minecraft - /usr/bin/ftb"
sudo ln -fs ~/.dotfiles/scripts/ftb /usr/bin/

#/etc folder
mess "/etc folder links"

mess "Bitlbee config - /etc/bitlbee folder"
sudo ln -fs /etc/.dotfiles/bitlbee /etc/bitlbee

link(){
    sudo cp -nr /etc/$1/* /etc/.dotfiles/$1/
    sudo rm -r /etc/$1
    sudo ln -fs /etc/.dotfiles/$1 /etc/$1
}

mess "Grub image + resolution configuration - /etc/default folder"
link "default"

mess "Grub's grub.d scripts - /etc/grub.d folder"
link "grub.d"

mess "Pulseaudio flat volumes configuration - /etc/pulse folder"
sudo ln -fs /etc/.dotfiles/pulse /etc/pulse

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
