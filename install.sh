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
            echo -e '    elif [ "$ans" == "EXIT" ]; then'                       >> $2
            echo -e '        exit'                                              >> $2
            echo -e '    fi'                                                    >> $2
            echo -e 'done'                                                      >> $2
        fi
    done < $1
}

mess -t "Prepare installation script (add error handling)"
mess "Make temporary 'eal' directory where all installation files will be put"
mkdir -p eal

mess "Copy ceal.sh and makepkg.patch"
cp ceal.sh makepkg.patch eal/

mess "Prepare eal.sh"
prepare eal.sh eal/eal.sh
mess "Prepare heal.sh"
prepare heal.sh eal/heal.sh
mess "Prepare peal.sh"
prepare peal.sh eal/peal.sh

if [ ! "$rootscript" == "" ]; then
    mess "Prepare root (post-install) script"
    echo $'
    source ceal.sh
    mess -t "ROOT executed script after installation"
    ' > root.sh
    cat root.sh $rootscript > temp && mv temp $rootscript
    rm root.sh
    prepare $rootscript eal/$rootscript
fi

mess "Prepare user-executed scripts"
for (( i = 0; i < ${#user[@]}; i++ )); do
    if ! [ "${gitname[$i]}" == "" -a "${userscript[$i]}" == "" ]; then
        mess "Prepare script for user ${user[$i]}"
        echo $'
        source ceal.sh
        mess -t "User executed script for ${user[$i]} user"
        ' > user.sh
        if [ ! "${gitname[$i]}" == "" ]; then
            mess "Add git configuration to user-executed script"
            echo $'
            mess "Configure git for ${user[$i]}"
            mess "Configure git user.name as ${gitname[$i]}"
            git config --global user.name ${gitname[$i]}
            mess "Configure git user.email as ${gitemail[$i]}"
            git config --global user.email ${gitemail[$i]}
            mess "Configure git merge.tool as ${gittool[$i]}"
            git config --global merge.tool ${gittool[$i]}
            mess "Configure git core.editor as ${giteditor[$i]}"
            git config --global core.editor ${giteditor[$i]}
            ' >> user.sh
        fi
        if [ ! "${userscript[$i]}" == "" ]; then
            mess "Assemble user-defined script (${userscript[$i]})"
            cat user.sh ${userscript[$i]} > temp && mv temp ${userscript[$i]}
            rm user.sh
            prepare ${userscript[$i]} eal/${userscript[$i]}
        fi
    fi
done

if [ ! "$buildafter" == "" ]; then
    mess "Prepare AUR BUILD post-install script"
    echo 'source ceal.sh'                                                   > after.sh
    echo 'mess -t "Build AUR software"'                                     >> after.sh
    for (( i = 0; i < ${#buildafter[@]}; i++ )); do
        echo "mess 'Build ${buildafter[$i]} ($((i+1))/${#buildafter[@]})'"  >> after.sh
        echo "yaourt -S --noconfirm ${buildafter[$i]}"                      >> after.sh
    done
    echo "sed -i '/$term ~\/after.sh &/d' ~/.xprofile"                      >> after.sh
    echo "rm ~/ceal.sh ~/after.sh"                                          >> after.sh
    prepare after.sh eal/after.sh
fi

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
