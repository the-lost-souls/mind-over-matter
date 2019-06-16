;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            : PHONG.ASM
;Author          : Cyberfish of The Lost Souls
;Last update     : 19.10.1995
;Action          : Realtime phongshading... (Yeah, right!)
;
;
;Using Libraries             :
;Using external files/macros : An object file with the object...
;
;Notes : Hmmm... At last something I'm proud of. Of course it isn't REAL
;phongshading, but it looks nice anyway. (Look PHONG.TXT)
;----------------------------------------------------------------------------

.Model  Small
.Stack  100h

MaxPolys        EQU 4000
MaxPoints       EQU 4000

MoveX           EQU 5                 *2          ;The movement on the
MoveY           EQU 4                 *2          ;three axis
MoveZ           EQU 3                 *2

;The viewport...
ViewMinX        EQU 1
ViewMaxX        EQU 319
ViewMinY        EQU 0
ViewMaxY        EQU 199

ASSUME cs : MyCode, ds : MyData

MyData        SEGMENT PUBLIC

ACos            DB  1, 1        ;These two just for avoiding white pixels...
                DB   1 ,  2 ,  3 ,  5 ,  6 ,  8 ,  9 , 11 , 13
                DB  14 , 16 , 17 , 19 , 20 , 22 , 23 , 25 , 26
                DB  28 , 29 , 31 , 32 , 34 , 35 , 37 , 38 , 39
                DB  41 , 42 , 44 , 45 , 46 , 48 , 49 , 50 , 52
                DB  53 , 54 , 55 , 57 , 58 , 59 , 60 , 61 , 63
                DB  64 , 65 , 66 , 67 , 68 , 69 , 70 , 71 , 72
                DB  73 , 74 , 75 , 75 , 76 , 77 , 78 , 79 , 79
                DB  80 , 81 , 82 , 82 , 83 , 83 , 84 , 85 , 85
                DB  86 , 86 , 87 , 87 , 87 , 88 , 88 , 88 , 89
                DB  89 , 89 , 89 , 90 , 90 , 90 , 90 , 90 , 90

                DB  92 , 92 , 93 , 95 , 96 , 98 , 99 ,101 ,103
                DB 104 ,106 ,107 ,109 ,110 ,112 ,113, 115 ,116
                DB 118 ,119 ,121 ,122 ,124 ,125 ,127 ,128 ,129
                DB 131 ,132 ,134 ,135 ,136, 138 ,139 ,140 ,142
                DB 143 ,144 ,145 ,147 ,148 ,149 ,150 ,151 ,153
                DB 154 ,155 ,156, 157 ,158 ,159 ,160 ,161 ,162
                DB 163 ,164 ,165 ,165 ,166 ,167 ,168 ,169 ,169
                DB 170, 171 ,172 ,172 ,173 ,173 ,174 ,175 ,175
                DB 176 ,176 ,177 ,177 ,177 ,178 ,178 ,178, 179
                DB 179 ,179 ,179 ,180 ,180 ,180 ,180 ,180 ,180

;The inverse cosinus-table
CosTabl         DB 90,89,89,89,89,88,88,88,88,87,87,87,87,87,86,86
                DB 86,86,85,85,85,85,85,84,84,84,84,83,83,83,83,83
                DB 82,82,82,82,81,81,81,81,81,80,80,80,80,79,79,79
                DB 79,78,78,78,78,78,77,77,77,77,76,76,76,76,75,75
                DB 75,75,75,74,74,74,74,73,73,73,73,72,72,72,72,72
                DB 71,71,71,71,70,70,70,70,69,69,69,69,68,68,68,68
                DB 67,67,67,67,67,66,66,66,66,65,65,65,65,64,64,64
                DB 64,63,63,63,63,62,62,62,62,61,61,61,61,60,60,60
                DB 60,59,59,59,58,58,58,58,57,57,57,57,56,56,56,56
                DB 55,55,55,54,54,54,54,53,53,53,53,52,52,52,51,51
                DB 51,51,50,50,50,49,49,49,48,48,48,48,47,47,47,46
                DB 46,46,45,45,45,45,44,44,44,43,43,43,42,42,42,41
                DB 41,41,40,40,40,39,39,38,38,38,37,37,37,36,36,36
                DB 35,35,34,34,34,33,33,32,32,32,31,31,30,30,29,29
                DB 28,28,28,27,27,26,26,25,25,24,23,23,22,22,21,20
                DB 20,19,19,18,17,16,16,15,14,13,12,11,10,08,05,00

;----------------------------------------------------------------------------
;The sinus table for angles in 1 - 360 degrees. All values are multiplied
;by 256 to save decimals.
;----------------------------------------------------------------------------

SinTabl         DW    1,    4,    9,   13,   18,   22,   27,   31,   36,   40
                DW   44,   49,   53,   58,   62,   66,   71,   75,   79
                DW   83,   88,   92,   96,  100,  104,  108,  112,  116
                DW  120,  124,  128,  132,  136,  139,  143,  147,  150
                DW  154,  158,  161,  165,  168,  171,  175,  178,  181
                DW  184,  187,  190,  193,  196,  199,  202,  204,  207
                DW  210,  212,  215,  217,  219,  222,  224,  226,  228
                DW  230,  232,  234,  236,  237,  239,  241,  242,  243
                DW  245,  246,  247,  248,  249,  250,  251,  252,  253
                DW  254,  254,  255,  255,  255,  256,  256,  256,  256
                DW  256,  256,  256,  255,  255,  255,  254,  254,  253
                DW  252,  251,  250,  249,  248,  247,  246,  245,  243
                DW  242,  241,  239,  237,  236,  234,  232,  230,  228
                DW  226,  224,  222,  219,  217,  215,  212,  210,  207
                DW  204,  202,  199,  196,  193,  190,  187,  184,  181
                DW  178,  175,  171,  168,  165,  161,  158,  154,  150
                DW  147,  143,  139,  136,  132,  128,  124,  120,  116
                DW  112,  108,  104,  100,   96,   92,   88,   83,   79
                DW   75,   71,   66,   62,   58,   53,   49,   44,   40
                DW   36,   31,   27,   22,   18,   13,    9,    4,    0
                DW   -4,   -9,  -13,  -18,  -22,  -27,  -31,  -36,  -40
                DW  -44,  -49,  -53,  -58,  -62,  -66,  -71,  -75,  -79
                DW  -83,  -88,  -92,  -96, -100, -104, -108, -112, -116
                DW -120, -124, -128, -132, -136, -139, -143, -147, -150
                DW -154, -158, -161, -165, -168, -171, -175, -178, -181
                DW -184, -187, -190, -193, -196, -199, -202, -204, -207
                DW -210, -212, -215, -217, -219, -222, -224, -226, -228
                DW -230, -232, -234, -236, -237, -239, -241, -242, -243
                DW -245, -246, -247, -248, -249, -250, -251, -252, -253
                DW -254, -254, -255, -255, -255, -256, -256, -256, -256
                DW -256, -256, -256, -255, -255, -255, -254, -254, -253
                DW -252, -251, -250, -249, -248, -247, -246, -245, -243
                DW -242, -241, -239, -237, -236, -234, -232, -230, -228
                DW -226, -224, -222, -219, -217, -215, -212, -210, -207
                DW -204, -202, -199, -196, -193, -190, -187, -184, -181
                DW -178, -175, -171, -168, -165, -161, -158, -154, -150
                DW -147, -143, -139, -136, -132, -128, -124, -120, -116
                DW -112, -108, -104, -100,  -96,  -92,  -88,  -83,  -79
                DW  -75,  -71,  -66,  -62,  -58,  -53,  -49,  -44,  -40
                DW  -36,  -31,  -27,  -22,  -18,  -13,   -9,   -4,    0
                DW    4,    9,   13,   18,   22,   27,   31,   36,   40
                DW   44,   49,   53,   58,   62,   66,   71,   75,   79
                DW   83,   88,   92,   96,  100,  104,  108,  112,  116
                DW  120,  124,  128,  132,  136,  139,  143,  147,  150
                DW  154,  158,  161,  165,  168,  171,  175,  178,  181
                DW  184,  187,  190,  193,  196,  199,  202,  204,  207
                DW  210,  212,  215,  217,  219,  222,  224,  226,  228
                DW  230,  232,  234,  236,  237,  239,  241,  242,  243
                DW  245,  246,  247,  248,  249,  250,  251,  252,  253
                DW  254,  254,  255,  255,  255,  256,  256,  256,  256
                DW  256,  256,  256,  255,  255,  255,  254,  254,  253





