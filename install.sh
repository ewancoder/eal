#!/bin/bash
source ceal.sh
if [ ! $(id -u) -eq 0 ]; then
    mess -w "You have to be ROOT to run this script. Exiting."
    exit
fi
clear
mess -t "Effective & Easy (Ewancoder) Arch Linux installation script\nVersion $version"
mess -w "Before proceeding, MAKE SURE that\n\t1) You have changed all constants in 'ceal.sh' file\n\t2) You have formatted your partitions as needed (fdisk + mkfs.ext4 + mkswap) and put them into 'ceal.sh' file"
source ceal.sh

prepare() {
    rm -f $2
    while read -r p; do
        if ! [[ "$p" == "" ]] &&
        ! [[ ${p:0:1} == "#" ]] &&
        ! [[ ${p:0:2} == "fi" ]] &&
        ! [[ ${p:0:3} == "if " ]] &&
        ! [[ ${p:0:4} == "for " ]] &&
        ! [[ ${p:0:4} == "else" ]] &&
        ! [[ ${p:0:4} == "done" ]] &&
        ! [[ ${p:0:4} == "' > " ]] &&
        ! [[ ${p:0:5} == "' >> " ]] &&
        ! [[ ${p:0:5} == "mess " ]] &&
        ! [[ ${p:0:5} == "elif " ]] &&
        ! [[ ${p:0:6} == "echo '" ]]; then
            echo "until $p; do" >> $2
            echo -e '    ans=""\n    mess -q "Error occured on step [$step]. Retry? (y/n)"' >> $2
            if [ $timeout -eq 0 ]; then
                echo -e "    read ans" >> $2
            else
                echo -e "    mess -q 'Auto-repeating in $timeout seconds'\n    read -t $timeout ans" >> $2
            fi
            echo -e '    if [ "$ans" == "n" ] || [ "$ans" == "N" ]; then\n        break\n    elif [ "$ans" == "givemebash" ]; then\n        /bin/bash\n    fi\ndone' >> $2
        else
            echo $p >> $2
        fi
    done < $1
}

mess -t "Prepare installation script - add error handling"
mess "Make temporary 'eal' directory where all installation files will be put"
mkdir -p eal
mess "Prepare eal.sh"
prepare eal.sh eal/eal.sh
mess "Prepare heal.sh"
prepare heal.sh eal/heal.sh
mess "Prepare peal.sh"
prepare peal.sh eal/peal.sh
cp ceal.sh eal/
cd eal

mess -t "Start installation"
mess "Make all scripts executable"
chmod +x {eal,heal,peal}.sh
if [ $hostinstall -eq 1 ]; then
    mess "Run host installation"
    ./heal.sh
else
    mess "Run regular installation"
    ./eal.sh
fi

mess "Remove temporary 'eal' directory"
cd ..
rm -r eal
mess "Unmount all within /arch"
grep /arch /proc/mounts | cut -d " " -f2 | sort -r | xargs umount -n

mess -w "This is it. You can reboot into your working system"
