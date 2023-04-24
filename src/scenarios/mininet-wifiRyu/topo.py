#!/usr/bin/python
# -*- coding: utf-8 -*-

from mn_wifi.net import Mininet_wifi
from mn_wifi.node import RemoteController
from mininet.log import setLogLevel, info
from mn_wifi.cli import CLI


def scenario_basic():

    net = Mininet_wifi()

    info("*** Creating nodes\n")
    
    

    info('*** Add Controller (Ryu) ***\n')
    c0 = net.addController( name = 'c0',
                            controller = RemoteController,
                            ip = '192.168.56.3',
                            protocol = 'tcp',
                            port = 6633)

    info('*** Add one UserAP ***\n')
    ap1 = net.addAccessPoint('ap1', mac='00:00:00:00:00:01',position='50,50,0')


    info('*** Add two WiFi stations ***\n')
    sta1 = net.addStation('sta1', mac='00:00:00:00:00:02', ip='10.0.0.1/8', position='30,60,0')
    sta2 = net.addStation('sta2', mac='00:00:00:00:00:03', ip='10.0.0.2/8', position='70,30,0')


    info("*** Configuring nodes\n")
    net.configureNodes()
    
    info('*** Add links ***\n')
    net.addLink(sta1, ap1)
    net.addLink(sta2, ap1)

    info('\n*** Build it ***\n')
    net.build()

    info('*** Start the controller ***\n')
    for controller in net.controllers:
        controller.start()

    info('*** Set controllers ***\n')
    net.get('ap1').start([c0])

    info('*** RUN Mininet-Wifis CLI ***\n')
    CLI(net)

    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    scenario_basic()