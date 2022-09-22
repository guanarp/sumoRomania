{
  Codigo para probar cada pin de la placa parallax
}
CON
  _clkmode = xtal1 + pll16x    ''Configura como modo oscilador a crystal y multiplicador por 16 para obtener 80Mhz
  _xinfreq = 5_000_000         ''Configura el valor del crystal

var

PUB Principal
dira[0..27]~~    ''Configura como salida los pines del 0 al 27

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
  outa[24] := 1
  outa[25] := 1
  outa[26] := 1
  outa[27] := 1
  pauseSec(10)

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
  outa[24] := 0
  outa[25] := 0
  outa[26] := 0
  outa[27] := 0
  pauseSec(10)


PUB pauseSec(time) | clocks              '' Pause for number of seconds
  if time > 0
    clocks := (clkfreq * time) '' esto deberia de ser una constante, pero hay que probar, segun documentacion
    waitcnt(clocks + cnt) ''cnt se supone que cuenta el tiempo actual

PUB pause(time) | clocks                 '' Pause for number of milliseconds
  if time > 0
    clocks := ((clkfreq / 1000) * time)
    waitcnt(clocks + cnt)