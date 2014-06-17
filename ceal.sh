#!/bin/bash
version="1.8.1 Clean, 2014"

#This is needed only for host-install (heal.sh)
#Set it to downloadable url path to root arch image
iso=http://ftp.byfly.by/pub/archlinux/iso/2014.06.01/arch/x86_64/root-image.fs.sfs

#AutoInstall (0 - pause on each step, 1 - pause only when needed)
auto=0

#Editor to edit files (vi, nano)
edit=vi

#Console font (cyr-sun16 for russian symbols)
font=cyr-sun16
#Locales: put here locales that you need (at least one should be set)
locale=( en_US.UTF-8 ru_RU.UTF-8 )

#Hostname & timezone
hostname=ewanhost
timezone=Europe/Minsk

#Mirrorlist - at least one should be set (starting from capital letter)
mirror=( Belarus Denmark United France Russia )

#Internet configuration

    #Use netctl (0 - use dhcpcd, 1 - use netctl)
    netctl=1 #If you set it as 0, you can leave all other settings because dhcpcd doesn't need them
    #Interface in your computer which is used for internet connection
    interface=enp2s0
    #Static IP address to use
    ip=192.168.100.22
    #DNS to use (usually, your router address)
    dns=192.168.100.1

#All devices - in the order of mounting ('/' goes before '/home'). At least one should be set (/). No slash in the end ('/home', not '/home/')

    #Just text info
    description=( Root Home Cloud Backup )
    #Devices which is to mount
    device=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
    #Mount points starting from '/'
    mount=( / /home /mnt/cloud /mnt/backup )
    #Filesystem, options, dump&pass (fstab entries)
    #'discard' option works only for SSD
    type=( ext4 ext4 ext4 ext4 )
    option=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
    dump=( 0 0 0 0 )
    pass=( 1 2 2 2 )

#Additional devices

    #Grub MBR device (where to install bootloader)
    mbr=/dev/sdb
    #Windows device for copying fonts
    #Leave it as '' or remove if you don't want to copy windows fonts
    windows=/dev/sdb1

#User configuration - at least one should be set

    #User login
    user=( ewancoder lft )
    #Shells for users (leave as '' for standard)
    #Shell must be a full-path name
    shell=( /bin/zsh /bin/zsh )
    #Each 'groups' entry is for separate user, the groups itself divided by comma (','). Group 'user' added to all users automatically (there's no need to include it here)
    #Leave it as '' if you don't need one
    group=( fuse,lock,uucp,tty fuse )
    #Main user - this is set just for my personal cause to make script simpler and more flexible by referring to $user variable later in the script (so I should write 'ewancoder' only ONCE). You can set your "main" user as your second user doing so: 'main=${user[1]}'
    main=${user[0]} #I am setting this as 'ewancoder'

    #Sudoers additional entries - these entries will be added to the SUDOERS file. You can use relative intercourse like ${user[0]} for first user and ${user[1]} for the second (count begins with zero)
    #If not needed, set it to sudoers='' or remove
    sudoers=(
        "$main ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0"
        "$main ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm"
    ) #I need these lines for using some commands without a need for password typing

#Executable commands and links

    #These commands will be executed by corresponding user, use \n at the end of each line except the last one and separate user-executed entries by ""
    #For example, here is defined commands which will be executed for the first user only (${user[0]}).
    #I am currently need these only to install vim plugins
    execs=(
        "mess 'Make vim swap&backup dirs' \n
        mkdir -p /home/$main/.vim/{swap,backup} \n
        mess 'Install vim plugins' \n
        vim +BundleInstall +qall"
    )

    #These commands will be executed consecutively by root user after all installation process, so there's no need to type '\n' at the end of each line. Each line separated from another by "". Do not try to paste here multiple commands like "first && second"
    rootexec=(
        "ln -fs /mnt/backup/Downloads/Completed /home/$main/Downloads/"
        "ln -fs /mnt/backup/Downloads/Downloading /home/$main/Downloads/"
        "ln -fs /mnt/backup/Downloads/Torrents /home/$main/Downloads/"
        "ln -fs /mnt/cloud/Dropbox /home/$main/Dropbox"
        "ln -fs /mnt/cloud/Copy /home/$main/Copy"
        "ln -fs /home/$main/.mtoolsrc /root/"
        "ln -fs /home/$main/bin/runonce.sh /home/$main/"
        "ln -fs /mnt/backup/Cloud/Copy/ca\(fr\).png /usr/share/gxkb/flags/ca\(fr\).png"
        "ln -fs /home/$main/Copy/Games/Minecraft/Feed\ The\ Beast/.ftblauncher /home/$main/.ftblauncher"
        "mkdir -p /mnt/usb"
        "mkdir -p /mnt/data"
        "mkdir -p /mnt/mtp"
        "rsync -a /mnt/backup/Arch/* /home/$main/"
        "rsync -a /mnt/backup/Other/cron /var/spool/cron"
        "ln -fs /home/$main/.vim /root/"
        "modprobe fuse"
        "chmod -x /etc/grub.d/10_linux"
        "grub-mkconfig -o /boot/grub/grub.cfg"
    )

