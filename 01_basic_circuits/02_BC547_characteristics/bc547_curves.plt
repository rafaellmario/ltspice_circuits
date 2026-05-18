[DC transfer characteristic]
{
   Npanes: 2
   {
      traces: 1 {34603010,0,"Ic(Q1)"}
      Parametric: "V(ce)"
      X: (' ',0,0,2,20)
      Y[0]: ('m',0,0,0.01,0.15)
      Y[1]: ('_',0,1e+308,0,-1e+308)
      Amps: ('m',0,0,0,0,0.01,0.15)
      Log: 0 0 0
      GridStyle: 1
      StepLegend: (3.24260355029586,0.136538461538462)
   },
   {
      traces: 1 {524290,0,"Ic(Q1)/Ib(Q1)"}
      Parametric: "Ic(Q1)"
      X: ('m',0,0,0.01,0.15)
      Y[0]: (' ',0,0,60,600)
      Y[1]: ('_',0,1e+308,0,-1e+308)
      Units: "" (' ',0,0,0,0,50,550)
      Log: 0 0 0
      GridStyle: 1
   }
}
