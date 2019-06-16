Program Raytrace;

Uses
  Crt, Dos, DemoGrx2;

Const
  ObjFile = 'sphere.bin';
  Distance = 350;
  PosX     = 0; {380}
  PosY     = 400;  {160}
  TPosX    = 180;
  TPosY    = 40;
  Vertices = 724;
  Faces    = 1444;
  Radius   = 600;
  ViewMinX = 0;
  ViewMaxX = 319;
  ViewMinY = 0;
  ViewMaxY = 199;
  ZLimit = 1;


Type
  ObjectType = Record
                 NumOfVertices : Word;
                 Vertices : Array(.1..Vertices * 3.) Of Integer;
                 NumOfFaces : Word;
                 Faces : Array(.1..Faces * 3.) Of Word;
               End;
  BAType = Array(.1..1.) Of Byte;
  WAType = Array(.1..1.) Of Word;

Var
  ObjectF, Map : File;
  Obj : ObjectType;
  Regs : Registers;
  Angle, NewX, NewY : Integer;                 { Returned from F3DTo2D }
  Face, Offs : Word;
  I, P, X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3 : Integer;
  MX1, MY1, MX2, MY2, MX3, MY3 : Integer;
  Visible : Integer;
  Texture : ^BAType;
  Screen : Array(.0..199, 0..319.) Of Byte             Absolute $A000:0000;
  Rgbs : RgbsType;
  Ray : ^WAType;

Procedure Initialize;
Begin
  GetMem(Texture, 65535);
  GetMem(Ray, 64000);

  FillChar(Ray^, 64000, 0);

  Assign(ObjectF, ObjFile);
  Reset(ObjectF, 1);
  BlockRead(ObjectF, Obj, (Vertices * 6) + (Faces * 6) + 4);
  Close(ObjectF);

  Assign(ObjectF, 'Rawfile.raw');
  Reset(ObjectF, 1);
  BlockRead(ObjectF, Texture^, 65535);
  Close(ObjectF);

  Regs.Ah := 0;
  Regs.Al := $13;
  Intr($10, Regs);

End;

Procedure ShutDown;

Begin
  Regs.Ah := 0;
  Regs.Al := $3;
  Intr($10, Regs);

  Assign(Map, 'Mapfile.bin');
  ReWrite(Map, 1);
  BlockWrite(Map, Ray^, 64000);
  Close(Map);

  FreeMem(Texture, 64000);
  FreeMem(Ray, 64000);

End;

Procedure Exchange(Var A, B : Integer);

Var
  Tmp : Integer;

Begin
  Tmp := B;
  B := A;
  A := Tmp;
End;


Procedure DrawFace(X1, Y1, X2, Y2, X3, Y3, TX1, TY1, TX2, TY2, TX3, TY3 : Integer);

Var
  C1, C2, Slope1, Slope2, TSlope1X, TSlope1Y, TSlope2X, TSlope2Y, TC1X, TC1Y, TC2X, TC2Y : Real;
  ISlopeX, ISlopeY, IX, IY : Real;
  Y, DeltaX, DeltaY, K, Move : Integer;
  W1, W2, WT1X, WT1Y, WT2X, WT2Y : Integer;

Label
  NoLine, NoPix;

Begin
  If Y1 > Y2 Then
  Begin
    Exchange(X1, X2);
    Exchange(Y1, Y2);
    Exchange(TX1, TX2);
    Exchange(TY1, TY2);
  End;
  If Y1 > Y3 Then
  Begin
    Exchange(X1, X3);
    Exchange(Y1, Y3);
    Exchange(TX1, TX3);
    Exchange(TY1, TY3);
  End;
  If Y2 > Y3 Then
  Begin
    Exchange(X2, X3);
    Exchange(Y2, Y3);
    Exchange(TX2, TX3);
    Exchange(TY2, TY3);
  End;

  If (Y1 > ViewMaxX) Or (Y3 < ViewMinX) Then Exit;

