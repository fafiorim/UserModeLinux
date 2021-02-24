#!/bin/bash
#
# This script was created to demonstrate how interact with a micro network topology using
# User Mode Linux to create other GNU/Linux machines and configure them as a
# LAN environment.
#
#	created by:Franzvitor Fiorim
#	date: September 10, 2017
#	date: October 16, 2020

# Before execute this script
#
# Before execute this script you will need to execute the net.sh script that
# is locate in ../utils diretory
#

# Logic topology
#
#	[UML-A1]	[UML-A2]
#	   |		   |
#      |___________|
#			 |
#			 |
#			 |
#		[Router A]
#			 |
#			 |
#			 |
#		  [HOST]
#


echo
echo '#-------------------[ Starting user: ((( '$USER' ))) ]-------------------#'
echo

## killall zumbi process
echo '# Cleaning zumbi process...'
sudo killall kernel64-4.3.5 < /dev/null > /dev/null
sudo killall uml_switch < /dev/null > /dev/null
sudo fuser -k /var/run/uml-utilities/uml_switch.ctl < /dev/null > /dev/null
#sudo tunctl -d tap0
echo '[OK]'
echo

echo '# Checking TAP interface ... '
echo
echo 'tap0'
sudo ifconfig tap0 | grep -w inet | awk {'print $2'} # Print IP address
sudo ifconfig tap0 | grep -w inet | awk {'print $4'} # Print netmask
echo

echo '[OK]'
echo

# Creating a swap file
#dd if=/dev/zero of=../emptyfs.swap bs=1024 seek=$[ 1024 * 1024 ] count=1

# Creating the switches
echo
echo 'Creating Switchs ...'
uml_switch -unix ./switch-tap -tap tap0 < /dev/null > /dev/null &
uml_switch -unix ./switch-RA_uml-A1-A2 < /dev/null > /dev/null &

echo '[ok]'

# Starting UML`s in multi-tab mode ...
echo '# Starting UMLs ...'
gnome-terminal --tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:ee,unix,./switch-tap \
eth1=daemon,cc:00:ff:ff:ee:03,unix,./switch-RA_uml-A1-A2 \
umid=RA \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./RA.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-RA.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:06,unix,./switch-RA_uml-A1-A2 \
umid=uml-A1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-A1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-A1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:07,unix,./switch-RA_uml-A1-A2 \
umid=uml-A2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-A2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-A2.cow,../emptyfs.swap > /dev/null" \ &
echo '[OK]'
echo
