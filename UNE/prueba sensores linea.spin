{Prueba de sensores
Pin0: Sensor oponente frente    (1 detecta  0 libre)
Pin1: Sensor oponente trasero   (1 detecta  0 libre)
Pin2: Sensor oponente derecho   (1 detecta  0 libre)
Pin3: Sensor oponente izquierdo (1 detecta  0 libre)
Pin4: Sensor linea izquierdo (1negro 0blanco)
Pin5: Sensor linea derecho   (1negro 0blanco)
Pin6: Salida motor izquierda (500adelante 1000atras)
Pin7: Salida motor derecha   (500atras 1000adelante)
Pin 15: 
Pin 16: 
Pin 17:
Pin 20:
Pin 22:
Pin 23:
}

CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up   

var
   long us     
PUB Principal
dira[0..5]~     ''Entradas sensores
dira[6..7]~~    ''Salidas motor
dira[8]~~       ''Led indicador 1
dira[11]~~      ''Led indicador 2
dira[14]~~      ''Parlante
dira[15]~       ''Control remoto
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us

PULSOUT(6,750) 'Motor izquierda
PULSOUT(7,750) 'Motor derecha

freqout(14,3500,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4000,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4500,30)         ''Genera un sonido para indicar cuando se reinicia

repeat   
  if (ina[5]==1)       
    outa[11] := 0           
  else
      outa[11] := 1
      

  if (ina[3]==1)       
    outa[8] := 0           
  else
      outa[8] := 1
            

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
 