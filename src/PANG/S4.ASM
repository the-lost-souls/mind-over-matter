;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            : PANG2.ASM
;Author          : Cyberfish of The Lost Souls
;Last update     : Desember 1995
;Action          : Yihaaa! Let's blow some ducks!!!
;
;
;Using Libraries             :
;Using external files/macros : An object file with the object...
;
;Notes :
;New Procedures :
;* SetupFaces : Goes through the face-list, and gets the center of each
;polygon. It the stores the face with angles, centercoordinate and coords
;in a structure.
;* StoreSP : Does all that Rotation and StoreP originally did. It first
;rotates the three normalvectors (one for each corner), then the facecoords
;before it stores ALL the faces as every face will be shown.
;
;There's a lot of ugly coding down here, but except from the procs above, it
;works as described in PHONG.DOC.
;
;MARK : As every face in the object is showed, one can only have half as
;much faces as normal.
;----------------------------------------------------------------------------;----------------------------------------------------------------------------

.Model  Small
.Stack  100h

MaxPolys        EQU 2000
MaxPoints       EQU 1100

MoveX           EQU 3                 *2          ;The movement on the
MoveY           EQU 3                 *2          ;three axis
MoveZ           EQU 2                 *2

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

Palette         DB  63,  63,  63,  62,  62,  63,  60,  60,  63,  57,  57,  62,  54,  54,  62,  51,  51,  61,  48,  48,  61,  45,  45,  60,  45,  45,  60
                DB  42,  42,  60,  41,  41,  60,  40,  40,  60,  40,  40,  59,  40,  40,  59,  39,  39,  59,  39,  39,  59,  39,  39,  59,  39,  39,  59
                DB  39,  39,  59,  39,  39,  58,  39,  39,  58,  39,  39,  58,  39,  39,  58,  38,  38,  58,  38,  38,  57,  38,  38,  57,  38,  38,  57
                DB  38,  38,  57,  38,  38,  56,  37,  37,  56,  37,  37,  56,  37,  37,  56,  37,  37,  55,  37,  37,  55,  37,  37,  55,  36,  36,  55
                DB  36,  36,  54,  36,  36,  54,  36,  36,  54,  36,  36,  53,  35,  35,  53,  35,  35,  53,  35,  35,  52,  35,  35,  52,  34,  34,  52
                DB  34,  34,  51,  34,  34,  51,  34,  34,  50,  33,  33,  50,  33,  33,  50,  33,  33,  49,  33,  33,  49,  32,  32,  48,  32,  32,  48
                DB  32,  32,  48,  31,  31,  47,  31,  31,  47,  31,  31,  46,  31,  31,  46,  30,  30,  45,  30,  30,  45,  30,  30,  45,  29,  29,  44
                DB  29,  29,  44,  29,  29,  43,  28,  28,  43,  28,  28,  42,  28,  28,  42,  27,  27,  41,  27,  27,  41,  27,  27,  40,  27,  27,  40
                DB  26,  26,  39,  26,  26,  39,  26,  26,  38,  25,  25,  38,  25,  25,  37,  24,  24,  37,  24,  24,  36,  24,  24,  36,  23,  23,  35
                DB  23,  23,  35,  23,  23,  34,  22,  22,  34,  22,  22,  33,  22,  22,  33,  21,  21,  32,  21,  21,  32,  21,  21,  31,  20,  20,  31



                
                                

                
;The red palette :
                DB  45,  33,  33,  45,  33,  33,  45,  33,  33,  45,  33,  33,  45,  33,  33,  45,  32,  32,  45,  32,  32,  44,  32,  32,  44,  32,  32
                DB  44,  31,  31,  44,  31,  31,  44,  30,  30,  44,  30,  30,  43,  29,  29,  43,  28,  28,  43,  28,  28,  42,  27,  27,  42,  27,  27
                DB  42,  26,  26,  41,  25,  25,  41,  24,  24,  41,  23,  23,  40,  23,  23,  40,  22,  22,  40,  21,  21,  39,  20,  20,  39,  20,  20
                DB  38,  19,  19,  38,  18,  18,  38,  17,  17,  37,  16,  16,  37,  15,  15,  36,  14,  14,  36,  14,  14,  35,  13,  13,  35,  13,  13
                DB  35,  11,  11,  34,  11,  11,  34,  10,  10,  33,   9,   9,  33,   9,   9,  33,   8,   8,  32,   7,   7,  32,   7,   7,  31,   7,   7
                DB  31,   6,   6,  31,   5,   5,  30,   5,   5,  30,   4,   4,  29,   4,   4,  29,   4,   4,  29,   3,   3,  28,   3,   3,  28,   3,   3
                DB  27,   2,   2,  27,   2,   2,  27,   2,   2,  26,   2,   2,  26,   1,   1,  26,   1,   1,  25,   1,   1,  25,   1,   1,  25,   1,   1
                DB  24,   1,   1,  24,   1,   1,  24,   0,   0,  23,   0,   0,  23,   0,   0,  23,   0,   0,  22,   0,   0,  22,   0,   0,  22,   0,   0
                DB  21,   0,   0,  21,   0,   0,  21,   0,   0,  20,   0,   0,  20,   0,   0,  20,   0,   0,  19,   0,   0,  19,   0,   0,  18,   0,   0
                DB  18,   0,   0,  18,   0,   0,  17,   0,   0,  17,   0,   0,  17,   0,   0,  16,   0,   0,  16,   0,   0,  16,   0,   0,  15,   0,   0


