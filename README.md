Ewancoder Arch Linux install script
===================================

![splash](https://raw.githubusercontent.com/ewancoder/eal/master/splash.png)

This is useful tool for reinstalling your arch linux and setting up all the programs automatically

It consists of 5 parts:

* eal.sh
* ceal.sh
* heal.sh
* peal.sh
* install.sh

How to install?
---------------

All you need to know is basically 2 parts:

* **ceal.sh** - Constants eal - all constants for the script. You need to edit this file for your needs and desires before you start an installation
* **install.sh** - executable file itself. You ran this file and installation begins. Read more in ceal.sh - I left there some comments

You can find more documentation at https://eal.readthedocs.org

Quick-install
-------------

You don't have to clone this git repo either. I've wrote a script which will curl (download) all 5 scripts to the current folder (I uploaded it onto my github site). Just run

```bash
bash <(curl ewancoder.github.io/al.sh)
```
