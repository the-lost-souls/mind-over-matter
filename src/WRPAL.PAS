Program WritePCX;

{
Program that takes a PCX-picture and saves the PICTURE (NOT the header OR the
palette) in a data file with a public datastructure defined in the CONST-part.

}

Uses
  Crt;

Const
  DataName = 'Palette';
  LoadFile = 'x_fine.pcx';
  FileName = 'p7_pal.ASM';

Type
  ArrayType = Array(.1..1.) Of Byte;

Var
  TextFile : Text;
  F : File;
  P : ^ArrayType;
  I, I2 : Word;
  B, B2 : Byte;

Label OneMore, Finish;

Begin
  B2 := 0;

  Assign(TextFile, FileName);
  ReWrite(TextFile);

  Assign(F, LoadFile);
  Reset(F, 1);
  GetMem(P, FileSize(F));
  BlockRead(F, P^, FileSize(F), I);
  I := FileSize(F);

  WriteLn(TextFile, 'PUBLIC          ', DataName);
  WriteLn(TextFile, 'MainData          SEGMENT PUBLIC');


  Write(TextFile, DataName, '             DB ');
  I2 := FileSize(F) - 767;
  Write(TextFile, (P^(.I2.) SHR 2):3);
  Inc(I2);

OneMore :

    Write(TextFile, ', ',(P^(.I2.) SHR 2):3);
    Inc(I2);
    Inc(B2);
    If B2 = 10 Then
    Begin
      If I2 > I Then Goto Finish;
      WriteLn(TextFile, ', ',(P^(.I2.) SHR 2):3);
      Inc(I2);
      If I2 > I Then Goto Finish;
      Write(TextFile, '                DB ');
      Write(TextFile, (P^(.I2.) SHR 2):3);
      B2 := 0;
      Inc(I2);
    End;

    If I2 <= I Then Goto OneMore;

Finish :

  WriteLn('Bytes : ', I2);

  WriteLn(TextFile,'');
  WriteLn(TextFile, 'MainData             ENDS');
  Write(TextFile, 'END');
  Close(TextFile);
  FreeMem(P, FileSize(F));
  Close(F);
{  ReadLn;}
End.