EXTRN           NumOfFaces : WORD, NumOfVertexes : WORD, Coords : WORD, PolyDefs : WORD;

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

ObjX            DW -400
ObjY            DW 0
ObjZ            DW 800
AngleX          DW 640
AngleY          DW 0
AngleZ          DW 0

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

CenterX         DW 0
CenterY         DW 0
CenterZ         DW 0

Col             DB 0
Col2            DB 0

Handle          DW 0
FileName1       DB 'Object8.bin', 0
FileName2       DB 'Obj8_n.bin', 0
Vertices        EQU 1003
Faces           EQU 1714

MyData        ENDS

MyCode        SEGMENT
.386

;----------------------------------------------------------------------------
;A procedure which manages the calculating of the points.
;si = OFFSET Object
;----------------------------------------------------------------------------

;ds, gs = MyData
;fs     = DifData

Rotation      PROC
                mov   ax, DifData
                mov   es, ax
                mov   ax, ObjSeg
                mov   gs, ax
                mov   di, OFSTempCoords         ;Constant
;                mov   si, OFFSET Coords        ;Real offset
                mov   si, 2
                mov   bp, NumOfVertexes         ;Load NumOfVertexes

                mov   bx, AngleX
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + 180]
                mov   CosVal1, ax

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 180]
                mov   CosVal2, ax

                mov   bx, AngleZ
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal3, ax
                mov   ax, [bx + 180]
                mov   CosVal3, ax

RotateLoop:

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

                mov   ax, gs:[si + 4]
                shl   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated X_Angle degrees
;Let's swing the Y-axis :

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

;Done calculating the new Z-coordinate rotated Y_Angle degrees

                imul  SinVal2                        ;Multiply Z (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[si]                     ;Put X-coordinate in ax
                shl   ax, 3

                imul  CosVal2                        ;Multiply X (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Y_Angle degrees
;Let's do the Z-axis :

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

;Done calculating the new X-coordinate rotated Z_Angle degrees

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

                mov   fs:[di], ax                  ;Put the calculated X,
                mov   fs:[di + 2], bx              ;Y
                mov   fs:[di + 4], cx              ;and Z coords in TempCoords

                add   di, 6                     ;Point to next record
                add   si, 6
                dec   bp
                jnz   RotateLoop                ;Next coordinate

                mov   ax, MyData
                mov   gs, ax

                ret
Rotation      ENDP

;ds, gs = MyData
;fs, es = DifData

StoreCl        PROC
                mov   ax, PolyData
                mov   es, ax
                mov   ax, DifData
                mov   fs, ax
                xor   di, di
                mov   bp, OFSNormalV            ;Segment DifData

                mov   bx, AngleX
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + 180]
                mov   CosVal1, ax

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 180]
                mov   CosVal2, ax

StoreCLoop:

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
                cmp   di, NumOfVertexes
                jb    StoreCLoop                ;Next coordinate
                ret
StoreCl       ENDP

;gs, ds = MyData
;es     = PolyData
;fs     = DifData

StoreP        PROC
                mov   ax, PolyData
                mov   es, ax
                mov   ax, DifData
                mov   fs, ax
                mov   ax, ObjSeg
                mov   gs, ax
;                mov   si, OFFSET PolyDefs
                mov   si, 4 + (Vertices * 6)
                mov   di, OFSPoly
                xor   bp, bp
                mov   Col, 0
                mov   Col2, 0

StoreLoop:
                mov   XMax, -32768
                mov   XMin, 32767
                mov   YMax, -32768
                mov   YMin, 32767

                mov   al, Col                   ;This is just bullshit to
                xchg  al, Col2                  ;get different colors
                mov   Col, al
                mov   al, Col
                mov   BYTE PTR es:[di + 4], 0           ;Save color

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

                mov   bx, gs:[si]              ;Load first vertex again
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


                push  si
                mov   si, di
                add   si, 8
                call  Visible
                pop   si
                cmp   ax, 0
                jge   DumpPoly

                add   di, 20
DumpPoly:
                add   si, 6
                inc   bp
                cmp   bp, NumOfFaces
                jb    StoreLoop                ;Next coordinate
                mov   WORD PTR es:[di - 20], 0

                mov   ax, Canvas
                mov   es, ax

                ret
StoreP        ENDP



;gs, ds = MyData
;es     = PolyData
;fs     = SinglePolys
;gs     = DifData

StoreSP        PROC
                mov   ax, PolyData
                mov   es, ax
                mov   ax, SinglePolys
                mov   fs, ax
                mov   ax, DifData
                mov   gs, ax

                xor   si, si
                mov   di, OFSPoly
                xor   bp, bp
                mov   Col, 0
                mov   Col2, 0

