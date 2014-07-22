#!/bin/bash
#Ewancoder Arch Linux (EAL) install script - useful tool for reinstalling your arch linux and setting up all the programs automatically
#2014 Ewancoder <ewancoder@gmail.com>
version="1.9.5 Error-Handled, 2014"

#If an error is detected while script is running, you will be prompted for action: repeat this command (which caused the error) or skip it and go further
#If timeout=0, script will wait for your decision. If you set $timeout variable to something, script will wait this time (in seconds) and then try to repeat failed command
timeout=10  #If an error happened, wait 10 seconds and try again

#Set hostinstall=1 if you want to install linux from within your already installed (arch) linux (yep, that's real)
#If you're already under live-cd and wanna install old-way, set it to 0
hostinstall=1
#This is needed only for host-install (installing from within your already working linux)
#Set it to downloadable url path to live-cd ROOT (extension should be fs.sfs) arch linux image
iso=http://ftp.byfly.by/pub/archlinux/iso/2014.06.01/arch/x86_64/root-image.fs.sfs

#With auto=0 script will pause on the each step and let you continue by pressing [RETURN] (useful for debugging)
#If you want to install in a totally automatical way, set this to 1
#Be AWARE: setting auto=1 means that script will very FAST execute lots of commands and will pause ONLY if an error would be detected
auto=0

#Console font (cyr-sun16 for russian symbols)
font=cyr-sun16
#Locales: put here locales which you need
locale=( en_US.UTF-8 ru_RU.UTF-8 )

#Hostname & timezone
hostname=ewanhost
timezone=Europe/Minsk

#Mirrorlist - list of countries in the order of importance
mirror=( Belarus Denmark Russia United France )

#Internet configuration

    #Use netctl (0 - use dhcpcd, 1 - use netctl)
    #If you set netctl=0, you don't need any of other settings in internet section, because dhcpcd doesn't use them
    netctl=1
    #Choose netctl profile to use (ethernet-static, wireless-wpa-static, etc...)
    profile=wireless-wpa-static

    #Network interface which is used for internet connection (enp2s0, wlp7s4, wlan0, etc...)
    #You can discover your network interface by typing [ip link] command
    interface=wlan
    #Static IP address to use
    ip=192.168.100.22
    #DNS to use (usually, your router address)
    #This setting sets both dns and gateway. If your network connection needs different dns&gateway, connect me and I'll improve the script
    dns=192.168.100.1

    #Settings for wireless connection
    essid=TTT
    key=192837465

#All devices - in the order of mounting ('/' goes before '/home'). No slash in the end ('/home', not '/home/')

    #Just text info which will display during install
    description=( Root Home Cloud Backup )
    #Devices which is to mount to corresponding mount points
    device=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
    #Mount points starting from '/'
    mount=( / /home /mnt/cloud /mnt/backup )
    #Filesystem, options, dump&pass (fstab entries)
    #'discard' option works only for SSD
    type=( ext4 ext4 ext4 ext4 )
    option=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
    dump=( 0 0 0 0 )
    pass=( 1 2 2 2 )

    #Swap options
    #device=/dev/sdSWAP mount=none type=swap option=defaults dump=0 pass=0

#Additional devices

    #Grub MBR device (where to install bootloader)
    mbr=/dev/sdb
    #Windows device for copying fonts
    #If you have windows installed somewhere (for example, in /dev/sdb1), you can automatically copy fonts from c:\windows\fonts to /usr/share/fonts/winfonts
    #Leave it as '' or remove if you don't want to copy windows fonts
    windows=/dev/sdb1
    #Temporary partition for unsquashing (1G or bigger)
    #If you have 1G free on '/' (or you're not installing from host-system), you don't need it
    #temp=/dev/sda9

