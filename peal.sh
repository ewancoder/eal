#!/bin/bash
cd "$(dirname "$BASH_SOURCE")" || exit
source ceal.sh
source myceal.sh
mess -t "Setup hostname & timezone"
mess "Set hostname ($hostname)"
echo $hostname > /etc/hostname
mess "Set local timezone ($timezone)"
ln -fs /usr/share/zoneinfo/$timezone /etc/localtime

mess -t "Uncomment locales"
for i in "${locale[@]}"; do
    mess "Add locale $i"
    sed -i "s/^#$i/$i/g" /etc/locale.gen
done
mess "Generate locales"
locale-gen
mess "Set up default locale (${locale[0]})"
echo "LANG=${locale[0]}" > /etc/locale.conf
#mess "Set font as $font"
#setfont $font

mess -t "Prepare for software installation"
mess "Apply patch to makepkg in order to return '--asroot' parameter"
patch /usr/bin/makepkg < /root/makepkg.patch
rm /root/makepkg.patch
mess "Install yaourt"
pacman -S git --noconfirm
git clone https://aur.archlinux.org/package-query.git
(
    cd package-query || mess -w "Error! Could not CD into 'package-query' folder."
    makepkg -si --noconfirm
)
rm -rf package-query
git clone https://aur.archlinux.org/yaourt.git
(
    cd yaourt || mess -w "Error! Could not CD into 'yaourt' folder."
    makepkg -si --noconfirm
)
mess "Add multilib via sed"
sed -i '/\[multilib\]/,+1s/#//' /etc/pacman.conf
mess "Update packages including multilib"
yaourt -Syy

mess -t "Install grub"
mess "Install grub to /boot"
pacman -S --noconfirm grub
mess "Install grub bootloader to $mbr mbr"
grub-install --target=i386-pc --recheck $mbr
mess "Install os-prober"
pacman -S --noconfirm os-prober
mess "Make grub config"
grub-mkconfig -o /boot/grub/grub.cfg

mess -t "Setup network connection"
if [ $network -eq 1 ]; then
    mess "Copy $profile template"
    cp /etc/netctl/examples/$profile /etc/netctl/
    mess "Configure network"
    sed -i -e "s/eth0/$interface/" -e "s/wlan0/$interface/" -e "s/^Address=.*/Address='$ip\/24'/" -e "s/192.168.1.1/$dns/" -e "s/^ESSID=.*/ESSID='$essid'/" -e "s/^Key=.*/Key='$key'/" /etc/netctl/$profile
    mess "Enable netctl $profile"
    netctl enable $profile
elif [ $network -eq 2 ]; then
    mess "Enable dhcpcd"
    systemctl enable dhcpcd
fi

