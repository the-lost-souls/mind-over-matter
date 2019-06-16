Program qk;

Uses
  DemoGrx2, Crt;

Var
  F : File Of Byte;
  Err : Word;
  W, W2 : Word;
  B, B2 : Byte;

Begin
  Assign(F, 'greets.raw');
  ReWrite(F);
  InitScreen($13);
  ViewPCX('x_greets.pcx');
  For W := 0 To 64000 Do
  Begin
    If Mem[$A000:W] <= 2 Then Mem[$A000:W] := 1 Else Mem[$A000:W] := 0;
  End;

  Repeat Until KeyPressed;


  For W := 0 To 7999 Do
  Begin
    B := 0;
    B2 := 1;
    For W2 := 0 To 7 Do
    Begin
      If Mem[$A000:(W*8)+W2] = 1 Then B := B Or B2;
      B2 := B2 SHL 1;
    End;
    Write(F, B);
  End;

  Close(F);

  InitScreen($3);

End.