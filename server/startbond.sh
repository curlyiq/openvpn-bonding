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
. /etc/openvpn/commonConfig

# load the required module

# the bond interface

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


# now find the WAN interface

export OUR_OWN_IP=`sudo -u nobody curl -s ipinfo.io/ip`
readarray -d " " -t templine <<< $(ip -br addr | grep $OUR_OWN_IP)
export OUR_WAN_INTERFACE=${templine[0]}

#readarray -t templine <<< $(ip -br addr | grep $OUR_OWN_IP)
#temp=$(echo $templine[0] | awk '{print $1}')
#export OUR_WAN_INTERFACE=$temp

# now add the masquerading rules

iptables -A FORWARD -i bond0 -j ACCEPT
iptables -A FORWARD -o bond0 -j ACCEPT
iptables -t nat -A POSTROUTING -o $OUR_WAN_INTERFACE -j MASQUERADE
