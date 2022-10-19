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
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
  cntMin     = 400

  left = 13 ''Estos son los sensores Pepper
  frontLeft = 8
  front = 9
  frontRight = 10
  right = 11

  leftLine = 4 ''Estos son los sensores de linea
  rightLine = 5

  mIzq = 23 ''Los pines para los motores
  mDer = 27

  signoIzq = 25 ''hay dos pines mas que hay que soldar para este caso
  signoDer = 24

  topLeft = 20
  topFront = 21
  topRight = 22 ''Ult pin de IO

  rfA = 0



var
   long us, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, lineaIzq, lineaDer, startSignal, sTopIzq, sTopFrente, sTopDer, sRfA, sRfB, sRfC, sRfD, killSwitch
   long Stack[1000] 'Stack space for new cog
   long Stack2[1000]

   long  duty1
   long  duty2
   long  period

   long  pwmstack[32]

PUB Principal
''dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
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

repeat until startSignal ''Para prender
  parar
    ''idea: como aca en paralelo esta leyendo todos los sesnores, ya se puede elegir una materia aca mismo luego



repeat until killSwitch ''este bucle si ya es de trabajo del bot

  {Hasta ahora esta estrategia tiene solamente todos los sensores peppers, hay que poner despues un arbol de decisiones para los keyence
  que van a estar arriba}

  {Trata primero de corregir los lugares que mas tardaria en colocarse bien, lo ultimo que decide es ir de frente}
  repeat while (lineaIzq and lineaDer) ''Negro es 1, blacno es 0
    if sIzq==0
      izquierda90PWM ''tal vez y por la posicion del sensor conviene girar un poco mas de 90 deg

    elseif sDer==0
      derecha90PWM

    elseif sTopIzq
      izquierda45PWM
      pararPWM

    elseif sTopDer
      derecha45PWM
      pararPWM

    elseif sTopFrente
      adelantePWM
      ''parar se podria hacer que vaya un poco al frente y luego quedarse quieto

    ''aca es otro if porque esto no es exclusivo con los sensores anteriores
    if sFrenteIzq==0
      izquierdacortoPWM
      ''adelante

    if sFrenteDer==0
      derechacortoPWM
      ''adelante

    if sFrente
      adelanterapidoPWM
    else
      pararPWM ''aca en vez de ir para el frente lento, podria quedarse quieto y buscar girando o algo asi, a discutir





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
    atras180PWM
    {PULSOUT(mIzq,1000) 'Motor derecha   verif  ''Esto deberia de ser un atras"
    PULSOUT(mDer,1000)} 'Motor izquierda verif



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
    startSignal := ina[rfA]
    sTopIzq := ina[topLeft]
    sTopFrente := ina[topFront]
    sTopDer := ina[topRight]


pub lecturas2
  ''lectura de sensores
  repeat
    sRfA := ina[rfA]
    ''provisoriamente es lo siguiente
    startSignal := ina[rfA]
    killSwitch := ina[rfC]


{pub kill
  repeat
    if killSwitch
      reboot}


pub adelante

  PULSOUT(mIzq,1400)
  PULSOUT(mDer,1600)

pub adelantePWM
  outa[signoIzq]~~ ''~~ es alto; ~ es bajo
  outa[signoDer]~~
  set_duty(1,5)
  set_duty(2,5)


pub adelanterapido
  PULSOUT(mIzq,2000)
  PULSOUT(mDer,2000)

pub adelanterapidoPWM
  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

pub adelanteLento
  PULSOUT(mIzq,1350)
  PULSOUT(mDer,1650)

pub adelanteLentoPWM
  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,2)
  set_duty(2,2)


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

pub derechacortoPWM | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000
  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt

    outa[signoIzq]~~
    outa[signoDer]~
    set_duty(1,10)
    set_duty(2,10)

    if (Time - TimeBase) > 15 * OneMS
      quit

    outa[signoIzq]~~
    outa[signoDer]~~




pub izquierdacorto | OneMS, TimeBase, Time
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

pub izquierdacortoPWM | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000
  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt

    outa[signoIzq]~
    outa[signoDer]~~
    set_duty(1,10)
    set_duty(2,10)

    if (Time - TimeBase) > 15 * OneMS
      quit

    outa[signoIzq]~~
    outa[signoDer]~~


pub derecha90 | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1300)
  PULSOUT(mDer,1300)
  waitcnt(TimeBase += 30*OneMS) 'ajustar
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub derecha90PWM | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~~
  outa[signoDer]~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 30*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)
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

pub derecha45PWM | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~~
  outa[signoDer]~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 15*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)

pub izquierda90 | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1900)
  PULSOUT(mDer,1900)
  waitcnt(TimeBase += 30*OneMS) 'ajustasr
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub izquierda90PWM | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 30*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)

pub izquierda45 | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  PULSOUT(mIzq,1900)
  PULSOUT(mDer,1900)
  waitcnt(TimeBase += 15*OneMS) 'ajustasr
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  'pause(20)

pub izquierda45PWM | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 15*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)

pub atras180 | OneMS, TimeBase ''comprobar
    TimeBase := cnt
    OneMS := clkfreq / 1000

    PULSOUT(mIzq,1200)
    PULSOUT(mDer,1200)
    waitcnt(TimeBase += 40*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
    PULSOUT(mIzq,1500)
    PULSOUT(mDer,1500)
    'pause(20)

pub atras180PWM | OneMS, TimeBase ''comprobar
    TimeBase := cnt
    OneMS := clkfreq / 1000

    outa[signoIzq]~
    outa[signoDer]~~
    set_duty(1,10)
    set_duty(2,10)
    waitcnt(TimeBase += 40*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
    set_duty(1,0)
    set_duty(2,0)
    'pause(20)

pub parar
  set_duty(1,0)
  set_duty(2,0)


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

pub start_pwm(p1, p2, freq)
  ''if your PWM frequency is lower than about 35kHz, you can do this in Spin

  period := clkfreq / (1 #> freq <# 35_000)                     ' limit pwm frequency

  cognew(run_pwm(p1, p2), @pwmstack)                            ' launch pwm cog



pub set_duty(ch, level)

  level := 0 #> level <# 100                                    ' limit duty cycle

  if (ch == 1)
    duty1 := -period * level / 100
  elseif (ch == 2)
    duty2 := -period * level / 100



pub run_pwm(p1, p2) | t                                         ' start with cognew

  if (p1 => 0)
    ctra := (%00100 << 26) | p1                                 ' pwm mode
    frqa := 1
    phsa := 0
    dira[p1] := 1                                               ' make pin an output

  if (p2 => 0)
    ctrb := (%00100 << 26) | p2
    frqb := 1
    phsb := 0
    dira[p2] := 1

  t := cnt                                                      ' sync loop timing
  repeat
    phsa := duty1
    phsb := duty2
    waitcnt(t += period)


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