{----------------- Vertices sorted! }

  DeltaX := (X2 - X1);
  DeltaY := (Y2 - Y1) + 1;
  Slope1 := DeltaX / DeltaY;

  TSLope1X := (TX2 - TX1);
  TSlope1X := TSlope1X / DeltaY;
  TSlope1Y := (TY2 - TY1) + 1;
  TSlope1Y := TSlope1Y / DeltaY;

  DeltaX := X3 - X1;
  DeltaY := (Y3 - Y1) + 1;
  Slope2 := DeltaX / DeltaY;
  TSlope2X := (TX3 - TX1);
  TSlope2X := TSlope2X / DeltaY;
  TSlope2Y := (TY3 - TY1) + 1;
  TSlope2Y := TSlope2Y / DeltaY;

  C1 := X1;
  C2 := X1;
  TC1X := TX1;
  TC1Y := TY1;
  TC2X := TX1;
  TC2Y := TY1;

  For Y := Y1 To Y3 Do
  Begin
    C1 := C1 + Slope1;
    C2 := C2 + Slope2;
    TC1X := TC1X + TSlope1X;
    TC1Y := TC1Y + TSlope1Y;
    TC2X := TC2X + TSlope2X;
    TC2Y := TC2Y + TSlope2Y;

    If Y < ViewMinY Then Goto NoLine;
    If Y > ViewMaxY Then Exit;

    W1 := Round(C1);
    W2 := Round(C2);

    WT1X := Round(TC1X);
    WT1Y := Round(TC1Y);
    WT2X := Round(TC2X);
    WT2Y := Round(TC2Y);

    K := W2 - W1;

    If K < 0 Then
    Begin
      Exchange(WT1X, WT2X);
      Exchange(WT1Y, WT2Y);
      Exchange(W1, W2);
      K := Abs(K);
    End;
    If K = 0 Then Inc(K);

    DeltaX := (WT2X - WT1X);
    DeltaY := (WT2Y - WT1Y);
    ISlopeX := DeltaX / K;
    ISlopeY := DeltaY / K;
    IX := WT1X;
    IY := WT1Y;

    DeltaY := W1;
    Repeat
      WT1X := Round(IX);
      WT1Y := Round(IY);

      If (DeltaY < ViewMinX) Or (DeltaY > ViewMaxX) Then Goto NoPix;

      Offs := (WT1Y SHL 6) + (WT1Y SHL 8) + WT1X;

      Screen[Y, DeltaY] := Texture^[Offs];

      Ray^[(Y * 160) + (DeltaY-160)] := Offs;
NoPix:

      IX := IX + ISlopeX;
      IY := IY + ISlopeY;
{      If IX >= 190 Then IY := IY-5;
      If IX <= 0 Then IY := IY + 5;}

      Inc(DeltaY);
    Until DeltaY > W2;

NoLine:
    If Y = Y2 Then
    Begin
      DeltaX := X3 - X2;
      DeltaY := Y3 - Y2;
      Inc(DeltaY);
      Slope1 := DeltaX / DeltaY;
      TSLope1X := (TX3 - TX2);
      TSlope1X := TSlope1X / DeltaY;
      TSlope1Y := (TY3 - TY2) + 1;
      TSlope1Y := TSlope1Y / DeltaY;
      TC1X := TX2;
      TC1Y := TY2;

      C1 := X2;
    End;

  End;

End;


Procedure F3DTo2D(X, Y, Z : Integer); Assembler;

Asm
                push  ax
                push  bx
                push  cx
                push  dx

                mov   cx, Z
                mov   ax, X

                or    ax, ax
                je   @DoneX

                cwd
                mov   dl, ah
                sal   ax, 8

                idiv  cx

@DoneX :
                mov   bx, Y
                or    bx, bx
                je    @DoneY
                xchg  ax, bx
                cwd
                mov   dl, ah
                sal   ax, 8

                idiv  cx
                xchg  ax, bx
