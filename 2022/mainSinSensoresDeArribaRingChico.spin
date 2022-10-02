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

CON
  _clkmode = xtal1 + pll16x    'Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz; que hace el xtal1??
  _xinfreq = 5_000_000         'Configura el valor del crystal
  cntMin     = 400      ' Minimum waitcnt value to prevent lock-up
  back = 16
  left = 17
  frontLeft = 18
  front = 19
  frontRight = 20
  right = 21


var
   long us
   byte ban
   long Stack[1000] 'Stack space for new cog


PUB Principal
''dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[23..24]~~    ''Salidas motor
dira[16..22]~   ''Entradas sensores
''us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us

outa[mIzq]~
outa[mDer]~ ''Poniendo a 0 por seguridad

PULSOUT(mIzq,1500) 'Motor1 siempre inicia apagado
PULSOUT(mDer,1500) 'Motor2 siempre inicia apagado



{dira[30]~~
outa[30]~~} ''Poner dos ~~ pone en high

'outa[8] := 1 ''no se que es esto creo que una lucecita

cognew(lecturas, @Stack)
cognew(selfStop, @Stack2)

'300mili


{repeat until ina[2] ''Para prender
    PULSOUT(23,1500) 'Motor1 siempre inicia apagado
    PULSOUT(24,1500) 'Motor2 siempre inicia apagado}

repeat

  'contar los 5 seg
  ''repeat

  pauseS(3) 'ahora le pongo 3s nomas for the lolz

  {esto si funciona habria que cambiar por las constantes mencionadas arriba para mejor implementacion}


  while ina[21] and ina[22] ''no hay kill switch todavia solo con los sens de linea estamos
    if ina[16]
      izquierda90

    elseif ina[20]
      derecha90

    elseif ina[17]
      izquierdacorto
      adelante

    elseif ina[19]
      derechacorto
      adelante

    elseif ina[18]
      frenterapido
    else
      frente




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

    {PULSOUT(23,1000) 'Motor derecha   verif  ''Esto deberia de ser un atras"
    PULSOUT(24,1000)} 'Motor izquierda verif
    atras180



pub lecturas
  ''lectura de sensores
  repeat
    valor := ina[16]
    valor1 := ina[17]
    valor2 := ina[18]
    valor3 := ina[19]
    valor4 := ina[20]
    valor5 := ina[21]
    valor6 := ina[22]


pub selfStop | TimeBase, OneMs, Time

  TimeBase := cnt
  OneMS = clkfreq/1000
  repeat
    Time = cnt
    if (Time - TimeBase) > 100 * OneMS and (ina[24] or ina[25])
      PULSOUT(23,1500)
      PULSOUT(24,1500)                                              ' Set to output
      !outa[30] ''Aca ponemos en low y con esto puenteado deberia de reiniciar el botcito








pub adelante        ''Verificado
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
    repeat 40
            PULSOUT(23,600) 'Motor derecha  verif
            PULSOUT(24,900) 'Motor izquierda  verif
    repeat 40
          PULSOUT(23,580) 'Motor derecha     ver
          PULSOUT(24,580) 'Motor izquierda   ver
  PULSOUT(23,750) 'Motor derecha  ver
  PULSOUT(24,750) 'Motor izquierda ver
  pause(20)
else
            PULSOUT(23,800) 'Motor derecha     verif
            PULSOUT(24,700) 'Motor izquierda   verif}
  PULSOUT(23,1700)
  PULSOUT(24,1700)

pub adelanterapido
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
      repeat 40
              PULSOUT(23,600) 'Motor derecha  ver
              PULSOUT(24,900) 'Motor izquierda  ver
      repeat 40
          PULSOUT(23,580) 'Motor derecha     ver
          PULSOUT(24,580) 'Motor izquierda   ver
      PULSOUT(23,750) 'Motor derecha  ver
      PULSOUT(24,750) 'Motor izquierda ver
      pause(20)
else
              PULSOUT(23,850) 'Motor derecha     ver
              PULSOUT(24,650) 'Motor izquierda   ver}
  PULSOUT(23,2000)
  PULSOUT(24,2000)

pub derechacorto | OneMS, TimeBase, Time

'esto podria ponerse en 0 nomas uno y el otro activar como para tener mejor rapidez de reaccion, cuestion de probar

TimeBase := cnt
OneMS = clkfreq/1000

repeat until !ina[20] 'no se si es esta la notacion (hasta que ya no lea)
  Time := cnt
  PULSOUT(23,1040)
  PULSOUT(24,1040)
  if (Time - TimeBase) > 15 * OneMS
    quit
PULSOUT(23,1500)
PULSOUT(24,1500)


pub izquierdacorto | OneMS, TimeBase, Time
{repeat 1
  PULSOUT(23,980) 'Motor derecha     ver
  PULSOUT(24,980) 'Motor izquierda   ver
  pause(20)
PULSOUT(23,750) 'Motor derecha  ver
PULSOUT(24,750) 'Motor izquierda ver
pause(20)}
TimeBase := cnt
OneMS = clkfreq/1000

repeat until !ina[18] 'no se si es esta la notacion (hasta que ya no lea)
  Time := cnt
  PULSOUT(23,1960)
  PULSOUT(24,1960)
  if (Time - TimeBase) > 15 * OneMS
    quit
PULSOUT(23,1500)
PULSOUT(24,1500)


pub derecha90 | OneMS, TimeBase    ''comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(23,1300)
PULSOUT(24,1300)
waitcn(TimeBase += 30*OneMS) 'ajustar
PULSOUT(23,1500)
PULSOUT(24,1500)
'pause(20)

pub izquierda90 | OneMS, TimeBase 'comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(23,1900)
PULSOUT(24,1900)
waitcnt(TimeBase += 30*OneMS) 'ajustasr
PULSOUT(23,1500)
PULSOUT(24,1500)
'pause(20)

pub atras180 | OneMS, TimeBase ''comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(23,1200)
PULSOUT(24,1200)
waitcnt(TimeBase += 40*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
PULSOUT(23,1500)
PULSOUT(24,1500)
'pause(20)


PUB PULSOUT(Pin,Duration)  | ClkCycles, TimeBase
{{
   esta descripcion es dudosa pero bueno
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.PULSOUT(2300)   ' 1 mS pulse
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