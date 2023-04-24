# Scenarios developed 

Escenario con Mininet y Onos corriendo en una Ubuntu 22.04 server. Onos (2.5.0) corre de forma remota en una VM aislada tambien con Ubuntu 22.04

En la máquina de Mininet, para levantar la topología:

```bash
sudo python3 topo.py
```

En la máquina de control, para levantar el controller y que haya conectividad, deberemos hacer lo siguiente:

```bash
bazel run onos-local -- clean debug
# option 'clean' to delete all previous running status
# option 'debug' to enable remote debugging (port 5005)
```

Importante, tiene que estar activadas las apps de reactive forwarding y las de openflow.

Para ver la GUI de onos podemos acceder a la url:  [http://localhost:8181/onos/ui](http://localhost:8181/onos/ui) 

Contraseña: **`onos/rocks`**

*   Press H to show all hosts in topology
*   Press P to highlight the port of each link
*   Press T to change into night mode


Para reiniciar Onos:

```bash
$ onos-service --cell restart'
$ sudo kill `sudo lsof -t -i:6633`
$ sudo kill `sudo lsof -t -i:6653`
$ bazel run onos-local clean
```

Para entrar en la CLI de onos:

```bash 
ssh -p 8101 karaf@localhost (pwd: karaf)
```

Para borrar la topologia, nos conectanos a la CLI de Onos

```bash 
karaf@root > onos:wipe-out please 
```

:joy: que te diga que lo tienes que pedir "por favor" me parto :joy:
