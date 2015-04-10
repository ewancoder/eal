#!/bin/bash
#Effective & Easy (Ewancoder) Arch Linux (EAL) install script - useful tool for reinstalling your arch linux and setting up all the programs automatically
#Copyright (c) 2015 Ewancoder (Ewan Zyryanov) <ewancoder@gmail.com>
version="2.2 Refreshing, 2014"
release="2.2.0 Refreshing Indeed"

#Common settings
    hostinstall=0 #Install from within already running distro
    iso=http://ftp.byfly.by/pub/archlinux/iso/`date +%Y.%m.01`/arch/x86_64/airootfs.sfs #Path to Arch linux ROOT (fs.sfs) image, need for $hostinstall=1
    auto=0 #Install automatically, pause only when error occurs. If $auto=0, the script will pause at the each step and let you continue by pressing [RETURN]
    verbose=1 #Show each executed command and values of used variables
    timeout=0  #When error occurred, wait N seconds and try again. Set this to 0 if you don't want script to repeat automatically: it will wait for your input
    font=cyr-sun16 #Console font [maybe this is deprecated]
    locale=( en_US.UTF-8 ru_RU.UTF-8 ) #Locales which you need. System locale will be the first
    hostname=ewanpc #Hostname of the PC
    timezone=Europe/Minsk #Your timezone in /usr/share/zoneinfo
    mirror=( Belarus Denmark Russia United France ) #List of repository countries in the order of importance

#Internet configuration
    netctl=1 #Use netctl. Set this to 0 if you want to use dhcpcd
    profile=ethernet-static #netctl profile in /etc/netctl/examples
    interface=enp2s0 #Network interface [see ip link]
    ip=192.168.100.22 #Static IP address
    dns=192.168.100.1 #DNS to use (usually, your router address)
    essid=TTT #Name of access point for wireless connection
    key=192837465 #Key for wireless connection

#Devices: place them in the order of mounting ('/' goes before '/home'), no slash in the end ('/home', not '/home/')
    description=( Root Home Backup Cloud Swap ) #Just text info which will display during install
    device=( /dev/Linux/ArchRoot /dev/Linux/ArchHome /dev/sda5 /dev/sdb5 /dev/Linux/Swap ) #Devices which is to mount to corresponding mount points
    mount=( / /home /mnt/backup /mnt/cloud none ) #Mount points starting from '/'
    type=( ext4 ext4 ext4 ext4 swap ) #Filesystem
    option=( rw,relatime,discard rw,relatime,discard rw,relatime rw,relatime,discard defaults ) #Options (discard works only for SSD)
    dump=( 0 0 0 0 0 ) #Make backup if 1 provided (usually 0)
    pass=( 1 2 2 2 0 ) #Used by fsck to check partitions in order (usually root = 1, other = 2)

#Additional devices
    mbr=/dev/sdb #Grub MBR device (where to install bootloader)
    windows=/dev/sdb1 #Copy fonts from windows system partition (C:\Windows\Fonts)
    #temp=/dev/sda10 #If you are installing from host-system ($hostinstall=1) and you have less than 1G free on '/', you will need additional partition to extract ROOT filesystem image

#Users
    user=ewancoder #User login. Could be more than 1 like this: user=( ewancoder seconduser )
    shell=/bin/zsh #Default shell
    #Each 'groups' entry is for separate user, the groups itself divided by comma (','). Group 'user' added to all users automatically (there's no need to include it here)
    group=fuse #Add user in these groups, separate by comma (,)
    main=${user[0]} #Main user of the system: used later as reference. I am setting it as 'ewancoder'
    sudoers="$main ALL=(ALL) NOPASSWD: /usr/bin/pacman" #Sudoers additional entries

#Git configuration
    gitname=$main #Git user name
    gitemail=$main@gmail.com #Git email
    gittool=vimdiff #Tool to use as diff
    giteditor="gvim -f" #Default editor

    gitrepo=( $main/dotfiles $main/etc $main/eal $main/${main}.github.io $main/adroit ) #All these repos will be cloned from github to corresponding folders
    gitfolder=( /home/$main/.dotfiles /etc/.dotfiles /home/$main/eal /home/$main/site /home/$main/adroit ) #Set corresponding folders without '/' at the end
    gitrule=( $main:users '' $main:users $main:users $main:users ) #CHOWN rule for whole folder content ('root' as default)
    gitbranch=( '' '' '' '' '' ) #Branch to checkout
    gitmodule=( ".oh-my-zsh .vim/bundle/vundle" ) #Sumbodules to pull (remove if you don't need any)
    gitlink=( /home/$main /etc ) #Where to link ALL content from the repo [DOTFILES automation]

