#!/bin/bash

# Vars
AP_SSID='new-ssid'
AP_MAC='00:00:00:00:00:01'
STA_2_CONN=('sta1' 'sta2')

# Create UserAP
echo '[+] Lanch UserAP config'
hwsim_mgmt -c -n intfUserAP
ip link set wlan0 down
ip link set wlan0  name ap1-wlan1
ip link set ap1-wlan1 down 
ip link set ap1-wlan1 up
ethtool -K ap1-wlan1 gro off 
ip link set ap1-wlan1 down 
ip link set ap1-wlan1 address ${AP_MAC}
ip link set ap1-wlan1 up
iw ap1-wlan1 set txpower fixed 100
echo -e "interface=ap1-wlan1\ndriver=nl80211\nssid=${AP_SSID}\nwds_sta=1\nhw_mode=g\nchannel=1\nctrl_interface=/var/run/hostapd\nctrl_interface_group=0" > mn43736_ap1-wlan1.apconf
hostapd -B mn43736_ap1-wlan1.apconf
ip link set ap1-wlan1 down 
ip link set ap1-wlan1 address ${AP_MAC}
ip link set ap1-wlan1 up
tc qdisc replace dev ap1-wlan1 root handle 2: netem rate 54.0000mbit latency 1.00ms
tc qdisc add dev ap1-wlan1 parent 2:1 handle 10: pfifo limit 1000
iw dev ap1-wlan1 set txpower fixed 1400

# Connect stations to AP
for sta in ${STA_2_CONN[@]}
do
    echo "[+] Connecting ${sta} to UserAP"
    PID_STA=$(ps aux | grep mininet | grep ${sta} | cut -d' ' -f7)
    echo "[+] ${sta} - Detected pid ${PID_STA}"
    nsenter --target ${PID_STA} --net iwconfig ${sta}-wlan0 essid ${AP_SSID} ap ${AP_MAC}
done
