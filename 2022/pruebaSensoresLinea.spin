{Ignorar todavia el comentario, hay que cambiar a nuesstro pineado porque todo se cambio de lugar}
{hacer con pasos de 50}

{A toda la implementacion de codigo le falta los sensores Keyence}
{Todos los valores de tiempo para los giros,etc todavia no se probaron y se tienen que corregir, el valor correcto tendremos con los imanes recien
me parece}

{Para los valores que se le pasa al pulsout creo que lo ideal
seria poner en una escala de -100% a 100% y el pulsout ya haga
la conversion, para mejor lectura y dimension de las velocidades}

{Prueba de sensores
Esta parte del comentario es todo de codigo reciclado no le estoy dando mucha bola todaavia pero cuando vaya a documentar voy a corregir bien
Pin0: IGNORAR AHORA Sensor Linea izquierda (0=blanco 1=negro)
Pin1: IGNORAR AHORA Sensor Linea derecha (0=blanco 1=negro) esto debo de hacer analogico en realidad, veremos cuando lleguen
Pin2: Control A (0=apagado 1=encendido) ''ver que onda, estos ya existian en el codigo anteriormente, yo dejo porque podria usar nomas
Pin3: Control B  (0=apagado 1=encendido)   ''En realidad deberia de tener 5 de estos porque 5 pines de control habrian (4 de estrategia 1 para prender)
Pin4: Libre
Pin5: Salida motor izquierda    (1000=atras 2000=adelante)  verif
Pin6: Salida motor derecha  (1000=atras 2000=adelante)  verif con conexionado
Pin 7: Libre
Pin 15: Libre no anda
Pin 16: No hay atras
Pin 17: Sensor Objetos izquierda (0=nada 1=objeto)
Pin 18: Sensor Objetos frente izquierda  (0=nada 1=objeto)
Pin 20: Sensor Objetos frente (0=nada 1=objeto)
Pin 22: Sensor Objetos frente derecha (0=nada 1=objeto)
Pin 23: Sensor Objetos derecha (0=nada 1=objeto)
Pin 24: linea izquierda
Pin 25: linea derecha

pin 30: pin de control para resetear de una el botcito
}

{OJO que solo hasta el pin numero 27 se puede usar, luego son pines especiales
 el pin num 15 parece que no funciona (segun pruebas de korea) asi que mejor no usar
 del 0 al 14 los pines son resistivos y no se tanto como afecta eso por eso estaba saltando, pero creo que no hay drama de los siguientes sensores
 montar en esos pines}

CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
  cntMin     = 400

  left = 16 ''Estos son los sensores Pepper
  frontLeft = 17
  front = 18
  frontRight = 19
  right = 20

  leftLine = 21 ''Estos son los sensores de linea
  rightLine = 22

  mIzq = 23 ''Los pines para los motores
  mDer = 24

  killSwitchStart = 14 ''El pin para usar el comando de activacion (para empezar)
  ''aca habria que poner mas pines para las estrategias
  topLeft = 25
  topFront = 26
  topRight = 27 ''Ult Pin de IO

  rfA = 8 ''Ahora podemos usar uno de ellos como start y el otro como kill
  rfB = 9
  rfC = 10
  rfD = 11


var
   long us, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, lineaIzq, lineaDer, startSignal, sTopIzq, sTopFrente, sTopDer, sRfA, sRfB, sRfC, sRfD, killSwitch
   long Stack[1000] 'Stack space for new cog
   long Stack2[1000]

PUB Principal
''dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[0..6]~~
dira[8..14]~
dira[23..24]~~    ''Salidas motor
dira[16..22]~   ''Entradas sensores
dira[25..27]~ ''Los keyence
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us



outa[mIzq]~
outa[mDer]~ ''Poniendo a 0 por seguridad

PULSOUT(mIzq,1500) 'Motor1 siempre inicia apagado
PULSOUT(mDer,1500) 'Motor2 siempre inicia apagado


cognew(lecturas, @Stack) ''Habilito un nucleo para que en paralelo ejecute la lectura de todos los sensores
cognew(lecturas2, @Stack2)




