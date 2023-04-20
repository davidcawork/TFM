# Scenarios developed 

Escenario con Mininet y Onos corriendo en una Ubuntu 22.04 server. Onos (2.5.0) corre de forma remota en una VM aislada tambien con Ubuntu 22.04

En la máquina de Mininet, para levantar la topología:

```bash
sudo python3 topo.py
```

En la máquina de control, para levantar el controller y que haya conectividad, deberemos hacer lo siguiente:

```bash
bazel run onos-local
```

Importante, tiene que estar activadas las apps de reactive forwarding y las de openflow