;The blue palette :

Palette                DB  63,  53,  63,  63,  53,  63,  63,  53,  61,  63,  52,  60,  63,  52,  57,  62,  51,  54,  62,  50,  50,  62,  49,  46,  62,  49,  46
                DB  61,  48,  38,  61,  47,  34,  61,  46,  29,  61,  45,  25,  60,  44,  22,  60,  43,  18,  60,  42,  15,  59,  42,  12,  59,  42,  12
                DB  59,  41,   8,  59,  40,   6,  58,  40,   5,  58,  39,   4,  58,  39,   3,  58,  39,   2,  57,  39,   2,  57,  38,   1,  57,  38,   1
                DB  57,  38,   1,  57,  38,   0,  56,  38,   0,  56,  37,   0,  56,  37,   0,  55,  37,   0,  55,  37,   0,  55,  37,   0,  55,  36,   0
                DB  54,  36,   0,  54,  36,   0,  54,  36,   0,  53,  36,   0,  53,  35,   0,  53,  35,   0,  52,  35,   0,  52,  35,   0,  52,  34,   0
                DB  51,  34,   0,  51,  34,   0,  50,  34,   0,  50,  33,   0,  50,  33,   0,  49,  33,   0,  49,  33,   0,  48,  32,   0,  48,  32,   0
                DB  48,  32,   0,  47,  31,   0,  47,  31,   0,  46,  31,   0,  46,  31,   0,  45,  30,   0,  45,  30,   0,  45,  30,   0,  44,  29,   0
                DB  44,  29,   0,  43,  29,   0,  43,  28,   0,  42,  28,   0,  42,  28,   0,  41,  27,   0,  41,  27,   0,  40,  27,   0,  40,  27,   0
                DB  39,  26,   0,  39,  26,   0,  38,  26,   0,  38,  25,   0,  37,  25,   0,  37,  24,   0,  36,  24,   0,  36,  24,   0,  35,  23,   0
                DB  35,  23,   0,  34,  23,   0,  34,  22,   0,  33,  22,   0,  33,  22,   0,  32,  21,   0,  32,  21,   0,  31,  21,   0,  31,  20,   0

;The red palette :
                DB  40,  40,  53,  39,  39,  53,  38,  38,  52,  35,  35,  51,  31,  31,  50,  27,  27,  49,  23,  23,  47,  19,  19,  46,  19,  19,  46
                DB  11,  11,  43,   9,   9,  42,   6,   6,  42,   4,   4,  41,   3,   3,  40,   2,   2,  40,   1,   1,  40,   1,   1,  39,   1,   1,  39
                DB   0,   0,  39,   0,   0,  39,   0,   0,  39,   0,   0,  38,   0,   0,  38,   0,   0,  38,   0,   0,  38,   0,   0,  38,   0,   0,  37
                DB   0,   0,  37,   0,   0,  37,   0,   0,  37,   0,   0,  37,   0,   0,  36,   0,   0,  36,   0,   0,  36,   0,   0,  36,   0,   0,  35
                DB   0,   0,  35,   0,   0,  35,   0,   0,  35,   0,   0,  34,   0,   0,  34,   0,   0,  34,   0,   0,  34,   0,   0,  33,   0,   0,  33
                DB   0,   0,  33,   0,   0,  32,   0,   0,  32,   0,   0,  32,   0,   0,  31,   0,   0,  31,   0,   0,  31,   0,   0,  30,   0,   0,  30
                DB   0,   0,  30,   0,   0,  29,   0,   0,  29,   0,   0,  29,   0,   0,  28,   0,   0,  28,   0,   0,  27,   0,   0,  27,   0,   0,  27
                DB   0,   0,  26,   0,   0,  26,   0,   0,  26,   0,   0,  25,   0,   0,  25,   0,   0,  24,   0,   0,  24,   0,   0,  24,   0,   0,  23
                DB   0,   0,  23,   0,   0,  22,   0,   0,  22,   0,   0,  21,   0,   0,  21,   0,   0,  21,   0,   0,  20,   0,   0,  20,   0,   0,  19
                DB   0,   0,  19,   0,   0,  18,   0,   0,  18,   0,   0,  18,   0,   0,  17,   0,   0,  17,   0,   0,  16,   0,   0,  16,   0,   0,  15




;EXTRN           NumOfFaces : WORD, NumOfVertexes : WORD, Coords : WORD, PolyDefs : WORD;

VecX1           DW 0
VecY1           DW 0
VecZ1           DW 0
VecX2           DW 0
VecY2           DW 0
VecZ2           DW 0

Mul1            DW 0
Mul2            DW 0
Mul3            DW 0
Mul4            DW 0
Mul5            DW 0
Mul6            DW 0

Ph_X1           DW 0
Ph_Y1           DW 0
Ph_X2           DW 0
Ph_Y2           DW 0
Ph_X3           DW 0
Ph_Y3           DW 0                           ;Used in the polyfill
Ph_Ang1         DB 0
Ph_Ang2         DB 0
Ph_Ang3         DB 0
Ph_X1Move       DD 0
Ph_X2Move       DD 0
Ph_diMove       DD 0
Ph_Ang1Move     DW 0
Ph_Ang2Move     DW 0
Ph_LR           DB 0

