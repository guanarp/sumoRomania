{Prueba de sensores
Esta parte del comentario es todo de codigo reciclado no le estoy dando mucha bola todaavia pero cuando vaya a documentar voy a corregir bien
Pin0: Sensor Linea izquierda (0=blanco 1=negro)
Pin1: Sensor Linea derecha (0=blanco 1=negro) esto debo de hacer analogico en realidad, veremos cuando lleguen
Pin2: Control A (0=apagado 1=encendido) ''ver que onda, estos ya existian en el codigo anteriormente, yo dejo porque podria usar nomas
Pin3: Control B  (0=apagado 1=encendido)   ''En realidad deberia de tener 5 de estos porque 5 pines de control habrian (4 de estrategia 1 para prender)
Pin4: Libre
Pin5: Salida motor izquierda    (1000=atras 2000=adelante)  verif
Pin6: Salida motor derecha  (1000=atras 2000=adelante)  verif con conexionado
Pin 7: Libre
Pin 15: Libre no anda
Pin 16: Sensor Objetos atras (0=nada 1=objeto)
Pin 17: Sensor Objetos izquierda (0=nada 1=objeto)
Pin 18: Sensor Objetos frente izquierda  (0=nada 1=objeto)
Pin 20: Sensor Objetos frenet (0=nada 1=objeto)
Pin 22: Sensor Objetos frente derecha (0=nada 1=objeto)
Pin 23: Sensor Objetos derecha (0=nada 1=objeto)
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
dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[5..6]~~    ''Salidas motor
dira[16..23]~   ''Entradas sensores oponentes (8 sensores)
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us
PULSOUT(5,1500) 'Motor1 siempre inicia apagado
PULSOUT(6,1500) 'Motor2 siempre inicia apagado

outa[8] := 1 ''no se que es esto creo que una lucecita
repeat
  outa[11] := 1       'led random, puedo sacar
  'contar los 5 seg
  ''repeat

  repeat until ina[2]
    PULSOUT(5,1500) 'Motor1 siempre inicia apagado
    PULSOUT(6,1500) 'Motor2 siempre inicia apagado

  {esto si funciona habria que cambiar por las constantes mencionadas arriba para mejor implementacion}

  if ina[16]
    atras

  elseif ina[17]
    izquierda90

  elseif ina[23]
    derecha90
  
  elseif ina[18]
    izquierdacorto
  
  elseif ina[20]
    derechacorto
  
  'aca hay que pensar bien como se puede aprovechar el paralelismo para los sensores
  


  {esta parte no es mi codigo, a cambiar todavia. La idea seria despues meter un selector de estrategia tambien}  
  if ina[19]==1    ' Sensor en frente; no se si hace falta el ==1, creo que lo ideal seria aca que este tenga corta distancia (media); u con otro sensor confirmar para que sea rapido
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
              adelante

  outa[11] := 0
  PULSOUT(5,750) 'Motor derecha   verif
  PULSOUT(6,750) 'Motor izquierda verif

pub adelante        ''Verificado
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
    repeat 40
            PULSOUT(5,600) 'Motor derecha  verif
            PULSOUT(6,900) 'Motor izquierda  verif
    repeat 40
          PULSOUT(5,580) 'Motor derecha     ver
          PULSOUT(6,580) 'Motor izquierda   ver
  PULSOUT(5,750) 'Motor derecha  ver
  PULSOUT(6,750) 'Motor izquierda ver
  pause(20)
else
            PULSOUT(5,800) 'Motor derecha     verif
            PULSOUT(6,700) 'Motor izquierda   verif}

pub adelanterapido
{if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
      repeat 40
              PULSOUT(5,600) 'Motor derecha  ver
              PULSOUT(6,900) 'Motor izquierda  ver
      repeat 40
          PULSOUT(5,580) 'Motor derecha     ver
          PULSOUT(6,580) 'Motor izquierda   ver
      PULSOUT(5,750) 'Motor derecha  ver
      PULSOUT(6,750) 'Motor izquierda ver
      pause(20)
else
              PULSOUT(5,850) 'Motor derecha     ver
              PULSOUT(6,650) 'Motor izquierda   ver}

pub derechacorto | OneMS, TimeBase, Time

'esto podria ponerse en 0 nomas uno y el otro activar como para tener mejor rapidez de reaccion, cuestion de probar

TimeBase := cnt
OneMS = clkfreq/1000

repeat until !ina[20] 'no se si es esta la notacion (hasta que ya no lea)
  Time := cnt
  PULSOUT(5,1040)
  PULSOUT(6,1040)
  if (Time - TimeBase) > 15 * OneMS
    quit
PULSOUT(5,1500)
PULSOUT(6,1500)


pub izquierdacorto | OneMS, TimeBase, Time
{repeat 1
  PULSOUT(5,980) 'Motor derecha     ver
  PULSOUT(6,980) 'Motor izquierda   ver
  pause(20)
PULSOUT(5,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(20)}
TimeBase := cnt
OneMS = clkfreq/1000

repeat until !ina[18] 'no se si es esta la notacion (hasta que ya no lea)
  Time := cnt
  PULSOUT(5,1960)
  PULSOUT(6,1960)
  if (Time - TimeBase) > 15 * OneMS
    quit
PULSOUT(5,1500)
PULSOUT(6,1500)


pub derecha90 | OneMS, TimeBase    ''comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(5,1300)
PULSOUT(6,1300)
waitcn(TimeBase += 30*OneMS) 'ajustar 
PULSOUT(5,1500) 
PULSOUT(6,1500) 
'pause(20)

pub izquierda90 | OneMS, TimeBase 'comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(5,1900) 
PULSOUT(6,1900) 
waitcnt(TimeBase += 30*OneMS) 'ajustasr
PULSOUT(5,1500) 
PULSOUT(6,1500) 
'pause(20)

pub atras | OneMS, TimeBase ''comprobar
TimeBase := cnt
OneMS := clkfreq / 1000

PULSOUT(5,1200) 
PULSOUT(6,1200)
waitcnt(TimeBase += 40*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar 
PULSOUT(5,1500) 
PULSOUT(6,1500) 
'pause(20)

PUB PULSOUT(Pin,Duration)  | ClkCycles, TimeBase
{{
   esta descripcion es dudosa pero bueno
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout(500)   ' 1 mS pulse
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


PUB pauseSec(time) | clocks, TimeBase, OneS              '' Pause for number of seconds
  if time > 0
    TimeBase := cnt
    OneS := clkfreq
    repeat time
      waitcnt(TimeBase += OneS)

PUB pausems(time) | clocks, TimeBase, OneMS                 '' Pause for number of milliseconds
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