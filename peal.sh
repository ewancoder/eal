#!/bin/bash
source ceal.sh
clear

mess -t "Ewancoder Arch Linux POST-installation script\nVersion $version"

mess -t "Activate and setup network connection"
if [ $netctl -eq 1 ]
then
    mess "Copy ethernet-static template"
    cp /etc/netctl/examples/ethernet-static /etc/netctl/
    mess "Configure network at $interface interface with $ip static ip address and $dns dns address"
    sed -i "s/eth0/$interface/" /etc/netctl/ethernet-static
    sed -i "s/^Address=.*/Address=('$ip\/24')/" /etc/netctl/ethernet-static
    sed -i "s/192.168.1.1/$dns/" /etc/netctl/ethernet-static
    mess "Enable and start netctl ethernet-static"
    netctl enable ethernet-static
    netctl start ethernet-static
else
    mess "Enable and start dhcpcd"
    systemctl enable dhcpcd
    dhcpcd
    mess -w "Wait several seconds to make sure that connection is up [RETURN]"
fi

mess -t "Install essential software"
mess "Install yaourt"
bash <(curl aur.sh) -si --asroot --noconfirm package-query yaourt
mess "Add multilib via sed"
sed -i '/\[multilib\]/,+1s/#//' /etc/pacman.conf
mess "Update packages including multilib"
yaourt -Syy

