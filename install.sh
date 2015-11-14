#!/bin/bash
source ceal.sh
source myceal.sh
if [ ! "$(id -u)" -eq 0 ]; then
    mess -w "You have to be ROOT to run this script. Exiting."
    exit
fi
clear
mess -t "$title\nVersion $version\nRelease $release"
mess -w "Before proceeding:\n\t1) Edit 'myceal.sh' configuration file\n\t2) Format your partitions as required (fdisk + mkfs.ext4 + mkswap)"
source myceal.sh

prepare() {
    rm -f "$2"
    while read -r p; do
        if [ "$p" == "" ] ||
           [ "${p:0:1}" == "#" ] ||
           [ "${p:0:2}" == "fi" ] ||
           [ "${p:0:3}" == "if " ] ||
           [ "${p:0:4}" == "for " ] ||
           [ "${p:0:4}" == "else" ] ||
           [ "${p:0:4}" == "done" ] ||
           [ "${p:0:4}" == "' > " ] ||
           [ "${p:0:5}" == "mess " ] ||
           [ "${p:0:5}" == "elif " ] ||
           [ "${p:0:7}" == "source " ] ||
           [ "${p:0:11}" == "cd \`dirname" ]; then  
            echo "$p" >> "$2"
        else
            cmd=$(echo "$p" | sed -r 's/(.)/\\\\\1/g')
            echo "cmd=\$(echo $cmd)" >> "$2"

            if [ $substitute -eq 1 ]; then
                parsed=$(perl -pe 's/\$(?:{.*?}|\w+)(*SKIP)(*F)|(.)/\\$1/g' <<< "$p")
            else
                parsed=$cmd
            fi
            echo "parsed=\$(echo $parsed)" >> "$2"

            if [ $verbose -eq 1 ]; then
                # shellcheck disable=SC2016
                echo 'mess -v "$cmd"' >> "$2"
                if [ $auto -eq 0 ]; then
                    {
                        # shellcheck disable=SC2016
                        echo -e 'read -rep $'"'"'\\e[33m-> '"'"' -i "$parsed" parsed'
                        echo -e 'echo $'"'"'\\e[0m'"'"''
                    } >> "$2"
                fi
            fi
            {
                # shellcheck disable=SC2016
                echo -e 'until eval "$parsed"; do'
                echo -e '    ans=""'
                # shellcheck disable=SC2016
                echo -e '    mess -q "Error occured on step [$step]. Retry? (y/n)"'
            } >> "$2"
            if [ $timeout -eq 0 ]; then
                echo -e "    read ans" >> "$2"
            else
                {
                    echo -e "    mess -q \"Auto-repeating in $timeout seconds\""
                    echo -e "    read -t $timeout ans"
                } >> "$2"
            fi
            {
                # shellcheck disable=SC2016
                echo -e '    if [ "$ans" == "n" -o "$ans" == "N" ]; then'
                echo -e '        break'
                # shellcheck disable=SC2016
                echo -e '    elif [ "$ans" == "givemebash" ]; then'
                echo -e '        /bin/bash'
                echo -e '        ans=""'
                # shellcheck disable=SC2016
                echo -e '        mess -q "Retry [$step]? (y/n)"'
                echo -e '        read ans'
                # shellcheck disable=SC2016
                echo -e '        if [ "$ans" == "n" -o "$ans" == "N" ]; then'
                echo -e '            break'
                echo -e '        fi'
                # shellcheck disable=SC2016
                echo -e '    elif [ "$ans" == "EXIT" ]; then'
                echo -e '        exit'
            } >> "$2"
            if [ "$verbose" -eq 1 ]; then
                {
                    # shellcheck disable=SC2016
                    echo -e '    elif [ ! "$ans" == "" ] || [ $auto -eq 0 ]; then'
                    # shellcheck disable=SC2016
                    echo -e '        read -rep $'"'"'\\e[33m-> '"'"' -i "$parsed" parsed'
                    echo -e '        echo $'"'"'\\e[0m'"'"''
                } >> "$2"
            fi
            {
                echo -e '    fi'
                echo -e 'done'
            } >> "$2"
        fi
    done < "$1"
}

mess -t "Prepare installation scripts (add error handling)"
mess "Make temporary 'eal' directory where all installation files will be put"
mkdir -p eal

mess "Copy ceal.sh, myceal.sh and makepkg.patch"
cp ceal.sh myceal.sh makepkg.patch eal/

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
    source myceal.sh
    mess -t "ROOT executed script after installation"
    ' > root.sh
    cat root.sh "$rootscript" > temp && mv temp "$rootscript"
    rm root.sh
    prepare "$rootscript" "eal/$rootscript"
fi

mess "Prepare user-executed scripts"
for (( i = 0; i < ${#user[@]}; i++ )); do
    if [ ! "${userscript[$i]}" == "" ]; then
        mess "Prepare script for user ${user[$i]}"
        echo $"
        source ceal.sh
        source myceal.sh
        mess -t 'User script ${user[$i]}'
        " > user.sh
        cat user.sh "${userscript[$i]}" > temp && mv temp "${userscript[$i]}"
        rm user.sh
        prepare "${userscript[$i]}" "eal/${userscript[$i]}"
    fi
done

#if [ ! "$buildafter" == "" ]; then
#    mess "Prepare AUR BUILD post-install script"
#    echo 'source ceal.sh'                                                   > after.sh
#    echo 'mess -t "Build AUR software"'                                     >> after.sh
#    for (( i = 0; i < ${#buildafter[@]}; i++ )); do
#        echo "mess 'Build ${buildafter[$i]} ($((i+1))/${#buildafter[@]})'"  >> after.sh
#        echo "yaourt -S --noconfirm ${buildafter[$i]}"                      >> after.sh
#    done
#    echo "sed -i '/$term ~\/after.sh &/d' ~/.xprofile"                      >> after.sh
#    echo "rm ~/ceal.sh ~/after.sh"                                          >> after.sh
#    prepare after.sh eal/after.sh
#fi

cd eal || mess -w "Can't CD into 'eal' folder"

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
