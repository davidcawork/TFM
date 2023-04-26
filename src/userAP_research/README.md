# UserAP research

Sobre la máquina personal de trabajo, hemos instalado Mininet-Wifi y Ryu para tener las herramientas necesarias para investigar como trabaja UserAP a bajo nivel.


## Información de la máquina

**LSB Relase**

```bash 
arppath@arppath-david:~/tfm_test/TFM/src/userAP_research$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.2 LTS
Release:        22.04
Codename:       jammy
```

**Kernel version** 

```bash
arppath@arppath-david:~/tfm_test/TFM/src/userAP_research$ uname -a 
Linux arppath-david 5.19.0-38-generic #39~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Mar 17 21:16:15 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
```

## Escenario

Bueno una vez que tenemos instalado MIninet-wifi vamos a programar un script en Python para automatizar el despliegue de la topología. Cosas importantes:

*    Los APs tienen que ser de la clase `UserAP` la cual es la encargada de hacer de wrapper de el BOFUSS.
*    El controller por defecto lo haremos `RemoteController` para que así podamos poner uno y quitarlo, y meter un ONOS que pesa más. En este caso trabajaremos con Ryu que pesa menos. (Spoiler solo tengo 4 GBs en la máquina de trabajo :joy:)
*    Las posiciones me dan igual, y los rangos me dan más igual, quiero que haya conectividad `STA1 <--> AP1 <--> STA2`.

A continuación dejo el script en python de la topología, `topo.py`:

```python=
#!/usr/bin/python
# -*- coding: utf-8 -*-

from mn_wifi.net import Mininet_wifi
from mininet.node import RemoteController
from mn_wifi.node import UserAP
from mininet.log import setLogLevel, info
from mn_wifi.cli import CLI


def scenario_basic():

    net = Mininet_wifi(accessPoint= UserAP)

    info("*** Creating nodes\n")
    
    info('*** Add Controller (Ryu) ***\n')
    c0 = net.addController( name = 'c0',
                            controller = RemoteController,
                            ip = 'localhost',
                            protocol = 'tcp',
                            port = 6633)

    info('*** Add one UserAP ***\n')
    ap1 = net.addAccessPoint('ap1', mac='00:00:00:00:00:01')


    info('*** Add two WiFi stations ***\n')
    sta1 = net.addStation('sta1', mac='00:00:00:00:00:02', ip='10.0.0.1/8')
    sta2 = net.addStation('sta2', mac='00:00:00:00:00:03', ip='10.0.0.2/8')


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
```


Para lanzar el entorno de pruebas deberemos tener dos terminales en la misma máquina. En una lanzaremos MIninet-wifis y en la otra el proceso de Ryu corriendo en `localhost:6633`. Dejo los comandos por aqui para que se puedan copiar y pegar más rápido:

```bash
# Lanzamos la topología
sudo python3 topo.py 
```

```bash
# Lanzamos el controlador
ryu-manager ryu.app.simple_switch_13
```

De esta forma ya tendríamos el escenario de pruebas desplegado :smirk: 

## Problemas al lanzar una xterm

Me ha pasado que lanzo la topología, quiero habria una shell en la network Namespace de una de las estaciones wifi y no se me abre el xterm...

```bash
mininet-wifi> xterm sta1
```

Digo... igual es que el programa `xterm` no está instalado? :thinking_face: 