X               DW 0                            ;
Y               DW 0                            ;
Z               DW 0                            ;Variables for procedure
X_Angle         DW 0                            ;"ROTATE"
Y_Angle         DW 0                            ;Storage variables for the
Z_Angle         DW 0                            ;input values
NewX            DW 0                            ;
NewY            DW 0                            ;
NewZ            DW 0                            ;

ObjX            DW 0
ObjY            DW 0
ObjZ            DW 1200
AngleX          DW 0
AngleY          DW 0
AngleZ          DW 0

Toughness       DW 750

SinVal1         DW 0
CosVal1         DW 0
SinVal2         DW 0
CosVal2         DW 0
SinVal3         DW 0
CosVal3         DW 0

XMax            DW 0
XMin            DW 0
YMax            DW 0
YMin            DW 0

Col             DB 0
Col2            DB 0

Handle          DW 0
FileName        DB 'RawFile.Raw', 0
FileName2       DB 'Object2.bin', 0
FileName3       DB 'Obj2_n.bin', 0
BPC             DW 0

ObjP            DW OFFSET NumOfVerts1

NumOfVerts1     DW 1024
OFSCoords       DW 2
NumOfFaces1     DW 2048
OFSFaces        DW 6148

MyData        ENDS


MyCode        SEGMENT
.386

;----------------------------------------------------------------------------
;A procedure which manages the calculating of the points.
;si = OFFSET Object
;----------------------------------------------------------------------------

;ds, gs = MyData
;es     = TempCoords
;fs     = DifData

Rotation      PROC
                mov   ax, TempCoords
                mov   es, ax
                mov   ax, DifData
                mov   fs, ax
                mov   ax, ObjSeg
                mov   gs, ax
                mov   di, OFSTempCoords         ;Constant
;                mov   si, OFFSET Coords         ;Real offset
                mov   si, ObjP
                mov   si, [si + 2]
                xor   bp, bp                    ;Zero counter

RotateLoop:
                mov   bx, bp
                shl   bx, 1
                mov   cx, Toughness
                sub   cx, fs:[bx + OFSVertLengths]

;------------ Setting X-angle
                mov   ax, MoveX
                cwd
                shld  dx, ax, 11
                shl   ax, 11

                div   cx

                shl   ax, 1
                mov   bx, AngleX
                sub   bx, ax
                cmp   bx, 0
                jg    AngleX1OK
                add   bx, 360 *2
AngleX1OK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + 180]
                mov   CosVal1, ax

;------------- Done Z-Angle


;------------ Setting Y-angle
                mov   ax, MoveY
                cwd
                shld  dx, ax, 11
                shl   ax, 11

                div   cx

                shl   ax, 1
                mov   bx, AngleY
                sub   bx, ax
                cmp   bx, 0
                jg    AngleY1OK
                add   bx, 360 *2
AngleY1OK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 180]
                mov   CosVal2, ax

;------------- Done Y-Angle

;------------ Setting Z-angle
                mov   ax, MoveZ
                cwd
                shld  dx, ax, 11
                shl   ax, 11

                div   cx

                shl   ax, 1
                mov   bx, AngleZ
                sub   bx, ax
                cmp   bx, 0
                jg    AngleZ1OK
                add   bx, 360 *2
AngleZ1OK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal3, ax
                mov   ax, [bx + 180]
                mov   CosVal3, ax

;------------- Done Z-Angle


;----------- Rotating...
                pusha                           ;Save registers
                mov   X, ax                     ;Save coordinates
                mov   Y, bx                     ;
                mov   Z, cx                     ;

