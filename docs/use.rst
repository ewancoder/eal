User Guide
**********

EAL script reads **ceal.sh** file and then do all it's magic based on constants which you should set first. I've made EAL script very flexible in terms of changeability and it's going to be much more flexible with your help and feedback.

1. Version
==========

There's nothing to configure. This variable shows current version of a script. I'm usually naming them funny for the things that I've added (for added heal.sh - Healed, for added error-handling - see below )

.. code-block:: bash

   version="1.9.5 Error-Handled, 2014"

2. Error-handling
=================

When there will occur an error within a script - you will be prompted with question either you wish to continue (skip the error) or to repeat command again. If you're installing some packages with pacman and there's just an internet connection goes down - you're probably will want to repeat the command. It is default action (so if you'd just press [RETURN] without any options given, it will repeat the command).

EAL script can automatically repeat the command if an error was detected. This is useful if you're installing script automatically (with **auto** switch turned on) and go for a walk at that time. You don't want to go back and see that some random error taked place at the beginning of the script and did not proceed further, do you?

Set variable **timeout** to number of seconds after which the command will be executed again. And then again. And etc. Set it to 0 if you don't want to use this feature.

.. code-block:: bash

   timeout=10

3. Installing from within host system
=====================================

If you'd like to install Arch Linux from within your already working (arch) linux (but in the other hdd/ssd partitions, of course) - this variables would do the trick.

.. note::

   I am writing (arch) in brackets because I'm going to make it possible to install arch linux from within ANY distribution (it's not as hard as it seems to be).

If you have live-cd, you can just reboot into it and run script without this feature. For that set **hostinstall=0**. Otherwise installation process will go through downloading live-cd, chrooting into it and installing arch linux from within your working distro.

.. code-block:: bash

   hostinstall=1

Also you should check **iso** variable. It should be a working link to the **root SFS (squashfs) live-cd image** (you could just leave it alone - it is working for me).

.. code-block:: bash

   iso=http://ftp.byfly.by/pub/archlinux/iso/2014.06.01/arch/x86_64/root-image.fs.sfs

4. Automatic install
====================

If you want to monitor EACH step of the script and give your permission to do it, leave **auto=0** as 0. It is default behaviour and I'm not going to change that although I'm using **auto=1** all the time. Because this way you can see all stuff happening and monitor all possible bugs that have not been caught by EAL error handler (although, I hope there's no such bugs).

Be AWARE: If you change auto to 1, all installation process will go as fast as your computer could think, download files and install packages. But this is pretty awesome when you just want to install your system and do your other stuff at the second window :)

.. code-block:: bash

   auto=0

5. Font and locales
===================

As archwiki tells us, we should set console fonts for displaying some character (for example, for russian utf-8 fonts it's cyr-sun16).

.. code-block:: bash

   font=cyr-sun16

And, as well, we need our locales set in **bash array**.

.. code-block:: bash

   locale=( en_US.UTF-8 ru_RU.UTF-8 )

Just list all locales you want to include there separated by whitespace like in the example. If you need only one locale, you can always exclude brackets and write it like a regular variable:

.. code-block:: bash

   locale=en_US.UTF-8

.. note::

   From now on, any time you'll see an array like var=( el1 el2 el3 ) you could just crop it to one value like var=el1 if you need only one value.

6. Hostname and timezone
========================

This is your hostname and timezone. There's all obvious. Hostname is the name of your PC, you should make it yourself. Timezone is linked file which is located at the /usr/share/zoneinfo/.

.. code-block:: bash

   hostname=ewanhost
   timezone=Europe/Minsk

7. Mirrorlist
=============

Mirrorlist is forming by using **grep** onto /etc/pacman.d/mirrorlist file from live-cd. So just include all countries (or any words which will be get by grep) consecutively respectively to importance. For example, here Belarus goes first, then all other countries. And United stays both for United States and for United Kingdom.

.. code-block:: bash

   mirror=( Belarus Denmark Russia United France )

8. Internet configuration
=========================

Internet can be configured 2 ways:

* dhcpcd - the most easiest way. It does not requires any configuration and runs out of box because it is dhcp receiver. Although, dhcp server should be set on your router and you should have ethernet connection (I've not experienced wi-fi connection over dhcpcd, although it is possible)
* netctl - powerful and easy-to-setup network manager which is stable and ensures good connection over any interfaces with any settings and contains lots of pre-configured profiles as example

If you set **netctl=0** - you will use dhcpcd service. Otherwise - you should set all params you need to use netctl.

.. code-block:: bash

   netctl=1

Profile is one of the profiles in /etc/netctl/examples folder which will be copied and edited by sed based on your config values. You can choose **ethernet-dhcp**, **ethernet-static**, **wireless-open**, **wireless-wpa-static**, etc. I am currently using **wireless-wpa-static**.

.. code-block:: bash

   profile=wireless-wpa-static

.. warning::

   Wireless-**WPA**-... profiles need **wpa_supplicant** package which handles **wpa** encryption. So make sure you have one in **software** section below

Also you should definitely configure network interface. You could run [ip link] command to know which interfaces do you have. It's going to be something like "enp2s0" or "wlp3s5". Mine is **wlan** just because I have applied special rules to udev.

.. code-block:: bash

   interface=wlan

If you're using **static** ip address (alongside with static netctl profile), you should definitely setup **ip** & **dns** and **gateway**. In my current configuration **dns** and **gateway** are the same, so I made them as one variable - **dns**. If you have different dns&gateway, you can connect me and I'll improve my script little bit more.

.. note::

   With netctl it's not dns of your provider, it's dns of your router. So you should basically set it to your router's ip address and it should all work.

.. code-block:: bash

   ip=192.168.100.22
   dns=192.168.100.1

If you're connecting via wi-fi (and maybe using encryption) you will need ESSID & PassKey to connect to your access point. There are easily set up here too.

.. code-block:: bash

   essid=TTT
   key=192837465

9. Devices
==========
