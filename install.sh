#!/bin/bash
source ceal.sh
clear
mess -t "Ewancoder Arch Linux installation script\nVersion $version"
mess -w "Before proceeding, MAKE SURE that\n\t1) You have changed all constants in 'ceal.sh' file\n\t2) You have formatted your partitions as needed (fdisk + mkfs.ext4) and put them into 'ceal.sh' file"
source ceal.sh

prepare() {
    rm -f $2
    while read -r p; do
        if ! [[ "$p" == "" ]] && ! [[ ${p:0:1} == "#" ]] && ! [[ ${p:0:3} == "if " ]] && ! [[ ${p:0:2} == "fi" ]] && ! [[ ${p:0:4} == "for " ]] && ! [[ ${p:0:4} == "else" ]] && ! [[ ${p:0:4} == "done" ]]; then
            echo  "until $p; do" >> $2
            echo -e "\tmess -q \"Eror occured. Retry? (y/n)\"\n\tread ans" >> $2
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
./heal.sh