repeat
  repeat until startSignal ''Para prender
    parar
      ''idea: como aca en paralelo esta leyendo todos los sesnores, ya se puede elegir una materia aca mismo luego


  'pauseS(5) ''tiempo reglamentado

  repeat until killSwitch ''este bucle si ya es de trabajo del bot

    {Hasta ahora esta estrategia tiene solamente todos los sensores peppers, hay que poner despues un arbol de decisiones para los keyence
    que van a estar arriba}

    {Trata primero de corregir los lugares que mas tardaria en colocarse bien, lo ultimo que decide es ir de frente}
    repeat while (lineaIzq and lineaDer) ''Negro es 1, blacno es 0
      adelanteLento
    atras180



    'aca hay que pensar bien como se puede aprovechar el paralelismo para los sensores



    {esta parte no es mi codigo, a cambiar todavia. La idea seria despues meter un selector de estrategia tambien}
    {if ina[19]==1    ' Sensor en frente; no se si hace falta el ==1, creo que lo ideal seria aca que este tenga corta distancia (media); u con otro sensor confirmar para que sea rapido
      'adelanterapido
      adelante
    else
      if ina[22]==1    ' Sensor Objetros derecha (0=nada 1=objeto)
        derecha90
      else
        if ina[23]==1    '      Sensor Objetros izquierda (0=nada 1=objeto)
          izquierda90
        else
          if ina[16]==1    '     Sensor Objetros atras (0=nada 1=objeto)
            atras180
          else
            if ina[17]==1    ' Sensor Objetros frente derecha (0=nada 1=objeto)
              derechacorto
            else
              if ina[20]==1    '     Sensor Objetros frente izquierda (0=nada 1=objeto)
                izquierdacorto
              else
                adelante}


      {creo que algo bueno aca seria preguntar cual de los dos sensores fue el que leyo y a partir de eso corregir, o si no que general sea dar una media vuelta y buscar de nuevo}
    ''atras180
      {PULSOUT(mIzq,1000) 'Motor derecha   verif  ''Esto deberia de ser un atras"
      PULSOUT(mDer,1000)} 'Motor izquierda verif



pub lecturas
  ''lectura de sensores
  repeat
    sIzq := NOT ina[left]
    sFrenteIzq := NOT ina[frontLeft]
    sFrente := NOT ina[front]
    sFrenteDer := NOT ina[frontRight]
    sDer := NOT ina[right]
    lineaIzq := ina[leftLine]
    lineaDer := ina[rightLine]
    startSignal := ina[killSwitchStart]
    sTopIzq := ina[topLeft]
    sTopFrente := ina[topFront]
    sTopDer := ina[topRight]


pub lecturas2
  ''lectura de sensores
  repeat
    sRfA := ina[rfA]
    sRfB := ina[rfB]
    sRfC := ina[rfC]
    sRfD := ina[rfD]
    ''provisoriamente es lo siguiente
    startSignal := ina[rfA]
    killSwitch := ina[rfB]



{pub kill
  repeat
    if killSwitch
      parar}


pub adelante        ''Verificado
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
    repeat 40
            PULSOUT(mIzq,600) 'Motor derecha  verif
            PULSOUT(mDer,900) 'Motor izquierda  verif
    repeat 40
          PULSOUT(mIzq,580) 'Motor derecha     ver
          PULSOUT(mDer,580) 'Motor izquierda   ver
  PULSOUT(mIzq,750) 'Motor derecha  ver
  PULSOUT(mDer,750) 'Motor izquierda ver
  pause(20)
else
            PULSOUT(mIzq,800) 'Motor derecha     verif
            PULSOUT(mDer,700) 'Motor izquierda   verif}
  PULSOUT(mIzq,1600)
  PULSOUT(mDer,1600)

pub adelanterapido
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
      repeat 40
              PULSOUT(mIzq,600) 'Motor derecha  ver
              PULSOUT(mDer,900) 'Motor izquierda  ver
      repeat 40
          PULSOUT(mIzq,580) 'Motor derecha     ver
          PULSOUT(mDer,580) 'Motor izquierda   ver
      PULSOUT(mIzq,750) 'Motor derecha  ver
      PULSOUT(mDer,750) 'Motor izquierda ver
      pause(20)
else
              PULSOUT(mIzq,850) 'Motor derecha     ver
              PULSOUT(mDer,650) 'Motor izquierda   ver}
  PULSOUT(mIzq,2000)
  PULSOUT(mDer,2000)

pub adelanteLento
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
      repeat 40
              PULSOUT(mIzq,600) 'Motor derecha  ver
              PULSOUT(mDer,900) 'Motor izquierda  ver
      repeat 40
          PULSOUT(mIzq,580) 'Motor derecha     ver
          PULSOUT(mDer,580) 'Motor izquierda   ver
      PULSOUT(mIzq,750) 'Motor derecha  ver
      PULSOUT(mDer,750) 'Motor izquierda ver
      pause(20)
