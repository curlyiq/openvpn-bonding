#!/bin/bash
numberOfTunnels=1

cp ./out/ta.key /etc/openvpn/ta.key
# Start and Enable Services
for counter in `seq 1 $numberOfTunnels`;
do
 cp ./out/clients/client${counter}.conf /ect/openvpn/client/.
 openvpn --daemon --config /ect/openvpn/client/client${counter}.conf
done