mess -t "Install all software"
for (( i = 0; i < ${#software[@]}; i++ )); do
    mess "Install ${softtitle[$i]} software ($((i+1))/${#software[@]})"
    yaourt -S --noconfirm ${software[$i]}
done
mess "Clean mess - remove orphans recursively"
pacman -Rns $(pacman -Qtdq) --noconfirm

if ! [ "$windows" == "" ]; then
    mess -t "Copy windows fonts to linux"
    mess "Mount windows partition to /mnt/windows"
    mkdir -p /mnt/windows
    mount $windows /mnt/windows
    mess "Copy windows fonts to /usr/share/fonts/winfonts"
    cp -r /mnt/windows/Windows/Fonts /usr/share/fonts/winfonts
    mess "Update fonts cache"
    fc-cache -fv
fi

filename1=/usr/lib/python3.4/site-packages/canto_next/feed.py
filename2=/usr/share/X11/locale/en_US.UTF-8/Compose
if [ -f $filename1 ] || [ -f $filename2 ]; then
    mess -t "Fix linux bugs&errors & add features"
fi
if [ -f $filename1 ]; then
    mess "Add canto-next daemon_new_item hook"
    sed -i "/from .tag import alltags/afrom .hooks import call_hook" $filename1
    sed -i "/item\[key\] = olditem/aplaceforbreak" $filename1
    sed -i "/placeforbreak/aplaceforelse" $filename1
    sed -i "/placeforelse/aplaceforcall" $filename1
    sed -i 's/placeforbreak/                    break/g' $filename1
    sed -i 's/placeforelse/            else:/g' $filename1
    sed -i 's/placeforcall/                call_hook("daemon_new_item", \[self, item\])/g' $filename1
fi
if [ -f $filename2 ]; then
    mess "Fix dead acute error in Compose-keys X11 file"
    sed -i "s/dead_actute/dead_acute/g" $filename2
fi

if ! [ "$service" == "" ]; then
    mess -t "Enable services"
    for s in ${service[@]}
    do
        mess "Enable $s service"
        systemctl enable $s
    done
fi

if ! [ "$group" == "" ]; then
    mess -t "Create non-existing groups"
    for i in "${group[@]}"
    do
        IFS=',' read -a grs <<< "$i"
        for j in "${grs[@]}"
        do
            if [ "$(grep $j /etc/group)" == "" ]; then
                mess "Add group '$j'"
                groupadd $j
            fi
        done
    done
fi

mess -t "Quickly create users (need for chmod-ing git repos)"
for i in ${user[@]}; do
    mess "Create user $i"
    useradd -m -g users -s /bin/bash $i
done

if ! [ "$gitrepo" == "" ]; then
    mess -t "Clone github repositories"
    for (( i = 0; i < ${#gitrepo[@]}; i++ )); do
        mess "Clone ${gitrepo[$i]} repo"
        git clone https://github.com/${gitrepo[$i]}.git ${gitfolder[$i]}
        if ! [ "${gitrule[$i]}" == "" ]; then
            mess "SET chown '${gitrule[$i]}'"
            chown -R ${gitrule[$i]} ${gitfolder[$i]}
        fi
        if ! [ "${gitmodule[$i]}" == "" ]; then
            mess "Pull submodules ${gitmodule[$i]}"
            cd ${gitfolder[$i]} && git submodule update --init --recursive ${gitmodule[i]}
            cd
        fi
        if ! [ "${gitlink[$i]}" == "" ]; then
            mess "Merge all files (make symlinks)"
            shopt -s dotglob
            for f in $(ls -A ${gitfolder[$i]}/ | grep -v .git); do
                if [ -d ${gitlink[$i]}/$f ]; then
                    mess "Move $f folder from ${gitlink[$i]} to ${gitfolder[$i]} becaus it exists"
                    cp -nr ${gitlink[$i]}/$f/* ${gitfolder[$i]}/$f/ 2>/dev/null
                    rm -r ${gitlink[$i]}/$f
                fi
                mess "Make symlink from ${gitfolder[$i]}/$f to ${gitlink[$i]}/"
                ln -fs ${gitfolder[$i]}/$f ${gitlink[$i]}/
            done
            shopt -u dotglob
        fi
    done
fi

mess -t "Setup users"
mess "Prepare sudoers file for pasting entries"
echo "\n## Users configuration" >> /etc/sudoers
for (( i = 0; i < ${#user[@]}; i++ )); do
    mess "Add user ${user[$i]} to groups: '${group[$i]}'"
    usermod -G ${group[$i]} ${user[$i]}
    mess "Add user ${user[$i]} entry into /etc/sudoers"
    echo "${user[$i]} ALL=(ALL) ALL" >> /etc/sudoers
    mess -p "Setup user (${user[$i]}) password [MANUAL]"
    passwd ${user[$i]}
    mess "Set ${user[$i]} shell to ${shell[$i]}"
    chsh -s ${shell[$i]} ${user[$i]}
    if ! [ "${gitname[$i]}" == "" ]; then
        mess "Prepare user-executed script for ${user[$i]} user"
        echo '
        source ceal.sh

        mess "Configure git for ${user[$i]}"
        mess "Configure git user.name as ${gitname[$i]}"
        git config --global user.name ${gitname[$i]}
        mess "Configure git user.email as ${gitemail[$i]}"
        git config --global user.email ${gitemail[$i]}
        mess "Configure git merge.tool as ${gittool[$i]}"
        git config --global merge.tool ${gittool[$i]}
        mess "Configure git core.editor as ${giteditor[$i]}"
        git config --global core.editor ${giteditor[$i]}
        ' > /home/${user[$i]}/user.sh
        echo -e ${execs[$i]} >> /home/${user[$i]}/user.sh
        mess "Make executable (+x)"
        chmod +x /home/${user[$i]}/user.sh
        #HERE NEEDED TO BE SURE THAT X-SERVER WONT START
        mv /home/${user[$i]}/.zprofile /home/${user[$i]}/.zprofilecopy 2>/dev/null
        mv /home/${user[$i]}/.bash_profile /home/${user[$i]}/.bash_profilecopy 2>/dev/null
        mess "Execute user-executed script by ${user[$i]} user"
        su - ${users[$i]} -c /home/${user[$i]}/user.sh
        mv /home/${user[$i]}/.zprofilecopy /home/${user[$i]}/.zprofile 2>/dev/null
        mv /home/${user[$i]}/.bash_profilecopy /home/${user[$i]}/.bash_profile 2>/dev/null
        rm /home/${user[$i]}/user.sh
    fi
done

if ! [ "$sudoers" == "" ]; then
    mess -t "Add additional entries into /etc/sudoers"
    echo "\n## Additional configuration" >> /etc/sudoers
    for i in "${sudoers[@]}"
    do
        mess "Add '$i' entry"
        echo $i >> /etc/sudoers
    done
fi

if ! [ "$link" == "" ]; then
    mess -t "Link all I need to link"
    for l in ${link[@]}
    do
        mess "Link $l"
        ln -fs $l
    done
fi

if ! [ "$rootexec" == "" ]; then
    mess -t "Execute all root commands"
    for (( i = 0; i < ${#rootexec[@]}; i++ )); do
        mess "Executing '${rootexec[$i]}'"
        ${rootexec[$i]}
    done
fi

mess -w "Installation is complete! [REBOOT]"
reboot
