Program Her_Kristian_har_du_sirkelen_din;

Uses
  Crt;

Const
     Radius = 130;  {189}
     N1 = 720;
     N2 = 1000;

Var
  W : Word;
  XOrg, YOrg, X2, Y2, XAdd, YAdd, I, K : LongInt;
  Col, VAngle, VAdd : Real;
  Ch : Char;
  ColAdd : ShortInt;
  F : File;

Procedure Vga; Assembler;

Asm
                mov   al, 13h
                mov   ah, 00h
                int   10h
End;

Procedure DosScr; Assembler;

Asm
                mov   al, 03h
                mov   ah, 00h
                int   10h
End;

Procedure PutPixel(X, Y, Col : Word);

Begin
  Mem[$A000:((Y-1)*320)+X] := Col;
End;

Begin
  ClrScr;
  Vga;
  XOrg := Radius;
  YOrg := 0;
  Col := 1;
  ColAdd := 1;
  For K := 0 To N1 Do
  Begin
    VAngle := ((360 / N1) * K) * ((2*Pi)/360);
    Y2 := Round((YOrg * cos(VAngle)) + (XOrg * sin(VAngle)));
    X2 := Round((XOrg * cos(VAngle)) - (YOrg * sin(VAngle)));
    XAdd := -X2;
    YAdd := -Y2;
    X2 := X2 + XAdd + 160;
    Y2 := Y2 + YAdd + 100;
    VAdd := ((360/N2)*((2*Pi)/360));
    ColAdd := 0;
    Repeat
      PutPixel(X2, Y2, Round(Col + (Coladd/4)));
      VAngle := VAngle - VAdd;
      Y2 := Round((YOrg * cos(VAngle)) + (XOrg * sin(VAngle)));
      X2 := Round((XOrg * cos(VAngle)) - (YOrg * sin(VAngle)));
      X2 := X2 + XAdd + 160;
      Y2 := Y2 + YAdd + 100;
    Until (X2 < 0) Or (X2 > 319) Or (Y2 < 0) Or (Y2 > 200);
    Col := Col + 0.25;
    If Col >= 31 Then Col := 1;
{    If Col <= 18 Then ColAdd := 1;}
  End;
  Asm
    push es
    push ds
    mov  ax, 0A000h
    mov  es, ax
    mov  ds, ax
    xor  di, di
    xor  si, si

    cld
    mov  BYTE PTR es:[di], 18
    inc  di
    mov  cx, 64000
    mov  dx, 1

@LoopP:
    mov  al, [di]
    or   al, al
    jnz  @NoFix

    or   dx, dx
    jnz  @NoFix2
    mov  al, es:[di + 1]
    jmp  @DoneFix
@NoFix2:
    mov  al, es:[di - 1]
@DoneFix:
    mov  es:[di], al
@NoFix:
    inc  di
    inc  dx
    cmp  dx, 320
    jb   @NoZ
    xor  dx, dx
@NoZ:

    dec  cx
    jnz  @LoopP

    pop  ds
    pop  es
  End;

  Assign(F, 'RawFile.raw');
  ReWrite(F, 1);
  BlockWrite(F, Mem[$A000:0000], 64000);
  Close(F);
  Repeat Until KeyPressed;
  DosScr;
End.