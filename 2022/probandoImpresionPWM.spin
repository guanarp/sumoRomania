OBJ
Serial:"FullDuplexSerial"
'' los programas primero deben guardarse para poder ser grabados en el propeller
'' negro 3 voltios
'' blanco 0 voltios
'' Sensor 3 y 4 son el medio-------> Estos son de ellos, hay que rehacer hei
'' sensor 0, 1 y 2 derecha
'' sensor 5, 6 y 7 son izquierda
CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
  cntMin     = 400


  left = 13 ''Estos son los sensores Pepper
  frontLeft = 8
  front = 9
  frontRight = 10
  right = 11

  leftLine = 6  ''Estos son los sensores de linea
  rightLine = 5

  mIzq = 23 ''Los pines para los motores
  mDer = 27

  ''topLeft = 20
  topFront = 21
  topRight = 22 ''Ult pin de IO

  signoIzq = 25 ''hay dos pines mas que hay que soldar para este caso
  signoDer = 24

  rfA = 0
  rfB = 1
  rfC = 2
  rfD = 3


var
long a,us, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, sLineaIzq, sLineaDer, sTopIzq, sTopFrente, sTopDer, sRfA, sRfB, sRfC, sRfD,startSignal, killSwitch
long Stack[1000] 'Stack space for new cog
long Stack2[1000] 'Stack space for new cog
long  duty1
long  duty2
long  period
long  pwmstack[32]

PUB Principal
'dira[0..3]~     ''Entradas sensores de lineas y pines de control A y B
dira[0..7]~ ''Entradas Control y lineas
dira[8..11]~ ''Entradas Pepper
dira[21..22]~   ''Entradas sensores Keyence
dira[23..26]~~    ''Salidas motor y pines de direccion
''a:=ina[16]
us := clkfreq / 1_000_000
outa[mIzq]~
outa[mDer]~ ''Poniendo a 0 por seguridad

sRfA :=1
startSignal := 0
killSwitch := 0

cognew(lecturas, @Stack) ''Habilito un nucleo para que en paralelo ejecute la lectura de todos los sensores
cognew(lecturas2, @Stack2)


start_pwm(mIzq, mDer, 20000)
outa[signoIzq]~
outa[signoDer]~
set_duty(1, 0)
set_duty(2, 0)


''PULSOUT(mIzq,1500) 'Motor1 siempre inicia apagado
''PULSOUT(mDer,1500) 'Motor2 siempre inicia apagado


Serial.start(31, 30, 0, 9600) ''Que onda esto no se de donde sale el start y sus parametros
  repeat
    ''valor:=ina[16]
    Serial.str(string("Sensor RFA: "))
    Serial.Dec(sRfA)
    Serial.tx(13) ''El tx13 es un enter nomas
    ''valor1:=ina[17]
    Serial.str(string("Sensor RFB: "))
    Serial.Dec(sRfB)
    Serial.tx(13)
    Serial.str(string("Sensor RFC: "))
    Serial.Dec(sRfC)
    Serial.tx(13)
    ''valor2:=ina[18]
    Serial.str(string("Sensor RFD: "))
    Serial.Dec(sRfD)
    Serial.tx(13)
    Serial.str(string("Sensor start: "))
    Serial.Dec(startSignal)
    Serial.tx(13)
    Serial.str(string("Sensor kill: "))
    Serial.Dec(killSwitch)
    Serial.tx(13)

    Serial.str(string("LineaIZQ: "))
    Serial.Dec(sLineaIzq)
    Serial.tx(13)
    Serial.str(string("LineaDER: "))
    Serial.Dec(sLineaDer)
    Serial.tx(13)
    ''valor3:=ina[19]

    Serial.str(string("Sensor presencia Izq: "))
    Serial.Dec(sIzq)
    Serial.tx(13)

    Serial.str(string("Sensor presencia frenteIzq: "))
    Serial.Dec(sFrenteIzq)
    Serial.tx(13)

    Serial.str(string("Sensor presencia Frente: "))
    Serial.Dec(sFrente)
    Serial.tx(13)

    Serial.str(string("Sensor presencia Frente derecha : "))
    Serial.Dec(sFrenteDer)
    Serial.tx(13)

    Serial.str(string("Sensor presencia Der: "))
    Serial.Dec(sDer)
    Serial.tx(13)

    Serial.str(string("Sensor arriba izq: "))
    Serial.Dec(sTopIzq)
    Serial.tx(13)

    Serial.str(string("Sensor arriba frente: "))
    Serial.Dec(sTopFrente)
    Serial.tx(13)

    Serial.str(string("Sensor arriba derecha: "))
    Serial.Dec(sTopDer)
    Serial.tx(13)

    Serial.str(string("==========================="))
    Serial.tx(13)

    ''outa[LED] := ina[SENSOR]     ''lee el sensor y le pasa el valor el led
    pauseMs(1500)

