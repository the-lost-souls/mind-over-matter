Program qk;

Uses
  DemoGrx2, Crt;

Var
  F : File of Byte;
  Err : Word;
  W : Word;
  B, B2 : Byte;


Begin
  Assign(F, 'theend.raw');
  ReWrite(F);
  InitScreen($13);
  ViewPCX('x_fine.pcx');
  For W := 0 To 64000 Do
  Begin
    Mem[$A000:W] := Mem[$A000:W] + 128;
  End;

  Repeat Until KeyPressed;

  For W := 0 To 31999 Do
  Begin
    B := Mem[$A000:W*2] - (128);
    B2 := Mem[$A000:(W * 2) + 1] - (128);
    B2 := B2 SHL 4;
    B := B OR B2;
    Write(F, B);
  End;

{  BlockWrite(F, Mem(.$A000:0000.), 65535, Err);}
  InitScreen($3);

End.