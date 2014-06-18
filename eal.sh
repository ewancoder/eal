#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source ceal.sh
clear

mess -t "Ewancoder Arch Linux installation script\nVersion $version"
mess -w "Before proceeding, MAKE SURE that\n\t1) You have changed all constants in 'ceal.sh' file\n\t2) You have FORMATTED your partitions as needed (fdisk + mkfs.ext4) and put them into 'ceal.sh' file"
source ceal.sh

mess -t "Mount all partitions and create fstab"
mess "Create local fstab file (prepare)"
echo "# /etc/fstab: static file system information" > fstab
for (( i = 0; i < ${#device[@]}; i++ )); do
    mess "Create folder /mnt${mount[$i]}"
    mkdir -p /mnt${mount[$i]}
    mess "Mount ${device[$i]} to /mnt${mount[$i]}"
    mount ${device[$i]} /mnt${mount[$i]}
    mess "Add fstab ${description[$i]} partition entry '${device[$i]}\t${mount[$i]}\t${type[$i]}\t${option[$i]}\t${dump[$i]}\t${pass[$i]}'"
    echo -e "\n# ${description[$i]} partition\n${device[$i]}\t${mount[$i]}\t${type[$i]}\t${option[$i]}\t${dump[$i]}\t${pass[$i]}" >> fstab
done

mess -t "Form mirrorlist"
for i in "${mirror[@]}"
do
    mess "Place $i in mirrorlist"
    grep -A 1 --no-group-separator $i /etc/pacman.d/mirrorlist >> mirrorlist
done
mess "Move new mirrorlist to /etc/pacman.d/mirrorlist"
mv mirrorlist /etc/pacman.d/mirrorlist
mess "Update pacman packages list"
pacman -Syy
mess "Initializing pacman keyring"
pacman-key --init
pacman-key --populate archlinux
pacman-key --keyserver hkp://pgp.mit.edu -r B02854ED753E0F1F

mess -t "Install & setup system"
mess "Install base-system"
pacstrap /mnt base base-devel
mess "Move previously created fstab to /mnt/etc/fstab"
mv fstab /mnt/etc/fstab
mess "Set hostname ($hostname)"
echo $hostname > /mnt/etc/hostname

mess -t "CHROOT to system"
mess "Create root folder (just in case)"
mkdir -p /mnt/root
mess "Prepare eal-chroot.sh chroot script"
echo '
#!/bin/bash
source /root/ceal.sh

mess "Set local timezone ($timezone)"
ln -fs /usr/share/zoneinfo/$timezone /etc/localtime

mess -t "Uncomment locales"
for i in ${locale[@]}; do
    mess "Add locale $i"
    sed -i "s/^#$i/$i/g" /etc/locale.gen
done
mess "Generate locales"
locale-gen
mess "Set font as $font"
setfont $font

mess "Install grub to /boot"
pacman -S --noconfirm grub
mess "Install grub bootloader to $mbr mbr"
grub-install --target=i386-pc --recheck $mbr
mess "Install os-prober"
pacman -S --noconfirm os-prober
mess "Make grub config"
grub-mkconfig -o /boot/grub/grub.cfg

mess -p "Setup ROOT password"
passwd
' > /mnt/root/eal-chroot.sh
mess "Add peal.sh to eal-chroot script"
cat peal.sh >> /mnt/root/eal-chroot.sh
mess "Add 'exit chroot' message to the end of eal-chroot script"
echo '
mess "Remove all scripts"
rm /root/{eal-chroot,ceal,peal}.sh

mess "Exit chroot"
exit
' >> /mnt/root/eal-chroot.sh
mess "Set executable flag for chroot script"
chmod +x /mnt/root/eal-chroot.sh
mess "Copy {ceal,peal}.sh to /mnt/root"
cp {ceal,peal}.sh /mnt/root/
mess "Go to arch-chroot"
arch-chroot /mnt /root/eal-chroot.sh

mess -t "Finish installation"
mess "Unmount all within /mnt"
umount -R /mnt
mess "Exiting chroot"
exit
