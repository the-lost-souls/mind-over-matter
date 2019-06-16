Program qk;

Uses
  DemoGrx2, Crt;

Var
  F : File;
  Err : Word;
  W : Word;
  B, B2 : Byte;

Begin
  Assign(F, 'theend.raw');
  ReWrite(F, 1);
  InitScreen($13);
  ViewPCX('x_fine.pcx');
  For W := 0 To 64000 Do
  Begin
    Mem[$A000:W] := Mem[$A000:W] + 128;
  End;

{  Repeat Until KeyPressed;}

  BlockWrite(F, Mem[$A000:0000], 64000);
  Close(F);

  InitScreen($3);

End.