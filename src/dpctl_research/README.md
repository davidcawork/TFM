# dpctl research

En este punto vamosa detectivar la herramienta de `dpctl` la cual se utiliza para gestionar el  plano de datos de software switch de referencia para la versión de OpenFlow 1.3, conocido como BOFUSS (Basic OpenFlow Software Switch).

*    [Repositorio oficial del switch](https://github.com/CPqD/ofsoftswitch13)

## Problemas han sido encontrados :face_with_cowboy_hat: 

La problematica principal que nos hemos encontrado despues de medio arreglar el _byPasseo_ del siglo del modulo del kernel mac80211_hwsim a la hora de hacer debug es que ibamos a sacar las tablas de flujos que se deberían haber instalado en el switch, sin embargo, estas no aparecen.

![](https://hackmd.io/_uploads/HkkX5zGH3.png)

Lo primero que hicimos es consultar si los dos UNIX sockets han sido creados en la ruta indicada en el lanzamiento del plano de datos y control del switch. Recordemos que los BOFUSS se lanza de la siguiente forma:

**ofdatapath**
```log
ofdatapath -i ap1-wlan1 punix:/tmp/ap1 -d 100000000001 --no-slicing 1> /tmp/ap1-ofd.log 2> /tmp/ap1-ofd.log &
```
**ofprotocol**
```log
ofprotocol unix:/tmp/ap1 tcp:localhost:6633 --fail=closed  --listen=punix:/tmp/ap1.listen 1> /tmp/ap1-ofp.log 2>/tmp/ap1-ofp.log &
```

Como se puede apreciar en los comandos anteriores se indican dos sockets UNIX. Uno de ellos, `/tmp/ap1`, es para la intercomunicación del plano de datos y el plano de control, y el otro, `/tmp/ap1.listen` es para la gestión propia según indica la documentación propia del switch.

Frente ha esta problematica, lo primero que se hizo es buscar de forma rápida, issues - PR en repositorios relacionados errores simimilares. A continuación, se indican algunos de las referencias encontradas:

*    https://github.com/mininet/mininet/issues/745 :heavy_check_mark: 
*    https://github.com/CPqD/ofsoftswitch13/issues/288
*    https://github.com/mininet/mininet/issues/670
*    https://github.com/mininet/mininet/issues/632
*    https://github.com/mininet/mininet/issues/628

Como se puede ver, en las referencias señalas, no se apreciar una causa común...

Indagando más allá hemos decidido lanzar la herramienta desde fuera de Mininet-Wifi... desde la propia terminal, y como presuponiamos, pasa lo mismo.

![](https://hackmd.io/_uploads/Sk0_EEzS2.png)

Hemos intentado, cambiar los permisos del socket UNIX para que tuvieran tambien permisos de escritura para todos los ususarios... pero nada, el resutado es el mismo.

## Todo empezó en la antigua Grecia :flag-gr: 

Yo suponía que la herrsmienta la había escrito Eder, dado que el binario que se compila y se instala se encuentran las fuentes en el repositorio del BOFUSS además de la documentación de la misma, es decir, las _manpages_. (Iluso de mi :face_palm: )

* Fuentes: https://github.com/CPqD/ofsoftswitch13/blob/master/utilities/dpctl.c
* Man-page: https://github.com/CPqD/ofsoftswitch13/blob/master/utilities/dpctl.8.in

Pero,  ¿Realmente esta herramienta es suya? **Negativo**.

La herramienta ha sido heredada de Stanford, 2008. Esto lo he averiguado dado que Eder instala las man-pages de la herrmaienta antigua :satisfied: (Un poco ñapa... hay que decirlo todo) 

Si nos fijamos en la man-page de la herrmaienta que se instala:

```bash
man dpctl
```

![](https://hackmd.io/_uploads/SyN7PNzSn.png)

La sintaxis que se usa es la siguiente:

```log
sudo dpctl CMD [SW]
```

Por el contrario, si sacamos la ayuda del binario de Eder, podemos apreciar lo siguiente:

```bash
dpctl -h
```

![](https://hackmd.io/_uploads/B1mYfKfBn.png)

Como se puede llegar a apreciar la sintaxis es completamente distinta. En este caso se aprecia como han sido intercambiado el parametro de comando y el parametro de identificación del switch en cuestión.

```log
sudo dpctl [SW] CDM
```

Y ya no es que no solo cambien la organización de los parametros... hay más tambien ha cambiado los comandos disponibles de la herramienta. Por ejemplo, vamos a fijarnos en uno de los comandos más conocidos como es `dump-flows`. Este comando es muy util y se utiliza en toda la documentación de Mininet para recolectar información de los flujos instalados en la lógica interna del switch. 

Si nos fijamos en las fuentes de la herramienta original, podemos ver como efectivamente hay una función para dicha funcionalidad:

*    https://github.com/mininet/openflow/blob/master/utilities/dpctl.c#L1114

Sin embargo, si nos vamos a las fuentes de la herramienta modificada por Eder, por mucho que busquemos en el source una función con las mismas caracteristicas para dumpear toda la información de flujos, no lo vamos a conseguir. 

*    https://github.com/CPqD/ofsoftswitch13/blob/master/utilities/dpctl.c

## Conclusiones de la detectivación :duck: 

Tenemos dos opciones trabajar con la nueva interfaz de comandos suministrada por la herramienta escrita por Eder o podemos instalar y compilar la versión anterior de la herramienta, arriesgando a que algo pete :full_moon_with_face:. 

### Opción 1: Los cambios nos hacen más fuertes

La primera opción es adaptarse y ver que lso cambios nos hacen más fuertes, :joy: así que vamosa ver como extraer los flujos del switch. Despues de ejecutar el comando de ayuda, `dpctl -h` podemos ver que la forma de extraer los flujos es:

```bash
sudo dpctl unix:/tmp/ap1.listen stats-flow
```

El problema de obtener así los flujos es que nos llega la información algo ofuscada:

![](https://hackmd.io/_uploads/HkKWLxRr2.png)

Como se puede ver en la captura anterior, nos indican que comando se manda al socket unix `unix:/tmp/ap1.listen` y los datos recibidos. Pero como indicabamos, se ve pocho pocho (No hay lujo primoooo, tus wewoooos :joy: ). En fin, habrá que parsearlo, y esto parece que no soy el primero en pensarlo. Un usuario del BOFUSS ya lo pensó en su momento, he hizo una PR al repo añadiendo un script de Python que parseaba la información recibida por el switch.

*    https://github.com/CPqD/ofsoftswitch13/blob/master/utilities/dpctl_parser.py

Herramienta escrita por un israeli ([github del creado de la herramienta original](https://github.com/simhond)). Pero claro la escribió en el año de la pera, con Python2.7. Además, que no quiero desprestigiar a mi colega isreali, pero script bastante mejorable :crying_cat_face: . (Por favor, si el mossad está leyendo esto, va a coña jajajajaja no quiero aparecer en un maletero aleatorio) :flag-il: :joy_cat: 

Bueno vamos a lo que vamos al meoyo, a nosotros nos llega lo siguiente:


```jsonld!
SENDING (xid=0xF0FF00F0):
stat_req{type="flow", flags="0x0", table="all", oport="any", ogrp="any", cookie=0x0", mask=0x0", match=oxm{all match}}


RECEIVED (xid=0xF0FF00F0):
stat_repl{type="flow", flags="0x0", stats=[{table="0", match="oxm{in_port="1", eth_dst="00:00:00:00:00:02", eth_src="00:00:00:00:00:03"}", dur_s="145668", dur_ns="49000000", prio="1", idle_to="0", hard_to="0", cookie="0x0", pkt_cnt="12", byte_cnt="948", insts=[apply{acts=[out{port="1"}]}]},
{table="0", match="oxm{in_port="1", eth_dst="00:00:00:00:00:03", eth_src="00:00:00:00:00:02"}", dur_s="145668", dur_ns="46000000", prio="1", idle_to="0", hard_to="0", cookie="0x0", pkt_cnt="11", byte_cnt="888", insts=[apply{acts=[out{port="1"}]}]},
{table="0", match="oxm{all match}", dur_s="146810", dur_ns="943000000", prio="0", idle_to="0", hard_to="0", cookie="0x0", pkt_cnt="1562", byte_cnt="164147", insts=[apply{acts=[out{port="ctrl", mlen="65535"}]}]}]}
```

Y hay que parsearlo. Para ello, vamos a pasar las estadisticas recibidas a un formato JSON. Lo hemos planteado en tres funciones, consultar el switch, parsear el output recibido, e imprimirlo. A la hora de parsearlo hay que tener en cuenta lo siguiente:

*    NO está en formato JSON. Por favor Eder, estabas borracho o algo? que formato de :shit:  es ese :joy_cat: 
*    Hay que quitar los saltos de linea, '\n' 
*    Hay que cambiar los '=' por ':'.
*    Los matches hay que meterle single qoutes para que no rompa el formato de JSON
*    Además hay que gestionar los objetos recibidos en las acciones a ejecutar por que están metidos uno dentro de otro.

En fin, las expresiones regulares son nuestras amigas. Dejo el script realizado por aquí, cuando pueda haré una PR ofreciendolo como upgrade al ya existente de mi amigo del mossad. 

```pythopn=
#!/usr/bin/python3

import sys
import json
import subprocess
import re

#   Initially created by @simhond for Python2.7 version.
#   Updated to Pyhton3 and cleaned up by @davidcawork

# MACROS


# Parse stats-flow
def parse_statsFlow(cmd):
    """
    Parse stats-flow command
    """
    cmd_fmt = (cmd.replace("\n", "")).split("stat_repl")[1]
    cmd_json_fmt = re.sub("\[(\w+){", r'["\1",{', re.sub("(\w+)=", r'"\1":', cmd_fmt))
    cmd_json_fmt = re.sub(
        r"oxm\{.*?\}", lambda match: match.group(0).replace('"', "'"), cmd_json_fmt
    )
    return json.loads(cmd_json_fmt)


# Get stats-flow
def get_statsFlow(params):
    """
    Execute dpctl stats-flow and capture stdout
    """
    return subprocess.run(
        ["dpctl", params, "stats-flow"], stdout=subprocess.PIPE
    ).stdout.decode("utf-8")


# Print stats-flow
def print_statsFlow(data):
    """
    print dpctl stats-flow parsed
    """
    stats = data["stats"]

    for stat in stats:
        print(
            "---------------------------------- Table "
            + stat["table"]
            + " --------------------------------"
        )
        print("[+] Match: " + stat["match"])
        print("[+] Duration: " + stat["dur_s"])
        print("[+] Prio: " + stat["prio"])
        print("[+] Pkt cnt: " + stat["pkt_cnt"])
        print("[+] Byte cnt: " + stat["byte_cnt"])
        print("[+] Insts: " + str(stat["insts"]))
        print(
            "---------------------------------------------------------------------------"
        )


# Main
if __name__ == "__main__":
    # Parse input data
    if len(sys.argv) <= 1:
        print("Please supply the datapath to use - example 'unix:/var/run/dp0'")
        sys.exit()

    # Vars
    cmd = get_statsFlow(sys.argv[1])

    # Parse cmd
    cmd_parsed = parse_statsFlow(cmd)

    # Print parsed cmd
    print_statsFlow(cmd_parsed)

```

Ejemplo de uso del parser:


Podemos apreciar lo bonito que queda ahora los flujos:

![](https://hackmd.io/_uploads/rkU4IBkI2.png)



### Opción 2: Yo he venido aquí a hablar de mi libro

La opción número 2 es adaptar la herramienta antigua. Lo que deberíamos hacer es ir al repositorio de la herramienta anterior de `dpctl` y compilarla sobre la herramienta nueva hecha por Eder. A continuación, se indica el repositorio de la herramienta antigua: 

*    https://github.com/mininet/openflow/tree/master


Como se puede ver los pasos serían los siguientes. Sobre una instalación fresh de Mininet, a continuación se indica el escenario utilizado:

*    https://github.com/davidcawork/TFM/tree/main/src/scenarios/mininet

Tenemos que clonar el repositorio de Openflow indicado anteriormente:

```bash
git clone https://github.com/mininet/openflow.git
```

Una vez que hemos clonado el repositorio de openflow de Standfor con la versión `1.0` de OpenFlow, vamos a instalar las dependencias generales que requiere el repositiorio para hacer un build desde el source. Mencionar que sería más adeacuado construir la herrmaienta exclusivamente y no todo el repo, con el controlador y la implementación `1.0` de OpenFlow. Pero como solo queremos hacer una prueba ocnceptual, vamos a seguir hacia delante. 

```bash
# Hacemos un install de las deps
sudo apt install git autotools-dev pkg-config libc6-dev
```

Una vez que tenemos las dependencias necesarias instaladas, podemos proceder hacer el make. A continuación, se indican los pasos para hacer un build desde el source:

```bash
# Entramos
cd openflow

# Booteamos y configuramos (a.k.a pre-checking de que tenemos todas las herramientas para hacer el make)
./boot.sh
./configure

# Build :)
make

# E instalamos para que el binari oen path de dpctl sea este ultimo
sudo make install
```

Ya tendíamos la herrmaienta instalada. Lo podemos comprobar si hacemos un `dpctl -h`. Como se puede apreciar en la siguiente figura ya no vemos la ayuda de la herrmaineta de Eder, si no, la ayuda de la herramienta oficial, ojo, ya hay dumpflows :smirk_cat: hehehehe 

![](https://hackmd.io/_uploads/SyOYAHmUh.png)


Podemos hacer una prueba con un escenario de prueba de Mininet :smile_cat:

```bash
# Lanzamos mininet con los switches tipo UserSwitch
sudo mn --switch user 
```

Y como se puede ver en la siguiente figura, ya funciona el comando de Dump-flows.

![](https://hackmd.io/_uploads/BkqGy8mU2.png)


**Resumen, yo he venido aqui a hablar de mi libro** :smiling_face_with_smiling_eyes_and_hand_covering_mouth: Pero bueno, como ya hemos hecho el parser de la herrmaineta de Eder, vamos a seguir la Opción 1, aunque viene bien que la gente diferencia cual es funcionamiento de la herrmaienta original y de la herrmaienta modificada. Creo que el hecho de haber documentado este detalle viene bien, en aras de diferencia y ayudar a la gente que acaba de sumergirse en el mundo de SDN, cual es la herramienta que están utilizando. 