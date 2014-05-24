#!/bin/bash
#Current version of the script. Shows in title of 'eal.sh' and 'peal.sh'. Should be set for properly showing the version in the titles
version="1.6 HARDCORE-Messy, 2014"

#Editor which will edit all the files (need only for user-based 'peal-user.sh', irssi passwords). Should be set for properly showing it in the title of 'eal.sh'
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

#Sudoers additional entries - these entries will be added to the SUDOERS file. You can use relative intercourse like ${users[0]} for first user and ${users[1]} for the second (count begins with zero)
#If not needed, set it to sudoers=""
sudoers=( "${users[0]} ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0" "${users[0]} ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm" )

#Internet configuration
netctl=1
interface=enp2s0
ip=192.168.100.22
dns=192.168.100.1

#Git configuration
gitname=ewancoder
gitemail=ewancoder@gmail.com
gittool=vimdiff
giteditor=vim

#Git variables - set gitrepos="" if you don't want to clone any
gitrepos=( ewancoder/dotfiles ewancoder/etc ewancoder/btp )
#WITHOUT last slash
gitfolders=( ~/.dotfiles /etc/.dotfiles ~/btp )
#Set gitmodules="" if you don't want to pull any
gitmodules=( ".oh-my-zsh .vim/bundle/vundle" )
gitlinks=( ~/ )
gitfilter=( "{.*,bin}" )

#Make these empty directories automatically. Set mkdirs="" if you don't want any
mkdirs=( ~/.vim/{swap,backup} )





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
