#!/bin/bash
source ceal.sh
clear
mess -t "Ewancoder Arch Linux installation script\nVersion $version"
mess -w "Before proceeding, MAKE SURE that\n\t1) You have changed all constants in 'ceal.sh' file\n\t2) You have formatted your partitions as needed (fdisk + mkfs.ext4) and put them into 'ceal.sh' file"
source ceal.sh

prepare() {
    rm -f $2
    while read -r p; do
        if ! [[ "$p" == "" ]] && ! [[ ${p:0:1} == "#" ]] && ! [[ ${p:0:3} == "if " ]] && ! [[ ${p:0:2} == "fi" ]] && ! [[ ${p:0:4} == "for " ]] && ! [[ ${p:0:4} == "else" ]] && ! [[ ${p:0:4} == "done" ]] && ! [[ ${p:0:6} == "echo '" ]] && ! [[ ${p:0:5} == "' >> " ]] && ! [[ ${p:0:4} == "' > " ]] && ! [[ ${p:0:5} == "mess " ]]; then
            echo  "until $p; do" >> $2
            echo -e "\tans=''" >> $2
            echo '    mess -q "Error occured on step [$step]. Retry? (y/n)"' >> $2
            if [ $timeout -eq 0 ]; then
                echo -e "\tread ans" >> $2
            else
                echo -e "\tmess -q 'Auto-repeating in $timeout seconds'\n\tread -t $timeout ans" >> $2
            fi
            echo '    if [ "$ans" == "n" ] || [ "$ans" == "N" ]; then' >> $2
            echo -e "\t\tbreak\n\tfi\ndone" >> $2
        else
            echo $p >> $2
        fi
    done <$1
}

mess "Prepare installation script - add error handling"
mkdir -p eal
prepare eal.sh eal/eal.sh
prepare heal.sh eal/heal.sh
prepare peal.sh eal/peal.sh
cp ceal.sh eal/
cd eal
chmod +x {eal,heal,peal}.sh
if [ $hostinstall -eq 1 ]; then
    ./heal.sh
else
    ./eal.sh
fi
cd ..
rm -r eal

mess -w "This is it. You can reboot into your working system"