#Execute commands after install
    #You need to restore your BACKUPS BEFORE symlinking DOTFILES
    backupexecs=(
        "rsync -a /mnt/backup/Arch/ /home/$main/"
    )
    #Commands executed by corresponding user after installation
    userexecs=(
        "mess 'Make vim swap&backup dirs' \n
        mkdir -p ~/.vim/{swap,backup} \n
        mess 'Install minted (latex)' \n
        mkdir -p ~/texmf/tex/latex/minted \n
        curl -o ~/texmf/tex/latex/minted/minted.sty https://raw.githubusercontent.com/gpoore/minted/master/source/minted.sty \n
        mess 'Install vim plugins' \n
        vim +BundleInstall +qall \n
        mess 'Setup initial RPI ip address' \n
        echo 192.168.100.110 > ~/.rpi \n
        mess 'Setup vlc playback speed to 1.2' \n
        mkdir /home/$main/.config/vlc \n
        echo 'rate=1.2' > /home/$main/.config/vlc/vlcrc \n
        mess 'Setup Qt style equal to GTK+' \n
        echo \"[Qt]\\nstyle=GTK+\""
    )
    #Commands executed by root after installation
    rootexecs=(
        "ln -fs ~/Mega/Backup/ewancoder.zsh-theme ~/.oh-my-zsh/themes/"
        "rsync -a /mnt/cloud/Mega/Backup/Arch/$main /var/spool/cron/"
        "mkinitcpio -p linux"
        "grub-mkconfig -o /boot/grub/grub.cfg"
        "ln -fs /mnt/backup/Downloads /home/$main/"
        "ln -fs /mnt/cloud/* /home/$main/"
        "mkdir -p /home/$main/.config"
        "mkdir -p /root/.config"
        "ln -fs /home/$main/.config/mc /root/.config/"
        "ln -fs /home/$main/.gitconfig /root/"
        "ln -fs /home/$main/.mtoolsrc /root/"
        "ln -fs /home/$main/.vim /root/"
        "ln -fs /home/$main/.oh-my-zsh /root/"
        "ln -fs /home/$main/.zshrc /root/"
        "ln -fs /home/$main/.zsh_aliases /root/"
        "ln -fs /usr/share/gxkb/flags/fr.png /usr/share/gxkb/flags/ca\(fr\).png"
        "ln -fs /mnt/cloud/Mega/Backup/Arch/spell /home/$main/.vim/"
        "ln -fs /mnt/cloud/Mega/Backup/Arch/Popcorn-Time /home/$main/.config/"
        "mkdir -p /mnt/data /media"
        "chown $main:users /mnt/{data,windows}"
    )

#Software configuration
    #Titles shows during install
    softtitle=(
        Drivers
        Audio
        Core
        Styling
        Web
        Office
        Coding
        Tools
    )
    #Packages (set drivers first for no-conflict)
    software=(
        "lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt5-gstreamer"
        "alsa-plugins alsa-utils lib32-alsa-plugins lib32-libpulse pulseaudio pulseaudio-alsa"
        "compton cronie cv devilspie udevil dmenu2 dunst-git feh fuse git gksu gxkb jmtpfs keychain libnotify mplayer openssh p7zip pygtk rsync rxvt-unicode screen slimlock-git sshfs the_silver_searcher tig tilda transset-df wmii-hg unrar unclutter unzip urxvt-perls wpa_supplicant xclip xflux xdotool xorg-server xorg-server-utils xorg-xinit zsh"
        "faience-icon-theme ffmpegthumbnailer gtk-theme-espresso slim-archlinux-solarized-spiral terminus-font ttf-dejavu tumbler"
        "canto-curses-git chromium chromium-pepper-flash megasync deluge dropbox jre8-openjdk icedtea-web net-tools skype wiznote"
        "anki calligra-braindump calligra-flow calligra-krita gcalcli geeqie gource gvim impressive kdegraphics-okular kdeutils-filelight libreoffice-fresh libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru mc pencil scrot syncplay thunar vlc"
        "ctags latex-beamer latex-pscyr mono python python-matplotlib python-numpy python-pygame-hg python-pyserial python-scipy python-sphinx python2-pygments texlive-core texlive-humanities texlive-langcyrillic texlive-latexextra texlive-pictures texlive-science wine"
        "dosfstools encfs gparted ntfs-3g smartmontools virtualbox"
    )
    #Services to enable
    service=(
        cronie
        systemd-networkd
        systemd-timesyncd
        deluged
    )

#===== INTERFACE =====
#Color constants
    Green=`tput setaf 2`
    Yellow=`tput setaf 3`
    Red=`tput setaf 1`
    Blue=`tput setaf 6`
    Bold=`tput bold`
    Def=`tput sgr0`

#Message function - neat output
mess(){
    if [ -f /var/lib/pacman/db.lck ]; then
        sudo rm -f /var/lib/pacman/db.lck #Need this in case pacman is still locked from last operation when installing on ssd very quicklky
    fi

    #Determine 'option' and 'message'
    if [ "${#1}" -gt "2" ]; then
        o=$2
        m=$1
    else
        o=$1
        m=$2
    fi

    #Stylize message
    case $o in
        "-p")
            Style="$Bold$Yellow\n-> $m [MANUAL]$Def"
            step=$m
            ;;
        "-w")
            Style="\n$Bold$Red! $m$Def"
            ;;
        "-t")
            Line="$(printf "%$(tput cols)s\n"|tr ' ' '-')"
            Style="\n$Line$Bold$Green\n-> $m$Def\n$Line"
            step=$m
            ;;
        "-q")
            Style="$Bold$Red$m$Def"
            ;;
        "-v")
            Style="$Blue-> $m$Def"
            echo $m | grep -oP '(?<!\[)\$[{(]?[^"\s\/\047.\\]+[})]?' | uniq > vars
            if [ ! "`cat vars`" == "" ]; then
                while read -r p; do
                    value=`eval echo $p`
                    Style=`echo -e "$Style\n\t$Green$p = $value$Def"`
                done < vars
            fi
            rm vars
            ;;
        *)
            Style="$Bold$Green\n-> $Def$Bold$m$Def"
            step=$m
            ;;
    esac

    #Print message
    if [ "$o" == "-v" ]; then
        echo -en "$Style"
        if [ $auto -eq 0 ]; then
            read
        fi
    elif [ "$o" == "-p" ]; then
        echo -en "$Style"
        read
    else
        echo -e "$Style"
        if [ "$o" == "-w" -o "$o" == "-p" ] || [ "$o" == "" -a $auto -eq 0 ]; then
            read -p $Bold$Yellow"Continue [ENTER]"$Def
        fi
    fi
}
