Ewancoder Arch Linux install script
===================================

![splash](http://raw.githubusercontent.com/ewancoder/eal/master/splash.png)

This is useful tool for reinstalling your arch linux and setting up all the programs automatically.

It includes 5 parts:

* *eal.sh* - installs base system and goes into *chroot* (peal.sh)
* *ceal.sh* - (configuration) file with all the settings, unique for each user and machine: you **should edit** it
* *heal.sh* - (host) a bridge between *install.sh* and *eal.sh* for installing from working linux distro
* *peal.sh* - (post) configures system under *chroot* and sets up all software (from your *dotfiles*)
* *install.sh* - starts the installation

Also, it includes *makepkg.patch*, which enables [--asroot option](https://projects.archlinux.org/pacman.git/commit/?id=61ba5c961e4a3536c4bbf41edb348987a9993fdb) during installation. Don't worry, the option is removed once installation is complete.

How to install?
---------------

All you need to know is basically 2 parts:

* ***ceal.sh*** - Constants eal - all constants for the script. You need to edit this file for your needs and desires before you start an installation
* ***install.sh*** - executable file itself. You run this file and installation begins. Read more in ceal.sh - I left there some comments

You can find [more documentation here](http://eal.readthedocs.org).

Quick-install
-------------

You don't have to clone this git repo. I have written a script which will curl (download) all 5 scripts to the current folder and uploaded it to my github website. Just run

```bash
bash <(curl ewancoder.github.io/al.sh)
```

or the same command with *wget*. You could also download [al.sh](http://ewancoder.github.io/al.sh), set +x (execution) flag and execute it like this:

```bash
curl -O ewancoder.github.io/al.sh
chmod +x al.sh
./al.sh
```
