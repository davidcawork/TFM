#!/usr/bin/python
# -*- coding: utf-8 -*-

from mininet.net import Mininet
from mininet.node import RemoteController
from mininet.node import CPULimitedHost, Host
from mininet.node import UserSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink


def scenario_basic():
    net = Mininet(  topo = None,
                    build = False,
                    host = CPULimitedHost,
                    link = TCLink,
                    ipBase = '10.0.0.0/8')

    info('*** Add Controller (Onos) ***\n')
    c0 = net.addController( name = 'c0',
                            controller = RemoteController,
                            ip = '192.168.56.3',
                            protocol = 'tcp',
                            port = 6633)

    info('*** Add two switchs ***\n')
    s1 = net.addSwitch('s1', cls = UserSwitch)
    s2 = net.addSwitch('s2', cls = UserSwitch)


    info('*** Add Host ***\n')
    h1 = net.addHost('h1', cls = Host, ip = '10.0.0.1', defaultRoute = None)
    h2 = net.addHost('h2', cls = Host, ip = '10.0.0.2', defaultRoute = None)
    h3 = net.addHost('h3', cls = Host, ip = '10.0.0.3', defaultRoute = None)
    h4 = net.addHost('h4', cls = Host, ip = '10.0.0.4', defaultRoute = None)


    info('*** Add links ***\n')
    net.addLink(s1, h1, bw = 10)
    net.addLink(s1, h2, bw = 10)
    net.addLink(s1, s2, bw = 5, max_queue_size = 500)
    net.addLink(s2, h3, bw = 10)
    net.addLink(s2, h4, bw = 10)
  

    info('\n*** Build it ***\n')
    net.build()

    info('*** Start the controller ***\n')
    for controller in net.controllers:
        controller.start()

    info('*** Set controllers ***\n')
    net.get('s2').start([c0])
    net.get('s1').start([c0])

    info('*** RUN Mininet\'s CLI ***\n')
    CLI(net)

    net.stop()

if __name__ == '__main__':
    setLogLevel('info')
    scenario_basic()