#!/bin/bash

numberOfTunnels=1
for counter in `seq 1 $numberOfTunnels`;
do
  systemctl stop openvpn-iptables${counter}.service
  systemctl stop openvpn-server@server${counter}.service
done