mess -t "Install all software"
for (( i = 0; i < ${#software[@]}; i++ )); do
    mess "Install ${softtitle[$i]} software ($((i+1))/${#software[@]})"
    yaourt -S --noconfirm "${software[$i]}"
done
mess -t "Build AUR software"
for (( i = 0; i < ${#build[@]}; i++ )); do
    mess "Build ${build[$i]} ($((i+1))/${#build[@]})"
    yaourt -S --noconfirm "${build[$i]}"
done
mess "Reinstall pacman (remove makepkg patch)"
pacman -S pacman --noconfirm
mess "Clean mess - remove orphans recursively"
pacman -Rns "$(pacman -Qtdq)" --noconfirm || true

if [ ! "$windows" == "" ]; then
    mess -t "Copy windows fonts to linux"
    mess "Mount windows partition to /mnt/windows"
    mkdir -p /mnt/windows
    mount $windows /mnt/windows
    mess "Copy windows fonts to /usr/share/fonts/winfonts"
    mkdir -p /usr/share/fonts
    cp -r /mnt/windows/Windows/Fonts /usr/share/fonts/winfonts
    mess "Update fonts cache"
    fc-cache -fv
    mess "Unmount windows partition"
    umount $windows
fi

if [ ${#service} -gt 0 ]; then
    mess -t "Enable services"
    for s in "${service[@]}"; do
        mess "Enable $s service"
        systemctl enable "$s"
    done
fi

if [ ! "$group" == "" ]; then
    mess -t "Create non-existing groups"
    for i in "${group[@]}"; do
        IFS=',' read -r -a grs <<< "$i"
        for j in "${grs[@]}"; do
            if [ "$(grep "$j" /etc/group)" == "" ]; then
                mess "Add group '$j'"
                groupadd "$j"
            fi
        done
    done
fi

mess -t "Quickly create users (need for chmod-ing git repos)"
for i in "${user[@]}"; do
    mess "Create user $i"
    useradd -m -g users -s /bin/bash $i
done

if [ ${#backup} -gt 0 ]; then
    if ! yaourt -Q rsync; then
        yaourt -S rsync
    fi
    mess -t "Restore system backup"
    shopt -s dotglob
    for (( i = 0; i < ${#backup[@]}; i++ )); do
        mess "Restore backup '${backup[$i]}'"
        eval "rsync -a ${backup[$i]}"
    done
    shopt -u dotglob
fi

if [ ${#gitrepo} -gt 0 ]; then
    mess -t "Clone github repositories"
    for (( i = 0; i < ${#gitrepo[@]}; i++ )); do
        mess "Clone ${gitrepo[$i]} repo"
        git clone "https://github.com/${gitrepo[$i]}.git" "${gitfolder[$i]}"
        if [ ! "${gitmodule[$i]}" == "" ]; then
            mess "Pull submodules ${gitmodule[$i]}"
            (
                cd "${gitfolder[$i]}" || mess -w "Can't CD into ${gitfolder[$i]} folder."
                git submodule update --init --recursive "${gitmodule[$i]}"
                IFS=' ' read -r -a submods <<< "${gitmodule[$i]}"
                for j in "${submods[@]}"; do
                    mess "Checkout submodule $j to master"
                    cd "${gitfolder[$i]}/$j" || mess -w "Can't CD into ${gitfolder[$i]}/$j"
                    git checkout master
                done
            )
        fi
        if [ ! "${gitrule[$i]}" == "" ]; then
            mess "SET chown '${gitrule[$i]}'"
            chown -R "${gitrule[$i]}" "${gitfolder[$i]}"
        else
            mess "SET chown '$main' for '.git' folder"
            chown -R $main:users "${gitfolder[$i]}/.git"
        fi
        mess "Set remote to SSH"
        (
            cd "${gitfolder[$i]}" || mess -w "Can't CD into ${gitfolder[$i]}"
            git remote set-url origin "git@github.com:${gitrepo[$i]}.git"
            if [ ! "${gitbranch[$i]}" == "" ]; then
                mess "Checkout to branch '${gitbranch[$i]}'"
                git checkout ${gitbranch[$i]}
            fi
        )
        if [ ! "${gitlink[$i]}" == "" ]; then
            mess "Merge all files (make symlinks)"
            shopt -s extglob
            for f in ${gitfolder[$i]}/!(.git*|README*); do
                if [ -d "${gitlink[$i]}/$f" ]; then
                    if [ "$(ls -A "${gitlink[$i]}/$f")" ]; then
                        mess "Copy files from $f folder to ${gitfolder[$i]}"
                        cp -npr "${gitlink[$i]}/$f"/* "${gitfolder[$i]}/$f/" 2>/dev/null
                    fi
                    mess "Remove $f folder (before linking)"
                    rm -rf "${gitlink[$i]:?}/$f"
                fi
                mess "Make symlink from ${gitfolder[$i]}/$f to ${gitlink[$i]}/"
                ln -fs "${gitfolder[$i]}/$f" "${gitlink[$i]}/"
            done
            shopt -u extglob
        fi
    done
fi

mess -t "Setup users"
mess "Prepare sudoers file for pasting entries"
echo -e "\n## Users configuration" >> /etc/sudoers
for (( i = 0; i < ${#user[@]}; i++ )); do
    if [ ! "${group[$i]}" == "" ]; then
        mess "Add user ${user[$i]} to groups: '${group[$i]}'"
        usermod -G ${group[$i]} ${user[$i]}
    fi
    mess "Add user ${user[$i]} entry into /etc/sudoers"
    echo "${user[$i]} ALL=(ALL) ALL" >> /etc/sudoers
    if ! [ "${userscript[$i]}" == "" ]; then
        (
            cd /home/${user[$i]} || mess -w "Can't CD into /home/${user[$i]}"
            mess "Place user-defined script in home directory"
            cp /root/${userscript[$i]} user.sh
            mess "Make executable (+x)"
            chmod +x user.sh
            mess "Copy ceal.sh (& myceal.sh) there"
            cp /root/{my,}ceal.sh .
            mess "Execute user-defined script by ${user[$i]} user"
            mv .bash_profile .bash_profilecopy 2>/dev/null
            su -c ./user.sh -s /bin/bash ${user[$i]}
            mv .bash_profilecopy .bash_profile 2>/dev/null
            mess "Remove user.sh & ceal.sh (& myceal.sh) scripts from home directory"
            rm {user,ceal,myceal}.sh
        )
    fi
    if [ ! "${shell[$i]}" == "" ]; then
        mess "Set ${user[$i]} shell to ${shell[$i]}"
        chsh -s ${shell[$i]} ${user[$i]}
    fi
done

if [ ! "$rootscript" == "" ]; then
    mess -t "Execute root script ($rootscript)"
    chmod +x $rootscript
    /bin/bash $rootscript
fi

#if [ ! "$buildafter" == "" ]; then
#    mv after.sh /home/$main/
#    cp /root/ceal.sh /home/$main/
#    chmod +x /home/$main/after.sh
#    chown $main:users /home/$main/after.sh
#    chown $main:users /home/$main/ceal.sh
#    echo "$term ~/after.sh &" >> /home/$main/.xprofile
#fi

mess -t "Setup all passwords"
mess -p "Setup ROOT password"
passwd
for i in "${user[@]}"; do
    mess -p "Setup user ($i) password"
    passwd $i
done

mess -t "Finish installation"
mess "Remove all scripts"
rm /root/{ceal,myceal,peal}.sh
mess "Exit chroot (installed system -> live-cd)"
exit
