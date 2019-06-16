Program WrSin;

Uses
  Crt;

Const
  AmbientR = 15;                         {No light}
  AmbientG = 15;
  AmbientB = 25;
  DiffuseR = 20;                         {The color}
  DiffuseG = 20;
  DiffuseB = 30;
  SpecularR = 18;                       {The highlight}
  SpecularG = 18;
  SpecularB = 8;
  Shiny = 1;


Var
  I, Degrees, I2 : Integer;
  X : Word;
  F : Text;
  R, G, B : Byte;
  T : Real;

Begin
  Assign(F, 'PhongPal.txt');
  ReWrite(F);
  ClrScr;
  Degrees := 0;
  Repeat
    Write(F, '                DB ');

    For I := 1 To 8 Do
    Begin
      T := Cos((2*Pi)/360*Degrees);
      For I2 := 1 To Shiny Do T := T * Cos((2*Pi)/360*Degrees);
      R := Round(AmbientR + (Cos((2*Pi)/360*Degrees) * DiffuseR) + (T * SpecularR));
      G := Round(AmbientG + (Cos((2*Pi)/360*Degrees) * DiffuseG) + (T * SpecularG));
      B := Round(AmbientB + (Cos((2*Pi)/360*Degrees) * DiffuseB) + (T * SpecularB));
      Write(F, R:3,', ', G:3,', ', B:3,', ');
      Inc(Degrees);
    End;

      R := Round(AmbientR + (Cos((2*Pi)/360*Degrees) * DiffuseR) + (T * SpecularR));
      G := Round(AmbientG + (Cos((2*Pi)/360*Degrees) * DiffuseG) + (T * SpecularG));
      B := Round(AmbientB + (Cos((2*Pi)/360*Degrees) * DiffuseB) + (T * SpecularB));
      WriteLn(F, R:3,', ', G:3,', ', B:3);
      Inc(Degrees);

  Until Degrees >= 90;
  Close(F);
End.

