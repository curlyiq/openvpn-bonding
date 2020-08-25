#!/bin/bash

# Load properties from commonConfig file
numberOfTunnels=1
natIP=  # Internal IP
externalIP=
devType=tun
devIPBase="10.8.0"
devIP="${devIPBase}.0"
devPort="119"  # Base port for dev interface. Counter will add the last digit
devMask="255.255.255.0"

# Local Directory
mkdir ./out
mkdir ./out/clients

# Install Softwares
apt update
apt install -y openvpn openssl ca-certificates iptables
apt install -y bridge-utils # ??

# IP Address (Server with ONE internal ip  address)
natIP=$(hostname -i)
#natIP=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}')
externalIP=$(curl -s ipinfo.io/ip)

# Routing - Forwarding
sysctl -w net.ipv4.ip_forward=1  # enable ip4 forwarding

# Keys
openvpn --genkey --secret ./out/ta.key

# Firewall iptables service
for counter in `seq 1 $numberOfTunnels`;
do
 clientConfigFile=./out/clients/client${counter}.conf
 cp ./client.conf.template $clientConfigFile 
 sed -i s/@devType/"${devType}"/g $clientConfigFile
 sed -i s/@externalIP/"${externalIP}"/g $clientConfigFile
 sed -i s/@devPort/"${devPort}${counter}"/g    $iptablesServiceFile
done