StoreSLoop:
                mov   XMax, -32768
                mov   XMin, 32767
                mov   YMax, -32768
                mov   YMin, 32767

                mov   al, Col                   ;This is just bullshit to
                xchg  al, Col2                  ;get different colors
                mov   Col, al
                mov   al, Col
                mov   es:[di + 4], al           ;Save color

                mov   ax, di
                add   ax, 20
                mov   es:[di], ax               ;Saving pointer

;------------- Getting angles...
                mov   bx, fs:[si]                  ;Load AngleX
                add   WORD PTR fs:[si], 5  *2
                cmp   WORD PTR fs:[si], 720
                jb    SAngXOK
                sub   WORD PTR fs:[si], 720
SAngXOK:
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + 180]
                mov   CosVal1, ax

                mov   bx, fs:[si + 2]              ;Load AngleY
                add   WORD PTR fs:[si + 2], 4  *2
                cmp   WORD PTR fs:[si + 2], 720
                jb    SAngYOK
                sub   WORD PTR fs:[si + 2], 720
SAngYOK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 180]
                mov   CosVal2, ax

                mov   bx, fs:[si + 4]              ;Load AngleZ
                add   WORD PTR fs:[si + 4], 4  *2
                cmp   WORD PTR fs:[si + 4], 720
                jb    SAngZOK
                sub   WORD PTR fs:[si + 4], 720
SAngZOK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal3, ax
                mov   ax, [bx + 180]
                mov   CosVal3, ax

                push  si
                push  bp

;----------- Got all sines and cosines...

;Let's rock around the X-axis first :

                mov   si, bp
                mov   ax, bp
                shl   si, 1
                shl   ax, 2
                add   si, ax
                add   si, OFFSET PolyDefs

                mov   bp, [si]
                mov   ax, bp
                shl   bp, 1
                shl   ax, 2
                add   bp, ax
                add   bp, OFSNormalV

                mov   ax, gs:[bp + 2]           ;Load Y
                sal   ax, 3
                imul  SinVal1                   ;Multiply Y (ax) with Sinvalue

                mov   cl, ah                    ;Shift right by 8
                mov   ch, dl                    ;

                mov   ax, gs:[bp + 4]
                sal   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   ax, cx

;Let's swing the Y-axis :

                imul  CosVal2                        ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[bp]               ;Put X-coordinate in ax
                sal   ax, 3

                imul  SinVal2                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done

;----------------- Rotated normal vector, done. ----------------------------
                sar   bx, 3
                cmp   bx, 0
                jge   Positive3
                neg   bx                        ;Make value positive
Positive3:
                mov   al, [OFFSET CosTabl + bx] ;Get angle

;dl = Angle of light hitting the vertex (corresponding to the normal vector)

                mov   es:[di + 5], al

                mov   bp, [si + 2]
                mov   ax, bp
                shl   bp, 1
                shl   ax, 2
                add   bp, ax
                add   bp, OFSNormalV

                mov   ax, gs:[bp + 2]           ;Load Y
                sal   ax, 3
                imul  SinVal1                   ;Multiply Y (ax) with Sinvalue

                mov   cl, ah                    ;Shift right by 8
                mov   ch, dl                    ;

                mov   ax, gs:[bp + 4]
                sal   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   ax, cx

;Let's swing the Y-axis :

                imul  CosVal2                        ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[bp]               ;Put X-coordinate in ax
                sal   ax, 3

                imul  SinVal2                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done

;----------------- Rotated normal vector, done. ----------------------------
                sar   bx, 3
                cmp   bx, 0
                jge   Positive4
                neg   bx                        ;Make value positive
Positive4:
                mov   al, [OFFSET CosTabl + bx] ;Get angle

;dl = Angle of light hitting the vertex (corresponding to the normal vector)

                mov   es:[di + 6], al

                mov   bp, [si + 4]
                mov   ax, bp
                shl   bp, 1
                shl   ax, 2
                add   bp, ax
                add   bp, OFSNormalV

                mov   ax, gs:[bp + 2]           ;Load Y
                sal   ax, 3
                imul  SinVal1                   ;Multiply Y (ax) with Sinvalue

                mov   cl, ah                    ;Shift right by 8
                mov   ch, dl                    ;

                mov   ax, gs:[bp + 4]
                sal   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   ax, cx

;Let's swing the Y-axis :

                imul  CosVal2                        ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, gs:[bp]               ;Put X-coordinate in ax
                sal   ax, 3

                imul  SinVal2                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done

;----------------- Rotated normal vector, done. ----------------------------
                sar   bx, 3
                cmp   bx, 0
                jge   Positive5
                neg   bx                        ;Make value positive
Positive5:
                mov   al, [OFFSET CosTabl + bx] ;Get angle

;dl = Angle of light hitting the vertex (corresponding to the normal vector)

                mov   es:[di + 7], al

                pop   bp
                pop   si


;------------------ Finished the normal vector and the colors ---------------------------
;Now rotating the first vertex...

                pusha                           ;Save registers

