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
    mess "Copy *.sh scripts to /home/${users[$i]} folder"
    cp *.sh /home/${users[$i]}/
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

warn "Installation is complete! [REBOOT]"
reboot
