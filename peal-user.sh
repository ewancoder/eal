#!/bin/bash
source ceal.sh

#After-X instructions
    #1) Just login into Copy & Dropbox (/mnt/cloud folder)
    #2) Setup BitlBee twitter account
        #Run sc (open screen irssi session)
        #Open bitlbee window, run
            #register && /oper <passwd>
            #account add twitter ewancoder
            #account on
            #/exit / run irssi again
            #<go to token link to accept>

mess "Download package-query.tar.gz file"
curl -O https://aur.archlinux.org/packages/pa/package-query/package-query.tar.gz
mess "UnTar package-query.tar.gz archive"
tar xvf package-query.tar.gz
mess "Cd into package-query directory"
cd package-query
mess "Makepkg here"
makepkg -s --noconfirm
mess "Install .xz package using pacman"
sudo pacman -U --noconfirm *.xz
mess "Download yaourt.tar.gz file"
curl -O https://aur.archlinux.org/packages/ya/yaourt/yaourt.tar.gz
mess "UnTar yaourt.tar.gz archive"
tar xvf yaourt.tar.gz
mess "Cd into yaourt directory"
cd yaourt
mess "Makepkg here"
makepkg --noconfirm
mess "Install .xz package using pacman"
sudo pacman -U --noconfirm *.xz
mess "Cd into home directory and remove all archives and dirs respectively"
cd && rm -r package-query*

mess "Install git"
sudo rm -f /var/lib/pacman/db.lck #Need this cause pacman is still locked when installing on ssd very quickly
yaourt -S --noconfirm git
mess "Configure git user.name"
git config --global user.name $gitname
mess "Configure git user.email"
git config --global user.email $gitemail
mess "Configure git merge.tool"
git config --global merge.tool $gittool
mess "Configure git core.editor"
git config --global core.editor $giteditor
mess "Make link to .gitconfig for /root user"
sudo ln -s ~/.gitconfig /root/
mess "Clone ~/.dotfiles github repository"
git clone https://github.com/$githome .dotfiles
mess "Clone /etc/.dotfiles github repository"
sudo git clone https://github.com/$gitetc /etc/.dotfiles
mess "Cd into .dotfiles & pull submodules: oh-my-zsh & vundle"
cd .dotfiles && git submodule update --init --recursive $gitmodules
mess "Make vim swap & backup dirs"
mkdir .vim/{swap,backup}
mess "Cd into home directory"
cd

mess "Merge all git links: Now will be executed script that will merge all git links from ~/.dotfiles & from /etc/.dotfiles"
./peal-merge.sh

mess "Make grub config based on new scripts + image"
sudo grub-mkconfig -o /boot/grub/grub.cfg
mess "Generate locales (en+ru)"
sudo locale-gen
mess "Set font cyr-sun16"
sudo setfont cyr-sun16
mess "Update yaourt/pacman including multilib"
yaourt -Syy

mess "Install Audio software (1/7)"
yaourt -S --noconfirm alsa-plugins alsa-utils pulseaudio pulseaudio-alsa lib32-libpulse lib32-alsa-plugins
mess "Install A Drivers software (2/7)"
yaourt -S --noconfirm lib32-nvidia-libgl mesa nvidia nvidia-libgl phonon-qt4-gstreamer
mess "Install Coding software (3/7)"
yaourt -S --noconfirm python python-matplotlib python-numpy python2-pygame python-pygame-hg python-scipy python-sphinx tig
mess "Install Core software (4/7)"
yaourt -S --noconfirm cron devilspie dmenu dosfstools dunst faience-icon-theme feh ffmpegthumbnailer fuse gnome-themes-standard encfs jmtpfs ntfs-3g gxkb jre kalu lm_sensors p7zip unzip pam_mount preload rsync rxvt-unicode screen terminus-font tilda transset-df ttf-dejavu tumbler xorg-server xorg-server-utils xorg-xinit wmii-hg unrar urxvt-perls xboomx xclip xcompmgr zsh
mess "Install Graphics software (5/7)"
yaourt -S --noconfirm geeqie gource scrot vlc
mess "Install Internet software (6/7)"
yaourt -S --noconfirm bitlbee canto-curses chromium chromium-libpdf chromium-pepper-flash djview4 deluge dropbox-experimental irssi perl-html-parser python2-mako skype
#Now I'm using jre instead of icedtea-web-java7

