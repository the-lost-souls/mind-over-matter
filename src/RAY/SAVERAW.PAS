Program qk;

Uses
  DemoGrx2, Crt;

Var
  F : File;
  Err : Word;
  W : Word;


Begin
  Assign(F, 'rawfile.raw');
  ReWrite(F, 1);
  InitScreen($13);
  ViewPCX('scape.pcx');
  For W := 0 To 64000 Do
  Begin
    Mem[$A000:W] := Round(Mem[$A000:W] / 1.9);
    Inc(Mem[$A000:W], 4);
  End;
  For W := 64000 To 65535 Do Mem[$A000:W] := Mem[$A000:(W - 1600)];


  BlockWrite(F, Mem(.$A000:0000.), 65535, Err);
  Repeat Until Keypressed;
  InitScreen($3);

End.