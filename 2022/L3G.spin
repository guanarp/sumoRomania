OBJ

  pst          : "FullDuplexSerial"

CON

  _clkmode      = xtal1 + pll16x
  _clkfreq      = 80_000_000

  SDApin         = 8            ' SDA of gyro connected to P0
  SCLpin         = 9            ' SCL of gyro connected to P1

  WRITE         = $D2           ' Request Write operation
  READ          = $D3           ' Request Read operation

  ' Control registers
  CTRL_REG1     = $20
  CTRL_REG2     = $21
  CTRL_REG3     = $22
  CTRL_REG4     = $23
  STATUS_REG    = $27
  OUT_X_INC     = $A8

  x_idx = 0
  y_idx = 1
  z_idx = 2

VAR

  long x
  long y
  long z

  long cx
  long cy
  long cz

  long ff_x
  long ff_y
  long ff_z

  long multiBYTE[3]

PUB Go | last_ticks

  pst.start(31, 30, 0, 115200)

  ' Set modes
  Wrt_1B(CTRL_REG3, $08)                    ' Fata ready signal
  Wrt_1B(CTRL_REG4, $80)                    ' Block data update
  Wrt_1B(CTRL_REG1, $1F)                    ' Enable all axes

  last_ticks := cnt

  repeat
    pst.tx(1)                               ' Set Terminal data at top of screen
    WaitForDataReady
    Read_MultiB(OUT_X_INC)                  ' Read XYZ bytes

    ' Divide by 114 to reduce noise
    x := (x - cx) / 114
    y := (y - cy) / 114
    z += (z - cz) / 114

    RawXYZ
    WaitCnt(ClkFreq / 4  + Cnt)             ' Delay before next loop

PUB RawXYZ
  'Display Raw X,Y,Z data

  pst.str(string("RAW X ",11))
  pst.dec(x)

  pst.str(string(13, "RAW Y ",11))
  pst.dec(y)

  pst.str(string(13, "RAW Z ",11))
  pst.dec(z)


'' Below here routines to support I2C interfacing

PUB WaitForDataReady | status
    repeat
      status := Read_1B(STATUS_REG)
      if (status & $08) == $08
        quit

PUB Wrt_1B(SUB1, data)
  ''Write single byte to Gyroscope.

      start
      send(WRITE)
      send(SUB1)
      send(data)
      stop

PUB Read_1B(SUB3) | rxd
 ''Read single byte from Gyroscope

      start
      send(WRITE)
      send(SUB3)
      stop

      start
      send(READ)
      rxd := receive(false)
      stop

     result := rxd

PUB Read_MultiB(SUB3)
 ''Read multiple bytes from Gyroscope

     start
      send(WRITE)
      send(SUB3)
      stop

      start
      send(READ)
      multiBYTE[x_idx] := (receive(true)) |  (receive(true)) << 8
      multiBYTE[y_idx] := (receive(true)) |  (receive(true)) << 8
      multiBYTE[z_idx] := (receive(true)) |  (receive(false)) << 8
      stop

      x := ~~multiBYTE[x_idx]
      y := ~~multiBYTE[y_idx]
      z := ~~multiBYTE[z_idx]

PRI send(value)

  value := ((!value) >< 8)

  repeat 8
    dira[SDApin]       := value
    dira[SCLpin]       := false
    dira[SCLpin]       := true
    value >>= 1

  dira[SDApin]         := false
  dira[SCLpin]         := false
  result               := not(ina[SDApin])
  dira[SCLpin]         := true
  dira[SDApin]         := true

PRI receive(aknowledge)

  dira[SDApin]         := false

  repeat 8
    result <<= 1
    dira[SCLpin]       := false
    result             |= ina[SDApin]
    dira[SCLpin]       := true

  dira[SDApin]         := (aknowledge)
  dira[SCLpin]         := false
  dira[SCLpin]         := true
  dira[SDApin]         := true

PRI start

  outa[SDApin]         := false
  outa[SCLpin]         := false
  dira[SDApin]         := true
  dira[SCLpin]         := true

PRI stop

  dira[SCLpin]         := false
  dira[SDApin]         := false
