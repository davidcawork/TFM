*** errRun: ['grep', '-c', 'processor', '/proc/cpuinfo'] 
4
  0*** Setting resource limits
*** Creating nodes
*** Add Controller (Ryu) ***
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ifconfig'] 
/usr/sbin/ifconfig
  0_popen ['mnexec', '-cd', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:c0'] 43743*** c0 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
*** c0 : ('echo A | telnet -e A localhost 6633',)
Telnet escape character is 'A'.
Trying 127.0.0.1...
telnet: Unable to connect to remote host: Connection refused
Unable to contact the remote controller at localhost:6633
*** Add one UserAP ***
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ip', 'addr'] 
/usr/sbin/ip
  1_popen ['mnexec', '-cd', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:ap1'] 43749*** ap1 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m

added intf lo (0) to node ap1
*** ap1 : ('ifconfig', 'lo', 'up')
*** errRun: ['which', 'ofdatapath'] 
/usr/local/bin/ofdatapath
  0*** errRun: ['which', 'ofprotocol'] 
/usr/local/bin/ofprotocol
  0*** Add two WiFi stations ***
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ip', 'addr'] 
/usr/sbin/ip
  1_popen ['mnexec', '-cdn', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:sta1'] 43756*** sta1 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
_popen ['mnexec', '-cdn', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:sta2'] 43758*** sta2 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
*** Configuring nodes
Loading 3 virtual wifi interfaces
Created mac80211_hwsim device with ID 0
Created mac80211_hwsim device with ID 1
Created mac80211_hwsim device with ID 2
rfkill unblock 2
*** sta1 : ('ip link set wlan0 down',)
*** sta1 : ('ip link set wlan0 name sta1-wlan0',)
rfkill unblock 3
*** sta2 : ('ip link set wlan1 down',)
*** sta2 : ('ip link set wlan1 name sta2-wlan0',)
*** ap1 : ('ip link set wlan2 down',)
*** ap1 : ('ip link set wlan2 name ap1-wlan1',)
*** ap1 : ('ip link set ap1-wlan1 up',)

added intf sta1-wlan0 (0) to node sta1
*** sta1 : ('ip link set', 'sta1-wlan0', 'down')
*** sta1 : ('ip link set', 'sta1-wlan0', 'address', '00:00:00:00:00:02')
*** sta1 : ('ip link set', 'sta1-wlan0', 'up')
*** sta1 : ('ip addr flush ', 'sta1-wlan0')
*** sta1 : ('ip addr add 10.0.0.1/8 brd + dev sta1-wlan0 && ip -6 addr add 2001:0:0:0:0:0:0:1/64 dev sta1-wlan0',)
*** sta1 : ('ip -6 addr flush ', 'sta1-wlan0')
*** sta1 : ('ip -6 addr add', '2001:0:0:0:0:0:0:1/64', 'dev', 'sta1-wlan0')
*** sta1 : ('ip link set lo up',)

added intf sta2-wlan0 (0) to node sta2
*** sta2 : ('ip link set', 'sta2-wlan0', 'down')
*** sta2 : ('ip link set', 'sta2-wlan0', 'address', '00:00:00:00:00:03')
*** sta2 : ('ip link set', 'sta2-wlan0', 'up')
*** sta2 : ('ip addr flush ', 'sta2-wlan0')
*** sta2 : ('ip addr add 10.0.0.2/8 brd + dev sta2-wlan0 && ip -6 addr add 2001:0:0:0:0:0:0:2/64 dev sta2-wlan0',)
*** sta2 : ('ip -6 addr flush ', 'sta2-wlan0')
*** sta2 : ('ip -6 addr add', '2001:0:0:0:0:0:0:2/64', 'dev', 'sta2-wlan0')
*** sta2 : ('ip link set lo up',)

added intf ap1-wlan1 (1) to node ap1
*** ap1 : ('ip link set', 'ap1-wlan1', 'up')
*** ap1 : ('ethtool -K', <WirelessLink ap1-wlan1>, 'gro', 'off')
*** ap1 : ('ip link set', 'ap1-wlan1', 'down')
*** ap1 : ('ip link set', 'ap1-wlan1', 'address', '00:00:00:00:00:01')
*** ap1 : ('ip link set', 'ap1-wlan1', 'up')
*** sta1 : ('iw dev', 'sta1-wlan0 set txpower fixed 100')
*** sta1-wlan0: the signal range should be changed to (at least) 116m
*** >>> See https://mininet-wifi.github.io/faq/#q7 for more information
*** sta2 : ('iw dev', 'sta2-wlan0 set txpower fixed 100')
*** sta2-wlan0: the signal range should be changed to (at least) 116m
*** >>> See https://mininet-wifi.github.io/faq/#q7 for more information
*** ap1 : ('iw dev', 'ap1-wlan1 set txpower fixed 100')
*** ap1-wlan1: the signal range should be changed to (at least) 116m
*** >>> See https://mininet-wifi.github.io/faq/#q7 for more information
*** ap1 : ("echo 'interface=ap1-wlan1\ndriver=nl80211\nssid=new-ssid\nwds_sta=1\nhw_mode=g\nchannel=1\nctrl_interface=/var/run/hostapd\nctrl_interface_group=0' > mn43736_ap1-wlan1.apconf",)
> > > > > > > *** ap1 : ('hostapd -B mn43736_ap1-wlan1.apconf ',)
ap1-wlan1: interface state UNINITIALIZED->ENABLED
ap1-wlan1: AP-ENABLED 
*** ap1 : ('ip link set', 'ap1-wlan1', 'down')
*** ap1 : ('ip link set', 'ap1-wlan1', 'address', '00:00:00:00:00:01')
*** ap1 : ('ip link set', 'ap1-wlan1', 'up')
_popen ['mnexec', '-da', '43749', 'tc', 'qdisc', 'replace', 'dev', 'ap1-wlan1', 'root', 'handle', '2:', 'netem', 'rate', '54.0000mbit', 'latency', '1.00ms'] 43921*** ap1 : ('tc qdisc add dev ap1-wlan1 parent 2:1 handle 10: pfifo limit 1000',)
*** sta1 : ('iw dev', 'sta1-wlan0 set txpower fixed 100')
*** sta2 : ('iw dev', 'sta2-wlan0 set txpower fixed 100')
*** ap1 : ('iw dev', 'ap1-wlan1 set txpower fixed 100')
*** Add links ***

added intf sta1-wlan0 (0) to node sta1
*** sta1 : ('ip link set', 'sta1-wlan0', 'up')
*** sta1 : ('ethtool -K', <WirelessLink sta1-wlan0>, 'gro', 'off')
 *** executing command: tc qdisc show dev sta1-wlan0
*** sta1 : ('tc qdisc show dev sta1-wlan0',)
qdisc mq 0: root 
qdisc fq_codel 0: parent :4 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc fq_codel 0: parent :3 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc fq_codel 0: parent :2 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
at map stage w/cmds: ['%s qdisc add dev %s root handle 5:0 htb default 1', '%s class add dev %s parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k']
 *** executing command: tc qdisc add dev sta1-wlan0 root handle 5:0 htb default 1
*** sta1 : ('tc qdisc add dev sta1-wlan0 root handle 5:0 htb default 1',)
 *** executing command: tc class add dev sta1-wlan0 parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k
*** sta1 : ('tc class add dev sta1-wlan0 parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k',)
cmds: ['%s qdisc add dev %s root handle 5:0 htb default 1', '%s class add dev %s parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k'] 
outputs: ['', ''] 
_popen ['mnexec', '-da', '43756', 'iwconfig', 'sta1-wlan0', 'essid', 'new-ssid', 'ap', '00:00:00:00:00:01'] 43933_popen ['mnexec', '-da', '43756', 'tc', 'qdisc', 'replace', 'dev', 'sta1-wlan0', 'root', 'handle', '2:', 'netem', 'rate', '8.0307mbit', 'latency', '1.58ms'] 43934
added intf sta2-wlan0 (0) to node sta2
*** sta2 : ('ip link set', 'sta2-wlan0', 'up')
*** sta2 : ('ethtool -K', <WirelessLink sta2-wlan0>, 'gro', 'off')
 *** executing command: tc qdisc show dev sta2-wlan0
*** sta2 : ('tc qdisc show dev sta2-wlan0',)
qdisc mq 0: root 
qdisc fq_codel 0: parent :4 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc fq_codel 0: parent :3 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc fq_codel 0: parent :2 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514 target 5ms interval 100ms memory_limit 32Mb ecn drop_batch 64 
at map stage w/cmds: ['%s qdisc add dev %s root handle 5:0 htb default 1', '%s class add dev %s parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k']
 *** executing command: tc qdisc add dev sta2-wlan0 root handle 5:0 htb default 1
*** sta2 : ('tc qdisc add dev sta2-wlan0 root handle 5:0 htb default 1',)
 *** executing command: tc class add dev sta2-wlan0 parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k
*** sta2 : ('tc class add dev sta2-wlan0 parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k',)
cmds: ['%s qdisc add dev %s root handle 5:0 htb default 1', '%s class add dev %s parent 5:0 classid 5:1 htb rate 11.000000Mbit burst 15k'] 
outputs: ['', ''] 
_popen ['mnexec', '-da', '43758', 'iwconfig', 'sta2-wlan0', 'essid', 'new-ssid', 'ap', '00:00:00:00:00:01'] 43940_popen ['mnexec', '-da', '43758', 'tc', 'qdisc', 'replace', 'dev', 'sta2-wlan0', 'root', 'handle', '2:', 'netem', 'rate', '8.0307mbit', 'latency', '1.58ms'] 43941*** Plot he network ***

*** Build it ***
*** Configuring nodes
Enabling Graph...
_popen ['mnexec', '-da', '43756', 'tc', 'qdisc', 'replace', 'dev', 'sta1-wlan0', 'root', 'handle', '2:', 'netem', 'rate', '8.0307mbit', 'latency', '1.58ms'] 43943_popen ['mnexec', '-da', '43758', 'tc', 'qdisc', 'replace', 'dev', 'sta2-wlan0', 'root', 'handle', '2:', 'netem', 'rate', '8.0307mbit', 'latency', '1.58ms'] 43944
added intf sta1-wlan0 (0) to node sta1
*** sta1 : ('ip link set', 'sta1-wlan0', 'up')
*** sta1 : ('ethtool -K', <WirelessLink sta1-wlan0>, 'gro', 'off')

added intf sta2-wlan0 (0) to node sta2
*** sta2 : ('ip link set', 'sta2-wlan0', 'up')
*** sta2 : ('ethtool -K', <WirelessLink sta2-wlan0>, 'gro', 'off')
*** Start the controller ***
*** Set controllers ***
*** ap1 : ('ofdatapath -i ap1-wlan1 punix:/tmp/ap1 -d 100000000001 --no-slicing 1> /tmp/ap1-ofd.log 2> /tmp/ap1-ofd.log &',)
*** ap1 : ('ofprotocol unix:/tmp/ap1 tcp:localhost:6633 --fail=closed  --listen=punix:/tmp/ap1.listen 1> /tmp/ap1-ofp.log 2>/tmp/ap1-ofp.log &',)
*** RUN Mininet-Wifis CLI ***
*** Starting CLI:
*** errRun: ['stty', 'echo', 'sane', 'intr', '^C'] 