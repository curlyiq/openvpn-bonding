#!/bin/bash

# #############################################
#
# startbond.sh
#
# creates multiple tap devices
# and bonds them together
#
# #############################################

# include the common settings
. commonConfig

# load the required module


for i in `seq 1 $numberOfTunnels`;
do
    openvpn --mktun --dev tap${i}
done

# then start the VPN connections

for i in `seq 1 $numberOfTunnels`;
do
    systemctl start openvpn-server@server${i}.service
done

# last but not least bring up the bonded interface

# now add the masquerading rules

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
