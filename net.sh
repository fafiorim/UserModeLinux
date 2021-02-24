#!/bin/bash
#
# This script was created to demonstrate how interact with a micro network topology using
# User Mode Linux to create other GNU/Linux machines and configure them as a
# LAN environment.
#
#	by:Franzvitor Fiorim
#	date: September 10, 2017

echo 1 >/proc/sys/net/ipv4/ip_forward

tunctl -u trendmicro -t tap0

ifconfig tap0 10.1.0.1 netmask 255.255.255.252 up

echo '# Configured interface: '
echo
echo 'interface: tap0'
sudo ifconfig tap0 | grep -w inet | awk {'print $2'}
sudo ifconfig tap0 | grep -w inet | awk {'print $4'}
echo

echo '[OK]'
echo
iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE
