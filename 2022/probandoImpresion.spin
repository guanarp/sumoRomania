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

var
long a, valor ,valor1 ,valor2 ,valor3 ,valor4 ,valor5 ,valor6 ,valor7 ,frontal, trasero, linea_adelante_derecha, linea_atras_derecha, linea_adelante_izquierda, linea_atras_izquierda
long c3,d3,e3,f3,g3,a3,b3,c4,d4,e4,f4,g4,a4,a4s,b4,c5,d5,d5s,e5,f5,g5,a5,a5s,b5,c6,R
long Stack[1000] 'Stack space for new cog
long Stack2[1000] 'Stack space for new cog

PUB Principal
dira[8..9]~~    ''Configura como salida los pines 8 para led de prueba y 9 para parlante
dira[16..25]~   ''Las entradas a leer
''a:=ina[16]

R:=0 ''no se que carajo es esto

cognew(lecturas, @Stack)


dira[6]~~ ''Pa ke     ''Configura como salida el pin 6
Serial.start(31, 30, 0, 9600) ''Que onda esto no se de donde sale el start y sus parametros
  repeat
    outa[6]:=1
    ''valor:=ina[16]
    Serial.str(string("Sensor RF: "))
    Serial.Dec(valor)
    Serial.tx(13) ''El tx13 es un enter nomas
    ''valor1:=ina[17]
    Serial.str(string("Linea1: "))
    Serial.Dec(valor1)
    Serial.tx(13)
    ''valor2:=ina[18]
    Serial.str(string("Linea2: "))
    Serial.Dec(valor2)
    Serial.tx(13)
    ''valor3:=ina[19]
    Serial.str(string("sensor presencia: "))
    Serial.Dec(valor3)
    Serial.tx(13)
    ''valor4:=ina[20]
    Serial.str(string("==========================="))
    Serial.tx(13)
    {Serial.str(string("el valor del sensor4 es"))
    Serial.Dec(valor4)
    Serial.tx(13)
    valor5:=ina[21]
    Serial.str(string("el valor del sensor5 es"))
    Serial.Dec(valor5)
    Serial.tx(13)
    valor6:=ina[22]
    Serial.str(string("el valor del sensor6 es"))
    Serial.Dec(valor6)
    Serial.tx(13)
    valor7:=ina[23]
    Serial.str(string("el valor del sensor7 es"))
    Serial.Dec(valor7)
    Serial.tx(13)
    Serial.str(string(" "))
    Serial.tx(13)}

    ''outa[LED] := ina[SENSOR]     ''lee el sensor y le pasa el valor el led
    pauseMs(200)

pub lecturas
  ''lectura de sensores
  repeat
    valor := ina[16]
    valor1 := ina[17]
    valor2 := ina[18]
    valor3 := ina[19]


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