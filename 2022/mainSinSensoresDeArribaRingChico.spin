{Ignorar todavia el comentario, hay que cambiar a nuesstro pineado porque todo se cambio de lugar}

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
  _clkmode = xtal1 + pll16x    'Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz; que hace el xtal1??
  _xinfreq = 5_000_000         'Configura el valor del crystal
  cntMin     = 400      ' Minimum waitcnt value to prevent lock-up
  
  left = 16 ''Estos son los sensores Pepper
  frontLeft = 17
  front = 18
  frontRight = 19
  right = 20

  leftLine = 21 ''Estos son los sensores de linea
  rightLine = 22

  mIzq = 23 ''Los pines para los motores
  mDer = 24

  killSwitchStart = 25 ''El pin para usar el comando de activacion (para empezar)
  ''aca habria que poner mas pines para las estrategias


var
   long us, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, lineaIzq, lineaDer, startSignal
   byte ban
   long Stack[1000] 'Stack space for new cog


PUB Principal

''dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[23..24]~~    ''Salidas motor
dira[16..22]~   ''Entradas sensores
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us

dira[23..24]~~    ''Salidas motor
dira[16..22]~   ''Entradas sensores


outa[mIzq]~
outa[mDer]~ ''Poniendo a 0 por seguridad

parar


cognew(lecturas, @Stack) ''Habilito un nucleo para que en paralelo ejecute la lectura de todos los sensores
cognew(selfStop, @Stack2)


repeat until startSignal ''Para prender
    parar
    ''idea: como aca en paralelo esta leyendo todos los sesnores, ya se puede elegir una materia aca mismo luego

pauseS(2) 'ahora le pongo 2s nomas for the lolz

repeat

  {esto si funciona habria que cambiar por las constantes mencionadas arriba para mejor implementacion}


  while lineaIzq and lineaDer ''Negro es 1, blacno es 0
    if sIzq
      izquierda90 ''tal vez y por la posicion del sensor conviene girar un poco mas de 90 deg

    elseif sDer
      derecha90

    elseif sFrenteIzq
      izquierdacorto
      adelante

    elseif sFrenteDer
      derechacorto
      adelante

    elseif sFrente
      frenterapido
    else
      frente ''aca en vez de ir para el frente lento, podria quedarse quieto y buscar girando o algo asi, a discutir




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
    atras180



pub lecturas
  ''lectura de sensores
  repeat
    sIzq := ina[left]
    sFrenteIzq := ina[frontLeft]
    sFrente := ina[front]
    sFrenteDer := ina[frontRight]
    sDer := ina[right]
    lineaIzq := ina[leftLine]
    lineaDer := ina[rightLine]
    startSignal := ina[killSwitchStart]


pub selfStop | TimeBase, OneMs, Time

  {esto es una medida de seguridad ya que ahora no tenemos 
  kill switch; la idea es que si paso un tiempo suficiente para 
  interpretar que "ya se cayo del ring" que se apague nomas al 
  leer los valores}

  TimeBase := cnt
  OneMS = clkfreq/1000
  repeat
    Time = cnt
    if (Time - TimeBase) > (100 * OneMS) and (lineaIzq==0 or lineaDer==0)
    parar
    reboot ''se supone que el reboot apaga el parallax, mirar referencia


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
  PULSOUT(mIzq,1700)
  PULSOUT(mDer,1700)

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

pub derechacorto | OneMS, TimeBase, Time

'esto podria ponerse en 0 nomas uno y el otro activar como para tener mejor rapidez de reaccion, cuestion de probar

{esto es otra forma de hacer el derecha corto, comparar con el que se tiene en el main}

TimeBase := cnt
OneMS = clkfreq/1000

repeat until !ina[20] 'no se si es esta la notacion (hasta que ya no lea)
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
OneMS = clkfreq/1000

repeat until !ina[18] 'no se si es esta la notacion (hasta que ya no lea)
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
waitcn(TimeBase += 30*OneMS) 'ajustar
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
     BS2.Pulsout(mIzq00)   ' 1 mS pulse
}}
  ClkCycles := (Duration *us) #> cntMin                    ' se pone directo '
                                                           ' - inst. time, min cntMin
  dira[Pin]~~                                              ' Set to output
  !outa[Pin]                                               ' set to opposite state
  waitcnt(ClkCycles + cnt)                                 ' wait until clk gets there
  !outa[Pin]
                                                          ' return to orig. state
  {dira[Pin]
  !outa[Pin]
  TimeBase := cnt
  ClkCycles := (Duration * us) #> cntMin
  waitcnt(TimeBase += ClkCycles)
  !outa[Pin]}                                   'creo que aca no afecta hacer esto porque una vez nomas se hace no es repetitivo


PUB pauseS(time) | TimeBase, OneS              '' Pause for number of seconds
  if time > 0
    TimeBase := cnt
    OneS := clkfreq
    repeat time
      waitcnt(TimeBase += OneS)

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