else
              PULSOUT(mIzq,850) 'Motor derecha     ver
              PULSOUT(mDer,650) 'Motor izquierda   ver}
  PULSOUT(mIzq,1350)
  PULSOUT(mDer,1650)
  ''PULSOUT2(mIzq,30)
  ''PULSOUT2(mDer,-30)

pub derechacorto | OneMS, TimeBase, Time

'esto podria ponerse en 0 nomas uno y el otro activar como para tener mejor rapidez de reaccion, cuestion de probar, no se giraria sobre propio eje

  TimeBase := cnt
  OneMS := clkfreq/1000

  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt
    PULSOUT(mIzq,1040)
    PULSOUT(mDer,1040)
    if (Time - TimeBase) > 15 * OneMS
      quit

  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)


pub izquierdacorto | OneMS, TimeBase, Time
  {repeat 1
    PULSOUT(mIzq,980) 'Motor derecha     ver
    PULSOUT(mDer,980) 'Motor izquierda   ver
    pause(20)
  PULSOUT(mIzq,750) 'Motor derecha  ver
  PULSOUT(mDer,750) 'Motor izquierda ver
  pause(20)}
  TimeBase := cnt
  OneMS := clkfreq/1000

  repeat until NOT sFrenteIzq 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt
    PULSOUT(mIzq,1960)
    PULSOUT(mDer,1960)
    if (Time - TimeBase) > 15 * OneMS
      quit
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)


pub derecha90 | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1300)
  PULSOUT(mDer,1300)
  waitcnt(TimeBase += 30*OneMS) 'ajustar
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub derecha45 | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1300)
  PULSOUT(mDer,1300)
  waitcnt(TimeBase += 15*OneMS) 'ajustar
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub izquierda90 | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1900)
  PULSOUT(mDer,1900)
  waitcnt(TimeBase += 30*OneMS) 'ajustasr
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub izquierda45 | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1900)
  PULSOUT(mDer,1900)
  waitcnt(TimeBase += 15*OneMS) 'ajustasr
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub atras180 | OneMS, TimeBase ''comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(mIzq,1200)
PULSOUT(mDer,1200)
waitcnt(TimeBase += 40*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
PULSOUT(mIzq,1500)
PULSOUT(mDer,1500)
'pause(20)

pub parar
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)


PUB PULSOUT(Pin,Duration)  | ClkCycles, TimeBase
{{
   esta descripcion es dudosa pero bueno
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.PULSOUT(mIzq00)   ' 1 mS pulse
}}


  {if Value >= 0
    Duration := 1500 + 5*Value
  else
    Duration := 1500 - 5*Value}
  TimeBase := cnt
  ClkCycles := (Duration *us) #> cntMin                    ' se pone directo '
                                                        ' - inst. time, min cntMin
  dira[Pin]~~                                              ' Set to output
  !outa[Pin]                                               ' set to opposite state
  waitcnt(TimeBase += ClkCycles)                                 ' wait until clk gets there
  !outa[Pin]
                                                          ' return to orig. state
  {dira[Pin]
  !outa[Pin]
  TimeBase := cnt
  ClkCycles := (Duration * us) #> cntMin
  waitcnt(TimeBase += ClkCycles)
  !outa[Pin]}                                   'creo que aca no afecta hacer esto porque una vez nomas se hace no es repetitivo



PUB pauseS(time) | TimeBase, OneSec              '' Pause for number of seconds
  if time > 0
    TimeBase := cnt
    OneSec := clkfreq
    repeat time
      waitcnt(TimeBase += OneSec)

PUB pauseMs(time) | TimeBase, OneMS                 '' Pause for number of milliseconds
  if time > 0
    OneMS := clkfreq / 1000 'Calculate cycles per 1 millisecond
    TimeBase := cnt 'Get current count
    repeat time
      waitcnt(TimeBase += OneMS)

{aca puedo hacer algo parecido pero por ejemplo usar un cog donde voy a pausar y que despues retorne nomas un true}



{PUB Toggle | TimeBase, OneMS
  dira[0]~~ 'Set P0 to output
  OneMS := clkfreq / 1000 'Calculate cycles per 1 millisecond
  TimeBase := cnt 'Get current count
  repeat 'Loop endlessly, este es el synced delay
    waitcnt(TimeBase += OneMS) ' Wait to start of next millisecond
    !outa[0] ' Toggle P0

  repeat 'esto es el fixed delay
    !outa[0] 'Toggle pin 0
    waitcnt(5_000 + cnt) 'Wait for 10 ms
  }