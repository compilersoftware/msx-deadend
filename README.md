# Dead End_ para MSX

Dead End_ está basado en Dead End, el juego del mismo nombre (pero sin el guión bajo) creado para Macintosh por Wolfgang Thaller entre los años 1993 y 1998. Esta versión para MSX se ha portado a partir de las de [ZX Spectrum 48K](https://compiler.speccy.org/spectrum-dead-end_.html), que se presentó al Concurso de BASIC 2020 de Bytemaniacos, y [Amstrad CPC](https://compiler.speccy.org/cpc-dead-end_.html), que se construyó a partir de la primera.

El objetivo del juego es alcanzar la salida de cada mapa. Se aplican las siguientes reglas:

* Los muros no se pueden atravesar.
* Para empujar una caja, tiene que haber espacio tras el personaje (para poder coger carrerilla y empujar) y tras la caja, para que se pueda desplazar.
* No hay límite de movimientos.
* No se ha implementado la funcionalidad de deshacer un movimiento; si nos quedamos atascados solo podemos reiniciar el nivel desde el principio.

## Enfoque

La idea era hacer una traducción directa del listado en BASIC para ZX Spectrum. Como BASIC no es un estándar, cada ordenador de la época implementaba su propio dialecto, también influenciado por sus características técnicas.

Por lo tanto, en ningún caso se ha buscado optimizar el listado original ni modificar su arquitectura; simplemente se han sustituido las instrucciones no disponibles en el BASIC de MSX por instrucciones o conjuntos de instrucciones equivalentes. También se ha intentado no usar ninguna instrucción propia de un modelo de MSX en concreto (y si se ha hecho ha sido por desconocimiento).

En este caso, además, también nos hemos apoyado en el listado para Amstrad, ya que en algunos casos se puede reaprovechar la implementación que se hizo para adaptar el código de la versión Spectrum.

## Herramientas

* El juego se ha desarrollado usando el emulador [CocoaMSX](https://github.com/CocoaMSX/CocoaMSX), inicialmente sobre un modelo Philips NMS-8250 y, posteriormente, también se ha probado en un Sony HB-75P.
* El emulador permite crear ficheros de disco (`.dsk`) y cinta (`.cas`) vacíos para poder usarlos. Pero, en este caso, ha sido necesario el uso de una herramienta externa, [Disk-Manager v0.15](http://www.lexlechz.at/en/software.html) para insertar y extraer el código fuente en la imagen de disco.
* Para generar el fichero en formato cartucho ROM (`.rom`) se ha usado la herramienta [MSX-BASIC ROM Creator](https://www.msxblog.es/msx-basic-rom-creator/).

## Arquitectura del código

* El estado del mapa del juego se guarda en la variable `B`. En algún momento decidí acortar los nombres de las variables no sé por qué motivo.
* Cada vez que se va a hacer un movimiento en una de las cuatro direcciones, se hacen las comprobaciones necesarias. Para ello, se leen siempre las dos casillas siguientes en el sentido del movimiento y la anterior (en sentido contrario):
  * Si la casilla siguiente está vacía, se hace el movimiento sin más.
  * Si la casilla siguiente está ocupada por un muro, no se puede mover.
  * Si la casilla siguiente está ocupada por una caja, y las otras dos que se miran están vacías, se empuja la caja.
  * Hay puntos de entrada, marcados con líneas REM de comentarios, para lo que sería cada "función" del código. De esa forma el código queda más estructurado.
* Se usa Screen 1 en todo el juego.

## Cambios respecto a las versiones de ZX Spectrum y Amstrad CPC

Sólo se reflejan los más relevantes

### Diferencias de sintaxis

* Se ha eliminado el uso de la palabra clave `LET`.
* De los modos de vídeo disponibles en el MSX, hemos optado por usar `Screen 1`, que era el más parecido. En el siguiente apartado se explican los detalles de implementación.
* En Spectrum, el color de tinta se selecciona de entre los disponibles con la palabra clave `INK`. En MSX se usa la palabra clave `COLOR` para establecer los colores de borde, fondo y tinta, entre cualquiera de los 16 disponibles en la paleta. No obstante, `COLOR` establece los colores para toda la pantalla, por lo que usaremos otro enfoque.
* En Spectrum los GDU (Gráficos Definidos por el Usuario) se introducen poniendo el cursor en un modo especial, `[G]`, y usando una de las letras del abecedario. En MSX se puede redefinir todo el juego de caracteres escribiendo directamente en una zona determinada de la memoria, mediante el uso de la palabra clave `POKE`.
* En Spectrum se usa la construcción `PRINT AT y,x` para situar el cursor en las coordenadas (x,y). El origen de coordenadas es el punto (0,0) que está en la esquina superior izquierda. En MSX se usa la palabra clave `LOCATE x,y`. El origen está en el mismo lugar.
* Para formatear los números, en MSX usamos la construcción `PRINT USING "####";` las almohadillas indican el formato.
* MSX carece de la palabra clave `INVERSE`, para pintar un carácter con los atributos invertidos. Hay que simularla redefiniendo el juego de caracteres.
* MSX carece de la palabra clave `BRIGHT`, para modificar el brillo del color empleado. Por el contrario, disponemos de 16 colores para elegir.
* En Spectrum, `GO TO` y `GO SUB` se escriben separado. Sus correspondientes en MSX son `GOTO` y `GOSUB`.
* En Spectrum, la palabra clave `DIM` define un vector de n elementos (con `DIM(n)`). Sin embargo, en MSX, sería un vector de n+1 elementos.
* En MSX, la palabra clave `RESTORE` no admite una variable como parámetro.

### Cambios en la implementación

* La pantalla del Spectrum es de 32x24 caracteres (256x192), exactamente del mismo tamaño que la del MSX en modo `Screen 1`. Estuve algunos días dando vueltas a usar `Screen 1` o `Screen 2`. El segundo modo permite más colores, a costa de no ser un modo de texto, sino gráfico, lo cual habría implicado seguramente cambios (aun) más profundos en el código.
* La diferencia con el Spectrum (y con el Amstrad) está en el tratamiento del color. En los dos primeros se puede establecer un color de fondo diferente para cada carácter, color que se puede establecer justo antes de pintarlo. Es decir, la información de color va asociada a cada celda 8x8 de la pantalla. En el MSX, la información de color va asociada a cada carácter del juego de caracteres. En concreto, en el caso de `Screen 1`, a cada grupo de 8 caracteres; por tanto se pueden asignar colores a 32 grupos de caracteres correlativos. Este tema me costó bastante entenderlo hasta que Jon Cortázar me lo explicó amablemente de forma muy clara.
* En el listado de Spectrum se hace un `CLEAR 59999`, con lo que reservamos la memoria por encima de ese punto para que no la use el BASIC. Se define una variable llamada `BUFFER` como un puntero a la posición de memoria 60000, donde se almacenan los datos de estado del mapa de juego. En MSX hemos decidido usar un vector definido en una variable con el mismo nombre (de hecho se ha renombrado a `B`, por acortar). El problema aparece con el algoritmo que usa el listado de Spectrum para calcular si es posible mover el muñeco y/o empujar una caja. En los bordes superior e inferior, es posible que intentemos leer fuera de la zona de datos. En la versión Spectrum no pasa nada porque, por cómo están construidos los mapas, el dato que se va fuera de rango no se usa, por lo que su valor da igual. En MSX, si hacemos lo mismo, obtendremos errores en tiempo de ejecución. Para solventarlo, se ha implementado una subrutina en la línea 7000, que devuelve 0 si el puntero está fuera de rango.
* Para cargar los datos del nivel en el que estamos, en Spectrum lo hacemos pasando una variable a la palabra clave `RESTORE`. Como en MSX no se puede, se ha implementado una subrutina en la línea 8000.
* En Spectrum, los GDU se definen pokeando la memoria. Los datos están definidos en la línea 9500 y siguientes. En MSX también tenemos que escribir directamente en la memoria, en la de vídeo en este caso, usando la palabra clave `VPOKE`. El juego de caracteres (o <em>tiles</em>) se almacena en la posición 0 y siguientes. Además, como hemos comentado, hay que generar los colores para cada grupo de 8 caracteres, escribiendo en la memoria de vídeo a partir de la dirección `BASE(6)`.
* Como consecuencia de lo anterior, hay que recolocar los tiles de manera inteligente en la memoria, de forma que los que compartan colores se sitúen de manera correlativa.
* Hemos tenido que definir a mano los caracteres con los colores invertidos que se usan el menú, ya que en MSX no disponemos de la palabra clave `INVERSE`.
* En MSX tenemos 16 colores disponibles. Hemos utilizado más o menos los mismos que en ZX Spectrum. La única diferencia es que, para escribir texto, el color es el mismo en toda la pantalla. Por eso, al iniciar y terminar los niveles, se aprecia un efecto extraño con los colores. Se podría haber pulido más para disimularlo, pero se ha decidido no hacer esa optimización.
* En MSX se ha optado por usar `BEEP` para generar un pitido con el movimiento del personaje, sin entrar en nada más elaborado usando la palabra clave `SOUND`.
