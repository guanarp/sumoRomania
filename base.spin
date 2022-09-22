{Prueba de sensores
Pin0: Sensor Linea Derecha (0=blanco 1=negro)
Pin1: Sensor Linea Izquierda (0=blanco 1=negro) esto debo de hacer analogico en realidad
Pin2: Control A (0=apagado 1=encendido) ''ver que onda
Pin3: Control B  (0=apagado 1=encendido)   '' same
Pin4: Libre
Pin5: Salida motor derecha    (500=atras 1000=adelante)  verif
Pin6: Salida motor izquierda  (500=adelante 1000=atras)  verif
Pin 7: Libre
Pin 15: Libre
Pin 16: Sensor Objetros atras (0=nada 1=objeto)
Pin 17: Sensor Objetros frente derecha (0=nada 1=objeto)
Pin 18: Sensor Objetros frente  (0=nada 1=objeto)
Pin 20: Sensor Objetros frente izquierda (0=nada 1=objeto)
Pin 22: Sensor Objetros derecha (0=nada 1=objeto)
Pin 23: Sensor Objetros izquierda (0=nada 1=objeto)
}

CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz; que hace el xtal1??
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up

var
   long us
   byte ban
   long Stack[1000] 'Stack space for new cog
PUB Principal
dira[0..3]~     ''Entradas sensores de lineas
dira[4..7]~~    ''Salidas motor
dira[8]~~       ''Led indicador 1
dira[11]~~      ''Led indicador 2
dira[14]~~      ''Parlante
dira[15]~       ''Control remoto
dira[16..23]~   ''Entradas sensores oponentes
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us
PULSOUT(5,750) 'Motor derecha   verif
PULSOUT(6,750) 'Motor izquierda verif
freqout(14,3500,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4000,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4500,30)         ''Genera un sonido para indicar cuando se reinicia
outa[8] := 1
repeat
  repeat while ina[2]==0


  repeat while ina[3]==0
     outa[11] := 1       ' led de la placa
     'contar los 5 seg
          ''repeat
     if ina[18]==1    '   Sensor Objetros frente  (0=nada 1=objeto)
          adelanterapido
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
if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
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
            PULSOUT(6,700) 'Motor izquierda   verif

pub adelanterapido
if (ina[0]==0 or ina[1]==0)        'esperamos por el sensor de lineas 1 es negro
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
              PULSOUT(6,650) 'Motor izquierda   ver

pub derechacorto
repeat 1
  PULSOUT(5,520) 'Motor derecha     ver
  PULSOUT(6,520) 'Motor izquierda   ver
  pause(20)
PULSOUT(5,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(20)

pub izquierdacorto
repeat 1
  PULSOUT(5,980) 'Motor derecha     ver
  PULSOUT(6,980) 'Motor izquierda   ver
  pause(20)
PULSOUT(5,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(20)

pub derecha90    ''verificado
repeat 30
  PULSOUT(5,650) 'Motor derecha     ver
  PULSOUT(6,650) 'Motor izquierda   ver
PULSOUT(5,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(20)

pub izquierda90
repeat 30
  PULSOUT(5,850) 'Motor derecha     ver
  PULSOUT(6,850) 'Motor izquierda   ver
PULSOUT(5,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(20)

pub atras180
repeat 45
  PULSOUT(5,590) 'Motor derecha     ver
  PULSOUT(6,590) 'Motor izquierda   ver
PULSOUT(5,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(20)

PUB PULSOUT(Pin,Duration)  | clkcycles
{{
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout(500)   ' 1 mS pulse
}}
  ClkCycles := (Duration * us * 2 - 1250) #> cntMin        ' duration * clk cycles for 2us
                                                           ' - inst. time, min cntMin
  dira[pin]~~                                              ' Set to output
  !outa[pin]                                               ' set to opposite state
  waitcnt(clkcycles + cnt)                                 ' wait until clk gets there
  !outa[pin]                                               ' return to orig. state

PUB freqout(pin,frequency,duration) | period,pulses,clocks,t
  dira[pin] := 1                     ' 0:Input, 1:Output
  period := 1000000 / frequency                          ' Period in us
  pulses := (duration*1000) / period                     ' Periods required for duration
  clocks := (clkfreq / 1000000 * period)                 ' Half period clocks
  repeat t from 0 to pulses
    outa[pin] := 0                   ' turn on
    waitcnt(clocks + cnt)            ' on time
    outa[pin] := 1                   ' turn off
    waitcnt(clocks + cnt)            ' off time
  dira[pin] := 0

PUB pauses(time) | clocks              '' Pause for number of seconds
  if time > 0
    clocks := (clkfreq * time)
    waitcnt(clocks + cnt)

PUB pause(time) | clocks                 '' Pause for number of milliseconds
  if time > 0
    clocks := ((clkfreq / 1000) * time)
    waitcnt(clocks + cnt)
