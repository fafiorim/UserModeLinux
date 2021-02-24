#!/bin/bash
#
# This script was created to demonstrate how a micro network topology using
# User Mode Linux to create other GNU/Linux machines and configure them as
# LAN environment.
#
#	created by:Franzvitor Fiorim
#	date: September 10, 2017

# Before execute this script
#
# Before execute this script you will need to execute the net.sh script that
# is locate in ../utils diretory
#

# Logic topology
#
#                         [ UML-A0 ]
#				                       |
#				                       |
#				                       |
#				                       |
#				                   [ HOST ]
#

echo
echo '#-------------------[ Starting user: ((( '$USER' ))) ]-------------------#'
echo

## killall zumbi process
echo '# Cleaning zumbi process...'
sudo killall kernel64-4.3.5 < /dev/null > /dev/null
sudo killall uml_switch < /dev/null > /dev/null
sudo fuser -k /var/run/uml-utilities/uml_switch.ctl < /dev/null > /dev/null
echo '[OK]'
echo

echo '# Checking TAP interface ... '
echo
echo 'interface: tap0'
sudo ifconfig tap0 | grep -w inet | awk {'print $2'} # Print IP address
sudo ifconfig tap0 | grep -w inet | awk {'print $4'} # Print netmask
echo

echo '[OK]'
echo

# Creating the switches
echo
echo 'Creating Switchs ...'
uml_switch -unix ./switch-tap -tap tap0 < /dev/null > /dev/null &

echo '[ok]'

# Starting UML`s in multi-tab mode ...
echo '# Starting UML uml-A0 ...'
gnome-terminal --tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:ee,unix,./switch-tap \
umid=uml-A0 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-A0.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-A0.cow,../emptyfs.swap > /dev/null" \ &
echo '[OK]'
echo
