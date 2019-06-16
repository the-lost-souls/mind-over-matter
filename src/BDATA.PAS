Program BuildData;

Uses
  Crt;

Const
  FileName = 'mom.tls';
  TextFile = 'Offsets.txt';
  Files    = 44;
  LF = CHR(13) + CHR(10);
  Sources : Array(.1..Files.) Of String[12] = (

  'gus.mse',
  'sb16.mse',
  'sbpro.mse',
  'sb2x.mse',
  'start.gdm',
  'b1.raw',
  'b2.raw',
  'mapfile1.bin',
  'mapfile2.bin',
  'picture1.pcx',
  'picture2.pcx',
  'object1.bin',
  'obj1_n.bin',
  'x_moe.pcx',
  'object2.bin',
  'obj2_n.bin',
  'object3.bin',
  'obj3_n.bin',
  'rawfile.raw',
  'object4.bin',
  'obj4_n.bin',
  'object8.bin',
  'obj8_n.bin',
  'p5_b.raw',
  'greets.raw',
  'object6.bin',
  'obj6_n.bin',
  'xenon.raw',
  'object7.bin',
  'obj7_n.bin',
  'prx.raw',
  'object9.bin',
  'obj9_n.bin',
  'spin.raw',
  'object5.bin',
  'obj5_n.bin',
  'infernal.raw',
  'mapfile3.bin',
  'rawfile2.raw',
  'mapfile4.bin',
  'rawfile3.raw',
  'shade.bin',
  'theend.raw',
  'main.gdm'

  );

Type
  BufferType = Array[1..1] Of Byte;

Var
  F, FSource : File;
  TextF : Text;
  I : Integer;
  Buffer : ^BufferType;
  Result : Word;
  HeaderS : String;

Begin
  HeaderS := 'ÖÄÄ-ùú'       + LF +
             'º Mind over'   + LF +
             '   Matter   º' + LF +
             '       úù-ÄÄ½' + CHR(26);

  GetMem(Buffer, 64000);

  Assign(F, FileName);
  Rewrite(F, 1);
  Assign(TextF, TextFile);
  Rewrite(TextF);
  BlockWrite(F, HeaderS[1], 50);

  For I := 1 To Files Do
  Begin
    Assign(FSource, Sources[I]);
    Reset(FSource, 1);
    WriteLn(TextF, Sources[I]:12,'  : ',FilePos(F));
    BlockRead(FSource, Buffer^, 64000, Result);
    Repeat
      WriteLn('Adding ',Result,' bytes from ',Sources[I]);
      BlockWrite(F, Buffer^, Result);
      BlockRead(FSource, Buffer^, 64000, Result);
    Until Result = 0;
    Close(FSource);
  End;

  Close(TextF);
  Close(F);
  FreeMem(Buffer, 64000);
End.