![](https://i.imgur.com/WqjSZ2U.png)

Pero si lo tenía instalado... BUscando información llegué a los siguientes enlaces:

*    https://stackoverflow.com/questions/49334663/xterm-not-opening-inside-mininet-hosts-no-ssh-no-vm

En el cual me explican que tengo que correr el siguiente comando en una terminal sin ser superusuario:

```bash
xhost +local:
```

El problema radica en que xterm no va a funcionar por defecto cuando estamos autenticados como superusuario, y sorpresa, mininet-wifi corre con permisos de superusuario. Mencionar que haciendo este apaño estamos dando acceso a cualquier usuario en nuestro sistema o en nuestra red local acceso a nuestra `$DISPLAY` sin autenticarse.


## Detectivando al `UserAP`

Lo primero que vamos hacer es ver la jerarquía de clases de la clase `UserAP`. Para ello, nos vamos al fichero [`node.py`](https://github.com/intrig-unicamp/mininet-wifi/blob/master/mn_wifi/node.py#L535) de Mininet-Wifi.  Nos vamos a la clase:


![](https://i.imgur.com/L4WWDPv.png)


Como se puede ver en la figura anterior, este es el diagrama UML de las clases relacionadas con `UserAP`. La lógica principalmente la ocupan los las clases primigenias `Node` y `Node_wifi`, las cuales tienen la mayoría de atributos y métodos. 

*    :warning: Mininet-Wifi re-define atributos que ya se encuentran en Mininet.... rarete :warning: En el UML no los hemos puesto dos veces, ya que los redefine y les asigna los mismos valores, código basura tobe honest.

Pero bueno, como podemos ver en el esquema, nuestra clase bajo estudio tienes dos ramas, la primera de ellas que adquiere la capacidad de gestion a modo de wrapper del BOFUSS (a través de `UserSwitch`), y la segunda rama, la cual adquiere las funcionamlidades WiFi de emulación gracias a la rama de `AP`, que asu vez añade toda la lógica de `Node_wifi`.

```python=
if __name__ == '__main__':
    setLogLevel('debug')
    scenario_basic()
```
Para estudiar en detalle vamos a poner el script indicado anteriormente en modo de log, `debug`. De esta forma, conseguiremos toda la traza de ejecución para el escenario. Este escenario, tiene únicamente dos estaciones y un `UserAP` por lo que será más sencillo de obtener información de que operaciones se llevan a cabo con la ejecución del Switch. Lo ejecutamos y obtenemos lo siguiente: 

```bash
*** errRun: ['grep', '-c', 'processor', '/proc/cpuinfo'] 
4
  0*** Setting resource limits
*** Creating nodes
*** Add Controller (Ryu) ***
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ifconfig'] 
/usr/sbin/ifconfig
  0_popen ['mnexec', '-cd', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:c0'] 359891*** c0 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
*** c0 : ('echo A | telnet -e A localhost 6633',)
Telnet escape character is 'A'.
Trying 127.0.0.1...
Connected to localhost.
Escape character is 'A'.

telnet> Connection closed.
*** Add one UserAP ***
*** errRun: ['which', 'mnexec'] 
/usr/bin/mnexec
  0*** errRun: ['which', 'ip', 'addr'] 
/usr/sbin/ip
  1_popen ['mnexec', '-cd', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:ap1'] 359897*** ap1 : ('unset HISTFILE; stty -echo; set +m',)
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
  1_popen ['mnexec', '-cdn', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:sta1'] 359904*** sta1 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
_popen ['mnexec', '-cdn', 'env', 'PS1=\x7f', 'bash', '--norc', '--noediting', '-is', 'mininet:sta2'] 359906*** sta2 : ('unset HISTFILE; stty -echo; set +m',)
unset HISTFILE; stty -echo; set +m
*** Configuring nodes
Loading 3 virtual wifi interfaces
Created mac80211_hwsim device with ID 0
Created mac80211_hwsim device with ID 1
Created mac80211_hwsim device with ID 2
rfkill unblock 17
*** sta1 : ('ip link set wlan0 down',)
*** sta1 : ('ip link set wlan0 name sta1-wlan0',)
rfkill unblock 18
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
*** ap1 : ("echo 'interface=ap1-wlan1\ndriver=nl80211\nssid=new-ssid\nwds_sta=1\nhw_mode=g\nchannel=1\nctrl_interface=/var/run/hostapd\nctrl_interface_group=0' > mn359884_ap1-wlan1.apconf",)
> > > > > > > *** ap1 : ('hostapd -B mn359884_ap1-wlan1.apconf ',)
ap1-wlan1: interface state UNINITIALIZED->ENABLED
ap1-wlan1: AP-ENABLED 
*** ap1 : ('ip link set', 'ap1-wlan1', 'down')
*** ap1 : ('ip link set', 'ap1-wlan1', 'address', '00:00:00:00:00:01')
*** ap1 : ('ip link set', 'ap1-wlan1', 'up')
_popen ['mnexec', '-da', '359897', 'tc', 'qdisc', 'replace', 'dev', 'ap1-wlan1', 'root', 'handle', '2:', 'netem', 'rate', '54.0000mbit', 'latency', '1.00ms'] 360049*** ap1 : ('tc qdisc add dev ap1-wlan1 parent 2:1 handle 10: pfifo limit 1000',)
*** sta1 : ('iw dev', 'sta1-wlan0 set txpower fixed 1400')
*** sta2 : ('iw dev', 'sta2-wlan0 set txpower fixed 1400')
*** ap1 : ('iw dev', 'ap1-wlan1 set txpower fixed 1400')
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
_popen ['mnexec', '-da', '359904', 'iwconfig', 'sta1-wlan0', 'essid', 'new-ssid', 'ap', '00:00:00:00:00:01'] 360059
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
_popen ['mnexec', '-da', '359906', 'iwconfig', 'sta2-wlan0', 'essid', 'new-ssid', 'ap', '00:00:00:00:00:01'] 360065
*** Build it ***
*** Configuring nodes

added intf sta1-wlan0 (0) to node sta1
*** sta1 : ('ip link set', 'sta1-wlan0', 'up')
*** sta1 : ('ethtool -K', <WirelessLink sta1-wlan0>, 'gro', 'off')

added intf sta2-wlan0 (0) to node sta2
*** sta2 : ('ip link set', 'sta2-wlan0', 'up')
*** sta2 : ('ethtool -K', <WirelessLink sta2-wlan0>, 'gro', 'off')
*** Start the controller ***
*** Set controllers ***
*** ap1 : ('ofdatapath -i ap1-wlan1 punix:/tmp/ap1 -d 100000000001 --no-slicing 1> /tmp/ap1-ofd.log 2> /tmp/ap1-ofd.log &',)
[1] 360070
*** ap1 : ('ofprotocol unix:/tmp/ap1 tcp:localhost:6633 --fail=closed  --listen=punix:/tmp/ap1.listen 1> /tmp/ap1-ofp.log 2>/tmp/ap1-ofp.log &',)
*** RUN Mininet-Wifis CLI ***
*** Starting CLI:
*** errRun: ['stty', 'echo', 'sane', 'intr', '^C'] 


```


De esta traza que podemos destacar, aparte de la gestion que lleva a cabo con las interfaces inalambricas, es la ejecución del **ofdatapath** y el **ofprotocol**. Dejo por aqui las lineas extraidas del bloque anterior:

**ofdatapath**
```log
ofdatapath -i ap1-wlan1 punix:/tmp/ap1 -d 100000000001 --no-slicing 1> /tmp/ap1-ofd.log 2> /tmp/ap1-ofd.log &
```
**ofprotocol**
```log
ofprotocol unix:/tmp/ap1 tcp:localhost:6633 --fail=closed  --listen=punix:/tmp/ap1.listen 1> /tmp/ap1-ofp.log 2>/tmp/ap1-ofp.log &
```

En cuanto a los ficheros de log tenemos los siguientes:

**ofdatapath**
```log
/tmp/ap1-ofd.log
```

**ofprotocol**
```log
/tmp/ap1-ofp.log
```

Es importante ya que serán nuestra referencia para el funcionamiento interno del BOFUSS. Para leerlo de una forma comoda suelo hcar un split de pantallas y hacer un watch cada 2,0s que vaya refrescando :smile_cat:

```bash
watch head /tmp/ap1-ofp.log
```

## Prueba de ping de topo.py (with WiFi stations)

Lo siguiente que hemos probado es hacer un ping, y nos llama la atención que el ping se puede llevar a cabo sin necesidad de que haya una conexión con el controlador. Es raro de narices pero encontramos el por qué :joy_cat:.

Cosas importantes de esta prueba a mencionar:

*   El AP1 correra en la root Network Namespace.
*   No se han especificado rangos, ni posiciones
*   Se empleará Ryu de controlador.
*   Las tablas ARP de las estaciones Wifi están vacias.

Como lanzamos el test: 

```BASH 
# Lanzamos el controller
ryu-manager ryu.app.simple_switch_13
```
```BASH 
#Lanzamos la topología
sudo python3 topo.py 
```
```BASH 
# Miramos el log de ofdatapath
watch head /tmp/ap1-ofd.log
```
```BASH 
# Mirar el log de ofprotocol
watch head /tmp/ap1-ofp.log
```


![](https://i.imgur.com/Dxxy7xZ.png)

En la otra pantalla tenemos Wireshark escuchando de la interfaz de loopback donde está corriendo el Controlador. Mencionar que para filtrar los mensajes de OpenFlow 1.3, debemos especificar el filtro de:

```
openflow_v4
```

![](https://i.imgur.com/vQGcC6E.png)


Lanzamos la topología, y sin llegar a lanzar en controlador, podemos ver como las tablas ARP de las estaciones WiFi están vacias y como el switch no ha detectado al controlador:

**Tablas ARP vacias** 

![](https://i.imgur.com/f6BuqaI.png)

**El BOFUSS no conecta con el controller**

![](https://i.imgur.com/avBvmeg.png)

Y con esta situación vamos hacer un ping de `sta1`a `sta2` y podemos ver lo que ocurre:

![](https://i.imgur.com/ew36QOc.png)


Hay conectividad!! :thinking_face:  JAJAJAJA qué está pasando?? Que hay un bypasseo ricolino ricolino. Esto puede ser critico por que en caso de que esta sea la operativa, nuestro switch modificado no tiene cabida. Si comprobamos de nuevo las tablas ARPs podemos ver como en efecto ha habido una resolución ARP en nuestras narices y no nos hemos dado ni cuenta. 


**Tablas ARP NO tan vacias** 

![](https://i.imgur.com/i6jV8ll.png)


### Detectivando el bypasseo del siglo por mac80211_hwsim

Vamos a indagar un poco más :thinking_face: está claro que el bypasseo viene por el pinche modulo del kernel, asi que bueno. Vamos a probar si con el `OVS` 

![](https://i.imgur.com/429KUFV.png)



--- 

https://superuser.com/questions/481145/what-is-the-difference-between-ad-hoc-and-mesh-network-also-with-p2p#:~:text=An%20%22ad%2Dhoc%22%20network,or%20it%20can%20be%20both.
https://hackmd.io/@akiranet/r1OC8CaNv
https://github.com/intrig-unicamp/mininet-wifi/blob/master/examples/meshAP.py