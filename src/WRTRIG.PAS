Program WriteTrig;

Uses
  Crt;

Const
  Interval = 0.25;

Var
  TFile : Text;
  Angle : Real;
  I : Integer;
  X : LongInt;

Begin
  Assign(TFile, 'TrigFile.txt');
  ReWrite(TFile);

  Angle := 0;

  Repeat
    Write(TFile, '                DD ');

    For I := 1 To 15 Do
    Begin
      X := Round(Sin((Angle/360)*(2*Pi)) * 65536);
      Write(TFile, X:3,' ,');
      Angle := Angle + Interval;
    End;

    X := Round(Sin((Angle/360)*(2*Pi)) * 65536);
    WriteLn(TFile, X:3);
    Angle := Angle + Interval;

  Until Angle >= 450;
  Close(TFile);
End.