#!/bin/bash
numberOfTunnels=1

cp ./out/ta.key /etc/openvpn/ta.key
# Start and Enable Services
for counter in `seq 1 $numberOfTunnels`;
do
 cp ./out/servers/openvpn-iptables${counter}.service /etc/systemd/system/.
 cp ./out/servers/server${counter}.conf /ect/openvpn/server/.
 systemctl enable --now openvpn-iptables${counter}.service
 systemctl enable --now openvpn-server@server${counter}.service
done