#Users configuration

    #User login
    #I am using 2 users. You can always set only one user like [user=myname] or [user=( myname )]
    user=( ewancoder lft )
    #Shells for users (leave as '' for standard)
    #Shell must be a full-path name
    shell=( /bin/zsh /bin/zsh )
    #Each 'groups' entry is for separate user, the groups itself divided by comma (','). Group 'user' added to all users automatically (there's no need to include it here)
    #Leave it as '' if you don't need one
    group=( fuse,lock,uucp,tty fuse ) #I am adding groups "fuse,lock,uucp,tty" to my first user (ewancoder) and only one group "fuse" to my second user (lft). Both will be also added in the group "users"
    #Main user - this variable is set just for referring to my nickname (ewancoder) only once per script. Then my nickname placed in a $main constant. You can set your "main" user as your second user doing so: 'main=${user[1]}'
    main=${user[0]} #I am setting this as 'ewancoder'

    #Sudoers additional entries - these entries will be added to the SUDOERS file. You can use relative intercourse like ${user[0]} for first user and ${user[1]} for the second (count begins with zero)
    #If not needed, set it to sudoers='' or remove
    sudoers=( "$main ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm" ) #I need these lines for using some commands without a need for password typing (NOPASSWD option does the trick)

#Executable commands and links

    #These commands will be executed by corresponding user, use \n at the end of each line except the last one and separate user-executed entries by ""
    #For example, here is defined commands which will be executed for the first user only (${user[0]}).
    #I am currently need these only to install vim plugins
    #You're probably do not need these so you could just delete it, but if you'll ever need to automatically execute some commands during install as user - you know the trick
    execs=(
        "mess 'Make vim swap&backup dirs' \n
        mkdir -p /home/$main/.vim/{swap,backup} \n
        mess 'Install vim plugins' \n
        vim +BundleInstall +qall \n
        mess 'Unmute pulseaudio' \n
        amixer sset Master unmute"
    )

    #These commands will be executed consecutively by root user after all installation process is finished. You can paste here whatever stuff you need to do. For example, I am linking some config from my $main (ewancoder) user to root directory, linking my downloads folder, rsyncing some files and etc.
    rootexec=(
        "ln -fs /mnt/backup/Downloads /home/$main/"
        "ln -fs /mnt/cloud/* /home/$main/"
        "ln -fs /home/$main/.gitconfig /root/"
        "ln -fs /home/$main/.mtoolsrc /root/"
        "ln -fs /home/$main/.vim /root/"
        "ln -fs /home/$main/.oh-my-zsh /root/"
        "ln -fs /home/$main/.zshrc /root/"
        "ln -fs /mnt/backup/Cloud/Copy/ca\(fr\).png /usr/share/gxkb/flags/"
        "ln -fs /home/$main/Copy/Games/Minecraft/Feed\ The\ Beast/.ftblauncher /home/$main/"
        "mkdir -p /mnt/{data,mtp,usb}"
        "chown $main:users /mnt/{data,mtp,usb,windows}"
        "rsync -a /mnt/backup/Arch/ /home/$main/"
        "rsync -a /mnt/backup/ArchConfig/ /home/$main/.config/"
        "rsync -a /mnt/backup/Other/cron /var/spool/"
        "modprobe fuse"
        "chmod -x /etc/grub.d/10_linux"
        "grub-mkconfig -o /boot/grub/grub.cfg"
    )

#Git configuration - make sure you have 'git' package in 'software' section below
#You can setup git for each user like 'gitname=( $main lolseconduser )' but I am using only one user
#You can remove whole git section if you don't need one
#Git is what making whole this thing shine! You can store all your configs in github repository and then automatically download it during install and link through the system. I'll write handbook about it some day and maybe habr-article

    #Your git user name
    gitname=$main
    #Git email
    gitemail=$main@gmail.com
    #Tool to use ad diff
    gittool=vimdiff
    #Editor to use
    giteditor=vim

    #All these repos will be cloned from github
    gitrepo=( $main/dotfiles $main/etc $main/btp $main/eal )
    #All the repos will be cloned in corresponding directories (set them without slash at the end)
    gitfolder=( /home/$main/.dotfiles /etc/.dotfiles /home/$main/btp /home/$main/eal )
    #Because all repos cloned as root user, all they are root-owned at the beginning. Here you can setup chown rule which will apply after cloning to all repo content
    gitrule=( $main:users '' $main:users $main:users )
    #Maybe you want to checkout into another branch
    gitbranch=( '' '' refactoring '' )
    #Sumbodules to pull (remove if you don't need any)
    gitmodule=( ".oh-my-zsh .vim/bundle/vundle" )
    #Where to link ALL content (merge) from the repo
    #This is the sweetest peace from the whole script. All the files from your $gitfolder directories will be symlinked to $gitlink directories
    gitlink=( /home/$main /etc )

