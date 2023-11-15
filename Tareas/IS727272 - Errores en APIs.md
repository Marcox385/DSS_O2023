# Errores comunes de autenticación y autorización en APIs
### IS727272 - Cordero Hernández, Marco Ricardo

_Mejor visto en [GitHub](https://github.com/Marcox385/DSS_O2023/blob/main/Tareas/IS727272%20-%20Errores%20en%20APIs.md)_

## Introducción
En la actualidad, la línea tecnológica se inclina mayoritariamente hacía el desarrollo web, por lo tanto, muchas sendas del aprendizaje del software seguro se están impartiendo sobre este tipo de aplicaciones. Dentro de una página funcional (y no estática) usualmente se tendrá comunicación entre el frontend y el backend, lo cual estaría siendo logrado comúnmente por *APIs*.

## Concepto
Según [Red Hat][1], el acrónimo *API* hace referencia a "Application Programming Interface" (Interfaz de Programación de Aplicación), lo cual a su vez significa el conjunto de instrucciones y protocolos para construir e integrar aplicaciones de software. Diversos tipos de APIs pueden crearse, tanto expuestas al público para interactuar con un servicio privado sin necesidad de exponer el código, o internas dentro de una alguna compañía para facilitar el acceso a componentes o alguna colección de datos parametrizada.  
Actualmente, las dos maneras más conocidas de crear APIs son *SOAP* (Simple Object Access Protocol) y *REST* (REpresentational State Transfer); la primera es un protocolo, y la segunda un patrón arquitectónico, es decir, para REST no hay una regla definida para su creación, sin embargo, los siguientes puntos deben cumplirse para considera a la API como "RESTful":
- Arquitectura cliente-servidor: REST se compone de clientes, servidores, y recursos; las peticiones se manejan a través de HTTP
- Statelessness (Sin estado): Los contenidos del cliente no se almacenan en el servidor entre peticiones, sino que la información de la sesión almacenada en el navegador del cliente
- Cacheability: Haciendo referencia a la memoria caché, su uso puede eliminar la necesidad de itneracciones entre el cliente y el servidor (repetición de datos)
- Sistema de capas: Las interacciones entre el cliente y el servidor pueden ser mediadas (middlewares) por capas adicionales. Estas capas pueden brindar funciones adicionales como balanceo de cargas, caché compartida, o *__seguridad__*
- Código _on demand_ (opcional): El cliente puede ser extendido al contar con la capacidad de recibir código transferido desde el servidor
- Interfaz uniforme: La esencia de la arquitectura REST se divide en cuatro facetas adicional
    - Identificación de recursos en las peticiones: Los recursos solicitados por los usuarios se identifican y se extraen desde las peticiones hechas desde el cliente, y su representación es alterna a lo que se muestra como respuesta de vuelta
    - Manipulación de recursos a través de representaciones: Los clientes reciben archivos que representan recursos, los cuales deben contar con información suficiente para permitir la modificación o eliminación de los recursos originales
    - Mensajes autodescriptivos: Cada mensaje regresado al cliente contiene información suficiente para describir cómo el mismo debe procesar la respuesta
    - Hypermedia como motor del estado de la aplicación: Después de acceder a un recurso, el cliente debe ser capaz de proporcionar todas las acciones posibles a través de hipervínculos

## Tópico principal
Quizás el punto más interesante de las definiciones anteriores resulta ser la _seguridad_ de los recursos en alguna capa media. A este concepto usualmente se le refiere como [**middlewares**][2], a los cuales se les puede ver como un paso intermedio entre el origen y destino de una petición realizada a través de una API. Tanto el concepto como su implementación resultan sencillos de entender, y el impacto que suponen en el entorno global de una aplicación en términos de seguridad resulta altamente beneficioso, por ejemplo, el uso de [JSON WEB Token (JWT)][3] podría bastar en un flujo sencillo de autenticación y autorización hacía y de recursos dentro de una API, de forma que únicamente a ciertos usuarios se les permite el acceso a ciertos recursos. La pregunta que en esta ocasión se formula es ¿Qué pasa cuando estas verificaciones básicas no se realizan?

## Errores comunes de autenticación y autorización de APIs
Dentro de cualquier tipo de desarrollo existirán errores que resultarían en un uso indebido de los bienes tecnológicos con fines generalmente no benignos, pero, en las APIs, al ser los componentes de las aplicaciones que muestran y manipulan datos, esto puede llegar a ser catastrófico. A continuación se presenta una [colección de errores][4] comunes que podrían encontrarse dentro de las mismas:
1. Ausencia de autenticación  
    En el más básico de los ejemplos, contar con APIs expuestas públicamente sin ningún mecanismo de autenticación puede resultar en filtración de datos valiosos para la operación de un negocio o hacerlo propenso a ataques [DDoS][5]. Considerando la arquitectura inicial del backend de una aplicación hecha en Javascript, se tiene el siguiente código:
    ```javascript
    const express = require('express');
    const path = require('path');
    const app = express();

    const users = ('', (req, res) => {
        const usersFile = path.join(__dirname,'..', '..', 'db', 'users.csv');
        res.sendFile(usersFile);
    });

    app.use('/users', users);
    ```
    El ejemplo hace uso de [Express][6], un framework de renombre en desarrollo web a través de Javascript, el cual permite la inclusión de middlewares para la estructura general del servicio que desplega. El componente en cuestión tendría que estar a la mitad de los argumentos de `app.use('/users', users)` para verificar la procedencia de la petición y quién la realiza. Evidentemente, al no hacer esta verificación básica, el (falso) archivo de usuarios sería accedido sin mayor complicación (las bases de datos no deberían ser manejadas en formato csv, pero eso va más allá del alcance del trabajo actual).

2. Verificaciones básicas  
    Aunque parezca increíble, algunas implementaciones de APIs <u>únicamente</u> revisan si las peticiones contienen tokens de autenticación, pero, no revisan si estos son válidos o si han expirado:
    ```javascript
    const express = require('express');
    const path = require('path');
    const app = express();

    const users = ('', (req, res) => {
        const usersFile = path.join(__dirname,'..', '..', 'db', 'users.csv');
        res.sendFile(usersFile);
    });

    const tokenVerification = (req, res, next) => {
        if (req.body['token']) next();

        console.log('Token missing!');
    }

    app.use('/users', tokenVerification, users);
    ```    
    Como se puede apreciar, el middleware creado únicamente valida la existencia de un parámetro `token` dentro de la petición, pero no verifica su contenido, expiración, validez de formato, etc. Esta validación, aunque aún perteneciente al terreno de lo básico, resulta esencial e igual de importante que las de mayor nivel de complejidad, incluso siendo este el paso habilitador para procesos subsecuentes.

3. Proliferación de tokens  
    Una vez que se descubre el amplio mundo de las autenticaciones en las APIs, también se encontrará el factor de la decisión por un método integral de autenticación y autorización con lógica interna. Pero, si la oferta es tan extensa ¿Por qué no tomar todos los métodos posibles? A mayor métodos de seguridad, mejor ¿No es así? Considerando el código anterior con algunas adiciones, se tendría lo siguiente:
    ```javascript
    const tokenVerification = (req, res, next) => {
        // Formato de token general
        if (req.body['token']) {
            // Validar token y luego continuar
            next();
        }

        // X-api-token
        if (req.body['x-api-token'] || req.body['X-api-token'] || ...) {
            // Validar token y luego continuar
            next();
        }

        // Formato interno para JWT
        if (req.body['jwtoken']) {
            // Validar token y luego continuar
            next();
        }

        // Passport
        if (req.body['jwt']) {
            passport.authenticate('jwt');
            next;
        }

        ...

        console.log('Token missing!');
    }
    ```
    De contar con seguridad nula, se pasa a una sobrecarga de métodos, lo cual eventualmente resultará en una prominente dificultad de la mantención de cada uno de ellos, puesto que se puede dar el caso en donde una estrategia afecte directamente a las otras y por ende al flujo global de la aplicación. También, se debe tener en cuenta que cantidad no significa calidad, y como se dice, una cadena es tan fuerte como su eslabón más débil; en otras palabras, si una sola parte de la implementación general es débil en cuestiones de seguridad, todas las demás habrán perdido su sentido.

# Referencias
[What is an API?. Red Hat.][1]  
[What is middleware?. Red Hat.][2]  
[JSON Web Token (JWT). IETF.][3]  
[API Security Best Practices: Avoiding the Top 5 Authentication Errors. Cequence Security, Inc..][4]  
[What is a DDoS attack?. Cloudflare][5]  
[Express. OpenJS Foundation.][6]

[1]:https://www.redhat.com/en/topics/api/what-are-application-programming-interfaces
[2]:https://www.redhat.com/en/topics/middleware/what-is-middleware
[3]:https://datatracker.ietf.org/doc/html/rfc7519
[4]:https://www.cequence.ai/blog/cybersecurity-case-studies/api-security-need-to-know-top-5-authentication-pitfalls/
[5]:https://www.cloudflare.com/learning/ddos/what-is-a-ddos-attack/
[6]:https://expressjs.com/
