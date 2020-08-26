#!/bin/bash

# Load properties from commonConfig file
numberOfTunnels=1
natIP=  # Internal IP
externalIP=
devType=tun
#devType=tap
devIPBase="10.8.0"
devIP="${devIPBase}.0"
devPort="119"  # Base port for dev interface. Counter will add the last digit
devMask="255.255.255.0"
client="vk"

# Local Directory
mkdir ./out
mkdir ./out/servers

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
#openvpn --genkey --secret ./out/ta.key

# Firewall iptables service
for counter in `seq 1 $numberOfTunnels`;
do
 iptablesServiceFile=./out/servers/openvpn-iptables${counter}.service
 cp ./openvpn-iptables.service.template $iptablesServiceFile
 sed -i s/@natIP/"${natIP}"/g $iptablesServiceFile
 sed -i s/@devIP/"${devIP}"/g    $iptablesServiceFile
 sed -i s/@devPort/"${devPort}${counter}"/g    $iptablesServiceFile
done

# OpenVPN Server Config file
for counter in `seq 1 $numberOfTunnels`;
do
	vpnConfigFile=./out/servers/server${counter}.conf
	cp ./server.conf.template $vpnConfigFile
	sed -i s/@natIP/"${natIP}"/g          		$vpnConfigFile
	sed -i s/@devType/"${devType}${counter}"/g	$vpnConfigFile
	sed -i s/@devIP/"${devIP}"/g			$vpnConfigFile
	sed -i s/@devMask/"${devMask}"/g	 	$vpnConfigFile
	sed -i s/@devPort/${devPort}${counter}/g 	$vpnConfigFile
done













