;----------------------------------------------------------------------------
;Let's rock around the X-axis first :
;----------------------------------------------------------------------------

                mov   ax, gs:[si + 2]                     ;Put Y-coordinate in ax
                shl   ax, 3

                imul  CosVal1                        ;Multiply Y with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[si + 4]                     ;Put Z-coordinate in ax
                shl   ax, 3

                imul  SinVal1                        ;Multiply Z (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   NewY, bx                  ;Save NewY

;----------------------------------------------------------------------------
;Done calculating the new Y-coordinate rotated X_Angle degrees
;----------------------------------------------------------------------------

                mov   ax, gs:[si + 2]                     ;Put Y-coordinate in ax
                shl   ax, 3

                imul  SinVal1                        ;Multiply Y (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[si + 4]           ;Load Z
                shl   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewZ, bx                  ;Save NewZ

;----------------------------------------------------------------------------
;Done calculating the new Z-coordinate rotated X_Angle degrees
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Let's swing the Y-axis :
;----------------------------------------------------------------------------

                mov   ax, NewZ                     ;Put Z-coordinate in ax

                imul  CosVal2                        ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[si]                     ;Put X-coordinate in ax
                shl   ax, 3

                imul  SinVal2                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   ax, NewZ                  ;Put "old" Z-coordinate in ax
                                                ;cause I can't use the newly
                                                ;calculated Z-coordinate here
                mov   NewZ, bx                  ;Save NewZ

;----------------------------------------------------------------------------
;Done calculating the new Z-coordinate rotated Y_Angle degrees
;----------------------------------------------------------------------------

                imul  SinVal2                        ;Multiply Z (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[si]                     ;Put X-coordinate in ax
                shl   ax, 3

                imul  CosVal2                        ;Multiply X (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewX, bx                  ;Save NewX

;----------------------------------------------------------------------------
;Done calculating the new X-coordinate rotated Y_Angle degrees
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;Let's do the Z-axis :
;----------------------------------------------------------------------------

                mov   ax, NewX                  ;Put X-coordinate in ax

                imul  CosVal3                        ;Multiply X with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Put Y-coordinate in ax

                imul  SinVal3                        ;Multiply Y (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax
                mov   ax, NewX
                mov   NewX, bx                  ;Save NewX

;----------------------------------------------------------------------------
;Done calculating the new X-coordinate rotated Z_Angle degrees
;----------------------------------------------------------------------------

                imul  SinVal3                        ;Multiply Y (ax) with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                     ;Load X-coordinate

                imul  CosVal3                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewY, bx                  ;Save NewY

;----------------------------------------------------------------------------
;Done calculating the new Y-coordinate rotated Z_Angle degrees
;----------------------------------------------------------------------------

                popa                            ;Load registers

                mov   ax, NewX                  ;Put the calculated
                mov   bx, NewY                  ;values back in to the
                mov   cx, NewZ                  ;registers
                sar   ax, 3
                sar   bx, 3
                sar   cx, 3
;---------- Done rotation...

                add   ax, ObjX                  ;Add objects position
                add   bx, ObjY                  ;You may remove them if they
                add   cx, ObjZ                  ;are zero

                mov   es:[di], ax                  ;Put the calculated X,
                mov   es:[di + 2], bx              ;Y
                mov   es:[di + 4], cx              ;and Z coords in TempCoords

                add   di, 6                     ;Point to next record
                add   si, 6
                inc   bp
                mov   bx, ObjP
                cmp   bp, [bx]                  ;NumOfVertexes
                jb    RotateLoop                ;Next coordinate

                ret
Rotation      ENDP

;ds, gs = MyData
;fs, es = DifData

StoreCl        PROC
                mov   ax, DifData
                mov   fs, ax
                mov   ax, PolyData
                mov   es, ax
                xor   di, di
                mov   bp, OFSNormalV            ;Segment DifData

StoreCLoop:
                mov   bx, di
                shl   bx, 1
                mov   ax, Toughness
                sub   ax, fs:[bx + OFSVertLengths]
                mov   cx, ax

;--------Setting X-angle
                mov   ax, MoveX
                cwd
                shld  dx, ax, 11
                shl   ax, 11
                div   cx

                shl   ax, 1
                mov   bx, AngleX
                sub   bx, ax
                cmp   bx, 0
                jg    AngleX2OK
                add   bx, 360 *2
AngleX2OK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + 180]
                mov   CosVal1, ax
;----------- Done X-angle

;--------Setting Y-angle
                mov   ax, MoveY
                cwd
                shld  dx, ax, 11
                shl   ax, 11
                div   cx

                shl   ax, 1
                mov   bx, AngleY
                sub   bx, ax
                cmp   bx, 0
                jg    AngleY2OK
                add   bx, 360 *2
AngleY2OK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 180]
                mov   CosVal2, ax
;----------- Done Y-angle

;-----------Rotating the normal vector...

;----------------------------------------------------------------------------
;Let's rock around the X-axis first :
;----------------------------------------------------------------------------

                mov   ax, fs:[bp + 2]           ;Load Y
                sal   ax, 3
                imul  SinVal1                        ;Multiply Y (ax) with Sinvalue

                mov   cl, ah                    ;Shift right by 8
                mov   ch, dl                    ;

                mov   ax, fs:[bp + 4]
                sal   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8
;                mov   al, ah                    ;Shift right by 8
;                mov   ah, dl                    ;

                add   ax, cx

;----------------------------------------------------------------------------
;Let's swing the Y-axis :
;----------------------------------------------------------------------------

                imul  CosVal2                        ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[bp]               ;Put X-coordinate in ax
                sal   ax, 3

                imul  SinVal2                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8
;                mov   al, ah                    ;Shift right by 8
;                mov   ah, dl

                sub   bx, ax                    ;Done

;----------------- Rotated normal vector, done. ----------------------------
                sar   bx, 3
                cmp   bx, 0
                jge   Positive1
                neg   bx                        ;Make value positive
Positive1:
                mov   al, [OFFSET CosTabl + bx] ;Get angle

;dl = Angle of light hitting the vertex (corresponding to the normal vector)

                stosb                           ;OFSCValues MUST be first
                                                ;in segment DifData!!!

                add   bp, 6
                mov   bx, ObjP
                cmp   di, [bx]                  ;NumOfVertexes
                jb    StoreCLoop                ;Next coordinate
                ret
StoreCl       ENDP


;gs, ds = MyData
;es     = PolyData
;fs     = DifData

StoreP        PROC
                mov   ax, ObjSeg
                mov   gs, ax
                mov   ax, MyData
                mov   ds, ax
                mov   ax, PolyData
                mov   es, ax
                mov   ax, TempCoords
                mov   fs, ax
;                mov   si, OFFSET PolyDefs
                mov   si, ObjP
                mov   si, [si + 6]
                mov   di, OFSPoly
                xor   bp, bp

StoreLoop:
                mov   XMax, -32768
                mov   XMin, 32767
                mov   YMax, -32768
                mov   YMin, 32767

                mov   ax, di
                add   ax, 20
                mov   es:[di], ax

;----------------- Rotated normal vector, done. ----------------------------

;                lodsw                           ;Load first vertex
                mov   ax, gs:[si]
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, cx
                add   bx, 15000                 ;Make all z-values positive
                mov   es:[di + 2], bx              ;Save Z-value to sort

                mov   bx, gs:[si]                  ;Load first vertex again
                mov   bl, es:[OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 5], dl              ;Save color
                call  F3DTo2D                   ;Project
                add   ax, 160
                add   bx, 100
                mov   es:[di + 8], ax              ;Save 2D-X
                mov   es:[di + 10], bx             ;Save 2D-Y

                cmp   ax, XMax
                jle   XLower1
                mov   XMax, ax
XLower1:
                cmp   ax, XMin
                jge   XHigher1
                mov   XMin, ax
XHigher1:
                cmp   bx, YMax
                jle   YLower1
                mov   YMax, bx
YLower1:
                cmp   bx, YMin
                jge   YHigher1
                mov   YMin, bx
YHigher1:



;Done first vertex/angle

;                lodsw                           ;Load second vertex
                mov   ax, gs:[si + 2]
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, gs:[si + 2]              ;Load second vertex again
                mov   bl, es:[OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 6], dl
                call  F3DTo2D
                add   ax, 160
                add   bx, 100
                mov   es:[di + 12], ax             ;Save 2D-X
                mov   es:[di + 14], bx             ;Save 2D-Y

                cmp   ax, XMax
                jle   XLower2
                mov   XMax, ax
XLower2:
                cmp   ax, XMin
                jge   XHigher2
                mov   XMin, ax
XHigher2:
                cmp   bx, YMax
                jle   YLower2
                mov   YMax, bx
YLower2:
                cmp   bx, YMin
                jge   YHigher2
                mov   YMin, bx
YHigher2:


;Done second vertex/angle

;                lodsw                           ;Load third vertex
                mov   ax, gs:[si + 4]
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, gs:[si + 4]              ;Load third vertex again
                mov   bl, es:[OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 7], dl
                call  F3DTo2D
                add   ax, 160
                add   bx, 100
                mov   es:[di + 16], ax           ;Save 2D-X
                mov   es:[di + 18], bx           ;Save 2D-Y

                cmp   ax, XMax
                jle   XLower3
                mov   XMax, ax
XLower3:
                cmp   ax, XMin
                jge   XHigher3
                mov   XMin, ax
XHigher3:
                cmp   bx, YMax
                jle   YLower3
                mov   YMax, bx
YLower3:
                cmp   bx, YMin
                jge   YHigher3
                mov   YMin, bx
YHigher3:

;Done third vertex/angle

                cmp   XMax, ViewMinX
                jl    DumpPoly
                cmp   XMin, ViewMaxX
                jg    DumpPoly
                cmp   YMax, ViewMinY
                jl    DumpPoly
                cmp   YMin, ViewMaxY
                jg    DumpPoly

                call  Visible
                cmp   ax, 0
                jge   DumpPoly

                add   di, 20
DumpPoly:
                add   si, 6
                inc   bp
                mov   bx, ObjP
                cmp   bp, [bx + 4]
                jb    StoreLoop                ;Next coordinate
                mov   WORD PTR es:[di - 20], 0

                mov   ax, Canvas
                mov   es, ax
                mov   ax, MyData
                mov   gs, ax

                ret
StoreP        ENDP

;gs     = MyData
;es, ds = PolyData

SortPolys     PROC
                push  es
                mov   ax, PolyData
                mov   es, ax
                mov   ds, ax

                mov   di, OFSFStart
                mov   cx, 256 * 2 /4            ;256 values * 2 bytes
                mov   eax, 0FFFFFFFFh
                rep   stosd

                mov   di, OFSFOfs
                mov   cx, 256
                mov   ax, OFSFStart
SetStartOffs1 :
                stosw
                add   ax, 2
                loop  SetStartOffs1

                mov   si, OFSPoly
                xor   cx, cx

;--------------------- Here goes the first radix ----------------------------

Byte1L:
                mov   cl, BYTE PTR [si + 2]     ;Load first radix (byte)
                mov   bx, 255
                sub   bx, cx
                shl   bx, 1                     ;Word structure
                add   bx, OFSFOfs

                mov   di, [bx]                  ;Load end of list

                mov   [bx], si                  ;Store current offset
                mov   [di], si                  ;/

                mov   si, [si]                  ;Next face
                or    si, si                    ;At end?
                jnz   Byte1L                    ;Nope...

;----------------- Done first radix. Now Connecting lists... -----------------

                mov   si, OFSFOfs
                xor   cx, cx
MarkEnd1 :
                lodsw                           ;Load offset to end of list
                add   cx, 2
                mov   bx, ax
                cmp   WORD PTR [bx], 0FFFFh
                je    MarkEnd1
                mov   di, cx
                add   di, OFSFStart

NextOffs1 :
                mov   ax, [di]
                cmp   di, OFSFStart + 512
                jge   DoneConnect1
                add   di, 2
                cmp   ax, 0FFFFh
                je    NextOffs1

                mov   [bx], ax                  ;Connect end with next list
                jmp   MarkEnd1

DoneConnect1 :
                mov   WORD PTR [bx], 0          ;Mark final end

;------------------ Sorting second radix, setting up... ------------------------
                mov   si, OFSFStart - 2     ;Load start of list
FindStart :
                add   si, 2
                cmp   WORD PTR [si], 0FFFFh
                je    FindStart

                mov   si, [si]

                mov   di, OFSFStart
                mov   cx, 256 * 2 /4            ;256 values * 2 bytes
                mov   eax, 0FFFFFFFFh
                rep   stosd

                mov   di, OFSFOfs
                mov   cx, 256
                mov   ax, OFSFStart
SetStartOffs2 :
                stosw
                add   ax, 2
                loop  SetStartOffs2
                xor   cx, cx

;--------------------- Here goes the second radix ----------------------------

Byte2L:
                mov   cl, BYTE PTR [si + 3]     ;Load second radix (byte)
                mov   bx, 255
                sub   bx, cx
                shl   bx, 1                     ;Word structure
                add   bx, OFSFOfs

                mov   di, [bx]                  ;Load end of list

                mov   [bx], si                  ;Store current offset
                mov   [di], si                  ;/

                mov   si, [si]                  ;Next face
                or    si, si                    ;At end?
                jnz   Byte2L                    ;Nope...

;----------------- Done second radix. Now Connecting lists... ----------------

                mov   si, OFSFOfs
                xor   cx, cx
MarkEnd2 :
                lodsw                           ;Load offset to end of list
                add   cx, 2
                mov   bx, ax
                cmp   WORD PTR [bx], 0FFFFh
                jz    MarkEnd2
                mov   di, cx
                add   di, OFSFStart
NextOffs2 :

                mov   ax, [di]
                cmp   di, OFSFStart + 512
                jge   DoneConnect2
                add   di, 2
                cmp   ax, 0FFFFh
                je    NextOffs2

                mov   [bx], ax                  ;Connect end with next list
                jmp   MarkEnd2

DoneConnect2 :
                mov   WORD PTR [bx], 0          ;Mark final end

                mov   ax, MyData
                mov   ds, ax
                pop   es
                ret
SortPolys     ENDP

;es = canvas
;ds = PolyData


DrawPolys     PROC
                cld
                mov   ax, PolyData
                mov   ds, ax
                mov   si, OFSFStart - 2
FindStart2 :
                add   si, 2
                cmp   WORD PTR [si], 0FFFFh
                je    FindStart2
                mov   si, [si]

DrawLoop:
                or    si, si
                jz    DoneDraw
                push  si

                add   si, 5
                mov   al, [si - 1]
                mov   gs:Col, 91
                call  DrawPTri

                pop   si
                mov   si, [si]

                jmp   DrawLoop

DoneDraw:
                mov   ax, MyData
                mov   ds, ax
                ret
DrawPolys     ENDP

DrawPTri      PROC
                mov   di, [si +  3]             ;Load X1
                mov   bp, [si +  5]             ;Load Y1
                mov   cx, [si +  7]             ;Load X2
                mov   dx, [si +  9]             ;Load Y2
                mov   ax, [si + 11]
                mov   gs:Ph_X3, ax
                mov   ax, [si + 13]
                mov   gs:Ph_Y3, ax
                mov   al, [si]                  ;Load Angle1
                mov   ah, [si + 1]              ;Load Angle2
                mov   bl, [si + 2]              ;Load Angle3

                push  MyData
                pop   ds

;The next three compares are for flipping the triangle. After these
;compares the state should be : Y1 < Y2 < Y3

                cmp   bp, dx                    ;Y1, Y2
                jle   Y1_Y2                     ;Y1 is smaller than Y2
                xchg  bp, dx                    ;Y1 <-> Y2
                xchg  di, cx                    ;X1 <-> X2
                xchg  al, ah                    ;Angle1 <-> Angle2
Y1_Y2:

                cmp   bp, Ph_Y3                 ;Y1, Y3
                jle   Y1_Y3                     ;Y1 is smaller than Y3
                xchg  bp, Ph_Y3                 ;Y1 <-> Y3
                xchg  di, Ph_X3                 ;X1 <-> X3
                xchg  al, bl                    ;Angle1 <-> Angle3
Y1_Y3:

                cmp   dx, Ph_Y3                 ;Y2, Y3
                jle   Y3_Y2                     ;Y2 is smaller than Y3
                xchg  dx, Ph_Y3                 ;Y2 <-> Y3
                xchg  cx, Ph_X3                 ;X2 <-> X3
                xchg  ah, bl                    ;Angle2 <-> Angle3
Y3_Y2:

                mov   Ph_X1, di                 ;Save X1
                mov   Ph_Y1, bp                 ;Save Y1
                mov   Ph_X2, cx                 ;Save X2
                mov   Ph_Y2, dx                 ;Save Y2

                mov   Ph_Ang1, al               ;Save Angle1
                mov   Ph_Ang2, ah               ;Save Angle2
                mov   Ph_Ang3, bl               ;Save Angle3
;There, now the state should be : Y1 < Y2 < Y3 (the angles is switched too)

                xor   ebx, ebx
                mov   ax, Ph_X2                 ;Make DeltaX (X3 - X1)
                sub   ax, Ph_X1                 ;/
                mov   bx, Ph_Y2
                sub   bx, Ph_Y1
                inc   bx

                cwde
                cdq                             ;eax -> eax:edx
                shl   eax, 8                    ;*256
                idiv  ebx                       ;Slope1
                mov   Ph_X1Move, eax            ;Save slope1

                mov   ah, Ph_Ang2               ;
                sub   ah, Ph_Ang1               ;Angle1Delta
                xor   al, al
                cwd
                idiv  bx                        ;Angleslope1
                mov   Ph_Ang1Move, ax

                mov   ax, Ph_X3
                sub   ax, Ph_X1
                mov   bx, Ph_Y3
                sub   bx, Ph_Y1
                inc   bx

                cwde
                cdq                             ;ax -> ax:dx
                sal   eax, 8                    ;*256
                idiv  ebx
                mov   Ph_X2Move, eax

                mov   ah, Ph_Ang3               ;
                sub   ah, Ph_Ang1               ;Angle1Delta
                xor   al, al
                cwd
                idiv  bx                        ;Angleslope1
                mov   Ph_Ang2Move, ax

                movzx ecx, Ph_X1                ;Init X-counters
                shl   ecx, 8                    ;/
                mov   edx, ecx                  ;/
                mov   edi, ecx                  ;/...and di

                mov   Ph_LR, 1
                mov   eax, Ph_X1Move
                cmp   eax, Ph_X2Move            ;X1move, X2move
                jl    NoFlip
                mov   Ph_LR, 0
NoFlip:

                xor   bx, bx
                mov   bh, Ph_Ang1               ;Init Angle-counters
                mov   si, bx

                mov   bp, Ph_Y1

;-------------------------------- Main loop ----------------------------------

Ph_Loop:

                mov   edi, edx
                or    Ph_LR, 0
                jz    UseX2
                mov   edi, ecx
UseX2:


;------------- Clipping the Y value

                cmp   bp, ViewMaxY
                jg    Ph_Done
                cmp   bp, ViewMinY
                jl    YClip

;------------------------------------

                push  ecx
                push  edx
                push  bx
                push  si

                xchg  bx, si
                or    Ph_LR, 0
                jz   NoSideFlip
                xchg  ecx, edx
                xchg  bx, si
NoSideFlip:

                shr   bx, 8
                shr   si, 8
                sar   edi, 8                    ;Left
                sar   ecx, 8                    ;Right
                mov   dx, cx
                sub   dx, di

                inc   dx
                cmp   dx, 0
                jg    NoPhuck2
                mov   dx, 1
NoPhuck2:


;------------Clipping right edge...

                cmp   di, ViewMaxX
                jl    Right1OK
                pop   si
                pop   bx
                pop   edx
                pop   ecx
                jmp   YClip
Right1OK:

                cmp   cx, ViewMaxX
                jl    RightOK
                mov   cx, ViewMaxX
RightOK:

;-------------Clipping left edge...
                cmp   cx, ViewMinX
                jg    Left1OK
                pop   si
                pop   bx
                pop   edx
                pop   ecx
                jmp   YClip
Left1OK:
                cmp   di, ViewMinX
                jge   LeftOK
                push  bx
                mov   ah, [OFFSET ACos + bx]
                sub   ah, [OFFSET ACos + si]
                xor   al, al

                mov   bx, dx
                cwd
                idiv  bx                        ;Horisontal colorslope

                pop   bx
                mov   dx, ViewMinX
                sub   dx, di
                imul  dx
                shrd  ax, dx, 8
                add   si, ax
                mov   dx, cx
                sub   dx, ViewMinX
                mov   di, ViewMinX

LeftOK:

                sub   cx, di

                inc   cx
                cmp   cx, 0
                jg    NoPhuck
                mov   cx, 1
NoPhuck:
;--------------------------- Done clipping ----------------------------------
;cx = number of pixels to put

                mov   ax, bp                    ;Set memory pointer
                shl   ax, 6
                add   di, ax
                mov   ax, bp
                shl   ax, 8
                add   di, ax

                mov   ah, [OFFSET ACos + bx]
                sub   ah, [OFFSET ACos + si]
                xor   al, al

                mov   bx, dx
                cwd
                idiv  bx                        ;Horisontal colorslope

                mov   dh, [OFFSET ACos + si]
                add   dh, Col
                xor   dl, dl
                mov   si, ax                    ;Use si as increasement
;                xor   bh, bh

;-------------------------- Horisontal loop ---------------------------------
;bx = used as pointer
;al = color
;si = increasement of horisontal colorcounter
;dx = colorcounter
;cx = number of pixels


                shr   cx, 1
                jnc   GoLoop
                jz    DoneLoop
                mov   bl, dh
                mov   al, [bx]
                stosb
                add   dx, si
GoLoop:

Ph_HorLoop:
                mov   bl, dh
                mov   al, [bx]
                add   dx, si
                mov   bl, dh
                mov   ah, [bx]
                stosw
                add   dx, si
                dec   cx
                jnz   Ph_HorLoop
;-------------------------- Horisontal loop finish --------------------------

DoneLoop:
                pop   si
                pop   bx
                pop   edx
                pop   ecx

YClip :
                inc   bp                        ;Increase Y
                cmp   bp, Ph_Y2
                jle   Ph_TestY3

;calculate new slopes
                push  edx

                xor   esi, esi
                mov   ax, Ph_X3
                sub   ax, Ph_X2
                mov   si, Ph_Y3
                sub   si, Ph_Y2
                inc   si

                cwde
                cdq
                sal   eax, 8
                idiv  esi                        ;Slope1
                mov   Ph_X1Move, eax            ;Save slope1

                mov   ah, Ph_Ang3               ;
                sub   ah, Ph_Ang2               ;Angle1Delta
                cwd
                xor   al, al
                idiv  si                        ;Angleslope1
                mov   Ph_Ang1Move, ax
                xor   al, al
                mov   ah, Ph_Ang2
                mov   si, ax

                movzx ecx, Ph_X2
                shl   ecx, 8
                pop   edx
                mov   Ph_Y2, 250

Ph_TestY3:

                add   ecx, Ph_X1Move
                add   edx, Ph_X2Move
                add   si, Ph_Ang1Move
                add   bx, Ph_Ang2Move

                cmp   bp, Ph_Y3
                jle   Ph_Loop

Ph_Done :
                mov   ax, PolyData
                mov   ds, ax

                ret
DrawPTri      ENDP

Main          PROC
                call  Initialize                ;Init palette, screen etc...

                mov   ax, MyData
                mov   ds, ax
                mov   gs, ax
                mov   ax, Canvas
                mov   es, ax

                mov   BPC, OFFSET Palette + (29 * 3)

;------------------------------ Done normals --------------------------------

PLoop:                                          ;Frameloop
                push  ds
                mov   ax, BackGrnd
                mov   ds, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                pop   ds

                call  Rotation
                call  StoreCl
                call  StoreP
                call  SortPolys
                call  DrawPolys

;Rotating palette...
                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, BPC

                mov   cx,32*3                  ;3*256 (RGB)=768 colors
                rep   outsb

                sub   BPC, 3
                cmp   BPC, OFFSET Palette
                jge   BpOK
                mov   BPC, OFFSET palette + (29*3)
BpOK:
;----------

                add   AngleX, MoveX
                cmp   AngleX, 720
                jbe    NoAngXFix
                sub   AngleX, 720
NoAngXFix:
                add   AngleY, MoveY
                cmp   AngleY, 720
                jbe    NoAngYFix
                sub   AngleY, 720
NoAngYFix:
                add   AngleZ, MoveZ
                cmp   AngleZ, 720
                jbe    NoAngZFix
                sub   AngleZ, 720
NoAngZFix:


                cld
                mov   ax, 0A000h
                mov   es, ax
                mov   ax, Canvas
                mov   ds, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd

                mov   ax, MyData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

;                mov   ah, 0
;                int   16h


                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Done                      ;OK, go home!
                jmp   PLoop                     ;No? Let's do another roll!
Done:

                call  ShutDown
Main          ENDP

Initialize    PROC
                mov   ax, MyData                ;Point ds to data-segment
                mov   gs, ax
                mov   ds, ax
                mov   ax, DifData
                mov   fs, ax
;-------------------------
                mov   ax, Canvas                ;Set es to canvas
                mov   es, ax

;----------------- Loading object...
                mov   ah, 3Dh                   ;Open file
                xor   al, al
                mov   dx, OFFSET FileName2
                int   21h
                mov   Handle, ax

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 18436                 ;Size of torus

                push  ds
                mov   dx, ObjSeg
                mov   ds, dx
                xor   dx, dx

                int   21h

                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close file
                int   21h

;Loading normals and vertlengths
                mov   ah, 3Dh                   ;Open file
                xor   al, al
                mov   dx, OFFSET FileName3
                int   21h
                mov   Handle, ax

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 1024 * 6              ;Size of normals

                push  ds
                mov   dx, DifData
                mov   ds, dx
                mov   dx, OFSNormalV

                int   21h

                mov   ah, 3Fh
                mov   bx, gs:Handle
                mov   cx, 1024 * 2
                mov   dx, OFSVertLengths
                int   21h

                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close file
                int   21h

;-------- Loading background...
                mov   ah, 3dh
                mov   al, 2
                mov   dx, OFFSET FileName
                int   21h
                mov   Handle, ax

                push  ds
                mov   bx, Handle
                mov   ax, BackGrnd
                mov   ds, ax
                mov   cx, 64000
                xor   dx, dx
                mov   ah, 3Fh
                int   21h
                pop   ds

                mov   ah, 3Eh
                mov   bx, Handle
                int   21h

                mov   si, OFFSET Palette
                mov   cx, 15
SetPal1:
                mov   al, cl
;                shl   al, 1
                add   al, 10
                mov   BYTE PTR [si], al
                mov   BYTE PTR [si + 1], 0
                mov   BYTE PTR [si + 2], 0
                add   si, 3
                loop  SetPal1

                xor   cx, cx
SetPal2:
                mov   al, cl
;                shl   al, 1
                add   al, 10
                mov   BYTE PTR [si], al
                mov   BYTE PTR [si + 1], 0
                mov   BYTE PTR [si + 2], 0
                add   si, 3
                inc   cx
                cmp   cx, 15
                jb    SetPal2

                mov   cx, 15
SetPal3:
                mov   al, cl
;                shl   al, 1
                add   al, 10
                mov   BYTE PTR [si], al
                mov   BYTE PTR [si + 1], 0
                mov   BYTE PTR [si + 2], 0
                add   si, 3
                loop  SetPal3

                xor   cx, cx
SetPal4:
                mov   al, cl
;                shl   al, 1
                add   al, 10
                mov   BYTE PTR [si], al
                mov   BYTE PTR [si + 1], 0
                mov   BYTE PTR [si + 2], 0
                add   si, 3
                inc   cx
                cmp   cx, 15
                jb    SetPal4

;------------

                mov   al, 13h                   ;320x200x256
                mov   ah, 00h                   ;set screenmode
                int   10h

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,1                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx,180*3                  ;3*256 (RGB)=768 colors
                rep   outsb

                xor   di, di                    ;Blank the canvas
                mov   cx, 16000
                xor   eax, eax
                rep   stosd

                ret
Initialize    ENDP

ShutDown      PROC
                pop  ax                        ;Dump ret adress
                mov  al, 03h                   ;80x25x16
                mov  ah, 00h                   ;set screenmode
                int  10h

                mov  ax, 04C00h
                int  21h
ShutDown      ENDP

;--------------------------- ASSEMBLER ROUTINE -------------------------------
;Name         : Visible
;Type         : Procedure
;Last update  : 10.10.95
;Action       : Tests if a triangle is visible for the crowd
;Optimized    : Think so...
;
;Input variables : [si] - [si+10] (6 Word values, 12 bytes)
;
;Output variables : ax
;
;Registers changed : ax, bx, cx, dx
;
;Notes : The input values are three XY-coords. If the triangle is visible,
;ax is returned with a positive value, if not it's coming home negative.
;The value of ax may be used for something useful, light-sourcing f.ex.
;PS : If the triangle is very big, you'll get an overflow on the ax-value,
;so you may want to divide the input-values down here before calculating.
;----------------------------------------------------------------------------

Visible       PROC
                mov   cx, es:[di + 12]
                mov   dx, es:[di + 14]
                mov   ax, es:[di + 16]
                mov   bx, es:[di + 18]

                sub   cx, es:[di + 8]                  ;X2-X1
                sub   bx, es:[di + 10]              ;Y3-Y1
                sub   dx, es:[di + 10]              ;Y2-Y1
                sub   ax, es:[di + 8]                  ;X3-X1

                imul  dx

                xchg  ax, bx

                imul  cx

                sub   ax, bx

                ret
Visible       ENDP

;----------------------------------------------------------------------------
;Name         : Rotate
;Type         : Procedure
;Last update  : Spring 1995
;Action       : Rotates a point around origo
;Optimized    : No. How do I a reduce the muls to 9???
;
;Input variables : ax = X   bx = Y   cx = Z
;                  dx = X_Angle si = Y_Angle di = Z_Angle
;
;Output variables : ax = NewX  bx = NewY  cx = NewZ
;
;Registers changed : ax, bx, cx
;
;Notes : Yes! Yes! Yes! At last : Rotating in assembler.
;----------------------------------------------------------------------------

Rotate        PROC
                pusha                           ;Save registers
                sal   ax, 3
                sal   bx, 3
                sal   cx, 3
                mov   X, ax                     ;Save coordinates
                mov   Y, bx                     ;
                mov   Z, cx                     ;

                mov   X_Angle, dx               ;Save angles
                mov   Y_Angle, si               ;
                mov   Z_Angle, di               ;


;----------------------------------------------------------------------------
;Let's rock around the X-axis first :
;----------------------------------------------------------------------------

                mov   si, dx                    ;Point to value [X_Angle]
                mov   cx, [si + 180 + OFFSET SinTabl]            ;Load cosinus(X_angle) in cx
                mov   bp, [si + OFFSET SinTabl]                  ;Load sinus(X_angle) in bp

                mov   ax, Y                     ;Put Y-coordinate in ax

                imul  cx                        ;Multiply Y with Cosvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                mov   di, ax                    ;Save ax in di

                mov   ax, Z                     ;Put Z-coordinate in ax

                imul  bp                        ;Multiply Z (ax) with Sinvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl

                sub   di, ax                    ;Done
                mov   NewY, di                  ;Save NewY

;----------------------------------------------------------------------------
;Done calculating the new Y-coordinate rotated X_Angle degrees
;----------------------------------------------------------------------------

                mov   ax, Y                     ;Put Y-coordinate in ax

                imul  bp                        ;Multiply Y (ax) with Sinvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                mov   di, ax                    ;Save ax in di

                mov   ax, Z

                imul  cx                        ;Multiply Z (ax) with Cosvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                add   di, ax
                mov   NewZ, di                  ;Save NewZ

;----------------------------------------------------------------------------
;Done calculating the new Z-coordinate rotated X_Angle degrees
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;Let's swing the Y-axis :
;----------------------------------------------------------------------------

                mov   si, Y_Angle               ;Point to value [Z_Angle]
                mov   cx, [si + 180 + OFFSET SinTabl]            ;Load cosinus(Z_angle) in cx
                mov   bp, [si + OFFSET SinTabl]                  ;Load sinus(Z_angle) in bp

                mov   ax, NewZ                     ;Put Z-coordinate in ax

                imul  cx                        ;Multiply Z with Cosvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                mov   di, ax                    ;Save ax in di

                mov   ax, X                     ;Put X-coordinate in ax

                imul  bp                        ;Multiply X (ax) with Sinvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl

                sub   di, ax                    ;Done
                mov   ax, NewZ                  ;Put "old" Z-coordinate in ax
                                                ;cause I can't use the newly
                                                ;calculated Z-coordinate here
                mov   NewZ, di                  ;Save NewZ

;----------------------------------------------------------------------------
;Done calculating the new Z-coordinate rotated Y_Angle degrees
;----------------------------------------------------------------------------

                imul  bp                        ;Multiply Z (ax) with Sinvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                mov   di, ax                    ;Save ax in di

                mov   ax, X                     ;Put X-coordinate in ax

                imul  cx                        ;Multiply X (ax) with Cosvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                add   di, ax
                mov   NewX, di                  ;Save NewX

;----------------------------------------------------------------------------
;Done calculating the new X-coordinate rotated Y_Angle degrees
;----------------------------------------------------------------------------
;----------------------------------------------------------------------------
;Let's do the Z-axis :
;----------------------------------------------------------------------------

                mov   si, Z_Angle               ;Point si to the Cos-values
                mov   cx, [si + 180 + OFFSET SinTabl]            ;Load cosinus(Z_angle) in cx
                mov   bp, [si + OFFSET SinTabl]                  ;Load sinus(Z_angle) in bp

                mov   ax, NewX                  ;Put X-coordinate in ax

                imul  cx                        ;Multiply X with Cosvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                mov   di, ax                    ;Save ax in di

                mov   ax, NewY                  ;Put Y-coordinate in ax

                imul  bp                        ;Multiply Y (ax) with Sinvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl

                sub   di, ax
                mov   ax, NewX
                mov   NewX, di                  ;Save NewX

;----------------------------------------------------------------------------
;Done calculating the new X-coordinate rotated Z_Angle degrees
;----------------------------------------------------------------------------

;                mov   ax, NewY                  ;Put Y-coordinate in ax

                imul  bp                        ;Multiply Y (ax) with Cosvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                mov   di, ax
                mov   ax, NewY                     ;Load X-coordinate

                imul  cx                        ;Multiply X (ax) with Sinvalue

                mov   al, ah                    ;Shift right by 8
                mov   ah, dl                    ;

                add   di, ax
                mov   NewY, di                  ;Save NewY

;----------------------------------------------------------------------------
;Done calculating the new Y-coordinate rotated Z_Angle degrees
;----------------------------------------------------------------------------

                popa                            ;Load registers

                mov   ax, NewX                  ;Put the calculated
                mov   bx, NewY                  ;values back in to the
                mov   cx, NewZ                  ;registers
                sar   ax, 3
                sar   bx, 3
                sar   cx, 3

                ret

Rotate        ENDP

;----------------------------------------------------------------------------
;Name         : F3DTO2D
;Type         : Procedure
;Last update  : 20.10.1995
;Action       : Projects 3D-coordinates (X, Y, Z) into the visible
;               X, Y - coordinates for the screen.
;Optimized    : Yes
;
;Input variables : ax = X   bx = Y   cx = Z
;
;Output variables : ax = NewX bx = NewY
;
;Registers changed : ax, bx
;
;Notes : The coordinates are calculated using origo as center.
;----------------------------------------------------------------------------

F3DTo2D       PROC
                push  cx
                push  dx

                cwd
                mov   dl, ah                    ;\
                mov   ah, al
                xor   al, al

                idiv  cx                        ;dx:ax / cx

                xchg  ax, bx
                cwd
                mov   dl, ah
                mov   ah, al
                xor   al, al

                idiv  cx
                xchg  ax, bx

                pop   dx
                pop   cx

                ret                             ;Go home!
F3DTo2D       ENDP

MyCode        ENDS

PolyData      SEGMENT
;The segment for the calculated polygons and the sorting arrays.
OFSCValues      EQU 0

OFSFStart       EQU 0 + 5000
OFSFOfs         EQU (256 * 2) + 5000
OFSPoly         EQU 1024 + 5000                 ;The starting offset of the
                                                ;faces.

                DB 65535 DUP (?)
PolyData      ENDS

DifData       SEGMENT
;Place for different calculated data.

OFSNormalV      EQU 0
OFSVertLengths  EQU OFSNormalV + (MaxPoints * 6)

                DB 65535 DUP (?)
DifData       ENDS

TempCoords    SEGMENT
OFSTempCoords   EQU 0
                DB 65535 DUP (?)
TempCoords    ENDS

ObjSeg        SEGMENT
                DB 64000 DUP (?)
ObjSeg        ENDS


BackGrnd      SEGMENT
                DB 64000 DUP (?)
BackGrnd      ENDS

;----------------------- The double buffer for screen ------------------------

Canvas        SEGMENT
                DB 64000 DUP (?)
Canvas        ENDS

END           Main