pub lecturas
  ''lectura de sensores
  repeat
    sIzq := ina[left]
    sFrenteIzq := ina[frontLeft]
    sFrente := ina[front]
    sFrenteDer :=  ina[frontRight]
    sDer :=  ina[right]
    slineaIzq := ina[leftLine]
    slineaDer := ina[rightLine]
    startSignal := ina[rfA]
    ''sTopIzq := ina[topLeft]
    sTopFrente := ina[topFront]
    sTopDer := ina[topRight]

pub lecturas2
  repeat
    ''sRfA := ina[rfA]
    ''sRfB := ina[rfB]
    ''sRfC := ina[rfC]
    ''sRfD := ina[rfD]
    ''provisoriamente es lo siguiente
    {if sRfA == 0
      if startSignal ==0
        startSignal := 1
        killSwitch := 0
      else
        startSignal := 0
        killSwitch := 1 }




PUB SEROUT_CHAR(Pin, char, Baud, Mode, Bits ) | x, BR
{{
  Send asynchronous character (byte) on defined pin, at Baud, in Mode for #bits
  Mode: 0 = Inverted - Normally low        Constant: BS2#Inv
        1 = Non-Inverted - Normally High   Constant: BS2#NInv
    BS2.Serout_Char(5,"A",9600,BS2#NInv,8)
}}
        BR := 1_000_000 / (Baud)                           ' Determine Baud rate
        char := ((1 << Bits ) + char) << 2                 ' Set up string with start & stop bit
        dira[pin]~~                                        ' set as output
        if MODE == 0                                       ' If mode 0, invert
                char:= !char
        pauseUs(BR * 2 )                                  ' Hold for 2 bits
        Repeat x From 1 to (Bits + 2)                      ' Send each bit based on baud rate
          char := char >> 1
          outa[Pin] := char
          pauseUs(BR - 65)
        return
PUB SEROUT_STR(Pin, stringptr, Baud, Mode, bits)
{{
  Sends a string for serout
    BS2.Serout_Str(5,string("Spin-Up World!",13),9600,1,8)
    BS2.Serout_Str(5,@myStr,9600,1,8)
      Code adapted from "FullDuplexSerial"
}}

    repeat strsize(stringptr)
      SEROUT_CHAR(Pin,byte[stringptr++],Baud, Mode, bits)  ' Send each character in string

PUB pauseS(time) | TimeBase, OneSec              '' Pause for number of seconds
  if time > 0
    TimeBase := cnt
    OneSec := clkfreq
    repeat time
      waitcnt(TimeBase += OneSec)

pub adelante

  PULSOUT(mIzq,1400)
  PULSOUT(mDer,1600)

pub adelantePWM
  outa[signoIzq]~~ ''~~ es alto; ~ es bajo
  outa[signoDer]~~
  set_duty(1,5)
  set_duty(2,5)


pub adelanterapido
  PULSOUT(mIzq,2000)
  PULSOUT(mDer,2000)

pub adelanterapidoPWM
  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

pub adelanteLento
  PULSOUT(mIzq,1350)
  PULSOUT(mDer,1650)

pub adelanteLentoPWM
  outa[signoIzq]~~
  outa[signoDer]~~
  set_duty(1,2)
  set_duty(2,2)


pub derechacorto | OneMS, TimeBase, Time

'esto podria ponerse en 0 nomas uno y el otro activar como para tener mejor rapidez de reaccion, cuestion de probar, no se giraria sobre propio eje

  TimeBase := cnt
  OneMS := clkfreq/1000

  repeat until NOT sFrenteDer 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt
    PULSOUT(mIzq,1040)
    PULSOUT(mDer,1040)
    if (Time - TimeBase) > 15 * OneMS
      quit

  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)

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