#Git configuration - make sure you have 'git' package in 'software' section below
#You can setup git for each user like 'gitname=( $main lolseconduser )' but I am using only one user
#You can remove whole git section of you don't need one

    #Your git user name
    gitname=$main
    #Git email
    gitemail=$main@gmail.com
    #Tool to use ad diff
    gittool=vimdiff
    #Editor to use
    giteditor=vim

    #Set gitrepos='' if you don't need any (or just remove all of this)
    gitrepo=( $main/dotfiles $main/etc $main/btp )
    #Where to clone current gitrepo - without slash at the end
    gitfolder=( /home/$main/.dotfiles /etc/.dotfiles /home/$main/btp )
    #Chown rule to apply to current gitrepo (set as '' to just leave as 'root')
    gitrule=( $main:users '' $main:users )
    #Sumbodules to pull - set to '' if you don't need any
    gitmodule=( ".oh-my-zsh .vim/bundle/vundle" )
    #Where to link ALL content (merging) from current repo (set '' if nowhere)
    gitlink=( /home/$main /etc )

#Software configuration

    #Just titles of the installed software - shows during install
    softtitle=(
        Audio
        Drivers
        Coding
        Core
        Internet
        Office
        Art
    )

    #Software itself
    software=(
        "alsa-plugins alsa-utils lib32-libpulse lib32-alsa-plugins pulseaudio pulseaudio-alsa"
        "lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt4-gstreamer"
        "python python-matplotlib python-mock python-numpy python-pygame-hg python-pyserial python-scipy python-sphinx tig"
        "cron devilspie dmenu dosfstools dunst encfs faience-icon-theme feh ffmpegthumbnailer fuse fuseiso git gksu gnome-themes-standard gxkb jmtpfs icedtea-web-java7 ntfs-3g pasystray-git pavucontrol rsync rxvt-unicode screen terminus-font tilda transset-df ttf-dejavu tumbler xorg-server xorg-server-utils xorg-xinit wmii-hg unrar unzip urxvt-perls xboomx xclip xcompmgr zsh"
        "canto-curses chromium chromium-libpdf chromium-pepper-flash deluge djview4 dropbox-experimental net-tools perl-html-parser python2-mako skype"
        "anki geeqie gource gparted gvim kdegraphics-okular libreoffice-calc libreoffice-common libreoffice-impress libreoffice-math libreoffice-writer libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru mc scrot smartmontools thunar"
        "lmms calligra-krita smplayer"
    )

    #Services to enable
    service=(
        cronie
        deluged
        deluge-web
    )

#===== INTERFACE =====

#Output styling
    Green=$(tput setaf 2)
    Yellow=$(tput setaf 3)
    Red=$(tput setaf 1)
    Bold=$(tput bold)
    Def=$(tput sgr0)

#Message function - shows a message and pauses process if 'auto=0'
mess(){
    if [ -f /var/lib/pacman/db.lck ]; then
        sudo rm -f /var/lib/pacman/db.lck #Need this cause pacman is still locked when installing on ssd very quicklky
    fi

    if [ "${#1}" -gt "2" ]; then
        m=$1
        o=$2
    else
        o=$1
        m=$2
    fi

    case $o in
        "-p")
            Style="$Bold$Yellow-> $m [MANUAL]$Def"
            Pause=1
            ;;
        "-t")
            Line="$(printf "%$(tput cols)s\n"|tr ' ' '-')"
            Style="$Line$Bold$Green\n-> $m$Def\n$Line"
            Pause=0
            ;;
        "-w")
            Style=$Bold$Red$m$Def
            Pause=1
            ;;
        "")
            Style="$Bold$Green\n-> $Def$Bold$m$Def"
            Pause=0
            ;;
    esac

    echo -e $Style
    if [ $Pause -eq 1 ] || [ $auto -eq 0 ]; then
        read -p $Bold$Yellow"Continue [ENTER]"$Def
    fi
}
