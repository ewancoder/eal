source ceal.sh
#Need to have squashfs-tools installed

mess -t "This script is intended for installing arch linux from within your working (arch) linux"
mess -w "Be sure that you've changed all constants in ceal.sh because this script will automatically execute eal.sh after chrooting into live-cd"

mess "Download root live-cd"
curl -O http://ftp.byfly.by/pub/archlinux/iso/2014.06.01/arch/x86_64/root-image.fs.sfs
mess "Unsquash root live-cd"
unsquashfs -d /squashfs-root root-image.fs.sfs
mess "Make /arch folder"
mkdir -p /arch
mess "Mount all needed things to /arch"
mount -o loop /squashfs-root/root-image.fs /arch
mount -t proc none /arch/proc
mount -t sysfs none /arch/sys
mount -o bind /dev /arch/dev
mount -o bind /dev/pts /arch/dev/pts
cp -L /etc/resolv.conf /arch/etc

mess "Copy {eal,peal,ceal}.sh scripts to /arch/root/"
cp {eal,peal,ceal}.sh /arch/root/
mess "Chroot into /arch and execute /arch/root/eal.sh"
chroot /arch /arch/root/eal.sh
