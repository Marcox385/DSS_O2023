# Common Weakness Enumeration vs CERT coding standards
### IS727272 - Cordero Hernández, Marco Ricardo

Para la investigación actual, se ha hecho uso principal del artículo [*What is the Connection Between CERT & CWE?*][1], en donde, entre otras cosas, se detalla cómo el 90% de los problemas de seguridad de software son a causa de errores de código, por lo cual las prácticas y estándares de código seguro son esenciales.

## Common Weakness Enumeration (Enumeración de vulnerabilidades comúnes)
Hace referencia a una lista de tipos de vulnerabilidades encontradas en software y hardware, la cual es desarrollada por una *comunidad* independiente de usuarios/desarrolladores.  
Su propósito es el de brindar un lenguaje común, una herramienta de medición para herramientas de seguridad, y un punto de partida para esfuerzos de identificación, mitigación y prevención de vulnerabilidades.  
También, proveé con nombres y descripciones para que las herramientas de análisis de software puedan ser utilizadas para identificar errores de código y los defectos que los causan.  
Adicional a lo anterior, este sistema permite a los desarrolladores diseñar y dar una mejor arquitectura a sus aplicaciones a través de la *enumeración* para vulnerabilidades de diseño y arquitectura, así como errores de diseño y código a bajo nivel.

## Estándares de código seguro CERT
El equipo de respuesta de emergencias de computación (*CERT* por sus siglas en inglés) se dedica a desarrollar estándares de código para los lenguajes C, C++ y Java. La manera en que esto se logra es a través de contribuciones públicas de un amplio rango de *comunidades* de ingenieros de software al rededor del mundo.  
Los estándares definidios por esta entidad están fuertemente documentados y diseñados para asegurar su cumplimiento dentro de equipos de desarrolladores para asegurar que el código de alta calidad y seguridad sea creado.  
Al seguir un conjunto uniforme de reglas, los desarrolladores pueden colaborar a través de pautas establecidas por una organización en vez de sus propias preferencias, las cuales podrían no ser completamente implementadas ni probadas.  
Una vez que los estándares desesados han sido establecidos en una organización, pueden ser usados cuantitativamente para evaluar la calidad y vulnerabilidades del código fuente de un proyecto. Esto es logrado a través de revisiones de código manuales o automatizadas usando herramientas de análiticas.  
Finalmente, los estándares de CERT incluyen normas para evitar los errores en código e implementación, así como errores de diseño en bajo nivel.


## Similitudes
La siguiente demostración de similitudes es extraída desde las páginas oficiales de [*Common Weakness Enumeration*][2] y [*SEI CERT Codign Standards*][3].

### Operaciones inseguras con archivos
- **CWE**: CWE-377 (Insecure Temporary File)
- **CERT**: Rec. 09. Input Output (FIO)
```python
f = open('archivo.txt', 'r') # No se comprueba que el archivo exista previo a su apertura
```

### Manejo de errores
- **CWE**: CWE-391 (Unchecked Error Condition)
- **CERT**: Rec. 12. Error Handling (ERR)
```python
try:
    y = int(input('Introduce un número'))   # Puede causar un error
    x = 100 / y                             # Puede causar un error
except ZeroDivisionError as e:
    print('Error: División entre 0', e)
except ValueError as e:
    print('Error: Entrada inválida', e)
else:
    print(f'Resultado = {y}')
finally:
    print('Saliendo...')
```

### Control de acceso
- **CWE**: CWE-284 (Improper Access Control)
- **CERT**: Rec. 10. Environment

```php
<?php
session_start();

if (!isset($_SESSION['authenticated']) || $_SESSION['authenticated'] !== true) { // No tiene suficiente protección
    header("Location: login.php");
    exit();
}

echo "Welcome to the protected page!";
?>
```

# Referencias
[What is the Connection Between CERT & CWE?. Xcalibyte.][1]  
[Common Weakness Enumeration. CWE.][2]  
[SEI CERT Coding Standards. CERT.][3]  

[1]:https://xcalibyte.com/what-is-the-connection-between-cert-cwe/
[2]:https://cwe.mitre.org/index.html
[3]:https://wiki.sei.cmu.edu/confluence/display/seccode/SEI+CERT+Coding+Standards
