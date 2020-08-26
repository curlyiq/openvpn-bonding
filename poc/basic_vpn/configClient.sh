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
client="vk"

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


mergeCert () {
		echo "<ca>"
		cat /etc/openvpn/server/easy-rsa/pki/ca.crt
		echo "</ca>"
		echo "<cert>"
		sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt
		echo "</cert>"
		echo "<key>"
		cat /etc/openvpn/server/easy-rsa/pki/private/"$client".key
		echo "</key>"
		echo "<tls-crypt>"
		sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
		echo "</tls-crypt>"
	} > ./out/clients/mergedCert.txt
echo " ============================================================="
mergeCert

# Firewall iptables service
for counter in `seq 1 $numberOfTunnels`;
do
 clientConfigFile=./out/clients/client${counter}.conf
 cp ./client.conf.template $clientConfigFile 
 sed -i s/@devType/"${devType}${counter}"/g $clientConfigFile
 sed -i s/@externalIP/"${externalIP}"/g $clientConfigFile
 sed -i s/@devPort/"${devPort}${counter}"/g   $clientConfigFile

# keys
sed -i '/#mycerts/ r ./out/clients/mergedCert.txt' $clientConfigFile
cp $clientConfigFile ./vk.ovpn
done


