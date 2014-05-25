#!/bin/bash
#Current version of the script. Shows in title of 'eal.sh' and 'peal.sh'. Should be set for properly showing the version in the titles
version="1.6 HARDCORE-Messy, 2014"

#Editor which will edit all the files (need only for user-based 'peal-user.sh', irssi passwords). Should be set for properly showing it in the title of 'eal.sh' AND editing in some cases
edit=vi

#All devices to mount - in the order of mounting (/mnt goes before /mnt/data, / goes before everything else)
#At least one should be set (/)

#Description is just some text which shows up during mounting
descriptions=( Root Home Cloud Backup )
#Devices is actual device points in the system
devices=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
#Mounts is mount points to where should these devices be mounted. They all should begin with '/' (root sign)
mounts=( / /home /mnt/cloud /mnt/backup )
#Types if filesystem types of devices written in the fstab file
types=( ext4 ext4 ext4 ext4 )
#Options is options which should be written in the fstab file
options=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
#Dumps & passes = fstab parameters
dumps=( 0 0 0 0 )
passes=( 1 2 2 2 )

#Grub MBR device - here is grub installed
mbr=/dev/sdb

#Hostname
hostname=ewanhost

#Local timezone
timezone=Europe/Minsk

#Mirrorlist - list of countries
#At least one should be set
mirrors=( Belarus Denmark United France Russia )

#User configuration
#At least one should be set - all software installation and configuration are being performed as user
users=( ewancoder lft )
groups=( fuse fuse,testing )
#Main user
user=${users[0]}

#Sudoers additional entries - these entries will be added to the SUDOERS file. You can use relative intercourse like ${users[0]} for first user and ${users[1]} for the second (count begins with zero)
#If not needed, set it to sudoers=""
sudoers=( "$user ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0" "$user ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm" )

#Internet configuration
netctl=1
interface=enp2s0
ip=192.168.100.22
dns=192.168.100.1

#Git configuration
gitname=$user
gitemail=$user@gmail.com
gittool=vimdiff
giteditor=vim

#Git variables - set gitrepos="" if you don't want to clone any
gitrepos=( $user/dotfiles $user/etc $user/btp )
#WITHOUT last slash
gitfolders=( /home/$user/.dotfiles /etc/.dotfiles /home/$user/btp )
#RULES to rule git folders (chown) (leave "" for default 'root' rule)
gitrules=( $user:users "" $user:users )
#Set gitmodules="" if you don't want to pull any
gitmodules=( ".oh-my-zsh .vim/bundle/vundle" )
#Without backslash
gitlinks=( ~ /etc )
gitfilter=( "{.*,bin}" "*" )

#Make these empty directories automatically. Set mkdirs="" if you don't want any
mkdirs=( ~/.vim/{swap,backup} )

softtitle=(
    Audio
    Drivers
    Coding
    Core
    Graphics
    Internet
    Office
    Additional
    Art
)

software=(
    "alsa-plugins alsa-utils lib32-libpulse lib32-alsa-plugins pulseaudio pulseaudio-alsa"
    "lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt4-gstreamer"
    "python python-matplotlib python-mock python-numpy python-pygame-hg python-scipy python-sphinx tig"
    "cron devilspie dmenu dosfstools dunst encfs faience-icon-theme feh ffmpegthumbnailer fuse gnome-themes-standard gxkb jmtpfs jre kalu lm_sensors ntfs-3g pam_mount preload rsync rxvt-unicode screen terminus-font tilda transset-df ttf-dejavu tumbler xorg-server xorg-server-utils xorg-xinit wmii-hg unrar unzip urxvt-perls xboomx xclip xcompmgr zsh"
    "geeqie gource scrot vlc"
    "bitlbee canto-curses chromium chromium-libpdf chromium-pepper-flash deluge djview4 dnsmasq dropbox-experimental hostapd irssi net-tools perl-html-parser python2-mako skype"
    "anki gvim kdegraphics-okular libreoffice-calc libreoffice-common libreoffice-impress libreoffice-math libreoffice-writer libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru"
    "gksu gparted mc pasystray-git pavucontrol smartmontools"
    "lmms calligra-krita smplayer"
)


links=(
    "/mnt/cloud/Dropbox /home/$user/Dropbox"
    "/mnt/cloud/Copy /home/$user/Copy"
    "~/Copy/Games/Minecraft/Feed\ The\ Beast/.ftblauncher ~/.ftblauncher"
    "/etc/.dotfiles/pam.d\;system-auth /etc/pam.d/system-auth"
)

cps=(
    "~/.dotfiles/scripts/runonce.sh ~/"
)

execs=(
    "chmod -x /etc/grub.d/10-linux"
)



#INTERFACE

auto=0

#------------------------------
#Output styling
    Green=$(tput setaf 2)
    Yellow=$(tput setaf 3)
    Red=$(tput setaf 1)
    Bold=$(tput bold)
    Def=$(tput sgr0)

title(){
    echo -e $Bold$Green$1$Def
}

pause(){
    read -p $Bold$Yellow"Continue [ENTER]"$Def
}

mess(){
    if [ -f /var/lib/pacman/db.lck ];
        sudo rm -f /var/lib/pacman/db.lck #Need this cause pacman is still locked when installing on ssd very quicklky (move to mess function)
    fi
    echo -e $Bold$Green"\n-> "$Def$Bold$1$Def
    if [ $auto -eq 0 ]
    then
        pause
    fi
}

messpause(){
    echo -e $Bold$Yellow"\n-> "$1$Def
    pause
}

warn(){
    echo -e "\n"$Bold$Red$1$Def
    pause
}

#------------------------------
#Link functions

balink(){
    cp -r /mnt/backup/Arch/$1 ~/$2
    sudo ln -fs ~/$2 /root/$2
    sudo cp -r /mnt/backup/Arch/$1 /home/$username2/$2
    sudo chown -R $username2:users /home/$username2/$2
}

foldlink(){
    sudo cp -nr /etc/$1/* /etc/.dotfiles/$1/
    sudo rm -r /etc/$1
    sudo ln -fs /etc/.dotfiles/$1 /etc/$1
}

link(){
    ln -fs ~/.dotfiles/$1 ~/$1
    sudo ln -fs ~/$1 /root/$1
    sudo cp -r ~/.dotfiles/$1 /home/$username2/$1
    sudo chown -R $username2:users /home/$username2/$1
}
