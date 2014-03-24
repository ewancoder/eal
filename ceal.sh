#Constants to change

    #Automode (if 0, you will be prompted on each step)
    auto=0

    #If 1, you will be prompted to edit fstab
    editfstab=1

    #Device to install grub mbr
    device=/dev/sdb

    #Editor (change to nano if you don't like vi)
    edit=vi

    #Your hostname
    hostname=ewanhost

    #If 1, setup netctl ethernet-static; otherwise - just run dhcpcd
    netctl=1

    #Local timezone
    timezone=Europe/Minsk

    #Your username & username2 login
    username=ewancoder
    username2=lft

    #If 1, copy windows fonts
    winfonts=1

    #Dropbox device
    cloud=/dev/sdb4
    clfs=ext4
    clparams=rw,relatime,discard

    #Backup device
    backup=/dev/sda5
    bafs=ext4
    baparams=rw,relatime

    #Windows device
    windows=/dev/sdb1

#Additionals constants
    
    #Mirrorlists
    mirror1=Belarus
    mirror2=United
    mirror3=Denmark
    mirror4=France
    mirror5=Russia

    #Git params
    gitname=ewancoder
    gitemail=ewancoder@gmail.com
    gittool=vimdiff
    giteditor=vim

    #dotfiles repositories
    githome=ewancoder/dotfiles.git
    gitetc=ewancoder/etc.git

    #git submodules to recursive update
    gitmodules=".oh-my-zsh .vim/bundle/vundle"

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