#These won't install if merged earlier
mess "Merge pulseaudio instead of alsa (pulseaudio won't install if merged earlier) - /etc/pulse folder"
foldlink "pulse"
mess "Merge bitlbee config (bitlbee won't install if merged earlier) - /etc/bitlbee folder"
foldlink "bitlbee"
#If merged earlier, pam_mount moves config and creates default one
mess "Merge pam_mount.conf.xml"
sudo ln -fs /etc/.dotfiles/security\;pam_mount.conf.xml /etc/security/pam_mount.conf.xml
#This is managed after actual canto installation :)
temp='os.system("touch /tmp/rssitems")'
filename=/usr/lib/python3.4/site-packages/canto_curses/tag.py
sudo sed -i "/import curses/aimport os" $filename
sudo sed -i "/call_hook(\"items_added/aplacefortabs$temp" $filename
sudo sed -i 's/placefortabs/        /g' $filename

mess "Install Office software (7/7)"
yaourt -S --noconfirm anki gvim kdegraphics-okular libreoffice-calc libreoffice-common libreoffice-impress libreoffice-math libreoffice-writer libreoffice-en-US hyphen hyphen-en hyphen-ru hunspell hunspell-en hunspell-ru thunar thunar-dropbox

mess "Install Additional software (8/7)"
yaourt -S --noconfirm gimp gksu gparted mc pasystray-git pavucontrol smartmontools

#Additional not-inistalled software
#Games - extremetuxracer, foobillard++, kdegames-kolf, kdegames-konquest, lbreakout2, openbve, pingus, rocksndiamonds, steam, supertux, supertuxcart, warmux, wesnoth
#Graphics - inkscape, mypaint
#Video editing - openshot
#Wind-a - mono virtualbox wine wine_gecko wine-mono

mess "Install Art Production software (9/7)"
yaourt -S --noconfirm lmms calligra-krita smplayer

mess "FINALLY cleaning mess - remove orphans (needed twice)"
pacman -Qdt | awk '{print $1}' | xargs sudo pacman -R --noconfirm
pacman -Qdt | awk '{print $1}' | xargs sudo pacman -R --noconfirm

mess "CLONE current workaround repositories (currently only btp.git)"
git clone https://github.com/ewancoder/btp.git

mess "Fix dead acute error in Compose-keys X11 file :)"
sudo sed -i "s/dead_actute/dead_acute/g" /usr/share/X11/locale/en_US.UTF-8/Compose

mess "Change bitlbee folder owner to bitlbee:bitlbee"
sudo mkdir -p /var/lib/bitlbee
sudo chown -R bitlbee:bitlbee /var/lib/bitlbee
mess "Activate & start bitlbee"
sudo systemctl enable bitlbee
#sudo systemctl start bitlbee
mess "Activate & start preload"
sudo systemctl enable preload
#sudo systemctl start preload
mess "Activate & start cronie"
sudo systemctl enable cronie
#sudo systemctl start cronie
mess "Deluge stuff"
sudo systemctl enable deluged
sudo systemctl enable deluge-web
mess "Change shell to /bin/zsh for $username & $username2 users"
sudo chsh -s /bin/zsh $username
sudo chsh -s /bin/zsh $username2
mess "Activate fuse (modprobe)"
sudo modprobe fuse
mess "Detect sensors (lm_sensors)"
sudo sensors-detect --auto

mess "Install Copy Agent"
curl -O https://copy.com/install/linux/Copy.tgz
tar xvf Copy.tgz
mv copy ctemp
rm *.tgz
mv ctemp/x86_64 .copy
rm -r ctemp
sudo ln -fs ~/.copy/CopyAgent /usr/bin/copy

mess "Download and place canadian icon into /usr/share/gxkb/flags/ca(fr).png"
curl -O http://files.softicons.com/download/web-icons/flags-icons-by-gosquared/png/24x24/Canada.png
sudo mv Canada.png /usr/share/gxkb/flags/ca\(fr\).png

mess "Remove files"
sudo rm *eal*

mess "Create regular directories (~/Downloads/*)"
mkdir -p ~/Downloads/Chrome\ Downloads
ln -fs /mnt/backup/Downloads/Torrents ~/Downloads/Torrents
ln -fs /mnt/backup/Downloads/Downloading ~/Downloads/Downloading
ln -fs /mnt/backup/Downloads/Completed ~/Downloads/Completed

if [ $winfonts -eq 1 ]
then
    mess "Mount windows partition to /mnt/windows"
    sudo mkdir -p /mnt/windows
    mess "Make regular dirs: /mnt/{usb, usb0, data, mtp}"
    sudo mkdir -p /mnt/{usb,usb0,data,mtp}
    sudo mount $windows /mnt/windows
    mess "Copy windows fonts to /usr/share/fonts/winfonts"
    sudo cp -r /mnt/windows/Windows/Fonts /usr/share/fonts/winfonts
    mess "Update fonts cache"
    sudo fc-cache -fv
fi

mess "BundleInstall - vim installing plugins"
vim +BundleInstall +qall

messpause "Change password for irssi config freenode autocmd [MANUAL]"
cp ~/.irssi/config_sample ~/.irssi/config
vim ~/.irssi/config

exit
