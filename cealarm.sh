#!/bin/bash
version="1.7.9 Pre-Clean (ARM), 2014"

auto=0
edit=vi
font=cyr-sun16
hostname=ewanserv
timezone=Europe/Minsk
mirrors=( Belarus Denmark United France Russia )

#All devices
    descriptions=( Root Home )
    devices=( /dev/sda1 /dev/sda2 )
    mounts=( / /home )
    types=( ext4 ext4 )
    options=( rw,relatime rw,relatime )
    dumps=( 0 0 0 0 )
    passes=( 1 2 2 2 )
#Additional devices
    mbr=/dev/sda

#User configuration
    users=ewancoder
    shells=/bin/bash
    groups=fuse,lock,uucp,tty
    sudoers="$users ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0"

#Internet configuration
    netctl=1
    interface=enp2s0 #?????
    ip=192.168.100.33
    dns=192.168.100.1

#Git configuration
    gitname=$users
    gitemail=$users@gmail.com
    gittool=vimdiff
    giteditor=vim

    gitrepos=( $users/rpi_dotfiles $users/rpi_etc )
    gitfolders=( /home/$users/.dotfiles /etc/.dotfiles )
    gitrules=( $users:users '' )
    gitlinks=( /home/$users /etc )

#Software configuration
#I need AUDIO totally because I am going to make RADIO and skype conversations and ETC
    softtitle=(
        Audio
        Coding
        Core
        Internet
    )

    #Software itself
    software=(
        "alsa-plugins alsa-utils pulseaudio pulseaudio-alsa"
        "python python-pyserial python-sphinx"
        "cron dosfstools fuse lm_sensors mtools ntfs-3g rsync screen unrar unzip"
        "bitlbee canto-curses copy-agent deluge dnsmasq dropbox-experimental hostapd irssi perl-html-parser"
    )

#Services to enable
services=(
    bitlbee
    cronie
    deluged
    deluge-web
    hostapd
    dnsmasq
)

#Links to link
#NEED TO CREATE THIS FILE FIRST
links=(
    "/home/$user/.mtoolsrc /root/"
)

#Execs to exec
#IRSSI CONFIG NEED TO MOVE HERE
execs=(
    "locale-gen"
    "setfont $font"
    "mkdir -p /var/lib/bitlbee"
    "chown -R bitlbee:bitlbee /var/lib/bitlbee"
    "chmod -x /etc/grub.d/10_linux"
    "modprobe fuse"
    "sensors-detect --auto"
    "cp /home/$user/.irssi/config_sample /home/$user/.irssi/config"
    "grub-mkconfig -o /boot/grub/grub.cfg"
)
#NEED TO FIX CRON FILE - now is only temporary solution (KOSTYL)

#Need this separately from execs array because I need to warn user before doing it
edits=(
    "/home/$user/.irssi/config"
)

#===== INTERFACE =====

#Output styling
    Green=$(tput setaf 2)
    Yellow=$(tput setaf 3)
    Red=$(tput setaf 1)
    Bold=$(tput bold)
    Def=$(tput sgr0)

#Shows title in green color
title(){
    echo -e $Bold$Green$1$Def
}

#Pause process
pause(){
    read -p $Bold$Yellow"Continue [ENTER]"$Def
}

#Message function - shows a message and pauses process if 'auto=0'
mess(){
    if [ -f /var/lib/pacman/db.lck ];
    then
        sudo rm -f /var/lib/pacman/db.lck #Need this cause pacman is still locked when installing on ssd very quicklky
    fi
    echo -e $Bold$Green"\n-> "$Def$Bold$1$Def
    if [ $auto -eq 0 ]
    then
        pause
    fi
}

#Shows a message in yellow color and pauses process
messpause(){
    echo -e $Bold$Yellow"\n-> "$1$Def
    pause
}

#Shows red warning and pauses process
warn(){
    echo -e "\n"$Bold$Red$1$Def
    pause
}
