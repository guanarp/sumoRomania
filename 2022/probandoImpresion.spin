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
  ''rfB = 1
  ''rfC = 2
  ''rfD = 3

var
long a,us, sIzq, sFrenteIzq, sFrente, sFrenteDer, sDer, sLineaIzq, sLineaDer, sTopIzq, sTopFrente, sTopDer, sRfA, sRfB, sRfC, sRfD,startSignal, killSwitch
long Stack[1000] 'Stack space for new cog
long Stack2[1000] 'Stack space for new cog

long  duty1
long  duty2
long  period

long  pwmstack[32]
long killstack[100]

long bandera

PUB Principal
dira[0..5]~
dira[8..14]~
dira[20..22]~
dira[23..24]~~    ''Salidas motor
''dira[16..22]~   ''Entradas sensores
''dira[25..27]~ ''los keyence
''a:=ina[16]
us := clkfreq / 1_000_000
outa[mIzq]~
outa[mDer]~ ''Poniendo a 0 por seguridad

{start_pwm(mIzq, mDer, 20000) ''los pines mizq y mder son canal 1 y 2, 20000 es la frecuencia del pwm, el maximo del driver chico que tenemos es 25k, mas bajo mas ruidoso
set_duty(1, 0) ''Se duty elige el porcentaje de velocidad: se traduce a en el canal 1, settea a 0% de velocidad
set_duty(2, 0)}


sRfA :=0
startSignal := 0
killSwitch := 1
bandera := 0

cognew(lecturas, @Stack) ''Habilito un nucleo para que en paralelo ejecute la lectura de todos los sensores
cognew(lecturas2, @Stack2)

''PULSOUT(mIzq,1500) 'Motor1 siempre inicia apagado
''PULSOUT(mDer,1500) 'Motor2 siempre inicia apagado


Serial.start(31, 30, 0, 9600) ''Que onda esto no se de donde sale el start y sus parametros
  repeat
    ''PULSOUT(mIzq,1500) 'Motor1 siempre inicia apagado
    ''PULSOUT(mDer,1500) 'Motor2 siempre inicia apagado
    {set_duty(1, 0) ''Se duty elige el porcentaje de velocidad: se traduce a en el canal 1, settea a 0% de velocidad
    set_duty(2, 0)}
    ''valor:=ina[16]
    Serial.str(string("Sensor RFA: "))
    Serial.Dec(sRfA)
    Serial.tx(13) ''El tx13 es un enter nomas
    ''valor1:=ina[17]

    Serial.str(string("Sensor start: "))
    Serial.Dec(startSignal)
    Serial.tx(13)
    Serial.str(string("Sensor kill: "))
    Serial.Dec(killSwitch)
    Serial.tx(13)

    Serial.str(string("Linea1: "))
    Serial.Dec(sLineaIzq)
    Serial.tx(13)
    Serial.str(string("Linea2: "))
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
    pauseMs(1000)
    if startSignal == 1
      bandera :=1
    if bandera :=1 and startSignal ==0
      reboot


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
    sTopIzq := ina[topLeft]
    sTopFrente := ina[topFront]
    sTopDer := ina[topRight]

pub lecturas2
  ''lectura de sensores
  repeat
    sRfA := ina[rfA]
    ''provisoriamente es lo siguiente
    startSignal := ina[rfA]
    {if startSignal ==1
      pauseSec(1)
      cognew(kill,@killstack)}


{pub kill
  repeat
    if startSignal == 0
      killSwitch := 0
    if killSwitch ==0
      bandera :=1
      quit}



pub pararPWM
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

PUB pauseSec(time) | TimeBase, OneSec              '' Pause for number of seconds
  if time > 0
    TimeBase := cnt
    OneSec := clkfreq
    repeat time
      waitcnt(TimeBase += OneSec)

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