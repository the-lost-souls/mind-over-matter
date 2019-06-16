Program qk;

Uses
  DemoGrx2, Crt;

Var
  F : File;
  Err : Word;


Begin
  Assign(F, 'rawfile2.raw');
  ReWrite(F, 1);
  InitScreen($13);
  ViewPCX('test.pcx');
  Repeat Until KeyPressed;
  BlockWrite(F, Mem(.$A000:0000.), 64000, Err);
  InitScreen($3);

End.