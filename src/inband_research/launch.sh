#!/bin/bash

echo '[+] Lanch UserAP config'
hwsim_mgmt -c -n intfUserAP
ip link set wlan0 down
ip link set wlan0  name ap1-wlan1
ip link set ap1-wlan1 down 
ip link set ap1-wlan1 up
ethtool -K ap1-wlan1 gro off 
ip link set ap1-wlan1 down 
ip link set ap1-wlan1 address 00:00:00:00:00:01
ip link set ap1-wlan1 up
iw ap1-wlan1 set txpower fixed 100
echo -e 'interface=ap1-wlan1\ndriver=nl80211\nssid=new-ssid\nwds_sta=1\nhw_mode=g\nchannel=1\nctrl_interface=/var/run/hostapd\nctrl_interface_group=0' > mn43736_ap1-wlan1.apconf
hostapd -B mn43736_ap1-wlan1.apconf
ip link set ap1-wlan1 down 
ip link set ap1-wlan1 address 00:00:00:00:00:01
ip link set ap1-wlan1 up
tc qdisc replace dev ap1-wlan1 root handle 2: netem rate 54.0000mbit latency 1.00ms
tc qdisc add dev ap1-wlan1 parent 2:1 handle 10: pfifo limit 1000
iw dev ap1-wlan1 set txpower fixed 100
ofdatapath -i ap1-wlan1 punix:/tmp/ap1 -d 100000000001 --no-slicing 1> /tmp/ap1-ofd.log 2> /tmp/ap1-ofd.log &
ofprotocol unix:/tmp/ap1 tcp:localhost:6633 --fail=closed  --listen=punix:/tmp/ap1.listen 1> /tmp/ap1-ofp.log 2>/tmp/ap1-ofp.log &