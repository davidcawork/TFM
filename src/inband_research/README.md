# in-Band research

En este documento vamos a investigar como hizo nuestro querido rumano de confianza la implementación de control in-band en el switch BOFUSS. Recordemos con que repositorios vamos a estar trabajando. 

*    Switch de boby in-band, `a.k.a` **`in-BOFUSS`**: https://github.com/NETSERV-UAH/in-BOFUSS
*    Basic OpenFlow Software Switch, `a.k.a` **`BOFUSS`**: https://github.com/CPqD/ofsoftswitch13

## Un poco de historia :book: 

Si queremos la historia más detallada nos podemos ir al papers del switch y listo... :joy_cat: Dejo el link por aqui para los interesados. Aquí vamos a seguir una descripción un poco más breve.

*    [The road to BOFUSS: The basic OpenFlow userspace software switch](https://www.sciencedirect.com/science/article/pii/S1084804520301594)

Este switch nació como una primera implementación por el 2008 en la universidad de Stanford, acuñado como:  *The Stanford Reference OpenFlow Switch*. Hablando en plata, era un minimo producto viable para demostrar y ayudar en el procesode estandarización del protocolo `Openflow 1.0`. Dicho minimo producto viable, fue retomado por los laboratorios de Ericsson (*Ericsson
Research TrafficLab*) para desarrollar la versión `Openflow 1.1`. Este último desarrollo fue retomado por nuestro compañero Eder, desde Brasil,  fue parte de su TFM y PhD, donde completo lo que hoy conocemos como el BOFUSS, el cual da soporte para la versión `Openflow 1.3`. Por último, este switch fue tomado por mi compañero Boby y modificado para hacer una implementación de In-band. En la siguiente figura se puede ver un pequeño resumen de ka historia del switch que vamos a meterle la pezuña. 


![](https://hackmd.io/_uploads/BJN4ntQLh.png)


Enlaces utiles:

*    OF 1.0: https://github.com/mininet/openflow
*    OF 1.1: https://github.com/TrafficLab/of11softswitch
*    OF 1.3: https://github.com/CPqD/ofsoftswitch13
*    OF 1.3 + in-band: https://github.com/NETSERV-UAH/in-BOFUSS

Documentación encontrada al respecto: 

*    TFM-Boby: https://ebuah.uah.es/dspace/handle/10017/46908
*    TFM-Villa: https://ebuah.uah.es/dspace/handle/10017/49672
*    Tesis-JAH: https://ebuah.uah.es/dspace/handle/10017/50437
*    Tesis-Eder: https://www.dca.fee.unicamp.br/~chesteve/thesis/Dissertacao-Eder-SoftSwitch13-20150416.pdf
*    Wiki de github: https://github.com/CPqD/ofsoftswitch13/wiki
*    Publicación no oficial de Eder: https://www.dca.fee.unicamp.br/~chesteve/pubs/sbrc14-ferramentas-ofsoftswitch13.pdf
*    Publicación oficial de eder y compañía: https://www.sciencedirect.com/science/article/pii/S1084804520301594


Cuando mucha gente ha metido la pezuña en un proyecto... malo. Sabes que toca hacer un poco de arquelogía. Nuestro plan es el siguiente:

1. Entender la arquitectura del BOFUSS :ballot_box_with_check: 
2. Entender la interfaz del BOFUSS :ballot_box_with_check:
3. Conseguir debuggear al BOFUSS
4. Ver los cambios realizados por nuestro amigo Bobys
5. Identificar la motivación de los cambios añadidos por boby
6. Ver que tenemos que adaptar para tener el in-band en wireless.

## Arqueología I :t-rex:  : La arquitectura del BOFUSS

La arquitectura del BOFUSS se puede apreciar en la siguiente figura: 

![](https://hackmd.io/_uploads/r152NcmIn.png)

Según se ha podido leer, por el propio creador, está arquitura si bien es cierto que no trara de replicar la especificación al 100%, es la implementación más cercana a la especificación oficial de `OpenFlow 1.3`. Las siguientes sections no siguen ningún grupo lógico de la especificación estandar de OpenFlow, son solo agrupaciones que se han creadido adeacuadas despues de ver y consultar la documentación oficial del BOFUSS y relacionados.

Como se puede ver en la figura anterior, el software switch se compone de dos bloques fundamentales.

*    Plano de datos, `a.k.a` **`Datapath`**, en la herramienta al plano de datos lo podemos encontrar como `udatapath/ofdatapath`.
*    Plano de control, `a.k.a` **`Control plane`**, en la herramienta al plano de control lo podemos encontrar como `secchan/ofprotocol`.

El primero de ellos, el `udatapath/ofdatapath` se caracteriza por ser el bloque funcional de gestionar el procesamiento de los paquetes datos, y en ocariones de control (en función del paradigma de control). Dentro de este bloque funcional se pueden encontrar elementos internos como por ejemplo, los puertos, conocidos como `Port`, los `Flow`, `Meter`, `Group`, `Table` y el `Packet Parser`. El bloque del agente de control, es el encargado de gestionar la información de control entre el controlador y el dispositivo. Los mensajes de Openflow viajarán desde el plano de secure channel, a la librería de de oflib, y de ahí al datapath para instanciar en las tablas de flujos correspondientes. Más adelante se explican en detalle cada bloque de la arquitectura. 



### Ports

Los puertos OpenFlow desempeñan un papel fundamental como puntos de entrada y salida para los paquetes de datos en un entorno OpenFlow. Cuando se ejecuta un software switch en una máquina, puede utilizar interfaces físicas o virtuales como sus puertos (interfaces físicas o virtuales como veths o también radio taps emulados). Los puertos físicos permiten el control de interfaces Ethernet o **WiFi**, lo que facilita la gestion de tanto topologías de red realistas como emuladas. Aunque la velocidad del software switch puede ser limitada dado que trabaja en espacio de usuario, la posibilidad de crear un entorno de pruebas boostea la experiencia de los usuarios que desarrollan y evalúan aplicaciones OpenFlow. Se podría pensar que los puertos del switch se limitan simplemente a enviar y recibir paquetes de red. ERROR. También tienen una serie de mini-responsabilidades realcionadas con la gestión del protocolo openflow. Estas responsabilidades se pueden resumir:

*    OpenFlow permite cierto nivel de control sobre el comportamiento que tiene que tener un puerto en particular. Si se recibe un mensaje de modificación de puerto, este tiene que permitir configurar el estado del puerto. Los puertos pueden configurarse para que droppen todos los paquetes recibidos, prohíban la generación de mensajes de tipo openflow `Packet In` a partir de los paquetes que llegan, además de marcar el estado del pueblo como fuera de servicio. El agente que gestione el puerto deben gestionar estos mensajes de configuración que le lleguen, y cambiar el comportamiento del puerto según la configuración recibida.
*    Los puertos Openflow tienen que llevar un monitoreo del estado de la interfaz física o emulada que gestionan. Si bien es cierto que el controlador no puede actuar sobre el estado real de la interfaz, el switch tiene que informar sobre los cambios de estado del enlace.
*    Generalmente cuando se lleva a cabo un `Packet-In` por que hay un miss, solo se manda al controlador las cebeceras del mensaje a consultar junto al propio mensaje del `Packet-In`. Los puertos, durante dicha consulta tendrán que gestionar los buffers que almacenarán los paquetes a consultar para ser procesados más tarde.
*    El controlador a través del agente de control, también puede consultar sobre la descripción de un puerto.Por tsnto, el software switch tendrá que recolectar la información que onsidere oporturna como por ejemplo la velocidad actual y máxima de las interfaces reales, almacenarla para enviarla posteriormente cuando el controlador se lo requiera. 
*    Las colas según hemos podido consultar no son parte de la definición estandar de Openflow. SIn embargo, Openflow puede  confirgurar colas asociadas a unos puertos dados. Los puertos por tanto tendrán la responsabilidad de llevar a cabo la asociación de configuración de cola y asociación de cola con un puerto además de actulizar los contadores de paquetes de puerto y cola asociada.

Ficheros relacionados a consultar:

[udapath/dp_ports.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/dp_ports.h)  
[udapath/dp_ports.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/dp_ports.c)  
[udapath/dp_buffers.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/dp_buffers.h)  
[udapath/dp_buffers.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/dp_buffers.c)  
[lib/netdev.h](https://github.com/CPqD/ofsoftswitch13/blob/master/lib/netdev.h)  
[lib/netdev.c](https://github.com/CPqD/ofsoftswitch13/blob/master/lib/netdev.c)


### Packet Parser


Antes que el paquete en cuestión llegue a la pipeline de procesamiento del software switch, este debe ser parseado para adaptarlo a las estructuras de datos que se manejan en el switch. Para ello, el cómo se tiene que parsear los paquetes se definió en el estandar de `OpenFlow 1.1`. Esto es importante, ya que debe haber consistencia en como los paquetes deben ser paserados, pero esto a su vez supuso una limitación para nuevos diseños de switches, y supone modificaciones cada vez que se añade un nuevo protocolo. Por ello, más adelante con especificaciones posteriores del protocolo esta limitación se vio eleiminada. Nuestro parser quetenemos en el BOFUSS hace uso de **NetBee** coomo disector y parseador de paquetes. Una vez que se han identificado los campos de protocolo que contiene el paquete, se crea una estructura de matching con la cual se atacará a la pipeline de procesamiento del switch. 

Este proceso anteriormente descrito se puede dar en dos ocasiones. 

*    Que el paquete de red entre por uno de los puertos gestionados por el software switch.
*    Que un paquete que ya ha sido modificado y redirigido por la pipeline de procesamiento, o enviado a una nueva tabla de adelante con la instrucción de *Go To Table*.
   
      
Esto es así dado que una revalidación del paquete es necesaria, y el parsear tambien se encarga de comprobar la valided del TTL. Además de añadir información de metadatos al mismo. Cada vez que se quiera dar soporte a nuevos protocolos, se tendrá que modificar el parsing del switch. Para ello, se tiene que llevar modificaciones a cabo en el fichero `*.xml` en lenguaje NetPDL. NetPDL es un lenguaje de descripción que describe cómo Netbee debe analizar los protocolos. 

![](https://hackmd.io/_uploads/HydHZiEI3.png)



Ficheros relacionados a consultar:

[udatapath/packet_handle_std.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/packet_handle_std.h)  
[udatapath/packet_handle_std.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/packet_handle_std.c)  
[udapath/packet.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/packet.h)  
[udapath/packet.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/packet.c)  
[nbee_link/nbee_link.h](https://github.com/CPqD/ofsoftswitch13/blob/master/nbee_link/nbee_link.h)  
[nbee_link/nbee_link.cpp](https://github.com/CPqD/ofsoftswitch13/blob/master/nbee_link/nbee_link.cpp)

Fichero NetPDL importante que describe el parsing
[customnetpdl.xml](https://github.com/CPqD/ofsoftswitch13/blob/master/customnetpdl.xml)


### Flow Tables

Las `Flow Tables` son el core de procesamiento del software switch. Las flow tables siempre son el siguiente paso despues del procesamiento y podrían considerarse el corazón del entorno openflow dado que son el primer componente en la pipeline de procesamiento del switch. Aunque el uso de multiples tablas de flujos es opcional, la especififcaión indica que se utilice al menos una tabla, a la hora de la implementación se considera más que recomendado dado que inviable el hecho de gestionar el escalado de una apliación con unicamente solo una tabla de flujo.

En pocas palabras podríamos definir una  `Flow Table` como una lista de flujos, donde cada flujo se compone de unos campos de matching y de unas intrucciones asocidas en caso de que haya match. Instrucciones que como se indican, tienen que estár definidas previamente en la especificación de Openflow. Una vez el paquete se ha validado y se ha parseado en una estructura de matching, se comprueba con una entrada de un flujo con el campo de matching, en caso de coincida con dicho flujo, las instrucciones asociadas se ejecutan. 

A continuación se indican algunos de los aspectos que tienen que cumplir las tablas de flujo.

-    La implementación de una tabla de `miss` es obligatoria, ya que el switch tiene que hacer algo con los paquetes los cuales no matchean con ninguna flow entry. Por el contrario, si no se implementa ninguna tabla de `miss`, se tiene que establecer una action por defecto. En el caso del switch se ha establecido que se tiren los paquetes.
-    Otro aspecto a considerar, el cual, tiene que ser gestionado por las `Flow table` es la gestión de los paquetes `Flow-Mod`. Estos mensjaes son generados desde el controlador y gestionados por el agente de control del switch para creación o eliminación de entradas de flujo en alguna `Flow Table`.
-    El switch debe permitir al controlador de reconfigurar sus prestaciones. Es decir, las propiedades de las tablas deben ser conocidad por el controlador, y las tablas deben en todo modomento responder a los mensajes de consulta de features.
-    Por cada paquete del plano de datos que les lleguen, deben llevar a cabo un *look up*,  es decir, consultar si el paquete entrante de datos coincide con algún campo de match de algún flujo de la tabla. En caso de que exista algún match, se ejecutará la instrucción asociada. 
-    Otro aspecto-tarea, a llevar a cabo por el switch, es llevar el recuento de las estadisticas de las entradas activas, los *look ups* realizados, y paquetes que han hecho match.

En cuanto aspectos de implementación, podemos destacar, las reglas se indexan en la tablas de flujos en orden de prioridad, si tienen la misma prioridad, se indexarán en orden de llegada. En cuanto a la complejidad del tiempo de *look up*, es lineal es decir `O(n)`, donde `n` es el número de flujos. Esto no es muy eficiente dado que crece de forma lineal según el número de flujos aumenta. Aunque según ha indicado el autor, es suficiente para llevar prueas de concepto. Otro detealle de implementación, que tenemos que tener en cuenta es el numero de entras de flujos por tabla de flujos, actualmente esta definido a 64 por una macro.  Si se quisiera cambiar este param solo habría que cambiar la macro y recompilar el proyecto. Por útlimo, mencionar que las tablas de flujos tienen una lista de *idle* y *hard timeout*. Las tablas comprueban cada 100ms si alguna de sus entradas de flujos han expirado. 


Ficheros relacionados a consultar:

[udatapath/pipeline.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/pipeline.h)  
[udatapath/pipeline.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/pipeline.c)  
[udatapath/std_match.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/std_match.h)  
[udatapath/std_match.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/std_match.c)  
[udatapath/dp_actions.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/dp_actions.h)  
[udatapath/dp_actions.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/dp_actions.c)  
[udatapath/action_set.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/action_set.h)  
[udatapath/action_set.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/action_set.c)  
[udatapath/flow_entry.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/flow_entry.h)  
[udatapath/flow_entry.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/flow_entry.c)  
[udatapath/flow_table.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/flow_table.h)  
[udatapath/flow_table.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/flow_table.c)


### Group Table

Tampoco voy ahondar mucho en esta section dado que no las vamos a utilizar. Las `Group Tables`, se utilizan para agregar flow entries que tienen una politica de acción similar. Una vez agregadas llevan a cabo una serie de acciones. Para ello, desde las flow tables se les asigna una identifiacodr de tabla de grupo. Con dicha ID van a una entrada de una tabla de grupo y se lleva a cabo una acción. Estas entraadas tambien tienen contadores para llevar un conteo de los matches que ha habido.


![](https://hackmd.io/_uploads/SkF4oYNI3.png)


Ficheros relacionados a consultar:

[udatapath/group_entry.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/group_entry.h)  
[udatapath/group_entry.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/group_entry.c)  
[udatapath/group_table.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/group_table.h)  
[udatapath/group_table.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/group_table.c)



### Meter Table

La `Meter Table` es el core del QoS del software switch. Para cada flujo se tienen unas meter asociadas en la propia entrada en la tabla de flujo. Dichas meters, tienen una entrada en la meter table. Cada entrada se compone de una ID, un contador, y unas meter bands. Estas últimas, las meters-bands son las encargadas de de llevar a cabo las operaciones de QoS. Cada Meter-band debe tener un tipo, un ratio, el cual será el limite que tiene que superarse para aplicar la action definida por el tipo de la meter. A cotninuación, se indica una figura que ilustra la arquitectura de una Meter table. 

![](https://hackmd.io/_uploads/r1-E6Y4U2.png)


Entre las responsabilidades de las meter tables podemos encontrarnos las siguientes:

-    Creación, destrucción y modificación de las entradas de las meters
-    Medir el ratio de aquellos maqutees que han matchado en una flow entry, y apuntan a una meter table.
-    mantener actualizado los contadores de las estadisticas de los paquetes procesados por cada entarda en la meter table.


Ficheros relacionados a consultar:


[udatapath/meter_entry.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/flow_entry.h)  
[udatapath/meter_entry.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/meter_entry.c)  
[udatapath/meter_table.h](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/meter_table.h)  
[udatapath/meter_table.c](https://github.com/CPqD/ofsoftswitch13/blob/master/udatapath/meter_table.c)





### `oflib` (Marshaling/Unmarshaling library)

Los mensajes de OpenFlow están definidos, de una manera en particular para ser transmitidos por la red. Los mensajes tienen que estar en modo 8-byte alineados, por lo que habrá alguna ocasión donde se tenga que añadir padding para que se cumpla esta regla. Otro requisito es que el mensaje tiene que estar en Network byte order, `a.k.a` Big Endian. Los mensajes OpenFlow que se mandan por la red tienen que estar en el formato indicado anteriormente, es decir, el byte de mayor peso de una palabra tiene que estar almacenado en la posción más pequeña (dir más baja).

Las arquitecturas de cada máquina pueden variar, y el formato de datos con en el que trabajan tambien. Por ejemplo para ARM e Intel el formato con el cual trabajan ambas arquitecturas es Little Endian byte order. Por ello, en arás de manejar y codificar mensajes openflow re qrequiere una conversión big-endian a little-endian. 

![](https://hackmd.io/_uploads/BkuHksNLh.png)


Debido a cual, se necesita una capa de abstración de la arquitectura donde se vaya a correr dicho software switch. Por ello, aunque el estandar de Openflow no lo indique se ha añadido esta librería denominada como `Oflib`. La función principal de esta librería es las operacioens de *Marshaling*/*Unmarshaling*. para que la transmisión de información de mensajes OPenflow a la red se completamente autonoma. Las responsabilidades de esta librería son las siguientes:

-    Cada mensaje openflow debe tener una función para empaquetarlo y despaquetarlo. De aqui en adelante, y en el repositorio, nos referimos a hacer un *pack* es coger una estructura de datos openflow y prepararla para ser transmitida por la red. Cuando realziamos una operación de *unpack*, cogemos info que viene por la red, y la convertimos a estructuras que entienda la arquitectura sobre la cual está corriendo nuestro software switch.
-    Otra esponsabilidad que tiene la librería es señalar con errores o warnings en caso de los mensajes Openflow estén mal codificados.


Ficheros relacionados a consultar:

[oflib](https://github.com/CPqD/ofsoftswitch13/tree/master/oflib)



### Communication Channel

El software switch se comuniaca con el controlador SDN a través de este agente de control que acuta de proxy como proxy entre el datapath  y el controlador SDN. Este agente se encarga de gestionar las conexiones con el controlador SDN, aunque, si bien es cierto que este agente no está pactado en el estandar de Openflow, esto da libertad a las diferentes implementaciones para configurar la conexion hacia al controlador como quieran. Por ejemplo, si se quiere que la conexión sea segura extremo a extremo, se tendría que utilizar TLS encima de TCP. 

Entre las responsabilidades de esta capa podemos mencionar las siguientes.

-    El agente de control se tiene que encargar de abrir una conexión TCP conentre el switch y el controlador. 
-    El establecimiento de la conexión es responsabilidad del agente de control. Despues del inicio de la conexión, el switch negocia la versión Openflow a utilizarentre el switch y el controlador. Este proceso se conoce como handshake.
-    El agente de control debe soportar más de un controlador. 
-    Además, el agente de control debe soportar más de una conexión con el mismo controlador.

Ficheros relacionados a consultar:

[secchan](https://github.com/CPqD/ofsoftswitch13/tree/master/secchan)


## Arqueología II :t-rex:  : El interfaz del BOFUSS

La interfaz del BOFUSS se puede dividir en dos binarios claramente diferenciados. El primero de ellos, `ofprotocol` y el `ofdatapath`. 

### Binario  **`ofprotocol`**

El binario de `ofprotocol` establece un canal seguro de comuniación entre el datapath OPenFlow y el controlador remoto. Este conecta con el datapath mediante Netlink o TCP, y con el controlador remoto mediante TCP o SSL, actuando de proxy entre los dos mundos. 

```bash
 ofprotocol [options] datapath controller[,controller...]
```

Uno de los parametros obligatorios es el datapath a gestionar. Este se puede indicar de las siguientes formas:

*    `unix:file` se indica un descriptor de un socket UNIX el cual es el mismo indicado por el `ofdatapath`. Mediante este socket unix se comuniacarán datapath y plano de control.
*    `tcp:HOST[:PORT]` En este caso se puede conectar tambien en red mediante puerto y dirección IP. Este caso se usa cuando se quiere tener separado en máquinas diferentes datapath y agente de control. Puerto por defecto, 6653.

En cambio el parametro del controlador es opcional, y solo soporta conexiones TCP. Para la conexión con el controlador se contemplan dos formas diferenciadas para la conexión del controlador. 

*    **out-of-band**: con esta configuración el tráfico OpenFlow utiliza una red privada para comunicarse con el controlador. 
*    **in-band**: con esta configuración el tráfico OpenFlow viaja por la misma red que la red de datos. Esta opción, es la opción por defecto. 



Para configurar el control in-band manualmente se tiene que especificar la ubicación del controlador a la hora de ofprotocol. También se debe configurar la interfaz de red como el puerto local OpenFlow para permitir que ofprotocol se conecte el controlador. 

El puerto local OpenFlow es un puerto de red virtual que ofprotocol conecta a los puertos físicos del conmutador. El nombre del dispositivo de red del puerto local puede especificarse en la línea de comandos ofdatapath, utilizando la opción --local-port. A menudo es tap0.



### Binario  **`ofdatapath`**

La herramienta de `ofdatapath` es una implementación de espacio de usuario para una datapath OpenFlow. Este monitorea una o más interfaces de red, las cuales reenviarán paquetes este ellas de acuerto a la politica de reenvio descrita en las tablas de flujos. 

```
ofdatapath [options] -i netdev[,netdev]...  method [method]... 
```

Cuando este binario se usa junto al binario `ofprotocol`, se conforma lo que se conoce como BOFUSS (Basic OpenFlow Software Switch). 

Para el acceso a las interfaces de red, el binario normalmente tiene que correr como root. Otro detalle a tener en cuenta es como los binarios se van a comunicar entre si, normalmente se lleva a cabo mediante un socket UNIX, pero tambien se puede llevar a cabo mediante una conexión TCP para llevara a cabo una conexión pasiva.

*    `punix:file`, escucha por una conexión en el descriptor del socket UNIX indicado
*    `ptcp:[port]`, escucha por conexiones TCP en el puerto por defecto ~~975~~ **6653**.

Esto de puerto por defecto el 975 es más falso que una moneda de tres euros. Prueba rápida:

![](https://hackmd.io/_uploads/HkslN2BIn.png)

![](https://hackmd.io/_uploads/rycbE3S83.png)

A pastar perro sanche :joy_cat: además dejo por aquí el link del puerto en cuestión donde se define.

https://github.com/CPqD/ofsoftswitch13/blob/master/include/openflow/openflow.h#LL75C1-L75C27

Sigamos con los parametros de configuración del software switch. Uno de los más importantes, es indicar los puertos a gestionar el switch. Es decir, que interfaces va a manejar. 

*    `-i, --interfaces=netdev[,netdev]` Con este comando indicamos cada puerto que tendrá el switch. Cada interfaz se le asiganará un número de puerto. Otro, detalle a tener en cuenta es que las interfaces no pueden tener IPs. 
*    `-L, --local-port=netdev`, Con este comando indicamos el puerto local que tendrá el switch el cual será la interfaz física o virtual, que se usará para el control in-band. Cuando está opción no está indicada, por defecto, se creará una interfaz de tipo tap, `tap0` o algo así, la cual se utilizará para el control del software switch. Si no se quiere dejar como responsabilidad al Kernel  la de asignar un nombre a la interfaz tap, se puede indicar como `--local-port=tap:name`. Se crea [aquí](https://github.com/CPqD/ofsoftswitch13/blob/master/lib/netdev.c#L705). Para más información sobre las interfaces tun/tap, ver el anexo X.
*    `--no-local-port`, se le indica al software switch que no va a utilizar un puerto local, ergo, no podremos trabajar en modo in-band.
*    `--no-slicing`, se utiliza para deshabilitar la configuración de las colas asociadas a los puertos. Por ello, cadatendrá un total de 0 colas. Esta opción se suele utilizar cuando algunas de las configuraciones de colas (tc y kernel) no se encuentran disponibles. (Mininet y MIninet-wifi corre el BOFUSS con esta opción por defecto)
* `-d, --datapath-id=dpid`, Especifica el Datapath ID Openflow, conocido como `dpid`. Es un identificador del datapath de 16 digitos hexadecimales. Si no se especifica, el `ofdatapath` pilla uno aleatorio. 
   

## Arqueología III :t-rex:  : Debug al BOFUSS


Recordemos nuestro escenario. Vamos a trabajar con MIninet-Wifi, redes inlambricas, ergo, ya no podemos hacer como Boby de pillar shell scripts y ponernos hacer Network Namespaces y veths como enfermos... entonces, que nos toca? Trabajar codo con codo con Mininet-Wifi.

Ahora bien, puede complicarse bastante asi que vamos hacer una primera aproximación, vamos a ejecutar el código de una topología sencilla en modo debug para ver los comandos que se lanzan y despues ya vemos como pasarlo a un shell scripts. Nuestras herramientas de trabajo serán las siguientes:

*    VS Code
*    Mininet-WiFi
*    WIreshark
*    GDB

El script de topología de mininet-wifi a correr es el mismo que se indicó en la section anterior. A continuación se indica la traza.

```log

```

## Referencias chingonas 

*    https://opennetworking.org/wp-content/uploads/2014/10/openflow-spec-v1.3.0.pdf
*    https://github.com/netgroup-polito/netbee
*    https://staff.polito.it/mario.baldi/publications/2005ComNet_NetPDL.pdf
*    