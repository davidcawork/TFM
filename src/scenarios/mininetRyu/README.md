# Scenarios developed 

Escenario con Mininet y Ryu corriendo en una Ubuntu 22.04 server. Ryu corre de forma remota en una VM aislada tambien con Ubuntu 22.04

En la máquina de Mininet, para levantar la topología:

```bash
sudo python3 topo.py
```

En la máquina de control, para levantar el controller y que haya conectividad, deberemos hacer lo siguiente:

```bash
ryu-manager ryu.app.simple_switch_13
```
