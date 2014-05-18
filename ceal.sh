#!/bin/bash

#Current version of script
version="1.6 Pre-Cleaned, 2014"

#ALL DEVICES

    descriptions=( 'Root' 'Home' 'Cloud partition' 'Backup partition' )
    devices=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
    mounts=( / /home /mnt/cloud /mnt/backup )
    types=( ext4 ext4 ext4 ext4 )
    options=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
    dumps=( 0 0 0 0 )
    passes=( 1 2 2 2 )

#Switches

    #Automode (if 0, you will be prompted on each step)
    auto=0

    #If 1, setup netctl ethernet-static; otherwise setup dhcpcd
    netctl=1

    #If 1, your fstab's partitions mounted under /mnt will be set to 'discard'
    ssd=1

    #If 1, copy windows fonts
    winfonts=1

#Constants

    #Editor (change to nano if you don't like vi)
    edit=vi

    #Hostname
    hostname=ewanhost

    #Local timezone
    timezone=Europe/Minsk

    #NetCtl settings
    interface=enp2s0
    ip=192.168.100.22
    dns=192.168.100.1

    #Username & username2 login
    users=( ewancoder lft )
    groups=( fuse fuse )

    #Sudoers additional entries
    sudoers=( "${$users[0]} ALL=(ALL) NOPASSWD: /usr/bin/ifconfig lan up 192.168.1.1 netmask 255.255.255.0" "${$users[0]} ALL=(ALL) NOPASSWD: /usr/bin/yaourt -Syua --noconfirm" )

    username=ewancoder
    username2=lft

#Devices information

    #Backup & Cloud devices
    edevices=( /dev/sda5 /dev/sdb4 )
    efs=( ext4 ext4 )
    eparams=( rw,relatime rw,relatime,discard )

    #Backup device
    backup=/dev/sda5
    bafs=ext4
    baparams=rw,relatime

    #Cloud device
    cloud=/dev/sdb4
    clfs=ext4
    clparams=rw,relatime,discard

    #Grub MBR device
    mbr=/dev/sdb

    #Windows device
    windows=/dev/sdb1

#Additionals constants
    
    #Mirrorlists
    mirrors=( Belarus United Denmark France Russia )

    #Git params
    gitname=ewancoder
    gitemail=ewancoder@gmail.com
    gittool=vimdiff
    giteditor=vim

    #Dotfiles repositories
    gitrepos=( ewancoder/dotfiles ewancoder/etc )
    gitfolders=( ~/.dotfiles /etc/.dotfiles )
    gitmodules=( ".oh-my-zsh .vim/bundle/vundle" )

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
