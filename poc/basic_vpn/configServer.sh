#!/bin/bash

# Load properties from commonConfig file
numberOfTunnels=1
natIP=  # Internal IP
externalIP=
#devType=tun
devType=tap
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

# Get easy-rsa
easy_rsa_url='https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz'
mkdir -p /etc/openvpn/server/easy-rsa/
{ wget -qO- "$easy_rsa_url" 2>/dev/null || curl -sL "$easy_rsa_url" ; } | tar xz -C /etc/openvpn/server/easy-rsa/ --strip-components 1
chown -R root:root /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/server/easy-rsa/
# Create the PKI, set up the CA and the server and client certificates
./easyrsa init-pki
./easyrsa --batch build-ca nopass
EASYRSA_CERT_EXPIRE=3650 ./easyrsa build-server-full server nopass
EASYRSA_CERT_EXPIRE=3650 ./easyrsa build-client-full "$client" nopass
EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
# Move the stuff we need
cp pki/ca.crt pki/private/ca.key pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn/server
# CRL is read with each client connection, while OpenVPN is dropped to nobody
chown nobody:"$group_name" /etc/openvpn/server/crl.pem
# Without +x in the directory, OpenVPN can't run a stat() on the CRL file
chmod o+x /etc/openvpn/server/
# Generate key for tls-crypt
openvpn --genkey --secret /etc/openvpn/server/tc.key












































