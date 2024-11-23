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


Trabajo práctico N°2: Aritmética de Punto Flotante
----
El objetivo del trabajo práctico fue implementar un circuito que pueda operar con sumas, restas y multiplicaciones respetando la aritmética de punto flotante.

- Multiplicador: En los test del multiplicador hay algunos casos que mi código no los pasa. Luego de debuguear que era lo que estaba sucediendo me di cuenta que en los tests se toman 2 consideraciones, el exponente máximo a representar va a ser el ``` (others => ‘1’) & ‘0’ ``` y cuando haya que saturar un número ese va a ser su exponente. En cambio en mi código determine ( por lo visto en clase) que el exponente máximo y de saturación si se da el caso sea ``` (others => ‘1’)``` . Adjunto una captura de lo que sucede:

<div align="center">
    <img width="70%" src="img/multiplicador_test_problema.png">
</div> 

Para compilar el codigo:
</br>
```bash
make multiplicador
```
Para compilar visualizar el gtkwave:
</br>
```bash
make viewm
```

- Sumador: Para poder determinar el tipo de operación a hacer (suma/resta) se indica seteando un bit de entrada al circuito, '1' indica resta y '0' indica suma.

Para compilar el codigo:
</br>

```bash
make sumador
```

Para compilar visualizar el gtkwave:
</br>
```bash
make views
```

Trabajo práctico N°3: Cordic
----
El objetivo del trabajo práctico fue implementar un circuito que pueda rotar vectores siguiendo el algoritmo cordic visto en clase. Se describieron 3 diseños distintos del cordic, de manera iterativa, de manera desenrollada y desenrollada pipeline. La señal ```vhdl ack='1'``` indica que el dato esta disponible a la salida del cordic.

- Diseño iterativo: Cada etapa del cordic se ejecuta en un ciclo del reloj. Si se busca hacer el algoritmo cordic en n etapas, se va a requerir n ciclos del clock para obtener el resultado.
Para compilar y visualizar el codigo:
</br>

```vhdl
-- En el archivo pre_cordic linea 46 
cor_type: entity work.cordic_iter
``` 

```bash
# Por consola
make enrollado
```

- Diseño desenrollado:  El cordic esta implementado de forma asíncronica, por lo que luego de un transitorio la respuesta va a estar disponible a la salida del cordic.
Para compilar y visualizar el codigo:
</br>

```vhdl
-- En el archivo pre_cordic linea 46 
cor_type: entity work.cordic_des
``` 

```bash
# Por consola
make desenrollado
```

- Diseño desenrollado-pipe:  En este caso mezclamos ambas cosas, el primer resultado se va a obtener luego de n clocks y luego los siguientes resultados van a ser entregados cada flanco del clock.
Para compilar y visualizar el codigo:
</br>

```vhdl
-- En el archivo pre_cordic linea 46 
cor_type: entity work.cordic_pipe
``` 

```bash
# Por consola
make pipe
```
