# Sistemas Digitales
Trabajo práctico N°1: Implementación de un Sistema Secuencial
----
El objetivo del trabajo práctico fue implementar un circuito secuencial con la finalidad de controlar un cruce de calles con dos semáforos. Para lograr este objetivo se planteó 6 estados posibles:

```vhdl
type state is(vr, ar0, ar1, ra0, ra1, rv)
```
Codificando el color del primer semaforo en la primer columna y el segundo en la segunda.

Para el pasaje entre los distintos estados se utilizaron 2 contadores. Uno que cuenta hasta 3 segundos y el otro cuenta hasta 10 sumando 1 cada vez que el primer contador llega a 3 segundos. 

y el diagrama de estados es el siguiente: [diagrama](https://www.canva.com/design/DAGS_wTfiOU/q404G--gAez69Ve8bOcunA/edit?utm_content=DAGS_wTfiOU&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)



