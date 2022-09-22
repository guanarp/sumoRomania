{Prueba Sensor de lineas Ñaro
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
Pin 23: Sensor Objetros izquierda (0=nada 1=objeto) }
OBJ

                  
CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
  cntMin     = 400      ' Minimum waitcnt value to prevent lock-up 
var
long us, a ,frontal, trasero,linea_adelante_derecha, linea_atras_derecha,linea_adelante_izquierda, linea_atras_izquierda
long Stack[1000] 'Stack space for new cog   
long Stack2[1000] 'Stack space for new cog   

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
'cognew (control, @Stack) 


repeat
  repeat while ina[0]==0

    outa[8] := 1

   
  outa[8] := 0    
  
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
PUB PAUSE_uS(Duration) | clkCycles
{{
   Causes a pause for the duration in uS
   Smallest value is 20 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pause_uS(1000)   ' 1 mS pause
}}
   clkCycles := Duration * clkfreq / 1_000_000  #> 400                    ' duration * clk cycles for us
                                                           ' - inst. time, min cntMin 
   waitcnt(clkcycles + cnt)                                ' wait until clk gets there                             
    