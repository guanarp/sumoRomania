CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up   {381 dicen que funca}

  left = 13 ''Estos son los sensores Pepper
  frontLeft = 8
  front = 9
  frontRight = 10
  right = 11

  leftLine = 4 ''Estos son los sensores de linea
  rightLine = 5

  mIzq = 23 ''Los pines para los motores
  mDer = 27

  signoIzq = 25 ''hay dos pines mas que hay que soldar para este caso
  signoDer = 24


  topLeft = 20
  topFront = 21
  topRight = 22 ''Ult pin de IO

  rfA = 0
  rfB = 1
  rfC = 2
  rfD = 3

var
   long us, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, lineaIzq, lineaDer, startSignal, sTopIzq, sTopFrente, sTopDer, sRfA, sRfB, sRfC, sRfD, killSwitch
   long Stack[1000] 'Stack space for new cog 'Stack space for new cog
   long Stack2[1000]
   ''Para el PWM

   long  duty1
   long  duty2
   long  period

   long  pwmstack[32]


PUB Principal
'dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[0..5]~ ''Entradas Control y lineas
dira[8..11]~ ''Entradas Pepper
dira[20..22]~   ''Entradas sensores Keyence
dira[23..26]~~    ''Salidas motor y pines de direccion

us:= clkfreq / 1_000_000

start_pwm(mIzq, mDer, 20000)
set_duty(1, 0)
set_duty(2, 0)

cognew(lecturas, @Stack) ''Habilito un nucleo para que en paralelo ejecute la lectura de todos los sensores
cognew(lecturas2, @Stack2)

repeat while srfA==0
  parar

  ''izquierda45PWM
  ''atras180PWM
  ''izquierda45PWM
  ''pauseSec(2)

repeat while srfA==1
  repeat while (lineaIzq==1 and lineaDer==1)
    adelantePWM
    pauseSec(0.1)


  atras180PWM
  ''pauseSec(0.1)

repeat
  parar
{pub control
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
Term.Str(@S) }}


pub lecturas
  ''lectura de sensores
  repeat
    sIzq := ina[left]
    sFrenteIzq := ina[frontLeft]
    sFrente := ina[front]
    sFrenteDer := ina[frontRight]
    sDer := ina[right]
    lineaIzq := ina[leftLine]
    lineaDer := ina[rightLine]
    startSignal := ina[rfA]
    sTopIzq := ina[topLeft]
    sTopFrente := ina[topFront]
    sTopDer := ina[topRight]

pub lecturas2
  ''lectura de sensores
  repeat
    sRfA := ina[rfA]
    ''provisoriamente es lo siguiente
    startSignal := ina[rfA]
    killSwitch := ina[rfC]


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


pub parar
  set_duty(1,0)
  set_duty(2,0)


pub atras180PWM | OneMS, TimeBase ''comprobar
    TimeBase := cnt
    OneMS := clkfreq / 1000

    outa[signoIzq]~
    outa[signoDer]~
    set_duty(1,10)
    set_duty(2,10)
    waitcnt(TimeBase += 600*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
    set_duty(1,0)
    set_duty(2,0)
    'pause(20)


pub izquierda45PWM | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~
  outa[signoDer]~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 250*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)


pub izquierda90PWM | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~
  outa[signoDer]~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 400*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)


pub derecha45PWM | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 250*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)


pub derecha90PWM | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 400*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)
  'pause(20)


pub izquierdacortoPWM | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000
  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt

    outa[signoIzq]~
    outa[signoDer]~~
    set_duty(1,10)
    set_duty(2,10)

    if (Time - TimeBase) > 15 * OneMS
      quit

    outa[signoIzq]~~
    outa[signoDer]~~


pub derechacortoPWM | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000
  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt

    outa[signoIzq]~~
    outa[signoDer]~
    set_duty(1,10)
    set_duty(2,10)

    if (Time - TimeBase) > 15 * OneMS
      quit

    outa[signoIzq]~~
    outa[signoDer]~~


pub adelanteLentoPWM
  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,2)
  set_duty(2,2)


pub adelanterapidoPWM
  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

pub adelantePWM  | OneMS, TimeBase, Time
  outa[signoIzq]~ ''~~ es alto; ~ es bajo
  outa[signoDer]~~
  set_duty(1,12)
  set_duty(2,10)



pub start_pwm(p1, p2, freq)
  ''if your PWM frequency is lower than about 35kHz, you can do this in Spin

  period := clkfreq / (1 #> freq <# 35_000)                     ' limit pwm frequency

  cognew(run_pwm(p1, p2), @pwmstack)                            ' launch pwm cog



pub set_duty(ch, level)

  level := 0 #> level <# 100                                    ' limit duty cycle

  if (ch == 1)
    duty1 := -period * level / 100
  elseif (ch == 2)
    duty2 := -period * level / 100



pub run_pwm(p1, p2) | t                                         ' start with cognew

  if (p1 => 0)
    ctra := (%00100 << 26) | p1                                 ' pwm mode
    frqa := 1
    phsa := 0
    dira[p1] := 1                                               ' make pin an output

  if (p2 => 0)
    ctrb := (%00100 << 26) | p2
    frqb := 1
    phsb := 0
    dira[p2] := 1

  t := cnt                                                      ' sync loop timing
  repeat
    phsa := duty1
    phsb := duty2
    waitcnt(t += period)



PUB pauseSec(time) | clocks              '' Pause for number of seconds
  if time > 0
    clocks := (clkfreq * time) '' esto deberia de ser una constante, pero hay que probar, segun documentacion
    waitcnt(clocks + cnt) ''cnt se supone que cuenta el tiempo actual

PUB pause(time) | clocks                 '' Pause for number of milliseconds
  if time > 0
    clocks := ((clkfreq / 1000) * time)
    waitcnt(clocks + cnt)