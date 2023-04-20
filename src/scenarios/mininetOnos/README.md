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

Para reiniciar Onos:

```bash
$ onos-service --cell restart'
$ sudo kill `sudo lsof -t -i:6633`
$ sudo kill `sudo lsof -t -i:6653`
```