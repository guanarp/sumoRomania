{PINES DESACTUALIZADOS, SI QUIERO USAR CAMBIAR}

{Prueba de sensores
Pin0: Sensor Linea Derecha (0=blanco 1=negro)
Pin1: Sensor Linea Izquierda (0=blanco 1=negro)
Pin2: Control A (0=apagado 1=encendido)
Pin3: Control B  (0=apagado 1=encendido)
Pin4: Libre
Pin5: Salida motor derecha    (
Pin6: Salida motor izquierda   l driver tiene entre 1us y 2 us entonces le paso entre 1000 y 2000. Verificar el stop.
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
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up   {381 dicen que funca}

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
   long us,sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, lineaIzq, lineaDer, startSignal
   long Stack[1000] 'Stack space for new cog
PUB Principal
dira[23..24]~~    ''Salidas motor
dira[16..22]~   ''Entradas sensores
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us
{PULSOUT(5,750) 'Motor derecha
PULSOUT(6,750) 'Motor izquierda}


PULSOUT(mIzq,1500)
PULSOUT(mDer,1500)
{cognew (control, @Stack)} ''habilitamos un cog con 1000 espacios para stack
{Print("Hola mundo")}
repeat
  {PULSOUT(9,1400)
  PULSOUT(10,1400)
  pauseSec(5)
  PULSOUT(9,1500)
  PULSOUT(10,1500)
  pauseSec(5)
  PULSOUT(9,1600)
  PULSOUT(10,1600)
  pauseSec(5)}
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)
  pauseSec(2)
  PULSOUT(mIzq,1550)
  PULSOUT(mDer,1550)
  pauseSec(2)


  {pauseSec(3)
  PULSOUT(9,750)
  PULSOUT(10,750)
  pauseSec(3)                                 b
  PULSOUT(9,1000)
  PULSOUT(10,1000)
  pauseSec(3)}

  {if (ban==1)
    repeat 5
          PULSOUT(5,600) 'Motor
          PULSOUT(6,900) 'Motor
          pause(20)
    repeat 5
          PULSOUT(5,750) 'Motor
          PULSOUT(6,750) 'Motor
          pause(20)
    repeat 5
          PULSOUT(5,900)
          PULSOUT(6,600)
          pause(20)
  else
          PULSOUT(5,750)
          PULSOUT(6,750)
          pause(20) }

pub control
repeat
  if ina[2]==1        'esperamos por el control
      if ban==0
         ban:=1
      else
         ban:=1
      pause(500)
  else
    ban :=1


{PUB Print | S
S := Num.ToStr(LongVal, Num#DEC)
Term.Str(@S) }




PUB PULSOUT(Pin,Duration)  | ClkCycles, TimeBase
{{
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout(500)   ' 1 mS pulse
}}
'' time * 2us = total time
  ClkCycles := (Duration *us) #> cntMin        ' duration * clk cycles for 2us
  TimeBase := cnt                                                         ' - inst. time, min cntMin
  dira[Pin]~~                                              ' Set to output
  !outa[Pin]                                               ' set to opposite state
  waitcnt(ClkCycles + TimeBase)                                 ' wait until clk gets there
  !outa[Pin]                                               ' return to orig. state


  {duration := (duration * (clkfreq / 1_000_000)) #> 381

  dira[noparse][[/noparse]pin]~~
  !outa[noparse][[/noparse]pin]
  waitcnt(duration)
  !outa[noparse][[/noparse]pin]}

PUB pauseSec(time) | clocks              '' Pause for number of seconds
  if time > 0
    clocks := (clkfreq * time) '' esto deberia de ser una constante, pero hay que probar, segun documentacion
    waitcnt(clocks + cnt) ''cnt se supone que cuenta el tiempo actual

PUB pause(time) | clocks                 '' Pause for number of milliseconds
  if time > 0
    clocks := ((clkfreq / 1000) * time)
    waitcnt(clocks + cnt)