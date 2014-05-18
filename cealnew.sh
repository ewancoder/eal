#!/bin/bash

#Current version of script
version="1.6 HARDCORE-Messy, 2014"

#All devices

descriptions=( Root Home Cloud Backup )
devices=( /dev/sdb5 /dev/sdb6 /dev/sdb4 /dev/sda5 )
mounts=( / /home /mnt/cloud /mnt/backup )
types=( ext4 ext4 ext4 ext4 )
options=( rw,relatime,discard rw,relatime,discard rw,relatime,discard rw,relatime )
dumps=( 0 0 0 0 )
passes=( 1 2 2 2 )

#Mirrorlist
mirrors=( Belarus United Denmark France Russia )

#Local timezone
timezone=Europe/Minsk

#Hostname
hostname=ewanhost

#Grub MBR device
mbr=/dev/sdb