@DoneY :

                mov   NewX, ax
                mov   NewY, bx

                pop   dx
                pop   cx
                pop   bx
                pop   ax
End;


Procedure Draw;

Label
  NoFace;

Begin
  For I := 1 To Obj.NumOfFaces Do
  Begin
    P := (I - 1);
    P := P + (P SHL 1);
    Inc(P);
    Face := Obj.Faces[P];
    Face := Face + (Face SHL 1);
    Inc(Face);
    X1 := Obj.Vertices[Face];
    Y1 := Obj.Vertices[Face + 1];
    Z1 := Obj.Vertices[Face + 2];

    Face := Obj.Faces[P + 1];
    Face := Face + (Face SHL 1);
    Inc(Face);
    X2 := Obj.Vertices[Face];
    Y2 := Obj.Vertices[Face + 1];
    Z2 := Obj.Vertices[Face + 2];

    Face := Obj.Faces[P + 2];
    Face := Face + (Face SHL 1);
    Inc(Face);
    X3 := Obj.Vertices[Face];
    Y3 := Obj.Vertices[Face + 1];
    Z3 := Obj.Vertices[Face + 2];



{ Calculating mapping-coordinates... }
    Angle := Round((ArcTan( X1/(Abs(Z1)+1) ) /(2*Pi)) * 360);
    MX1 := Round(((Radius*2*Pi)/360)*Angle/2) + TPosX;
    Angle := Round((ArcTan( Y1/(Abs(Z1)+1) ) /(2*Pi)) * 360);
    MY1 := Round(((Radius*2*Pi)/360)*Angle/2) + TPosY;
    MY1 := (Y1 DIV 1) + TPosY;

    Angle := Round((ArcTan( X2/(Abs(Z2)+1) ) /(2*Pi)) * 360);
    MX2 := Round(((Radius*2*Pi)/360)*Angle/2) + TPosX;
    Angle := Round((ArcTan( Y2/(Abs(Z2)+1) ) /(2*Pi)) * 360);
    MY2 := Round(((Radius*2*Pi)/360)*Angle/2) + TPosY;
    MY2 := (Y2 DIV 1) + TPosY;

    Angle := Round((ArcTan( X3/(Abs(Z3)+1) ) /(2*Pi)) * 360);
    MX3 := Round(((Radius*2*Pi)/360)*Angle/2) + TPosX;
    Angle := Round((ArcTan( Y3/(Abs(Z3)+1) ) /(2*Pi)) * 360);
    MY3 := Round(((Radius*2*Pi)/360)*Angle/2.0) + TPosY;
    MY3 := (Y3 DIV 1) + TPosY;

    Inc(X1, PosX);
    Inc(Y1, PosY);
    Inc(Z1, Distance);

    Inc(X2, PosX);
    Inc(Y2, PosY);
    Inc(Z2, Distance);

    Inc(X3, PosX);
    Inc(Y3, PosY);
    Inc(Z3, Distance);

    If (Z1 < ZLimit) Or (Z2 < ZLimit) Or (Z3 < ZLimit) Then GOTO NoFace;

{ Projecting... }
    F3DTo2D(X1, Y1, Z1);
    X1 := NewX + 160;
    Y1 := NewY + 100;
    F3DTo2D(X2, Y2, Z2);
    X2 := NewX + 160;
    Y2 := NewY + 100;
    F3DTo2D(X3, Y3, Z3);
    X3 := NewX + 160;
    Y3 := NewY + 100;

    Visible := ( (X2-X1) * (Y3-Y1) ) - ( (Y2-Y1) * (X3-X1) );

    If Visible < 0 Then
    Begin
      DrawFace(X1, Y1, X2, Y2, X3, Y3, MX1, MY1, MX2, MY2, MX3, MY3);
    End;
NoFace:
  End;


End;


Begin
  Initialize;

  GetPCXPalette('scape.pcx', Rgbs);
  Set256Palette(Rgbs);

  Draw;

  Repeat Until KeyPressed;

  ShutDown;
End.