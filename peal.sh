#!/bin/bash
source ceal.sh
clear

title "Ewancoder Arch Linux POST-Installation script\nVersion $version"

mess "Create all non-existing groups"
for i in "${groups[@]}"
do
    IFS=',' read -a gr <<< "$i"
    for j in "${gr[@]}"
    do
        if [ "$(grep $j /etc/group)" == "" ]; then
            mess "Add group '$j'"
            groupadd $j
        fi
    done
done

mess "Prepare sudoers file for pasting entries"
echo "\n## Users configuration" >> /etc/sudoers

mess "Create all users"
for (( i = 0; i < ${#users[@]}; i++ )); do
    mess "Add user ${users[$i]} with groups: 'users,${groups[$i]}'"
    useradd -m -g users -G ${groups[$i]} -s /bin/bash ${users[$i]}
    mess "Add user ${users[$i]} entry into /etc/sudoers"
    echo "${users[$i]} ALL=(ALL) ALL" >> /etc/sudoers
    messpause "Setup user (${users[$i]}) password [MANUAL]"
    passwd ${users[$i]}
done

if ! [ "$sudoers" == "" ]; then
    mess "Add additional entries into /etc/sudoers"
    echo "\n## Additional configuration" >> /etc/sudoers
    for i in "${sudoers[@]}"
    do
        mess "Add '$i' entry"
        echo $i >> /etc/sudoers
    done
fi

mess "Activate and setup network connection"
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

mess "Install essential software"
mess "Install yaourt"
bash <(curl aur.sh) -si --asroot --noconfirm package-query yaourt
mess "Install git"
yaourt -S --noconfirm git
mess "Configure git for root AND main user ($user)"
mess "Configure git user.name as $gitname"
git config --global user.name $gitname
mess "Configure git user.email as $gitemail"
git config --global user.email $gitemail
mess "Configure git merge.tool as $gittool"
git config --global merge.tool $gittool
mess "Configure git core.editor as $giteditor"
git config --global core.editor $giteditor
mess "Link this config to $user - main user"
ln -fs ~/.gitconfig /home/$user/

mess "Add multilib via sed"
sed -i '/\[multilib\]/,+1s/#//' /etc/pacman.conf
mess "Update yaourt/pacman including multilib"
yaourt -Syy

mess "Install all software"
for (( i = 0; i < ${#software[@]}; i++ )); do
    mess "Install ${softtitle[$i]} software ($((i+1))/${#software[@]})"
    yaourt -S --noconfirm ${software[$i]}
done
mess "Finally cleaning mess - remove orphans recursively"
pacman -Rns $(pacman -Qtdq) --noconfirm

mess "Clone github repositories"
if ! [ "$gitrepos" == "" ]; then
    for (( i = 0; i < ${#gitrepos[@]}; i++ )); do
        mess "Clone ${gitrepos[$i]} repo"
        git clone https://github.com/${gitrepos[$i]}.git ${gitfolders[$i]}
        if ! [ "${gitrules[$i]}" == "" ]; then
            mess "SET chown '${gitrules[$i]}'"
            chown -R ${gitrules[$i]} ${gitfolders[$i]}
        fi
        if ! [ "${gitmodules[$i]}" == "" ]; then
            mess "Pull submodules ${gitmodules[$i]}"
            cd ${gitfolders[$i]} && git submodule update --init --recursive ${gitmodules[$i]}
        fi
        if ! [ "${gitlinks[$i]}" == "" ]; then
            mess "MERGE all LINKS"
            shopt -s dotglob #Setting dotglob (temporary solution instead of filter)
            for f in $(ls -A ${gitfolders[$i]}/ | grep -v .git); do
                if [ -d ${gitlinks[$i]}/$f ]; then
                    mess "Move $f folder from ${gitlinks[$i]} to ${gitfolders[$i]} because it exists :)"
                    cp -nr ${gitlinks[$i]}/$f/* ${gitfolders[$i]}/$f/
                    rm -r ${gitlinks[$i]}/$f
                fi
                mess "MERGE $f to ${gitlinks[$i]}"
                ln -fs ${gitfolders[$i]}/$f ${gitlinks[$i]}/
            done
            shopt -u dotglob #Unsetting dotglob
        fi
        mess "Cd into home directory"
        cd
    done
fi

mess "Setup all users shells"
for (( i = 0; i < ${#users[@]}; i++ )); do
    if ! [ "${shells[$i]}" == "" ]; then
        chsh -s ${shells[$i]} ${users[$i]}
    fi
done

if ! [ "$windows" == "" ]; then
    mess "Mount windows partition to /mnt/windows"
    mkdir -p /mnt/windows
    mount $windows /mnt/windows
    mess "Copy windows fonts to /usr/share/fonts/winfonts"
    cp -r /mnt/windows/Windows/Fonts /usr/share/fonts/winfonts
    mess "Update fonts cache"
    fc-cache -fv
fi

#FIX ISSUES AND BUGS

filename=/usr/lib/python3.4/site-packages/canto_next/feed.py
if [ -f $filename ]; then
    mess "Add canto-next daemon_new_item hook"
    sed -i "/from .tag import alltags/afrom .hooks import call_hook" $filename
    sed -i "/item\[key\] = olditem/aplaceforbreak" $filename
    sed -i "/placeforbreak/aplaceforelse" $filename
    sed -i "/placeforelse/aplaceforcall" $filename
    sed -i 's/placeforbreak/                    break/g' $filename
    sed -i 's/placeforelse/            else:/g' $filename
    sed -i 's/placeforcall/                call_hook("daemon_new_item", \[self, item\])/g' $filename
fi

mess "Fix dead acute error in Compose-keys X11 file :)"
filename=/usr/share/X11/locale/en_US.UTF-8/Compose
if [ -f $filename ]; then
    sed -i "s/dead_actute/dead_acute/g" $filename
fi

mess "Enable all services"
for s in ${services[@]}
do
    mess "Enable $s service"
    systemctl enable $s
done

mess "Link all I need to link"
for l in ${links[@]}
do
    ln -fs $l
done

mess "Execute all I need to execute"
for (( i = 0; i < ${#execs[@]}; i++ )); do
    mess "Executing '${execs[$i]}'"
    ${execs[$i]}
done

mess "Edit all I need to edit"
for e in ${edits[@]}
do
    messpause "Edit $e file as you need to"
    $edit $e
done

warn "Installation is complete! [REBOOT]"
reboot
