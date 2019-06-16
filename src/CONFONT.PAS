Program ConFont;

Uses
  DemoGrx2, Crt;

Const
  InputFile = 'testfont.PCX';
  OutputFile = 'FONT.ASM';
  CharArray = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ';
  XSize = 19;
  YSize = 27;
  CharsOnLine = 16;

Var
  TempFile : File Of Byte;
  OutFile : Text;
  Color : Byte;
  I, X, Y, XPos, YPos : Integer;
  CA : String;
  W : Word;



Procedure SaveChar;

Begin
  For Y := YPos To (YPos+ YSize - 1) Do
  For X := XPos To XPos + XSize -1 Do
  Begin
    Color := Mem(.$A000:(Y * 320) + X.);
    If Color = 240 Then Color := 0;
    Write(TempFile, Color);
  End;
End;

Procedure Bin2Db;

Begin
  I := 1;

  Assign(OutFile, OutPutFile);
  Rewrite(OutFile);
  Seek(TempFile, 0);

  WriteLn(OutFile, '.Model  Small');
  WriteLn(OutFile, 'PUBLIC          Font');
  WriteLn(OutFile, 'MainData          SEGMENT PUBLIC');
  Write(OutFile, 'Font');

  For I := 1 To Length(CA) Do
  Begin
{    Write(OutFile, CA(.I.));}
    For Y := 1 To YSize Do
    Begin
      Write(OutFile, '                DB ');
      For X := 1 To (XSize - 1) Do
      Begin
        Read(TempFile, Color);
        Write(OutFile, Color:3, ', ');
      End;
      Read(TempFile, Color);
      WriteLn(OutFile, Color:3);
    End;
    WriteLn(OutFile);
  End;

  WriteLn(OutFile, 'MainData      ENDS');
  Write(OutFile, 'END');

  Close(OutFile);
End;

Begin
  Assign(TempFile, 'Temp.bin');
  Rewrite(TempFile);
  CA := CharArray;
  InitScreen($13);
  XPos := 0;
  YPos := 1;
  ViewPCX(InPutFile);

  For W := 0 To 64000 DO
  Begin
    Inc(Mem[$A000:W], 240);
  End;

  For I := 1 To CharsOnLine Do
  Begin
    SaveChar;
    Inc(XPos, (XSize + 1));
  End;
  Inc(YPos, (YSize + 1));
  XPos := 0;
  For I := 1 To CharsOnLine Do
  Begin
    SaveChar;
    Inc(XPos, (XSize + 1));
  End;
  Inc(YPos, (YSize + 2));
  XPos := 0;
  For I := 1 To 5 Do
  Begin
    SaveChar;
    Inc(XPos, (XSize + 1));
  End;

  Bin2Db;
  InitScreen(3);
  Close(TempFile);
  Erase(TempFile);
End.