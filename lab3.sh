#!/bin/bash
#
# This script was created to demonstrate how interact with a micro network topology using
# User Mode Linux to create other GNU/Linux machines and configure them as a
# LAN environment.
#
#	by:Franzvitor Fiorim
#	date: September 10, 2017
#	updated: October 16, 2020

# Before execute this script
#
# Before execute this script you will need to execute the net.sh script that
# is locate in ../utils diretory
#

# Logic topology
#
#
#   [UML-C1]        [UML-C2]                         [UML-D1]         [UML-D2]
#     |                 |                                |                 |
#     |________ ________|                                |________ ________|
#              |                                                  |
#              |                                                  |
#              |                                                  |
#         [Router C]------------------[Router 3]-------------[Router D]
#                                         |
#                                         |
#                                         |
#                                         |								 [UML-2X2]
#                                         |									 |
#                                         |									 |
#		------------------------------[Router 2]------------------------------
#		|								  |
#		|								  |									 
#	[UML-2X1]							  |
#                                         |
#                                         |
#                                         |
#           [Router A]----------------[Router 1]---------------[Router B]
#               |                         |                        |
#               |                         |                        |
#       ________|________                 |                ________|________
#      |                 |                |               |                 |
#      |                 |                |               |                 |
#   [UML-A1]         [UML-A2]             |           [UML-B1]          [UML-B2]
#                                         |
#                                         |
#                                     [ HOST ]
#
#

echo
echo '#------------------[ Starting user: ((( '$USER' ))) ]------------------#'
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
echo 'tap0'
sudo ifconfig tap0 | grep -w inet | awk {'print $2'} # print IP address
sudo ifconfig tap0 | grep -w inet | awk {'print $4'} # print netmask
echo

echo '[OK]'
echo

# Creating the switches
echo
echo 'Creating Switchs ...'
uml_switch -unix ./switch-tap -tap tap0 < /dev/null > /dev/null &
uml_switch -unix ./switch-R1_R2 < /dev/null > /dev/null &
uml_switch -unix ./switch-R1_RA < /dev/null > /dev/null &
uml_switch -unix ./switch-R1_RB < /dev/null > /dev/null &
uml_switch -unix ./switch-RA_uml-A1-A2 < /dev/null > /dev/null &
uml_switch -unix ./switch-RB_uml-B1-B2 < /dev/null > /dev/null &
uml_switch -unix ./switch-R2_R3 < /dev/null > /dev/null &
uml_switch -unix ./switch-R2_UML-2X1 < /dev/null > /dev/null &
uml_switch -unix ./switch-R2_UML-2X2 < /dev/null > /dev/null &
uml_switch -unix ./switch-R3_RC < /dev/null > /dev/null &
uml_switch -unix ./switch-R3_RD < /dev/null > /dev/null &
uml_switch -unix ./switch-RC_uml-C1-C2 < /dev/null > /dev/null &
uml_switch -unix ./switch-RD_uml-D1-D2 < /dev/null > /dev/null &

echo '[ok]'

# Starting UML`s in multi-tab mode ...
echo '# Starting UMLs ...'
gnome-terminal --tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:ee,unix,./switch-tap \
eth1=daemon,cc:00:ff:ff:ee:01,unix,./switch-R1_R2 \
eth2=daemon,cc:00:ff:ff:ee:02,unix,./switch-R1_RA \
eth3=daemon,cc:00:ff:ff:ee:03,unix,./switch-R1_RB \
umid=R1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./R1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-R1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:04,unix,./switch-R1_RA \
eth1=daemon,cc:00:ff:ff:ee:05,unix,./switch-RA_uml-A1-A2 \
umid=RA \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./RA.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-RA.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:06,unix,./switch-R1_RB \
eth1=daemon,cc:00:ff:ff:ee:07,unix,./switch-RB_uml-B1-B2 \
umid=RB \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./RB.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-RB.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:08,unix,./switch-RA_uml-A1-A2 \
umid=uml-A1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-A1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-A1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:09,unix,./switch-RA_uml-A1-A2 \
umid=uml-A2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-A2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-A2.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:10,unix,./switch-RB_uml-B1-B2 \
umid=uml-B1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-B1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-B1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:ee:11,unix,./switch-RB_uml-B1-B2 \
umid=uml-B2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-B2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-B2.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ee:02:01,unix,./switch-R1_R2 \
eth1=daemon,cc:00:ff:ee:02:02,unix,./switch-R2_R3 \
eth2=daemon,cc:00:ff:ee:02:03,unix,./switch-R2_UML-2X1 \
eth3=daemon,cc:00:ff:ee:02:04,unix,./switch-R2_UML-2X2 \
umid=R2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./R2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-R2.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:02:05,unix,./switch-R2_UML-2X1 \
umid=uml-2X1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-2X1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-2X1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:02:06,unix,./switch-R2_UML-2X2 \
umid=uml-2X2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-2X2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-2X2.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ee:03:01,unix,./switch-R2_R3 \
eth1=daemon,cc:00:ff:ee:03:02,unix,./switch-R3_RC \
eth2=daemon,cc:00:ff:ee:03:03,unix,./switch-R3_RD \
umid=R3 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./R3.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-R3.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:03:03,unix,./switch-R3_RC \
eth1=daemon,cc:00:ff:ff:03:04,unix,./switch-RC_uml-C1-C2 \
umid=RC \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./RC.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-RC.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:03:05,unix,./switch-R3_RD \
eth1=daemon,cc:00:ff:ff:03:06,unix,./switch-RD_uml-D1-D2 \
umid=RD \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./RD.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-RD.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:03:07,unix,./switch-RC_uml-C1-C2 \
umid=uml-C1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-C1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-C1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:03:08,unix,./switch-RC_uml-C1-C2 \
umid=uml-C2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-C2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-C2.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:03:09,unix,./switch-RD_uml-D1-D2 \
umid=uml-D1 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-D1.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-D1.cow,../emptyfs.swap > /dev/null" \
--tab-with-profile=default \
--command "../utils/kernel64-4.3.5 \
mode=skas0 \
eth0=daemon,cc:00:ff:ff:03:10,unix,./switch-RD_uml-D1-D2 \
umid=uml-D2 \
mem=128M \
xterm=gnome-terminal,-t,-x con=null con0=fd:0,fd:1 \
ubd0=./uml-D2.cow,../utils/CentOS6.x-AMD64-root_fs \
ubd1=./swap32-uml-D2.cow,../emptyfs.swap > /dev/null" \ &
echo '[OK]'
echo
