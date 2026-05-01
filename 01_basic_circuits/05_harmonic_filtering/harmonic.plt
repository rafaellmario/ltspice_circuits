[FFT of time domain data]
{
   Npanes: 1
   {
      traces: 3 {524290,0,"V(in)"} {524291,0,"V(out1)"} {524292,0,"V(out2)"}
      X: ('M',0,20,0,2.62142e+06)
      Y[0]: (' ',0,1e-11,20,1)
      Y[1]: ('M',0,-1.3e+06,100000,100000)
      Log: 1 2 0
      GridStyle: 1
      PltMag: 1
   }
}
[Transient Analysis]
{
   Npanes: 1
   {
      traces: 3 {524290,0,"V(in)"} {524291,0,"V(out1)"} {524292,0,"V(out2)"}
      X: ('m',0,0,0.005,0.05)
      Y[0]: (' ',1,-3.6,0.6,3.6)
      Y[1]: ('_',0,1e+308,0,-1e+308)
      Volts: (' ',0,0,0,-3.6,0.6,3.6)
      Log: 0 0 0
      GridStyle: 1
   }
}