pub izquierdacorto | OneMS, TimeBase, Time
  TimeBase := cnt
  OneMS := clkfreq/1000

  repeat until NOT sFrenteIzq 'no se si es esta la notacion (hasta que ya no lea)
    Time := cnt
    PULSOUT(mIzq,1960)
    PULSOUT(mDer,1960)
    if (Time - TimeBase) > 15 * OneMS
      quit
  PULSOUT(mIzq,1500)
  PULSOUT(mDer,1500)

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



pub derecha45PWM | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~~
  outa[signoDer]~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 15*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)

pub derecha90PWM | OneMS, TimeBase    ''comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~~
  outa[signoDer]~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 30*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)
  'pause(20)

pub izquierda45PWM | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 15*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)

pub izquierda90PWM | OneMS, TimeBase 'comprobar
  TimeBase := cnt
  OneMS := clkfreq / 1000

  outa[signoIzq]~
  outa[signoDer]~~
  set_duty(1,10)
  set_duty(2,10)

  waitcnt(TimeBase += 30*OneMS) 'ajustar

  set_duty(1,0)
  set_duty(2,0)


pub atras180PWM | OneMS, TimeBase ''comprobar
    TimeBase := cnt
    OneMS := clkfreq / 1000

    outa[signoIzq]~
    outa[signoDer]~~
    set_duty(1,10)
    set_duty(2,10)
    waitcnt(TimeBase += 40*OneMS) 'ese 40 es un valor random despues vamos a tener que ajustar
    set_duty(1,0)
    set_duty(2,0)
    'pause(20)

pub parar
  set_duty(1,0)
  set_duty(2,0)

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


PUB pauseMs(time) | TimeBase, OneMS                 '' Pause for number of milliseconds
  if time > 0
    OneMS := clkfreq / 1000 'Calculate cycles per 1 millisecond
    TimeBase := cnt 'Get current count
    repeat time
      waitcnt(TimeBase += OneMS)

PUB pauseUs(time) | TimeBase, OneUS
{{
   Causes a pause for the duration in uS
   Smallest value is 20 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pause_uS(1000)   ' 1 mS pause
}}
    if time > 0                    ' duration * clk cycles for us
                                                           ' - inst. time, min cntMin
        OneUS := clkfreq / 1_000_000 'Calculate cycles per 1 millisecond
        TimeBase := cnt
        repeat time
            waitcnt(TimeBase += OneUS)                            ' wait until clk gets there


PUB PULSOUT(Pin,Duration)  | ClkCycles, TimeBase
{{
   esta descripcion es dudosa pero bueno
   Produces an opposite pulse on the pin for the duration in 2uS increments
   Smallest value is 10 at clkfreq = 80Mhz
   Largest value is around 50 seconds at 80Mhz.
     BS2.Pulsout(500)   ' 1 mS pulse
}}
  ClkCycles := (Duration *us) #> cntMin        ' duration * clk cycles for 2us
  TimeBase := cnt                                                         ' - inst. time, min cntMin
  dira[Pin]~~                                              ' Set to output
  !outa[Pin]                                               ' set to opposite state
  waitcnt(ClkCycles + TimeBase)                                 ' wait until clk gets there
  !outa[Pin]                                               ' return to orig. state                                 'creo que aca no afecta hacer esto porque una vez nomas se hace no es repetitivo