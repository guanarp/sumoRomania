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
Pin 16: Control A
Pin 17: Control B
Pin 20:
Pin 22:
Pin 23:
}

CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal
   cntMin     = 400      ' Minimum waitcnt value to prevent lock-up   

var
     long us,  nombre  
   byte ban, bandera
   long Stack[1000] 'Stack space for new cog     
PUB Principal
dira[0..5]~     ''Entradas sensores
dira[6..7]~~    ''Salidas motor
dira[8]~~       ''Led indicador 1
dira[11]~~      ''Led indicador 2
dira[14]~~      ''Parlante
dira[16..17]~       ''Control remoto
bandera := 0
ban:= 0  
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us

PULSOUT(6,750) 'Motor izquierda
PULSOUT(7,750) 'Motor derecha

freqout(14,3500,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4000,30)         ''Genera un sonido para indicar cuando se reinicia
freqout(14,4500,30)         ''Genera un sonido para indicar cuando se reinicia
     

outa[8] := 1                  ''luz de encendido
repeat
     
  if ina[16]==1
      if bandera==1     
         bandera := 0
         ban:= 0   
           cogstop(nombre)
          outa[11] := 0
          PULSOUT(7,750) 'Motor derecha  
         PULSOUT(6,750) 'Motor izquierda 
          waitcnt((clkfreq ) + cnt)    

      elseif bandera==0
              outa[11] := 1       ' led de la placa  
          bandera := 1
          ban:= 1  
            waitcnt((clkfreq) + cnt)    
             cognew (parada, @Stack)   
    

pub parada
nombre:= cogid
dira[0..5]~     ''Entradas sensores
dira[6..7]~~    ''Salidas motor
dira[8]~~       ''Led indicador 1
dira[11]~~      ''Led indicador 2
dira[14]~~      ''Parlante
dira[16..17]~       ''Control remoto
us:= clkfreq / 1_000_000                  ' Clock cycles for 1 us    
repeat
  
     'contar los 5 seg                                 
  if bandera == 1
     if ban == 1   
        repeat 4
          pause (1010)
     ban:= 0         
     if ina[0]==1    '   Sensor Objetros frente  (0=nada 1=objeto) 
          adelanterapido   
     else  
        if ina[2]==1    ' Sensor Objetros derecha (0=nada 1=objeto) 
           derecha90
           pause (50)      
        else
           if ina[3]==1    '      Sensor Objetros izquierda (0=nada 1=objeto)
              izquierda90
                pause (50)
           else
               if ina[1]==1    '     Sensor Objetros atras (0=nada 1=objeto)
                  atras180
                  pause (50)
               else
                          adelante   
     
  if bandera == 0
      outa[11] := 0
    PULSOUT(7,750) 'Motor derecha   
     PULSOUT(6,750) 'Motor izquierda

     
pub adelante        ''Verificado
if (ina[4]==0)        'esperamos por el sensor izq de lineas 1 es negro
    repeat 12       'atras
            PULSOUT(7,650) 'Motor derecha  verif
            PULSOUT(6,850) 'Motor izquierda  verif
            pause(20)
            if ina[17]==1
              quit 
      repeat 6       'derecha
              
        PULSOUT(7,690) 'Motor derecha     ver
        PULSOUT(6,690) 'Motor izquierda   ver
        pause(20)
          if ina[17]==1
              quit 
  PULSOUT(7,750) 'Motor derecha  ver
  PULSOUT(6,750) 'Motor izquierda ver
  pause(20) 
else    
   if ( ina[5]==0)        'esperamos por el sensor der de lineas 1 es negro
      repeat 12       'atras
            PULSOUT(7,650) 'Motor derecha  verif
            PULSOUT(6,850) 'Motor izquierda  verif
            pause(20)
            if ina[17]==1
              quit 
      repeat 6       'derecha
              
        PULSOUT(7,810) 'Motor derecha     ver
        PULSOUT(6,810) 'Motor izquierda   ver
        pause(20)
          if ina[17]==1
              quit 
      PULSOUT(7,750) 'Motor derecha  ver
      PULSOUT(6,750) 'Motor izquierda ver
      pause(20) 
   else
            PULSOUT(7,800) 'Motor derecha     verif
            PULSOUT(6,700) 'Motor izquierda   verif
            pause(20)

pub adelanterapido
if (ina[4]==0)        'esperamos por el sensor izq de lineas 1 es negro
       repeat 12       'atras
            PULSOUT(7,650) 'Motor derecha  verif
            PULSOUT(6,850) 'Motor izquierda  verif
            pause(20)
            if ina[17]==1
              quit 
      repeat 6       'derecha
              
        PULSOUT(7,690) 'Motor derecha     ver
        PULSOUT(6,690) 'Motor izquierda   ver
        pause(20)
          if ina[17]==1
              quit 
  PULSOUT(7,750) 'Motor derecha  ver
  PULSOUT(6,750) 'Motor izquierda ver
  pause(20) 
else    
   if ( ina[5]==0)        'esperamos por el sensor der de lineas 1 es negro
      repeat 12       'atras
            PULSOUT(7,650) 'Motor derecha  verif
            PULSOUT(6,850) 'Motor izquierda  verif
            pause(20)
            if ina[17]==1
              quit 
      repeat 6       'derecha
              
        PULSOUT(7,810) 'Motor derecha     ver
        PULSOUT(6,810) 'Motor izquierda   ver
        pause(20)
          if ina[17]==1
              quit 
      PULSOUT(7,750) 'Motor derecha  ver
      PULSOUT(6,750) 'Motor izquierda ver
      pause(20)
   else
              PULSOUT(7,1000) 'Motor derecha     ver
              PULSOUT(6,500) 'Motor izquierda   ver
              pause(20)


pub derecha90    ''ya
repeat 3      
  PULSOUT(7,590) 'Motor derecha     ver
  PULSOUT(6,590) 'Motor izquierda   ver
  pause(20)
PULSOUT(7,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(40)
 
pub izquierda90       ''ya
repeat 3      
  PULSOUT(7,910) 'Motor derecha     ver
  PULSOUT(6,910) 'Motor izquierda   ver
  pause(20)
PULSOUT(7,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(40)
 
pub atras180   ''ya
repeat 5     
  PULSOUT(7,590) 'Motor derecha     ver
  PULSOUT(6,590) 'Motor izquierda   ver
  pause(20)
PULSOUT(7,750) 'Motor derecha  ver
PULSOUT(6,750) 'Motor izquierda ver
pause(400) 






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
 