  {Prueba de sensores
Pin0: Sensor Linea Derecha (0=blanco 1=negro)
Pin1: Sensor Linea Izquierda (0=blanco 1=negro)
Pin2: Libre(con resistencia 1k)
Pin3: Libre(con resistencia 1k)
Pin4: Libre
Pin5: Salida motor izquierda    (500=adelante 1000=atras)
Pin6: Salida motor derecha  (500=atras 1000=adelante)
Pin 7: Libre
Pin 15: Control Remoto (0=apagado 1=encendido)
Pin 16: Sensor Objetros atras (0=nada 1=objeto)
Pin 17: Sensor Objetros frente derecha (0=nada 1=objeto)
Pin 20: Sensor Objetros frente izquierda (0=nada 1=objeto)
Pin 22: Sensor Objetros derecha (0=nada 1=objeto)
Pin 23: Sensor Objetros izquierda (0=nada 1=objeto)
}

CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up

var
   long us
PUB Principal
dira[0..3]~     ''Entradas sensores de lineas
dira[4..7]~~    ''Salidas motor
dira[8]~~       ''Led indicador 1
dira[11]~~      ''Led indicador 2
dira[14]~~      ''Parlante
dira[15]~       ''Control remoto
dira[16..23]~   ''Entradas sensores oponentes
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us
PULSOUT(5,750) 'Motor izquierda
PULSOUT(6,750) 'Motor derecha
freqout(14,3500,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4000,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4500,30)         ''Genera un sonido para indicar cuando se reinicia

repeat
  if (ina[15]==1)        'esperamos por el control
    outa[8] := 1       ' led de la placa
    if (ina[17]==1)        'esperamos por el sensor oponente frente derecha

       repeat 1
          PULSOUT(5,520) 'Motor izquierda
          PULSOUT(6,520) 'Motor derecha
          pause(20)
      repeat 5
          PULSOUT(5,750) 'Motor izquierda
          PULSOUT(6,750) 'Motor derecha
          pause(20)

    if (ina[20]==1)        'esperamos por el sensor oponente frente izquierda
         repeat 1
          PULSOUT(5,980) 'Motor izquierda
          PULSOUT(6,980) 'Motor derecha
          pause(20)
      repeat 5
          PULSOUT(5,750) 'Motor izquierda
          PULSOUT(6,750) 'Motor derecha
          pause(20)
  else
      outa[8] := 0
PUB PULSOUT(Pin,Duration)  | clkcycles ''no me convence porque es un lockdown, querria poder hacer algo trasversal como en arduino
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
