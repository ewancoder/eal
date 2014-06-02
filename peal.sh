#!/bin/bash
source ceal.sh
clear

title "Ewancoder Arch Linux POST-Installation script\nVersion $version"

for i in "${groups[@]}"
do
    IFS=',' read -a gr <<< "$i"
    for j in "${gr[@]}"
    do
        if [ "(grep $j /etc/group)" == "" ]; then
            mess "Add group '$j'"
            groupadd $j
        fi
    done
done

mess "Prepare sudoers file for pasting entries"
echo "\n## Users configuration" >> /etc/sudoers
for (( i = 0; i < ${#users[@]}; i++ )); do
    mess "Add user ${users[$i]} with groups: 'users,${groups[$i]}'"
    useradd -m -g users -G ${groups[$i]} -s /bin/bash ${users[$i]}
    mess "Add user ${users[$i]} entry into /etc/sudoers"
    echo "${users[$i]} ALL=(ALL) ALL" >> /etc/sudoers
    messpause "Setup user (${users[$i]}) password [MANUAL]"
    passwd ${users[$i]}
    if [ -f ${users[$i]}.sh ];
        mess "Copy ceal.sh & ${users[$i]}.sh scripts to /home/${users[$i]} folder"
        cp ceal.sh ${users[$i]}.sh /home/${users[$i]}/
    fi
done

mess "Add additional entries into /etc/sudoers"
echo "\n## Additional configuration" >> /etc/sudoers

if ! [ "$sudoers" == "" ]; then
    for i in "${sudoers[@]}"
    do
        mess "Add '$i' entry"
        echo $i >> /etc/sudoers
    done
fi

if [ $netctl -eq 1 ]
then
    mess "Copy ethernet-static template"
    cp /etc/netctl/examples/ethernet-static /etc/netctl/
    mess "Configure network at $interface device with $ip static ip address and $dns dns address"
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
    warn "Wait several seconds and try to ping something at another tty, then if network is ready, press [RETURN]"
fi

#INSTALL ESSENTIAL SOFTWARE
mess "Install yaourt"
bash <(curl aur.sh) -si --asroot --noconfirm package-query yaourt

mess "Install git"
yaourt -S --noconfirm --asroot git

mess "Add multilib via sed"
sed -i '/\[multilib\]/,+1s/#//' /etc/pacman.conf
mess "Update yaourt/pacman including multilib"
yaourt -Syy

#INSTALL ALL SOFTWARE
for (( i = 0; i < ${#software[@]}; i++ )); do
    mess "Install ${softtitle[$i]} software ($((i+1))/${#software[@]})"
    yaourt -S --noconfirm --asroot ${software[$i]}
done
mess "FINALLY cleaning mess - remove orphans recursively"
pacman -Rns $(pacman -Qtdq) --noconfirm

mess "Clone github repositories"
if ! [ "$gitrepos" == "" ]; then
    for (( i = 0; i < ${#gitrepos[@]}; i++ )); do
        mess "Clone ${gitrepos[$i]} repo"
        git clone https://github.com/${gitrepos[$i]}.git ${gitfolders[$i]}
        if ! [ "${gitrules[$i]}" == "" ]; then
            mess "SET rule '${gitrules[$i]}'"
            chown -R ${gitrules[$i]} ${gitfolders[$i]}
        fi
        if ! [ "${gitmodules[$i]}" == "" ]; then
            mess "Pull submodules ${gitmodules[$i]}"
            cd ${gitfolders[$i]} && git submodule update --init --recursive ${gitmodules[$i]}
        fi
        if ! [ "${gitlinks[$i]}" == "" ]; then
            mess "MERGE all LINKS"
            for f in ${gitfolders[$i]}/${gitfilter[$i]}; do
                if [ -d ${gitlinks[$i]}/$(basename $f) ]; then
                    mess "Move $(basename $f) folder from ${gitlinks[$i]} to ${gitfolders[$i]} because it exists :)"
                    cp -nr ${gitlinks[$i]}/$(basename $f)/* $f/ && rm -r ${gitlinks[$i]}/$(basename $f)
                fi
                mess "MERGE ${gitfolders[$i]}/${gitfilter[$i]} to ${gitlinks[$i]}"
                ln -fs ${gitfolders[$i]}/${gitfilter[$i]} ${gitlinks[$i]}/
            done
        fi
        mess "Cd into home directory"
        cd
    done
fi

#TEMPORARY HERE
mess "Link all I need to link"
for l in "${links[@]}"
do
    ln -fs $l
done
mess "Copy all I need to copy"
for c in "${cps[@]}"
do
    cp $c
done
#DO AFTER ACTUAL MERGING ALL STUFF FROM DOTFILES
mess "Exec what I need to exec"
for e in "${execs[@]}"
do
    $e
done

#NEED AFTER GIT FOR VIM SWAP DIRECTORIES
mess "Make empty directories where needed"
if ! [ "$mkdirs" == "" ]; then
    for i in ${$mkdirs[@]}
    do
        mess "Make $i directory"
        mkdir -p $i
    done
fi

mess "Make grub config based on new scripts"
grub-mkconfig -o /boot/grub/grub.cfg
mess "Generate locales (en+ru)"
locale-gen
mess "Set font cyr-sun16"
setfont cyr-sun16

mess "Setup all users configuration"
for (( i = 0; i < ${#users[@]}; i++ )); do
    if [ -f /home/${users[$i]}/${users[$i]}.sh ];
    then
        mess "Setup ${users[$i]} first"
        mess "CD into /home/${users[$i]}/ folder"
        de /home/${users[$i]}/
        mess "Add ${users[0]} NOPASSWD line to sudoers file"
        echo "${users[$i]} ALL = NOPASSWD: ALL" >> /etc/sudoers
        mess "Run peal-user.sh as ${users[0]} user"
        su - ${users[$i]} -c ./${users[$i]}.sh
        mess "Remove ${users[0]} NOPASSWD line from sudoers file"
        sed -i '/'${users[0]}' ALL = NOPASSWD: ALL/d' /etc/sudoers
    else
        mess "File /home/${users[$i]}/${users[$i]}.sh is not exist. Nothing to configure"
    fi
done

if [ $winfonts -eq 1 ]
then
    mess "Mount windows partition to /mnt/windows"
    sudo mkdir -p /mnt/windows
    mess "Make regular dirs: /mnt/{usb, usb0, data, mtp}"
    sudo mkdir -p /mnt/{usb,usb0,data,mtp}
    sudo mount $windows /mnt/windows
    mess "Copy windows fonts to /usr/share/fonts/winfonts"
    sudo cp -r /mnt/windows/Windows/Fonts /usr/share/fonts/winfonts
    mess "Update fonts cache"
    sudo fc-cache -fv
fi

#These won't install if merged earlier
filename=/usr/lib/python3.4/site-packages/canto_next/feed.py
sed -i "/from .tag import alltags/afrom .hooks import call_hook" $filename
sed -i "/item\[key\] = olditem/aplaceforbreak" $filename
sed -i "/placeforbreak/aplaceforelse" $filename
sed -i "/placeforelse/aplaceforcall" $filename
sed -i 's/placeforbreak/                    break/g' $filename
sed -i 's/placeforelse/            else:/g' $filename
sed -i 's/placeforcall/                call_hook("daemon_new_item", \[self, item\])/g' $filename

mess "Fix dead acute error in Compose-keys X11 file :)"
sed -i "s/dead_actute/dead_acute/g" /usr/share/X11/locale/en_US.UTF-8/Compose

mess "Change bitlbee folder owner to bitlbee:bitlbee"
mkdir -p /var/lib/bitlbee
chown -R bitlbee:bitlbee /var/lib/bitlbee
mess "Enable bitlbee"
systemctl enable bitlbee
#sudo systemctl start bitlbee
mess "Enable preload"
systemctl enable preload
#sudo systemctl start preload
mess "Enable cronie"
systemctl enable cronie
#sudo systemctl start cronie
mess "Enable deluged & deluge-web"
systemctl enable deluged
systemctl enable deluge-web
mess "Enable hostapd"
systemctl enable hostapd.service
mess "Enable dnsmasq"
systemctl enable dnsmasq.service
mess "Activate fuse (modprobe)"
modprobe fuse
mess "Detect sensors (lm_sensors)"
sensors-detect --auto

mess "Download and place canadian icon into /usr/share/gxkb/flags/ca(fr).png"
curl -o /usr/share/gxkb/flags/ca\(fr\).png http://files.softicons.com/download/web-icons/flags-icons-by-gosquared/png/24x24/Canada.png

warn "Installation is complete! [REBOOT]"
reboot
