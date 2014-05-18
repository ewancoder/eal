#!/bin/bash

#Current version of script
version="1.6 HARDCORE-Messy, 2014"

#All devices

descriptions=( Root Home Cloud Backup )
devices=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
mounts=( / /home /mnt/cloud /mnt/backup )
types=( ext4 ext4 ext4 ext4 )
options=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
dumps=( 0 0 0 0 )
passes=( 1 2 2 2 )

#Mirrorlist
mirrors=( Belarus United Denmark France Russia )

#Local timezone
timezone=Europe/Minsk

#Hostname
hostname=ewanhost

#Grub MBR device
mbr=/dev/sdb





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
