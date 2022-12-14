CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up   {381 dicen que funca}

  left = 13 ''Estos son los sensores Pepper
  frontLeft = 8
  front = 9
  frontRight = 10
  right = 11

  leftLine = 6 ''Estos son los sensores de linea
  rightLine = 5

  mIzq = 24 ''Los pines para los motores
  mDer = 27 ''27

  {signoIzq = 25 ''hay dos pines mas que hay que soldar para este caso
  signoDer = 27 ''24}


  topLeft = 21
  topFront = 20
  topRight = 22 ''Ult pin de IO

  stop = 25''0
  ''rfB = 1
  ''rfC = 2
  ''rfD = 3

  {veladelante = 80     ''max es 1880 y min 1080
  velatras = 20}
  veladelante = 1600''1785
  velatras = 1360''1254
  {Gveladelante=90
  Gvelatras=10}
  Gveladelante = 1840
  Gvelatras = 1120 ''1200
  velizq=20''30
  velder=20''40
  velizqgiro=40
  veldergiro=50
  veldercorto=35
  verizqcorto=45
var
   long us,bandera, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, lineaIzq, lineaDer, startSignal, sTopIzq, sTopFrente, sTopDer, stopSignal, killSwitch
   long Stack[1000] 'Stack space for new cog 'Stack space for new cog
   long Stack2[1000]
   long Stack3[1000]
   ''Para el PWM

   {long  duty1
   long  duty2
   long  period

   long  pwmstack[32]}


PUB Principal
'dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[0]~
dira[5..6]~ ''Entradas Control y lineas
dira[8..11]~ ''Entradas Pepper
dira[20..22]~   ''Entradas sensores Keyence
dira[23..27]~~    ''Salidas motor y pines de direccion
dira[25]~

us:= clkfreq / 1_000_000

''start_pwm(mIzq, mDer, 3000)
outa[mIzq]~
outa[mDer]~
parar
''set_duty(1, 0)
''set_duty(2, 0)

cognew(lecturas, @Stack) ''Habilito un nucleo para que en paralelo ejecute la lectura de todos los sensores
cognew(lecturas2, @Stack2)
cognew(lecturas3, @Stack3)
repeat while startSignal==0
  parar
  pauseMs(50)
  ''izquierda45PWM
  ''atras180PWM
  ''izquierda45PWM
  ''pauseSec(2)

startSignal:=1
stopSignal:=1

repeat while (startSignal==1)
  repeat while (lineaDer==1 and lineaIzq==1) ''(lineaIzq==1 ''and lineaDer==1)

    if (startSignal == 0 or stopSignal == 0)
        repeat
          parar
          pauseMs(50)

    elseif sFrente
      adelanterapido

      if (startSignal == 0 or stopSignal == 0)
        repeat
          parar
          pauseMs(50)
      elseif (sFrenteDer and lineaDer==1 and lineaIzq==1)
        derechacorto
      elseif (sFrenteIzq and lineaDer==1 and lineaIzq==1)
        izquierdacorto
      adelanterapido

    elseif sFrenteDer
      derechacorto

    elseif sFrenteIzq
      izquierdacorto

    elseif sTopFrente
       adelante

    elseif sTopDer
      derecha45

    elseif sTopIzq
      izquierda45

    elseif sIzq
      izquierda90

    elseif sDer
      derecha90

    else
        adelante
    ''adelante
    ''pauseMs(1000)
        {pauseMs(80) ''antes era 300
        parar
        repeat 4000
          pauseMS(1)
          if (sTopFrente or sTopDer or sTopIzq or sFrente or sFrenteDer or sFrenteIzq or sIzq or Sder)
                              ''  bandera:=1
                                quit}
      ''else
      ''  adelantePWM



    ''pauseMs(100)
    ''adelanterapidoPWM
      if (startSignal == 0 or stopSignal == 0)
        parar
        pauseMs(50)

    if (startSignal == 0 or stopSignal == 0)
      parar
      pauseMs(50)




  reversa
  pauseMs(200) ''estaba en 300 y es muuucho
  atras180
    ''pauseSec(0.1)
if (startSignal == 0 or stopSignal == 0)
    repeat
      parar
      pauseMs(50)


parar


pub lecturas
  ''lectura de sensores
  repeat
    sIzq := ina[left]
    sFrenteIzq := 0
    sFrente := 0
    sFrenteDer := 0
    sDer := ina[right]
    ''lineaIzq := ina[leftLine]
    ''  lineaDer := ina[rightLine]
    ''startSignal := ina[rfA]
    sTopIzq := 0
    sTopFrente := 0
    sTopDer := 0

pub lecturas2
  ''lectura de sensores
  repeat
    stopSignal := ina[stop]
    ''provisoriamente es lo siguiente
    startSignal := ina[0]
    ''killSwitch := ina[rfC]

pub lecturas3
  ''lectura de sensores
  repeat
    pauseMs(2)
    lineaIzq := ina[leftLine]
    lineaDer := ina[rightLine]



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
  !outa[Pin]
  ''pauseMs(50)                                               ' return to orig. state


  {duration := (duration * (clkfreq / 1_000_000)) #> 381

  dira[noparse][[/noparse]pin]~~
  !outa[noparse][[/noparse]pin]
  waitcnt(duration)
  !outa[noparse][[/noparse]pin]}



