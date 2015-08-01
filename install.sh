#!/bin/bash
source ceal.sh
if [ ! `id -u` -eq 0 ]; then
    mess -w "You have to be ROOT to run this script. Exiting."
    exit
fi
clear
mess -t "Effective & Easy (Ewancoder) Arch Linux installation script\nVersion $version\nRelease $release"
mess -w "Before proceeding:\n\t1) Change constants in 'ceal.sh' configuration file\n\t2) Format your partitions as needed (fdisk + mkfs.ext4 + mkswap)"
source ceal.sh

prepare() {
    inside=0
    rm -f $2
    while read -r p; do
        if [ "$p" == ""              \
          -o "${p:0:1}" == "#"       \
          -o "${p:0:2}" == "fi"      \
          -o "${p:0:3}" == "if "     \
          -o "${p:0:4}" == "for "    \
          -o "${p:0:4}" == "else"    \
          -o "${p:0:4}" == "done"    \
          -o "${p:0:4}" == "' > "    \
          -o "${p:0:5}" == "mess "   \
          -o "${p:0:5}" == "elif "   \
          -o "${p:0:7}" == "source " \
          -o "${p:0:11}" == "cd \`dirname" ]; then  
            echo $p                                                             >> $2
        else
            if [ $verbose -eq 1 ]; then
                str=`echo $p | sed "s/'/'\"'\"'/g"`
                if [ "${p:0:7}" == "echo $'" ]; then
                    inside=1
                    echo $p                                                     >> $2
                    continue
                elif [ "${p:0:5}" == "' >> " ]; then
                    inside=0
                    echo $p                                                     >> $2
                    continue
                else
                    if [ $inside -eq 1 ]; then
                        echo "mess -v \\'$str\\'"                               >> $2
                    else
                        echo "mess -v '$str'"                                   >> $2
                    fi
                fi
            fi
            echo "until $p; do"                                                 >> $2
            echo -e '    ans=""'                                                >> $2
            echo -e '    mess -q "Error occured on step [$step]. Retry? (y/n)"' >> $2
            if [ $timeout -eq 0 ]; then
                echo -e "    read ans"                                          >> $2
            else
                echo -e "    mess -q \"Auto-repeating in $timeout seconds\""    >> $2
                echo -e "    read -t $timeout ans"                              >> $2
            fi
            echo -e '    if [ "$ans" == "n" -o "$ans" == "N" ]; then'           >> $2
            echo -e '        break'                                             >> $2
            echo -e '    elif [ "$ans" == "givemebash" ]; then'                 >> $2
            echo -e '        /bin/bash'                                         >> $2
            echo -e '        ans=""'                                            >> $2
            echo -e '        mess -q "Retry [$step]? (y/n)"'                    >> $2
            echo -e '        read ans'                                          >> $2
            echo -e '        if [ "$ans" == "n" -o "$ans" == "N" ]; then'       >> $2
            echo -e '            break'                                         >> $2
            echo -e '        fi'                                                >> $2
            echo -e '    fi'                                                    >> $2
            echo -e 'done'                                                      >> $2
        fi
    done < $1
}

mess -t "Prepare installation script (add error handling)"
mess "Make temporary 'eal' directory where all installation files will be put"
mkdir -p eal
mess "Prepare eal.sh"
prepare eal.sh eal/eal.sh
mess "Prepare heal.sh"
prepare heal.sh eal/heal.sh
mess "Prepare peal.sh"
prepare peal.sh eal/peal.sh
mess "Copy ceal.sh and makepkg.patch"
cp ceal.sh eal/
cp makepkg.patch eal/
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
if ! umount -R /arch > /dev/null; then
    grep /arch /proc/mounts | cut -d " " -f2 | sort -r | xargs umount -n
fi

mess -w "Installation complete. You can reboot into your new working system"
