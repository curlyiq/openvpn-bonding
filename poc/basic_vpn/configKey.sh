#!/bin/bash

client="vk"

mkdir ./out/keys
currentDir=$(pwd)

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


# Create the DH parameters file using the predefined ffdhe2048 group
	echo '-----BEGIN DH PARAMETERS-----
	MIIBCAKCAQEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
	+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
	87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
	YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
	7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
	ssbzSibBsu/6iGtCOGEoXJf//////////wIBAg==
	-----END DH PARAMETERS-----' > /etc/openvpn/server/dh.pem

# Move Keys to out folder to create client ovpn file
cd $currentDir
cp /etc/openvpn/server/*.crt ./out/keys/.
cp /etc/openvpn/server/*.key ./out/keys/.
cp /etc/openvpn/server/*.pem ./out/keys/.