pub parar
  ''outa[signoIzq]~
  ''outa[signoDer]~
  {set_duty(1,50)
  set_duty(2,50)}
  PULSOUT(mIzq,1480)
  PULSOUT(mDer,1480)

 {
  set_duty(1,0)
  set_duty(2,0)
 }

pub atras180 | OneMS, TimeBase ''comprobar
    TimeBase := cnt
    OneMS := clkfreq / 1000

    ''outa[signoIzq]~~
    ''outa[signoDer]~~
    {set_duty(1,Gvelatras)
    set_duty(2,Gveladelante)}
    PULSOUT(mIzq,Gvelatras)
    PULSOUT(mDer,Gveladelante)
    waitcnt(TimeBase += 320*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
    parar
    ''set_duty(1,0)
    ''set_duty(2,0)
    'pause(20)


pub rampa | vel, OneMS, TimeBase
  TimeBase := cnt
  OneMS := clkfreq / 1000
  vel := 1480
  repeat until vel > 1880
    PULSOUT(mIzq,vel)
    PULSOUT(mDer,vel)
    vel += 50
    waitcnt(TimeBase += 500*OneMS)
  TimeBase := cnt

  parar
  waitcnt(TimeBase += 2000*OneMS)
  vel := 1480
  repeat until vel < 1080
    PULSOUT(mIzq,vel)
    PULSOUT(mDer,vel)
    vel -= 50
    TimeBase := cnt
    waitcnt(TimeBase += 500*OneMS)
  parar
  pauseSec(2)

pub izquierda45 | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,Gveladelante)
  set_duty(2,Gvelatras)}
  PULSOUT(mIzq,Gvelatras)
  PULSOUT(mDer,Gveladelante)

  waitcnt(TimeBase += 110*OneMS) 'ajustar

  parar
  ''set_duty(1,0)
  ''set_duty(2,0)


pub izquierda90 | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,Gveladelante)
  set_duty(2,Gvelatras)}
  PULSOUT(mIzq,Gvelatras)
  PULSOUT(mDer,Gveladelante)

  waitcnt(TimeBase += 150*OneMS) 'ajustar

  parar

pub derecha45 | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,Gvelatras)
  set_duty(2,Gveladelante)}
  PULSOUT(mIzq,Gveladelante)
  PULSOUT(mDer,Gvelatras)

  waitcnt(TimeBase += 120*OneMS) 'ajustar

  parar

pub derecha90 | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,Gvelatras)
  set_duty(2,Gveladelante)}
  PULSOUT(mIzq,Gveladelante)
  PULSOUT(mDer,Gvelatras)

  waitcnt(TimeBase += 200*OneMS) 'ajustar

  parar



{pub izquierdacortoPWM | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000
  repeat while sFrenteDer==1 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt

    outa[signoIzq]~
    outa[signoDer]~
    set_duty(1,velizq)
    set_duty(2,velder)


    if (Time - TimeBase) > 250 * OneMS
      quit

    ''outa[signoIzq]~
    ''outa[signoDer]~
  parar
}

pub izquierdacorto | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,90)
  set_duty(2,80)}
  PULSOUT(mIzq,1790)
  PULSOUT(mDer,1860)

  waitcnt(TimeBase += 100*OneMS) 'ajustar

  parar

pub derechacorto | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,80)
  set_duty(2,90)}
  PULSOUT(mIzq,1950)
  pauseMs(50)
  PULSOUT(mDer,1600)


  waitcnt(TimeBase += 200*OneMS) 'ajustar

  parar

{
pub derechacortoPWM | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000
  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt

    outa[signoIzq]~~
    outa[signoDer]~~
    set_duty(1,velizq)
    set_duty(2,velder)

    if (Time - TimeBase) > 250 * OneMS
      quit

    outa[signoIzq]~~
    outa[signoDer]~~
  parar
}
pub adelanteLento
  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,2)
  set_duty(2,2)}
  PULSOUT(mIzq,1550)
  PULSOUT(mDer,1550)


pub adelanterapido
  ''outa[signoIzq]~~
  ''outa[signoDer]~~
  {set_duty(1,90)
  set_duty(2,90)}
  PULSOUT(mIzq,1880)
  PULSOUT(mDer,1880)


pub adelante
  ''outa[signoIzq]~~ ''~~ es alto; ~ es bajo
  ''outa[signoDer]~~
  {set_duty(1,veladelante)''velder)
  set_duty(2,veladelante)''velizq)}
  PULSOUT(mIzq,veladelante)
  PULSOUT(mDer,veladelante)


pub reversa
  ''outa[signoIzq]~~ ''~~ es alto; ~ es bajo
  ''outa[signoDer]~~
  {set_duty(1,velatras)
  set_duty(2,velatras)}
  PULSOUT(mIzq,velatras)
  PULSOUT(mDer,velatras)

PUB pauseMs(time) | TimeBase, OneMS                 '' Pause for number of milliseconds
  if time > 0
    OneMS := clkfreq / 1000 'Calculate cycles per 1 millisecond
    TimeBase := cnt 'Get current count
    repeat time
      waitcnt(TimeBase += OneMS)

PUB pauseSec(time) | clocks              '' Pause for number of seconds
  if time > 0
    clocks := (clkfreq * time) '' esto deberia de ser una constante, pero hay que probar, segun documentacion
    waitcnt(clocks + cnt) ''cnt se supone que cuenta el tiempo actual

PUB pause(time) | clocks                 '' Pause for number of milliseconds
  if time > 0
    clocks := ((clkfreq / 1000) * time)
    waitcnt(clocks + cnt)