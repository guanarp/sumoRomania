{Prueba de todas las salidas de la placa


}
CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
 
var

PUB Principal
dira[0..23]~~    ''Configura como salida los pines del 0 al 23 

freqout(14,3500,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4000,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4500,30)         ''Genera un sonido para indicar cuando se reinicia


repeat
 
  outa[0] := 1
  outa[1] := 1
  outa[2] := 1
  outa[3] := 1
  outa[4] := 1
  outa[5] := 1
  outa[6] := 1
  outa[7] := 1
  outa[8] := 1
  outa[9] := 1
  outa[10] := 1
  outa[11] := 1
  outa[12] := 1
  outa[13] := 1
  outa[15] := 1
  outa[16] := 1
  outa[17] := 1
  outa[18] := 1
  outa[19] := 1
  outa[20] := 1
  outa[21] := 1
  outa[22] := 1
  outa[23] := 1
  freqout(14,5000,100) 
  
  outa[0] := 0
  outa[1] := 0
  outa[2] := 0
  outa[3] := 0
  outa[4] := 0
  outa[5] := 0
  outa[6] := 0
  outa[7] := 0
  outa[8] := 0
  outa[9] := 0
  outa[10] := 0
  outa[11] := 0
  outa[12] := 0
  outa[13] := 0
  outa[15] := 0
  outa[16] := 0
  outa[17] := 0
  outa[18] := 0
  outa[19] := 0
  outa[20] := 0
  outa[21] := 0
  outa[22] := 0
  outa[23] := 0
  pauses(1)
 
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
 