#Software configuration

    #Just titles of the installed software - shows during install
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

    #Software itself
    #Firstly set drivers software, only then - all other relative to them. Otherwise you can get a conflict error.

    #===== DRIVERS =====
        #lib32-nvidia-libgl - just 32bit symlinks, needed for Steam
        #mesa - opensource openGL implementation
        #nvidia - nvidia drivers for linux
        #nvidia-libgl - just libraries symlinks
        #phonon-qt4/5-gstreamer - backend for qt4/5 (currently I need qt4 because qt5 is not fully packaged yet)

    #===== AUDIO =====
        #alsa-plugins - advanced features like upmixing/downmixing and HQ resampling
        #alsa-utils - alsamixer and other tools
        #lib32-alsa-pluginsa - for Steam and Wine
        #lib32-libpulse - pulseaudio for Steam/Wine
        #ponymix - cli tools to rule pulseaudio
        #pulseaudio - pulseaudio itself
        #pulseaudio-alsa - alsa configuration for pulseaudio (/etc/asoundrc.conf)

    #===== CORE =====
        #compton - lightweight x-compositor
        #cronie - cron daemon
        #devilspie - sets transparency to windows based on ruleset (see transset-df)
        #dmenu - lightweight menu (see xboomx)
        #dunst - lightweight notification daemon
        #feh - image viewer / wallpaper
        #fuse - FUSE itself
        #git - version control system
        #gksu - graphical sudo
        #gxkb - language indicator
        #jmtpfs - mtp (android) mount
        #openssh - ssh server/client
        #p7zip - universal archiver for 7z packages
        #rsync - files transfer tool
        #rxvt-unicode - supercool term (also see urxvt-perls)
        #screen - this is what I am using instead of TMUX
        #tig - git pretty viewer
        #tilda - fullscreen terminal on Mod+F12
        #transset-df - transparency-setting tool (see devilspie)
        #xorg-server - xserver
        #xorg-server-utils - the most important stuff based on current configuration
        #xorg-xinit - startx tool
        #wmii-hg - supercool WM (although I am planning on switching to dwm)
        #unclutter - for hiding the mouse
        #unrar, unzip - default archivers
        #urxvt-perls - for showing/clicking url within urxvt (see urxvt)
        #wpa_supplicant - connection via wpa2-psk
        #xboomx - wrapper around dunst based on frequency (see dunst)
        #xclip - tool to get clipboard content (need for dbss [dropbox screenshoter] script)
        #zsh - bash alternative
        
    #===== STYLING =====
        #faience-icon-theme - icons
        #ffmpegthumbnailer - lightweight video thumbnailer
        #gnome-themes-standard - adwaita theme for gtk2/gtk3 and qt(GTK+)
        #gtk-theme-flatstudio - dark flat theme the best ever
        #terminus-font - terminal font
        #ttf-dejavu - system fonts
        #tumbler - thumbnails

    #===== WEB =====
        #canto-curses - canto RSS reader
        #chromium - web browser
        #chromium-pepper-flash - lastest google flash support (also chromium-libpdf for pdf)
        #copy-agent - copy cloud service
        #deluge - torrent client (although I am planning on switching to rtorrent)
        #dropbox-experimental - dropbox cloud service
        #icedtea-web-java7- java for chromium (and openjdk7 as well)
        #net-tools - arp, ifconfig and other net tools
        #pygtk - graphical gui needed for deluge
        #skype - for calls

    #===== OFFICE =====
        #anki - language learning software
        #calligra-krita - the best painting edtor ever
        #geeqie - image viewer
        #gource - git visualization
        #gvim - the best editor ever
        #kdegraphics-okular - the best pdf/djvu/anything viewer
        #libreoffice-calc, libreoffice-common, libreoffice-impress, libreoffice-math, libreoffice-writer - office software
        #libreoffice-en-US - language pack
        #hyphen, hyphen-en, hyphen-ru - hyphenation for libreoffice
        #hunspell, hunspell-en, hunspell-ru - spellcheck for libreoffice
        #mc - midnight commander
        #scrot - screenshots software
        #thunar - files explorer
        #vlc - the best player ever

    #===== CODING =====
        #python - my possession :)
        #python-matplotlib - python plotting library [sci]
        #python-numpy - python scientific tools (numbers) [sci]
        #python-pygame-hg - pygame for python3
        #python-pyserial - arduino serial communication library
        #python-scipy - python science/engineering [sci]
        #python-sphinx - sphinx documentation engine
        
    #===== TOOLS =====
        #dosfstools - formatting fat/ntfs
        #encfs - encrypted fuse filesystem
        #gparted - drive partitioning
        #ntfs-3g - fuse driver to mount ntfs
        #smartmontools - drive s.m.a.r.t. diagnostics

    software=(
        "lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt4-gstreamer"
        "alsa-plugins alsa-utils lib32-alsa-plugins lib32-libpulse ponymix pulseaudio pulseaudio-alsa"
        "compton cronie devilspie dmenu dunst feh fuse git gksu gxkb jmtpfs openssh p7zip rsync rxvt-unicode screen tig tilda transset-df xorg-server xorg-server-utils xorg-xinit wmii-hg unrar unclutter unzip urxvt-perls wpa_supplicant xboomx xclip zsh"
        "faience-icon-theme ffmpegthumbnailer gnome-themes-standard gtk-theme-flatstudio terminus-font ttf-dejavu tumbler"
        "canto-curses chromium chromium-pepper-flash copy-agent deluge dropbox-experimental icedtea-web-java7 net-tools pygtk skype"
        "anki calligra-krita geeqie gource gvim kdegraphics-okular libreoffice-calc libreoffice-common libreoffice-impress libreoffice-math libreoffice-writer libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru mc scrot thunar vlc"
        "python python-matplotlib python-numpy python-pygame-hg python-pyserial python-scipy python-sphinx"
        "dosfstools encfs gparted ntfs-3g smartmontools"
    )

    #Removed (and not sure) software:
        #python2-mako - why did I need this?
        #perl-html-parser - now irssi on distant server

    #Services to enable (systemctl enable $service)
    service=(
        cronie
        deluged
        deluge-web
    )

#===== INTERFACE =====
#All below is just styling stuff. You do NOT need to configure it. Just don't touch it :)

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
            Style="$Bold$Yellow\n-> $m [MANUAL]$Def"
            Pause=1
            step=$m
            ;;
        "-t")
            Line="$(printf "%$(tput cols)s\n"|tr ' ' '-')"
            Style="\n$Line$Bold$Green\n-> $m$Def\n$Line"
            Pause=0
            step=$m
            ;;
        "-w")
            Style="\n$Bold$Red! $m$Def"
            Pause=1
            ;;
        "-q")
            Style="$Bold$Red$m$Def"
            Pause=0
            ;;
        "")
            Style="$Bold$Green\n-> $Def$Bold$m$Def"
            Pause=0
            step=$m
            ;;
    esac

    echo -e $Style
    if [ $Pause -eq 1 ] || [ $auto -eq 0 ]; then
        if ! [ "$o" == "-t" ] && ! [ "$o" == "-q" ]; then
            read -p $Bold$Yellow"Continue [ENTER]"$Def
        fi
    fi
}
