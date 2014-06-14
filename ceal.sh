#!/bin/bash
version="1.8 Almost-Clean (Full-Clean will be like 1.8.2), 2014"

#AutoInstall (0 - pause on each step, 1 - pause only when needed)
auto=0

#Editor to edit files (vi, nano)
edit=vi

#Console font (cyr-sun16 for russian symbols)
font=cyr-sun16

#Hostname
hostname=ewanhost

#Local timezone
timezone=Europe/Minsk

#Mirrorlist - at least one should be set
mirror=( Belarus Denmark United France Russia )

#All devices - in the order of mounting ('/' goes before '/home'). At least one should be set (/). No slash in the end ('/home', not '/home/')

    #Just text info
    description=( Root Home Cloud Backup )
    #Devices which is to mount
    device=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
    #Mount points starting from '/'
    mount=( / /home /mnt/cloud /mnt/backup )
    #Filesystem, options, dumps&passes (fstab entries)
    #'discard' option - for SSD
    type=( ext4 ext4 ext4 ext4 )
    option=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
    dump=( 0 0 0 0 )
    pass=( 1 2 2 2 )

#Additional devices

    #Grub MBR device (where to install bootloader)
    mbr=/dev/sdb
    #Windows device for copying fonts
    #Leave as '' if you don't want to copy windows fonts
    windows=/dev/sdb1

#User configuration - at least one should be set

    #User login
    user=( ewancoder lft )
    #Shells for users (leave as '' for standard)
    #SHELL must be a FULL-path name
    shell=( /bin/zsh /bin/zsh )
    #Each 'groups' entry is for separate user, the groups itself divided by comma (','). Group 'user' added to all users automatically (there's no need to include it here)
    #Leave it as '' if you don't need one
    group=( fuse,lock,uucp,tty fuse )
    #Main user - this is set just for my personal cause to make script simpler and more flexible by referring to $user variable later in the script (so I should write 'ewancoder' only ONCE). You can set your "main" user as your second user doing so: 'user=${users[1]}'
    main=${user[0]} #I am setting this as 'ewancoder'

    #Sudoers additional entries - these entries will be added to the SUDOERS file. You can use relative intercourse like ${users[0]} for first user and ${users[1]} for the second (count begins with zero)
    #If not needed, set it to sudoers=''
    sudoers=(
        "$main ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0"
        "$main ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm"
    ) #I need these lines for using some commands without a need for password typing

    execs=(
        "mess 'Make vim swap&backup dirs'
        mkdir -p /home/$main/.vim/{swap,backup} \n
        mess 'Install vim plugins'
        vim +BundleInstall +qall \n
        mess 'Copy irssi config sample'
        cp /home/$main/.irssi/config_sample /home/$main/.irssi/config
        mess 'Edit irssi passwords [MANUAL]' pause
        $edit /home/$main/.irssi/config"
    )

#Execs to exec
#Do NOT try to paste here multiple commands like 'first && second'
rootexec=(
    "mkdir -p /mnt/usb"
    "mkdir -p /mnt/data"
    "mkdir -p /mnt/mtp"
    "locale-gen"
    "setfont $font"
    "chmod -x /etc/grub.d/10_linux"
    "modprobe fuse"
    "sensors-detect --auto"
    "rsync -a /mnt/backup/Arch/* /home/$main/"
    "mv /home/$main/cron/$main /var/spool/cron/"
    "rm -r /home/$main/cron"
    "ln -fs /home/$main/.vim /root/"
    "grub-mkconfig -o /boot/grub/grub.cfg"
)

#NEED TO FIX CRON FILE - now is only temporary solution (KOSTYL)

#Internet configuration

    #Use netctl (0 - use dhcpcd, 1 - use netctl)
    netctl=1 #If you set it 0, you can leave all other settings as '' because dhcpcd doesn't need any parameters
    #Interface in your computer which is used for internet connection
    interface=enp2s0
    #Static IP address to use
    ip=192.168.100.22
    #DNS to use (usually, your router address)
    dns=192.168.100.1

#Git configuration

    #Your git user name
    gitname=$main
    #Git email
    gitemail=$main@gmail.com
    #Tool to use ad diff
    gittool=vimdiff
    #Editor to use
    giteditor=vim

    #Set gitrepos='' if you don't need any
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
        "python python-matplotlib python-mock python-numpy python-pygame-hg python-pyserial python-scipy python-sphinx tig"
        "cron devilspie dmenu dosfstools dunst encfs faience-icon-theme feh ffmpegthumbnailer fuse fuseiso git gnome-themes-standard gxkb jmtpfs jre kalu lm_sensors ntfs-3g pam_mount preload rsync rxvt-unicode screen terminus-font tilda transset-df ttf-dejavu tumbler xorg-server xorg-server-utils xorg-xinit wmii-hg unrar unzip urxvt-perls xboomx xclip xcompmgr zsh"
        "geeqie gource scrot"
        "canto-curses chromium chromium-libpdf chromium-pepper-flash deluge djview4 dnsmasq dropbox-experimental hostapd net-tools perl-html-parser python2-mako skype"
        "anki gvim kdegraphics-okular libreoffice-calc libreoffice-common libreoffice-impress libreoffice-math libreoffice-writer libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru"
        "gksu gparted mc mtools pasystray-git pavucontrol smartmontools thunar"
        "lmms calligra-krita smplayer"
    )

#Services to enable
service=(
    preload
    cronie
    deluged
    deluge-web
    hostapd
    dnsmasq
)

#Links to link
link=(
    "/mnt/cloud/Dropbox /home/$main/Dropbox"
    "/mnt/cloud/Copy /home/$main/Copy"
    "/home/$main/Copy/Games/Minecraft/Feed\ The\ Beast/.ftblauncher /home/$main/.ftblauncher"
    "/etc/.dotfiles/pam.d\;system-auth /etc/pam.d/system-auth"
    "/mnt/backup/Cloud/Copy/ca\(fr\).png /usr/share/gxkb/flags/ca\(fr\).png"
    "/home/$main/bin/runonce.sh /home/$main/"
    "/mnt/backup/Downloads/* /home/$main/Downloads/"
    "/home/$main/.mtoolsrc /root/"
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
