# General
    hostinstall=1
    iso="http://ftp.byfly.by/pub/archlinux/iso/$(date +%Y.%m.01)/arch/x86_64/airootfs.sfs" # DEFAULT.
    auto=0
    verbose=1
    timeout=10
    hostname=ewanpc
    timezone=Europe/Minsk # DEFAULT.
    locale=( en_US.UTF-8 ru_RU.UTF-8 )
    mirror=( Belarus Denmark Russia United France ) # DEFAULT.

# Devices
    description=( Root Backup Cloud )
    device=( /dev/sdb6 /dev/sda5 /dev/sdb5 )
    mount=( / /mnt/backup /mnt/cloud )
    type=( ext4 ext4 ext4 )
    option=( rw,relatime,discard rw,relatime rw,relatime,discard )
    dump=( 0 0 0 )
    pass=( 1 2 2 )
    mbr=/dev/sdb

# Users
    user=ewancoder
    shell=/bin/zsh
    group=fuse,uucp
    main=${user[0]} # First user.
    userscript=ewancoder_script.sh

# Git dotfiles
    gitrepo=( $main/dotfiles $main/etc )
    gitfolder=( /home/$main/.dotfiles /etc/.dotfiles )
    gitrule=( $main:users '' )
    gitmodule=( ".vim/bundle/vundle" )
    gitlink=( /home/$main /etc )

# Restore backup
    backup=(
        "/mnt/backup/Arch/ /home/$main/"
    )
    rootscript=root_script.sh

# Software
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
    software=(
        "lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt5-gstreamer ttf-dejavu"
        "alsa-plugins alsa-utils lib32-alsa-plugins lib32-libpulse pulseaudio pulseaudio-alsa"
        "cronie devilspie udevil feh fuse git gksu keychain libnotify mpv nawk openssh p7zip pygtk redshift rsync rxvt-unicode screen sshfs tig tilda transset-df unrar unclutter unzip urxvt-perls wpa_supplicant xclip xdotool xorg-server xorg-server-utils xorg-xinit zsh"
        "faience-icon-theme ffmpegthumbnailer terminus-font tumbler"
        "chromium deluge jre8-openjdk icedtea-web net-tools skype"
        "anki calligra-krita filelight geeqie gource vim impressive kdegraphics-okular libreoffice-fresh hyphen hyphen-en hunspell hunspell-en mc scrot thunar"
        "ctags mono pygmentize python python-matplotlib python-numpy python-pyserial python-requests python-scipy python-sphinx python2-pygments texlive-core texlive-humanities texlive-langcyrillic texlive-latexextra texlive-pictures texlive-science wine"
        "dosfstools encfs gparted ntfs-3g smartmontools thefuck virtualbox"
    )
    service=( cronie deluged systemd-networkd systemd-timesyncd )
    build=( compton progress dmenu2 dropbox dunst-git gtk-theme-espresso gcalcli gxkb slimlock-git slim-archlinux-solarized-spiral hyphen-ru hunspell-ru-aot jmtpfs latex-beamer pencil popcorntime-bin slack-desktop syncplay pasystray-git xcape )
