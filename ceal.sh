#!/bin/bash
version="1.7 Pre-Cleaned, 2014"

#AutoInstall (0 - pause on each step, 1 - pause only when needed)
auto=0

#Editor to edit files (vi, nano)
edit=vi

#All devices - in the order of mounting ('/' goes before '/home'). At least one should be set (/). No slash in the end ('/home', not '/home/')

    #Just text info
    descriptions=( Root Home Cloud Backup )
    #Devices which is to mount
    devices=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
    #Mount points starting from '/'
    mounts=( / /home /mnt/cloud /mnt/backup )
    #Filesystem, options, dumps&passes (fstab entries)
    #'discard' option - for SSD
    types=( ext4 ext4 ext4 ext4 )
    options=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
    dumps=( 0 0 0 0 )
    passes=( 1 2 2 2 )

#Additional devices

    #Grub MBR device (where to install bootloader)
    mbr=/dev/sdb
    #Windows device for copying fonts
    #Leave as '' if you don't want to copy windows fonts
    windows=/dev/sdb1

#Mirrorlist - at least one should be set
mirrors=( Belarus Denmark United France Russia )

#Hostname
hostname=ewanhost

#Local timezone
timezone=Europe/Minsk

#User configuration - at least one should be set

    #User login
    users=( ewancoder lft )
    #Each 'groups' entry is for separate user, the groups itself divided by comma (','). Group 'user' added to all users automatically (there's no need to include it here)
    #Leave it as '' if you don't need one
    groups=( fuse fuse,testing )
    #Main user - this is set just for my personal cause to make script simpler and more flexible by referring to $user variable later in the script. You can set your "main" user as your second user doing so: 'user=${users[1]}'
    user=${users[0]} #I am setting this as 'ewancoder'

#Sudoers additional entries - these entries will be added to the SUDOERS file. You can use relative intercourse like ${users[0]} for first user and ${users[1]} for the second (count begins with zero)
#If not needed, set it to sudoers=''
sudoers=(
    "$user ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0"
    "$user ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm"
) #I need these lines for using some commands without a need for password typing

#Internet configuration

    #Use netctl (0 - use dhcpcd, 1 - use netctl)
    netctl=1
    #Interface in your computer which is used for internet connection
    interface=enp2s0
    #Static IP address to use
    ip=192.168.100.22
    #DNS to use (usually, your router address)
    dns=192.168.100.1

#Git configuration

    #Your git user name
    gitname=$user
    #Git email
    gitemail=$user@gmail.com
    #Tool to use ad diff
    gittool=vimdiff
    #Editor to use
    giteditor=vim

    #Set gitrepos='' if you don't need any
    gitrepos=( $user/dotfiles $user/etc $user/btp )
    #Where to clone current gitrepo - without slash at the end
    gitfolders=( /home/$user/.dotfiles /etc/.dotfiles /home/$user/btp )
    #Chown rule to apply to current gitrepo (set as '' to just leave as 'root')
    gitrules=( $user:users '' $user:users )
    #Sumbodules to pull - set to '' if you don't need any
    gitmodules=( ".oh-my-zsh .vim/bundle/vundle" )
    #Where to link ALL content (merging) from current repo (set '' if nowhere)
    gitlinks=( ~ /etc )
    #What to link (merge) from current repo to link above (filter)
    gitfilter=( "{.*,bin}" "*" )

#Software configuration

    #Just titles of the installed software - shows during install
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

    #Software itself
    software=(
        "alsa-plugins alsa-utils lib32-libpulse lib32-alsa-plugins pulseaudio pulseaudio-alsa"
        "lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt4-gstreamer"
        "python python-matplotlib python-mock python-numpy python-pygame-hg python-scipy python-sphinx tig"
        "cron devilspie dmenu dosfstools dunst encfs faience-icon-theme feh ffmpegthumbnailer fuse gnome-themes-standard gxkb jmtpfs jre kalu lm_sensors ntfs-3g pam_mount preload rsync rxvt-unicode screen terminus-font tilda transset-df ttf-dejavu tumbler xorg-server xorg-server-utils xorg-xinit wmii-hg unrar unzip urxvt-perls xboomx xclip xcompmgr zsh"
        "geeqie gource scrot vlc"
        "bitlbee canto-curses chromium chromium-libpdf chromium-pepper-flash deluge djview4 dnsmasq dropbox-experimental hostapd irssi net-tools perl-html-parser python2-mako skype"
        "anki gvim kdegraphics-okular libreoffice-calc libreoffice-common libreoffice-impress libreoffice-math libreoffice-writer libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru"
        "gksu gparted mc pasystray-git pavucontrol smartmontools thunar"
        "lmms calligra-krita smplayer"
    )

#Make these empty directories automatically. Set mkdirs="" if you don't want any
mkdirs=( ~/.vim/{swap,backup} )


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




winfonts=1








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
