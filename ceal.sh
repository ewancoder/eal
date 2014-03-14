#Constants to change

    #Automode (if 0, you will be prompted on each step)
    auto=0

    #If 0, you will be prompted to edit fstab
    clearfstab=0

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

    #Your username login
    username=ewancoder

    #If 1, copy windows fonts from mounted /mnt/windows partition (ask for mount)
    winfonts=1

#------------------------------
#Output styling
    Green=$(tput setaf 2)
    Yellow=$(tput setaf 3)
    Red=$(tput setaf 1)
    Bold=$(tput bold)
    Def=$(tput sgr0)

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