;---------------Let's rock around the X-axis first :

                mov   ax, fs:[si + 14]          ;Put Y-coordinate in ax
                shl   ax, 3

                imul  CosVal1                   ;Multiply Y with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 16]          ;Put Z-coordinate in ax
                shl   ax, 3

                imul  SinVal1                   ;Multiply Z (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   NewY, bx                  ;Save NewY

;------------- Done calculating the new Y-coordinate rotated X_Angle degrees

                mov   ax, fs:[si + 14]          ;Put Y-coordinate in ax
                shl   ax, 3

                imul  SinVal1                   ;Multiply Y (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 16]
                shl   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated X_Angle degrees
;Let's swing the Y-axis :

                mov   ax, NewZ                  ;Put Z-coordinate in ax

                imul  CosVal2                   ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 12]          ;Put X-coordinate in ax
                shl   ax, 3

                imul  SinVal2                   ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   ax, NewZ                  ;Put "old" Z-coordinate in ax
                                                ;cause I can't use the newly
                                                ;calculated Z-coordinate here
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated Y_Angle degrees

                imul  SinVal2                   ;Multiply Z (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 12]          ;Put X-coordinate in ax
                shl   ax, 3

                imul  CosVal2                   ;Multiply X (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Y_Angle degrees
;Let's do the Z-axis :

                mov   ax, NewX                  ;Put X-coordinate in ax

                imul  CosVal3                   ;Multiply X with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Put Y-coordinate in ax

                imul  SinVal3                   ;Multiply Y (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax
                mov   ax, NewX
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Z_Angle degrees

                imul  SinVal3                   ;Multiply Y (ax) with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Load X-coordinate

                imul  CosVal3                   ;Multiply X (ax) with Sinvalue

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

                push  bx
                mov   bx, bp
                mov   dx, bp
                shl   bx, 1
                shl   dx, 2
                add   bx, dx
                add   bx, OFSTempNV

                mov   dx, gs:[bx]
                sar   dx, 3
                add   fs:[si + 6], dx

                mov   dx, gs:[bx + 2]
                sar   dx, 3
                add   fs:[si + 8], dx

                mov   dx, gs:[bx + 4]
                sar   dx, 3
                add   fs:[si + 10], dx

                pop   bx

                add   ax, fs:[si + 6]           ;Add objects position
                add   bx, fs:[si + 8]           ;You may remove them if they
                add   cx, fs:[si + 10]          ;are zero
                add   ax, ObjX
                add   bx, ObjY
                add   cx, ObjZ

                cmp   cx, 40
                jl    DumpSPoly

                mov   dx, cx
                add   dx, 15000                 ;Make all z-values positive
                mov   es:[di + 2], dx           ;Save Z-value to sort

                call  F3DTo2D                   ;Project
                add   ax, 160
                add   bx, 100
                mov   es:[di + 8], ax           ;Save 2D-X
                mov   es:[di + 10], bx          ;Save 2D-Y

                cmp   ax, XMax
                jle   XSLower1
                mov   XMax, ax
XSLower1:
                cmp   ax, XMin
                jge   XSHigher1
                mov   XMin, ax
XSHigher1:
                cmp   bx, YMax
                jle   YSLower1
                mov   YMax, bx
YSLower1:
                cmp   bx, YMin
                jge   YSHigher1
                mov   YMin, bx
YSHigher1:


;                               FIRST VERTEX DONE!
;----------------------------------------------------------------------------
;Now rotating the second vertex...

                pusha                           ;Save registers

;---------------Let's rock around the X-axis first :

                mov   ax, fs:[si + 20]          ;Put Y-coordinate in ax
                shl   ax, 3

                imul  CosVal1                   ;Multiply Y with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 22]          ;Put Z-coordinate in ax
                shl   ax, 3

                imul  SinVal1                   ;Multiply Z (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   NewY, bx                  ;Save NewY

;------------- Done calculating the new Y-coordinate rotated X_Angle degrees

                mov   ax, fs:[si + 20]          ;Put Y-coordinate in ax
                shl   ax, 3

                imul  SinVal1                   ;Multiply Y (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 22]
                shl   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated X_Angle degrees
;Let's swing the Y-axis :

                mov   ax, NewZ                  ;Put Z-coordinate in ax

                imul  CosVal2                   ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 18]          ;Put X-coordinate in ax
                shl   ax, 3

                imul  SinVal2                   ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   ax, NewZ                  ;Put "old" Z-coordinate in ax
                                                ;cause I can't use the newly
                                                ;calculated Z-coordinate here
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated Y_Angle degrees

                imul  SinVal2                   ;Multiply Z (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 18]          ;Put X-coordinate in ax
                shl   ax, 3

                imul  CosVal2                   ;Multiply X (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Y_Angle degrees
;Let's do the Z-axis :

                mov   ax, NewX                  ;Put X-coordinate in ax

                imul  CosVal3                   ;Multiply X with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Put Y-coordinate in ax

                imul  SinVal3                   ;Multiply Y (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax
                mov   ax, NewX
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Z_Angle degrees

                imul  SinVal3                   ;Multiply Y (ax) with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Load X-coordinate

                imul  CosVal3                   ;Multiply X (ax) with Sinvalue

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

                add   ax, fs:[si + 6]           ;Add objects position
                add   bx, fs:[si + 8]           ;You may remove them if they
                add   cx, fs:[si + 10]          ;are zero
                add   ax, ObjX
                add   bx, ObjY
                add   cx, ObjZ

                call  F3DTo2D                   ;Project
                add   ax, 160
                add   bx, 100
                mov   es:[di + 12], ax           ;Save 2D-X
                mov   es:[di + 14], bx          ;Save 2D-Y

                cmp   ax, XMax
                jle   XSLower2
                mov   XMax, ax
XSLower2:
                cmp   ax, XMin
                jge   XSHigher2
                mov   XMin, ax
XSHigher2:
                cmp   bx, YMax
                jle   YSLower2
                mov   YMax, bx
YSLower2:
                cmp   bx, YMin
                jge   YSHigher2
                mov   YMin, bx
YSHigher2:

;                               DONE SECOND VERTEX!
;----------------------------------------------------------------------------
;Now rotating the third vertex...

                pusha                           ;Save registers

;---------------Let's rock around the X-axis first :

                mov   ax, fs:[si + 26]          ;Put Y-coordinate in ax
                shl   ax, 3

                imul  CosVal1                   ;Multiply Y with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 28]          ;Put Z-coordinate in ax
                shl   ax, 3

                imul  SinVal1                   ;Multiply Z (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   NewY, bx                  ;Save NewY

;------------- Done calculating the new Y-coordinate rotated X_Angle degrees

                mov   ax, fs:[si + 26]          ;Put Y-coordinate in ax
                shl   ax, 3

                imul  SinVal1                   ;Multiply Y (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 28]
                shl   ax, 3

                imul  CosVal1                        ;Multiply Z (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated X_Angle degrees
;Let's swing the Y-axis :

                mov   ax, NewZ                  ;Put Z-coordinate in ax

                imul  CosVal2                   ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 24]          ;Put X-coordinate in ax
                shl   ax, 3

                imul  SinVal2                   ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   ax, NewZ                  ;Put "old" Z-coordinate in ax
                                                ;cause I can't use the newly
                                                ;calculated Z-coordinate here
                mov   NewZ, bx                  ;Save NewZ

;Done calculating the new Z-coordinate rotated Y_Angle degrees

                imul  SinVal2                   ;Multiply Z (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si + 24]          ;Put X-coordinate in ax
                shl   ax, 3

                imul  CosVal2                   ;Multiply X (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Y_Angle degrees
;Let's do the Z-axis :

                mov   ax, NewX                  ;Put X-coordinate in ax

                imul  CosVal3                   ;Multiply X with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Put Y-coordinate in ax

                imul  SinVal3                   ;Multiply Y (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax
                mov   ax, NewX
                mov   NewX, bx                  ;Save NewX

;Done calculating the new X-coordinate rotated Z_Angle degrees

                imul  SinVal3                   ;Multiply Y (ax) with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, NewY                  ;Load X-coordinate

                imul  CosVal3                   ;Multiply X (ax) with Sinvalue

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

                add   ax, fs:[si + 6]           ;Add objects position
                add   bx, fs:[si + 8]           ;You may remove them if they
                add   cx, fs:[si + 10]          ;are zero
                add   ax, ObjX
                add   bx, ObjY
                add   cx, ObjZ

                call  F3DTo2D                   ;Project
                add   ax, 160
                add   bx, 100
                mov   es:[di + 16], ax           ;Save 2D-X
                mov   es:[di + 18], bx          ;Save 2D-Y

                cmp   ax, XMax
                jle   XSLower3
                mov   XMax, ax
XSLower3:
                cmp   ax, XMin
                jge   XSHigher3
                mov   XMin, ax
XSHigher3:
                cmp   bx, YMax
                jle   YSLower3
                mov   YMax, bx
YSLower3:
                cmp   bx, YMin
                jge   YSHigher3
                mov   YMin, bx
YSHigher3:

;                               DONE THIRD VERTEX!
;---------------------------------------------------------------------------

                cmp   XMax, ViewMinX
                jl    DumpSPoly
                cmp   XMin, ViewMaxX
                jg    DumpSPoly
                cmp   YMax, ViewMinY
                jl    DumpSPoly
                cmp   YMin, ViewMaxY
                jg    DumpSPoly

                add   di, 20
DumpSPoly:
                add   si, 30
                inc   bp
                cmp   bp, NumOfFaces
                jb    StoreSLoop                ;Next coordinate
                mov   WORD PTR es:[di - 20], 0

                mov   ax, Canvas
                mov   es, ax
                mov   ax, MyData
                mov   gs, ax

                ret
StoreSP        ENDP



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
                mov   ax, MyData
                mov   gs, ax
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
                mov   gs:Col, al
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
                mov   al, [OFFSET ACos + bx]
                stosb
                add   dx, si
GoLoop:
;                shr   cx, 1
;                jz    DoneLoop

Ph_HorLoop:
                mov   bl, dh
                mov   al, [OFFSET ACos + bx]
                add   dx, si
                mov   bl, dh
                mov   ah, [OFFSET ACos + bx]
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


;bp = Offset to put normalvector
;si = offset to polydef

SetNormals    PROC
                mov   bx, [si + 2]              ;Load second vertex
                shl   bx, 2                     ;\
                mov   dx, [si + 2]              ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                mov   ax, [OFFSET Coords + bx]  ;Load X
                mov   bx, [si]                  ;Load first vertex
                shl   bx, 2                     ;\
                mov   dx, [si]                  ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                sub   ax, [OFFSET Coords + bx]  ;Subtract first vector
                mov   VecX1, ax                 ;Save vector

                mov   bx, [si + 2]              ;Load second vertex
                shl   bx, 2                     ;\
                mov   dx, [si + 2]              ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                mov   ax, [OFFSET Coords+2+bx]  ;Load Y
                mov   bx, [si]                  ;Load first vertex
                shl   bx, 2                     ;\
                mov   dx, [si]                  ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                sub   ax, [OFFSET Coords+2+bx]  ;Subtract first vector
                mov   VecY1, ax                 ;Save vector

                mov   bx, [si + 2]              ;Load second vertex
                shl   bx, 2                     ;\
                mov   dx, [si + 2]              ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                mov   ax, [OFFSET Coords+4+bx]  ;Load Z
                mov   bx, [si]                  ;Load first vertex
                shl   bx, 2                     ;\
                mov   dx, [si]                  ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                sub   ax, [OFFSET Coords+4+bx]  ;Subtract first vector
                mov   VecZ1, ax                 ;Save vector

;-------------------------- SECOND VECTOR ----------------------------------
                mov   bx, [si + 4]              ;Load third vertex
                shl   bx, 2                     ;\
                mov   dx, [si + 4]              ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                mov   ax, [OFFSET Coords + bx]  ;Load X
                mov   bx, [si]                  ;Load first vertex
                shl   bx, 2                     ;\
                mov   dx, [si]                  ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                sub   ax, [OFFSET Coords + bx]  ;Subtract first vector
                mov   VecX2, ax                 ;Save vector

                mov   bx, [si + 4]              ;Load third vertex
                shl   bx, 2                     ;\
                mov   dx, [si + 4]              ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                mov   ax, [OFFSET Coords+2+bx]  ;Load Y
                mov   bx, [si]                  ;Load first vertex
                shl   bx, 2                     ;\
                mov   dx, [si]                  ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                sub   ax, [OFFSET Coords+2+bx]  ;Subtract first vector
                mov   VecY2, ax                 ;Save vector

                mov   bx, [si + 4]              ;Load third vertex
                shl   bx, 2                     ;\
                mov   dx, [si + 4]              ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                mov   ax, [OFFSET Coords+4+bx]  ;Load Z
                mov   bx, [si]                  ;Load first vertex
                shl   bx, 2                     ;\
                mov   dx, [si]                  ;Mul by 6
                shl   dx, 1                     ;/
                add   bx, dx                    ;/
                sub   ax, [OFFSET Coords+4+bx]  ;Subtract first vector
                mov   VecZ2, ax                 ;Save vector

;---------------------------- Calculating... -------------------------------

                mov   bx, VecY1
                mov   ax, VecZ2
                imul  bx
                mov   Mul1, ax

                mov   bx, VecZ1
                mov   ax, VecY2
                imul  bx
                mov   Mul2, ax

                mov   bx, VecZ1
                mov   ax, VecX2
                imul  bx
                mov   Mul3, ax

                mov   bx, VecX1
                mov   ax, VecZ2
                imul  bx
                mov   Mul4, ax

                mov   bx, VecX1
                mov   ax, VecY2
                imul  bx
                mov   Mul5, ax

                mov   bx, VecY1
                mov   ax, VecX2
                imul  bx
                mov   Mul6, ax

                mov   ax, Mul1
                mov   bx, Mul3
                mov   cx, Mul5
                sub   ax, Mul2
                sub   bx, Mul4
                sub   cx, Mul6

                mov   fs:[bp], ax
                mov   fs:[bp + 2], bx
                mov   fs:[bp + 4], cx
;----------------- Done calculating normalvector --------------------------

                ret
SetNormals    ENDP

ComNormals    PROC
                xor   bp, bp
ComLoop:
                xor   ax, ax                    ;Zero vector
                xor   bx, bx                    ;/
                xor   cx, cx                    ;/

                xor   dx, dx                    ;Zero counter
                mov   si, OFFSET PolyDefs
CPolyLoop:
                cmp   [si], bp
                je    AddVector
                cmp   [si + 2], bp
                je    AddVector
                cmp   [si + 4], bp
                je    AddVector
                jmp   NotAddVector

AddVector:
                push  bp
                mov   di, dx                    ;\
                shl   di, 1                     ;bp * 6 -> di
                mov   bp, dx                    ;/
                shl   bp, 2                     ;/
                add   di, bp                    ;/
                pop   bp

                add   ax, fs:[OFSTempNV + di]
                add   bx, fs:[OFSTempNV + di + 2]
                add   cx, fs:[OFSTempNV + di + 4]

NotAddVector:
                add   si, 6
                inc   dx
                cmp   dx, NumOfFaces
                jb    CPolyLoop


                mov   di, bp                    ;\
                shl   di, 1                     ;bp * 6 -> di
                mov   dx, bp                    ;/
                shl   dx, 2                     ;/
                add   di, dx                    ;/

                add   di, OFSNormalV
                mov   fs:[di], ax
                mov   fs:[di + 2], bx
                mov   fs:[di + 4], cx

;----------------- Calculating length of new normalvector -------------------

                movsx eax, WORD PTR fs:[di]
                imul  eax
                mov   ebx, eax

                movsx eax, WORD PTR fs:[di + 2]
                imul  eax
                add   ebx, eax

                movsx eax, WORD PTR fs:[di + 4]
                imul  eax
                add   ebx, eax

;(X^2) + (Y^2) + (Z^2) can't get larger than 32-bits!!!
;Shouldn't be a problem.

                mov   ecx, 0
                mov   eax, 1
SQRoot:
                inc   ecx

                mov   eax, ecx
                mul   ecx

                cmp   eax, ebx
                jb    SQRoot

;ecx = |vector|
                mov   eax, 65536 * 256
                cdq
                div   ecx
                mov   cx, ax

                movsx eax, WORD PTR fs:[di]               ;Load old X
                imul  ecx
                sar   eax, 16
                mov   fs:[di], ax

                movsx eax, WORD PTR fs:[di + 2]           ;Load old Y
                imul  ecx
                sar   eax, 16
                mov   fs:[di + 2], ax

                movsx eax, WORD PTR fs:[di + 4]          ;Load old Z
                imul  ecx
                sar   eax, 16
                mov   fs:[di + 4], ax

                inc   bp
                cmp   bp, NumOfVertexes
                jb    ComLoop

                ret
ComNormals    ENDP


;es = SinglePolys

SetupFaces    PROC
                mov   cx, NumOfFaces
                mov   si, OFFSET PolyDefs
                xor   di, di
                mov   ax, SinglePolys
                mov   es, ax
                cld

SetFLoop:
                push  cx

                xor   ax, ax
                mov   cx, 3
                rep   stosw                     ;Reserve space for angles

                mov   bx, [si]                  ;Load vertex 1
                mov   bp, bx                    ;\
                shl   bx, 1                     ;\
                shl   bp, 2                     ;Mul by 6
                add   bx, bp                    ;/
                add   bx, OFFSET Coords
                mov   ax, [bx]                  ;Load X1
                mov   dx, [bx + 2]              ;Load Y1
                mov   cx, [bx + 4]              ;Load Z1

                mov   bx, [si + 2]              ;Load vertex 2
                mov   bp, bx                    ;Mul by 6
                shl   bx, 1                     ;/
                shl   bp, 2                     ;/
                add   bx, bp                    ;/
                add   bx, OFFSET Coords
                add   ax, [bx]                  ;Add X2
                add   dx, [bx + 2]              ;Add Y2
                add   cx, [bx + 4]              ;Add Z2

                mov   bx, [si + 4]              ;Load vertex 3
                mov   bp, bx                    ;Mul by 6
                shl   bx, 1                     ;/
                shl   bp, 2                     ;/
                add   bx, bp                    ;/
                add   bx, OFFSET Coords
                add   ax, [bx]                  ;Add X3
                add   dx, [bx + 2]              ;Add Y3
                add   cx, [bx + 4]              ;Add Z3

                mov   bx, dx                    ;Transfer Y

                mov   bp, 3
                cwd                             ;ax -> ax:dx
                idiv  bp
                mov   CenterX, ax
                stosw

                mov   ax, bx
                cwd
                idiv  bp
                mov   CenterY, ax
                stosw

                mov   ax, cx
                cwd
                idiv  bp
                mov   CenterZ, ax
                stosw

                mov   bx, si

                mov   si, [bx]
                mov   bp, si
                shl   si, 1
                shl   bp, 2
                add   si, bp
                add   si, OFFSET Coords
                lodsw
                sub   ax, CenterX
                stosw
                lodsw
                sub   ax, CenterY
                stosw
                lodsw
                sub   ax, CenterZ
                stosw

                mov   si, [bx + 2]
                mov   bp, si
                shl   si, 1
                shl   bp, 2
                add   si, bp
                add   si, OFFSET Coords
                lodsw
                sub   ax, CenterX
                stosw
                lodsw
                sub   ax, CenterY
                stosw
                lodsw
                sub   ax, CenterZ
                stosw

                mov   si, [bx + 4]
                mov   bp, si
                shl   si, 1
                shl   bp, 2
                add   si, bp
                add   si, OFFSET Coords
                lodsw
                sub   ax, CenterX
                stosw
                lodsw
                sub   ax, CenterY
                stosw
                lodsw
                sub   ax, CenterZ
                stosw

                mov   si, bx
                add   si, 6                     ;Next face

                pop   cx
                dec   cx
                jnz   SetFLoop

                mov   ax, Canvas
                mov   es, ax

                ret
SetupFaces    ENDP



Main          PROC
                call  Initialize                ;Init palette, screen etc...


;--------------------------- Calculating normals ----------------------------
                mov   cx, NumOfFaces
                mov   si, OFFSET PolyDefs
                mov   bp, OFSTempNV
NormalLoop:
                push  cx
                call  SetNormals
                add   si, 6
                add   bp, 6

                pop   cx
                loop  NormalLoop

                call  ComNormals                ;Combine all normals to one
                                                ;for each vertex
                call  SetupFaces

;----------------- Saving normalvectors and single faces
                mov   ah, 3Ch                   ;Create file
                xor   cx, cx                    ;Normal attributes
                mov   dx, OFFSET FileName2
                int   21h
                mov   Handle, ax

                mov   ah, 40h
                mov   bx, Handle
                mov   cx, (Vertices*6) + (MaxPolys*6)

                push  ds
                mov   dx, DifData
                mov   ds, dx
                mov   dx, OFSTempNV
                int   21h
                pop   ds

                mov   ah, 40h
                mov   bx, Handle
                mov   cx, (Faces*30)

                push  ds
                mov   dx, SinglePolys
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close file
                int   21h

                mov   cx, 20
MoveLoop:
                push  cx
                xor   eax, eax                  ;Blank canvas
                xor   di, di
                mov   cx, 16000
                rep   stosd

                call  Rotation
                call  StoreCl
                call  StoreP
                call  SortPolys
                call  DrawPolys

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

                add   ObjX, 20
                sub   ObjZ, 20
                add   AngleX, 4

                pop   cx
                dec   cx
                jnz   MoveLoop


;------------------------------ Done normals --------------------------------
                mov   cx, 50
PLoop:                                          ;Frameloop
                push  cx

                xor   eax, eax                  ;Blank canvas
                xor   di, di
                mov   cx, 16000
                rep   stosd

                call  StoreSP
                call  SortPolys
                call  DrawPolys

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

;                add   ObjX, 10

                pop   cx
                dec   cx
                jnz   PLoop


                call  ShutDown
Main          ENDP

Initialize    PROC
                mov   ax, MyData                ;Point ds to data-segment
                mov   gs, ax
                mov   ds, ax
                mov   ax, DifData
                mov   fs, ax

                mov   al, 13h                   ;320x200x256
                mov   ah, 00h                   ;set screenmode
                int   10h

;----------------- Saving object...
                mov   ah, 3Ch                   ;Create file
                xor   cx, cx                    ;Normal attributes
                mov   dx, OFFSET FileName1
                int   21h
                mov   Handle, ax

                mov   ah, 40h
                mov   bx, Handle
                mov   cx, 4 + (Vertices*6) + (Faces * 6)
                mov   dx, OFFSET NumOfVertexes
                int   21h

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close file
                int   21h

                mov   si, OFFSET NumOfVertexes
                mov   ax, ObjSeg
                mov   es, ax
                xor   di, di
                mov   cx, 4 + (Vertices*6) + (Faces * 6)
                rep   movsb

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,1                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx,180*3                  ;3*256 (RGB)=768 colors
                rep   outsb

                mov   ax, Canvas                ;Set es to canvas
                mov   es, ax

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
                mov   cx, es:[si + 4]
                mov   dx, es:[si + 6]
                mov   ax, es:[si + 8]
                mov   bx, es:[si + 10]

                sub   cx, es:[si]                  ;X2-X1
                sub   bx, es:[si + 2]              ;Y3-Y1
                sub   dx, es:[si + 2]              ;Y2-Y1
                sub   ax, es:[si]                  ;X3-X1

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
                or    ax, ax
                jz   _DoneX

                cwd
                mov   dl, ah                    ;\
                mov   ah, al
                xor   al, al

                idiv  cx                        ;dx:ax / cx

_DoneX:
                or    bx, bx                     ;Is Y positive?
                jz    _DoneY
                xchg  ax, bx
                cwd
                mov   dl, ah
                mov   ah, al
                xor   al, al

                idiv  cx
                xchg  ax, bx
_DoneY:

                pop   dx
                pop   cx

                ret                             ;Go home!
F3DTo2D       ENDP

MyCode        ENDS

PolyData      SEGMENT
;The segment for the calculated polygons and the sorting arrays.

OFSFStart       EQU 0 + 5000
OFSFOfs         EQU (256 * 2) + 5000
OFSPoly         EQU 1024 + 5000                 ;The starting offset of the
                                                ;faces.

                DB 65535 DUP (?)
PolyData      ENDS

DifData       SEGMENT
;Place for different calculated data.

OFSCValues      EQU 0
OFSTempNV       EQU MaxPolys
OFSNormalV      EQU OFSTempNV + (MaxPolys * 6)
OFSTempCoords   EQU OFSNormalV + (MaxPoints * 6)

                DB 65535 DUP (?)
DifData       ENDS

SinglePolys   SEGMENT
                DB 65535 DUP (?)
SinglePolys   ENDS

ObjSeg        SEGMENT
                DB 65536 DUP (?)
ObjSeg        ENDS

;----------------------- The double buffer for screen ------------------------

Canvas        SEGMENT
                DB 64000 DUP (?)
Canvas        ENDS

END           Main
