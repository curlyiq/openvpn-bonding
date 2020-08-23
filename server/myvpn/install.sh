#!/bin/bash

# #############################################
#
# install.sh - run as root.
#
# installs openvpn, openssl, bonding
# drivers and also bridge-utils
#
# creates a secret key
# creates 4 server configs with tap BONDING
#
# #############################################

# the script needs to be called from the directory where
# the commonConfig file and the start/stop bridge files 
# are located

. commonConfig

# first install the necessary software

apt update && apt -y install openvpn openssl bridge-utils sed
#yum  update 
#sudo yum install -y epel-release
#sudo yum update -y # why twice - suggest on some website
#yum -y install openvpn openssl bridge-utils sed
# mkdir -p /etc/openvpn/certs

#cp commonConfig   /etc/openvpn
#cp startbond.sh /etc/openvpn
#cp stopbond.sh  /etc/openvpn


# now create a config file for each server instance 

for counter in `seq 1 $numberOfTunnels`;
do
    # the config files will be called server1.conf, server2.conf aso

    vpnConfigFile=/etc/openvpn/server/server${counter}.conf
    cp config/server.conf.template $vpnConfigFile

    # now we just replace the placeholders in the template file
    # @tap is replaced with tap0, tap1 etc.

    sed -i s/@dev/tap${counter}/g          $vpnConfigFile

    # we dont need ip addresses for the tap interfaces as they are bridged

    sed -i s/@ip/"${ipTrunk}.${counter}"/g $vpnConfigFile
    sed -i s/@mask/$ipMask/g $vpnConfigFile

    # we replace the @port placeholder with ports 1191, 1192, 1193 and so on

    sed -i s/@port/119${counter}/g $vpnConfigFile

    # enable the corresponding system unit

    systemctl enable openvpn-server@server${counter}.service
done

# enable ip4 forwarding with sysctl
sysctl -w net.ipv4.ip_forward=1

# --- print out the content of sysctl.conf
sysctl -p


# we will not use TLS etc. for this exercise but rather simple
# secret key authentication
# we only generate a new key if none is present.
# if a ta.key exists, we will use the existing one

cp ~/openvpn-bonding/ta.key /etc/openvpn/.
