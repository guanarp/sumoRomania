{Prueba de sensores
Pin0: Sensor Linea Derecha (0=blanco 1=negro)
Pin1: Sensor Linea Izquierda (0=blanco 1=negro)
Pin2: Control A (0=apagado 1=encendido)
Pin3: Control B  (0=apagado 1=encendido)
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
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up
var
   long us, ban
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
PULSOUT(5,750) 'Motor derecha
PULSOUT(6,750) 'Motor izquierda
freqout(14,3500,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4000,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4500,30)         ''Genera un sonido para indicar cuando se reinicia
cognew (control, @Stack)
ban:=0
repeat
  if (ban==1)
    repeat 5
          PULSOUT(5,600) 'Motor
          PULSOUT(6,900) 'Motor
          pause(20)
    repeat 5
          PULSOUT(5,750) 'Motor
          PULSOUT(6,750) 'Motor
                    pause(20)
    repeat 5
      if (ina[15]==1)
          PULSOUT(5,900)
          PULSOUT(6,600)
          pause(20)
    repeat 5
          PULSOUT(5,750)
          PULSOUT(6,750)
          pause(20)
  else
          PULSOUT(5,750)
          PULSOUT(6,750)
          pause(20)

pub control
repeat
  if ina[2]==1        'esperamos por el control
      if ban==0
         ban:=1
      else
         ban:=0
      pause(500)


PUB PULSOUT(pin,Duration)  | clkcycles
{{
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout(500)   ' 1 mS pulse
}}
  clkcycles := (Duration * us * 2) #> cntMin        ' duration * clk cycles for 2us
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
