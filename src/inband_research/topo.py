#!/usr/bin/python
# -*- coding: utf-8 -*-

from mn_wifi.net import Mininet_wifi
from mininet.node import RemoteController
from mn_wifi.node import UserAP
from mininet.log import setLogLevel, info
from mn_wifi.cli import CLI


def scenario_basic():
    net = Mininet_wifi(accessPoint=UserAP)

    info("*** Creating nodes\n")

    info("*** Add Controller (Ryu) ***\n")
    c0 = net.addController(
        name="c0",
        controller=RemoteController,
        ip="localhost",
        protocol="tcp",
        port=6633,
    )

    info("*** Add two WiFi stations ***\n")
    sta1 = net.addStation(
        "sta1", mac="00:00:00:00:00:02", ip="10.0.0.1/8", position="20,40,0", range=10
    )
    sta2 = net.addStation(
        "sta2", mac="00:00:00:00:00:03", ip="10.0.0.2/8", position="80,40,0", range=10
    )

    info("*** Configuring nodes\n")
    net.configureNodes()

    info("\n*** Build it ***\n")
    net.build()

    info("*** Start the controller ***\n")
    for controller in net.controllers:
        controller.start()

    info("*** RUN Mininet-Wifis CLI ***\n")
    CLI(net)

    net.stop()


if __name__ == "__main__":
    setLogLevel("debug")
    scenario_basic()
