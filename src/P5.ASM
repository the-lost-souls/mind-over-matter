;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            : P5.ASM
;Author          : Cyberfish of The Lost Souls
;Last update     : March 1996
;Action          : Mind over Matter - part 5
;
;
;Using Libraries             :
;Using external files/macros : An object file with the object...
;
;Notes :
;Maaaaan! This part was a hell to time!!! :((( (And I'm starting to get a
;_BIT_ tired of this demo too...)
;----------------------------------------------------------------------------;----------------------------------------------------------------------------

MaxPolys        EQU 2000
MaxPoints       EQU 1000

;The viewport...
ViewMinX        EQU 0
ViewMaxX        EQU 319
ViewMinY        EQU 0
ViewMaxY        EQU 199

ASSUME cs : Code1, ds : MainData

include        bwsb.inc
include        gdmtype.inc

PUBLIC          P5Main

MainData      SEGMENT PUBLIC
EXTRN           SinTabl : WORD, Handle : WORD
EXTRN           LastTime : DWORD, StartTime : DWORD
EXTRN           AmbientR : BYTE, AmbientG : BYTE, AmbientB : BYTE, DiffuseR : BYTE, DiffuseG : BYTE, DiffuseB : BYTE
EXTRN           SpecR : BYTE, SpecG : BYTE, SpecB : BYTE, Shiny : BYTE, NoSound : BYTE

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
                DB 0, 0, 0

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
                DB  63,  63,  63,  10,   6,   6,  14,   8,   8,   4,   2,   2
                DB   8,   4,   4,  24,  10,  10,  20,   8,   8,   6,   2,   2
                DB  30,  10,  10,  20,   6,   6,  28,   8,   8,  24,   6,   6
                DB  28,   6,   6,  10,   2,   2,  12,   2,   2,  24,   4,   4
                DB  14,   2,   2,  28,   4,   4,  16,   2,   2,  18,   2,   2
                DB  20,   2,   2,  22,   2,   2,  24,   2,   2,  26,   2,   2
                DB   2,   0,   0,   4,   0,   0,   8,   0,   0,  10,   0,   0
                DB  14,   0,   0,  20,   0,   0,  24,   0,   0,  30,  10,   8
                DB  33,  10,   8,  26,   6,   4,  30,  14,  12,  33,  14,  12
                DB  28,  12,  10,  30,  12,  10,  26,  10,   8,  26,   8,   6
                DB  28,   8,   6,  22,   6,   4,  24,   6,   4,  26,  14,  12
                DB  24,  12,  10,  26,  12,  10,  22,  10,   8,  24,  10,   8
                DB  22,   8,   6,  24,   8,   6,  18,   6,   4,  16,   4,   2
                DB  18,   4,   2,  28,  16,  14,  22,  12,  10,  20,  10,   8
                DB  20,   8,   6,  39,  20,  16,  37,  18,  14,  35,  16,  12
                DB  37,  16,  12,  18,   8,   6,  33,  14,  10,  24,   6,   2
                DB  22,  14,  12,  18,  10,   8,  35,  18,  14,  33,  16,  12
                DB  28,  12,   8,  14,   6,   4,  12,   4,   2,  24,   8,   4
                DB  24,  16,  14,  37,  22,  18,  35,  20,  16,  33,  18,  14
                DB  30,  16,  12,  16,   8,   6,  28,  14,  10,  39,  18,  12
                DB  26,  12,   8,  37,  16,  10,  24,  10,   6,  18,  12,  10
                DB  16,  10,   8,  33,  20,  16,  30,  18,  14,  28,  16,  12
                DB  43,  24,  18,  41,  22,  16,  26,  14,  10,  39,  20,  14
                DB  37,  18,  12,  12,   6,   4,  10,   4,   2,  20,   8,   4
                DB   8,   2,   0,  22,  16,  14,  33,  22,  18,  30,  20,  16
                DB  41,  24,  18,  14,   8,   6,  37,  20,  14,  41,  26,  20
                DB  28,  18,  14,  26,  16,  12,  35,  20,  14,  20,  10,   6
                DB  16,  12,  10,  39,  24,  18,   8,   4,   2,  14,  10,   8
                DB  37,  24,  18,  41,  24,  16,  28,  16,  10,  12,   8,   6
                DB  14,   8,   4,   8,   6,   4,   6,   4,   2,   4,   2,   0
                DB   6,   2,   4,  14,   2,   4,  14,   0,   2,  22,   2,   4
                DB  20,   0,   2,  26,   2,   4,  24,   0,   2,   0,   0,   0

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

ObjXR           DD -680 * 256
ObjYR           DD 0
ObjZR           DD 900 * 256
ObjX            DW 0
ObjY            DW 0
ObjZ            DW 0
ObjMoveX        DW 8
ObjMoveY        DW 0
ObjMoveZ        DW -5

AngleXR         DD 0
AngleYR         DD 0
AngleZR         DD 0
AngleX          DW 0
AngleY          DW 0
AngleZ          DW 0
AngMoveX        DW 0
AngMoveY        DW 34
AngMoveZ        DW 0

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

RTime           DD 0
MTime           DD 0

Pal2            DB 768 DUP (0)

Left            DW 0
Right           DW 0
MapF1           DB 1
MapF2           DB 0
MapF3           DB 0

FadeF1          DB 0
FadeF2          DB 0
SpeedUpF        DB 0
DingsF          DB 0
BumpF           DB 0
WobblyF         DB 0
GoWobbly        DB 0
WobblyC         DW 0
WAmp            DW 30
CrashF          DB 0
AFlag           DB 0

OCounter        DW OFFSET OLimits
OLimits         DW 24, 0
                DW OFFSET O1

                DW 25, 37
                DW OFFSET O1

                DW 27, 0
                DW OFFSET O1

                DW 28, 35
                DW OFFSET O1

                DW 30, 32
                DW OFFSET O1

                DW 40, 0

TCounter        DW OFFSET TLimits
TLimits         DD 21000
                DW OFFSET A1                    ;Blow it!

                DD 27000
                DW OFFSET A2                    ;Move back

                DD 35000
                DW OFFSET A3                    ;Fade out

                DD 39000
                DW OFFSET A4                    ;Load second object (bell)

                DD 42000 - 42000
                DW OFFSET A5                    ;View object

                DD 54500- 42000
                DW OFFSET A6                    ;Blow it!

                DD 61000- 42000
                DW OFFSET A7                    ;Move back

                DD 70000- 42000
                DW OFFSET A8                    ;Fade out

                DD 75000- 42000
                DW OFFSET A9                    ;Load third object (note)

                DD 80000 - 80000
                DW OFFSET A10                   ;View object

                DD 101000 - 80000
                DW OFFSET A11                   ;Blow it!

                DD 113000 - 80000
                DW OFFSET A12                    ;Move back

                DD 116000 - 80000
                DW OFFSET A13                    ;Fade out

                DD 122000 - 80000
                DW OFFSET A14                    ;Load fourth object (bulb)

                DD 125000 - 125000
                DW OFFSET A15                    ;View object

                DD 130000 - 125000
                DW OFFSET A16                    ;Bump

                DD 144000 - 125000
                DW OFFSET A17                    ;Stop/blow

                DD 155000 - 125000
                DW OFFSET A19                    ;Move back

                DD 165000 - 125000
                DW OFFSET A20                    ;Fade

                DD 170000- 125000
                DW OFFSET A21                    ;Load fifth object

                DD 190000- 190000
                DW OFFSET A22                   ;View object (well..weird?)

                DD 232000- 190000
                DW OFFSET A23                   ;Blow it!

                DD 241000- 190000
                DW OFFSET A24                   ;Move back

                DD 259000- 190000
                DW OFFSET A25                   ;Fade out

                DD 50000000

;----------------------------- Object definitions ---------------------------
ObjectP         DW OFFSET Object4

Object1         DW 724                          ;NumOfVertexes
                DW 1452                         ;NumOfFaces
                DW 2                            ;Offset Coords
                DW 4348                         ;Offset PolyDefs

Object2         DW 938                          ;NumOfVertexes
                DW 1876                         ;NumOfFaces
                DW 2                            ;Offset Coords
                DW 5632                         ;Offset PolyDefs

Object3         DW 829                          ;NumOfVertexes
                DW 1650                         ;NumOfFaces
                DW 2                            ;Offset Coords
                DW 4978                         ;Offset PolyDefs

Object4         DW 1003                         ;NumOfVertexes
                DW 1714                         ;NumOfFaces
                DW 2                            ;Offset Coords
                DW 4 + (1003*6)                 ;Offset PolyDefs

Object5         DW 548                         ;NumOfVertexes
                DW 1234                        ;NumOfFaces
                DW 2                           ;Offset Coords
                DW 4 + (548*6)                 ;Offset PolyDefs
MainData        ENDS

Code1        SEGMENT PUBLIC
.386
EXTRN           GetTimer : PROC, SetPhong : PROC, F3DTo2D : PROC
;----------------------------------------------------------------------------
;A procedure which manages the calculating of the points.
;si = OFFSET Object
;----------------------------------------------------------------------------

;ds, gs = MainData
;fs     = Data2

Rotation      PROC
                mov   ax, Data2
                mov   es, ax
                mov   fs, ax
                mov   ax, Data4
                mov   gs, ax
                mov   di, OFSTempCoords         ;Constant
                mov   si, ObjectP
                mov   bp, [si]                  ;NumOfVertexes
                mov   si, [si + 4]              ;Offset Coords

                mov   bx, AngleX
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + (90*8*2)]
                mov   CosVal1, ax

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + (90*8*2)]
                mov   CosVal2, ax

                mov   bx, AngleZ
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal3, ax
                mov   ax, [bx + (90*8*2)]
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

                mov   ax, MainData
                mov   gs, ax

                ret
Rotation      ENDP

;ds, gs = MainData
;fs, es = Data2

StoreCl        PROC
                mov   ax, Data1
                mov   es, ax
                mov   ax, Data2
                mov   fs, ax
                xor   di, di
                mov   bp, OFSNormalV            ;Segment Data2

                mov   bx, AngleX
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + (90*8*2)]
                mov   CosVal1, ax

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + (90*8*2)]
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
                                                ;in segment Data2!!!

                add   bp, 6
                mov   bx, ObjectP
                cmp   di, [bx]
                jb    StoreCLoop                ;Next coordinate
                ret
StoreCl       ENDP

;gs, ds = MainData
;es     = Data1
;fs     = Data2

StoreP        PROC
                mov   ax, Data1
                mov   es, ax
                mov   ax, Data2
                mov   fs, ax
                mov   ax, Data4
                mov   gs, ax
                mov   si, ObjectP
                mov   si, [si + 6]              ;Offset PolyDefs
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
                mov   bx, ObjectP
                cmp   bp, [bx + 2]
                jb    StoreLoop                ;Next coordinate
                mov   WORD PTR es:[di - 20], 0

                mov   ax, Canvas
                mov   es, ax

                ret
StoreP        ENDP

;gs, ds = MainData
;es     = Data1
;fs     = Data3
;gs     = Data2

StoreSP        PROC
                mov   ax, Data1
                mov   es, ax
                mov   ax, Data3
                mov   fs, ax
                mov   ax, Data2
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

;---Testing 123
                push  bp
                mov   dx, bp
                shl   bp, 1
                shl   dx, 2
                add   bp, dx

                movsx eax, WORD PTR gs:[bp + OFSTempNV]
                cdq
                imul  MTime
                sar   eax, 12
                add   fs:[si + 6], ax
;--
                mov   bx, fs:[si]                  ;Load AngleX
                or    ax, ax
                jz    SAngXOK
                or    CrashF, 0
                jz    NoCrash1
                sub   WORD PTR fs:[si], 3*2*8
                cmp   WORD PTR fs:[si], 0
                jg    SAngXOK
                mov   WORD PTR fs:[si], 0
NoCrash1:
                add   WORD PTR fs:[si], 4*2*8
                cmp   WORD PTR fs:[si], (360*8*2)
                jb    SAngXOK
                sub   WORD PTR fs:[si], (360*8*2)
SAngXOK:
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + (90*8*2)]
                mov   CosVal1, ax
;--
                movsx eax, WORD PTR gs:[bp + OFSTempNV + 2]
                cdq
                imul  MTime
                sar   eax, 12
                add   fs:[si + 8], ax

                mov   bx, fs:[si + 2]              ;Load AngleY
                or    ax, ax
                jz    SAngYOK
                or    CrashF, 0
                jz    NoCrash2
                sub   WORD PTR fs:[si + 2], 3*2*8
                cmp   WORD PTR fs:[si + 2], 0
                jg    SAngYOK
                mov   WORD PTR fs:[si + 2], 0
NoCrash2:

                add   WORD PTR fs:[si + 2], 4*2*8
                cmp   WORD PTR fs:[si + 2], (360*8*2)
                jb    SAngYOK
                sub   WORD PTR fs:[si + 2], (360*8*2)
SAngYOK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + (90*8*2)]
                mov   CosVal2, ax

                movsx eax, WORD PTR gs:[bp + OFSTempNV + 4]
                cdq
                imul  MTime
                sar   eax, 12
                add   fs:[si + 10], ax

                mov   bx, fs:[si + 4]              ;Load AngleZ
                or    ax, ax
                jz    SAngZOK
                or    CrashF, 0
                jz    NoCrash3
                sub   WORD PTR fs:[si + 4], 3*2*8
                cmp   WORD PTR fs:[si + 4], 0
                jg    SAngZOK
                mov   WORD PTR fs:[si + 4], 0
NoCrash3:

                add   WORD PTR fs:[si + 4], 4  *2*8
                cmp   WORD PTR fs:[si + 4], (360*8*2)
                jb    SAngZOK
                sub   WORD PTR fs:[si + 4], (360*8*2)
SAngZOK:

                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal3, ax
                mov   ax, [bx + (90*8*2)]
                mov   CosVal3, ax

                pop   bp

                mov   al, Col                   ;This is just bullshit to
                xchg  al, Col2                  ;get different colors
                mov   Col, al
                mov   al, Col
                mov   es:[di + 4], al           ;Save color

                mov   ax, di
                add   ax, 20
                mov   es:[di], ax               ;Saving pointer

                push  si
                push  bp

;----------- Got all sines and cosines...

;Let's rock around the X-axis first :

                push  fs
                mov   si, Data4
                mov   fs, si

                mov   si, bp
                mov   ax, bp
                shl   si, 1
                shl   ax, 2
                add   si, ax
                mov   bp, ObjectP
                add   si, ds:[bp + 6]

                mov   bp, fs:[si]
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

                mov   bp, fs:[si + 2]
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

                mov   bp, fs:[si + 4]
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

                pop   fs
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
;                add   fs:[si + 6], dx

                mov   dx, gs:[bx + 2]
                sar   dx, 3
;                add   fs:[si + 8], dx

                mov   dx, gs:[bx + 4]
                sar   dx, 3
;                add   fs:[si + 10], dx

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
                mov   bx, ObjectP
                cmp   bp, [bx + 2]
                jb    StoreSLoop                ;Next coordinate
                mov   WORD PTR es:[di - 20], 0

                mov   ax, Canvas
                mov   es, ax
                mov   ax, MainData
                mov   gs, ax

                ret
StoreSP        ENDP


;gs     = MainData
;es, ds = Data1

SortPolys     PROC
                push  es
                mov   ax, Data1
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

                mov   ax, MainData
                mov   ds, ax
                pop   es
                ret
SortPolys     ENDP

;es = canvas
;ds = Data1


DrawPolys     PROC
                mov   ax, MainData
                mov   gs, ax
                mov   ax, Data1
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
                mov   ax, MainData
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

                push  MainData
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
                add   dx, si
                mov   al, [OFFSET ACos + bx]

                mov   bl, dh
                add   dx, si
                mov   ah, [OFFSET ACos + bx]
                stosw
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
                mov   ax, Data1
                mov   ds, ax

                ret
DrawPTri      ENDP

P5Main        PROC
                call  Initialize                ;Init palette, screen etc...

;----------------------------------------------------------------------------
                call  GetTimer
                mov   LastTime, eax
                mov   RTime, 0

                mov   Right, 640
                mov   Left, 318


MapLoop:
                mov   ax, MainData
                mov   ds, ax
                call  GetTimer
                mov   ecx, LastTime
                mov   LastTime, eax
                sub   eax, ecx
                mov   MTime, eax
                add   RTime, eax

                mov   ax, Data5
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                xor   di, di
                xor   eax, eax
                mov   cx, 16000
                rep   stosd

                mov   bx, gs:Right
                sub   bx, gs:Left
                mov   ax, 320
                xor   dx, dx
                shld  dx, ax, 8
                shl   ax, 8
                div   bx
                cwde
;eax = slope
                mov   bx, gs:Right
                cmp   bx, 320
                jle   MRightOK
                mov   bx, 320
MRightOK:
                sub   bx, gs:Left
;bx = length
                xor   si, si
                mov   di, gs:Left
                mov   dx, 200
                mov   cx, bx
                xor   ebp, ebp
MYLoop:
                push  cx
                push  ebp
                push  di

XLoop:
                mov   esi, ebp
                shr   esi, 8
                mov   bl, [si]
                mov   es:[di], bl
                inc   di
                add   ebp, eax
                dec   cx
                jnz   XLoop

                pop   di
                pop   ebp
                pop   cx
                add   ebp, 320 * 256
                add   di, 320

                dec   dx
                jnz   MYLoop

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                or    MapF1, 0
                jz    NoMap1
                mov   eax, MTime
                shr   eax, 2
                sub   Left, ax
                sub   Right, ax

                cmp   Left, 0
                jg    NoMap1
                mov   Left, 0
                mov   Right, 320
                mov   MapF1, 0
                mov   MapF2, 1
NoMap1:

                or    MapF3, 0
                jz    NoMap3
                jmp   Poelse
NoMap3:

                or    MapF2, 0
                jz    NoMap2
                mov   eax, RTime
                sub   eax, 1300
                shr   eax, 2
                mov   bx, ax
                shl   bx, 1
                mov   ax, [bx + OFFSET SinTabl + (185*2*8)]
                add   ax, 256
                add   ax, 320-256
                mov   Right, ax

                cmp   bx, 175*2*8
                jb    NoMap2
                mov   Right, 320
                mov   MapF2, 0
                mov   MapF3, 1
NoMap2:

                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break
                jmp   MapLoop                      ;OK, go home!



;----------------------------------------------------------------------------

Poelse:

;                mov   ah, 24
;                call  MusicOrder
;                call  StartMusic

                or    NoSound, 0
                jz    MusicTiming

                jmp   DoneTiming
MusicTiming:
                mov   ah, 0FFh
                call  MusicOrder
                cmp   ax, 24
                jb    MusicTiming
DoneTiming:
                call  GetTimer
                mov   LastTime, eax
                mov   RTime, 0

MoveLoop:
                mov   ax, MainData
                mov   ds, ax
                call  GetTimer
                mov   ecx, LastTime
                mov   LastTime, eax
                sub   eax, ecx
                mov   MTime, eax
                add   RTime, eax

                or    GoWobbly, 0
                jz    NoW
                call  MusicRow
                cmp   WobblyC, 0
                jne   NoWFix
                cmp   ax, 48
                jb    NoWFix
                sub   ax, 64
NoWFix:
                cmp   ax, WobblyC
                jl    NoW
                mov   WobblyF, 1
                add   WobblyC, 16
                mov   WAmp, 10
                cmp   WobblyC, 64
                jb    NoW
                mov   WobblyC, 0
NoW:

                or    WobblyF, 0
                jz    NoWobbly
                mov   ax, Data5
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   dx, 200
                xor   si, si
                xor   di, di
                mov   bx, gs:WobblyC
YLoop:
                push  di
                push  si
                mov   ax, gs:[bx + OFFSET SinTabl]
                push  dx
                cwd
                idiv  gs:WAmp
                pop   dx
                cmp   ax, 0
                jg    Incdi
                neg   ax
                add   si, ax
                jmp   DoneSin
Incdi:
                add   di, ax
DoneSin:

                mov   cx, 320/4
                rep   movsd
                pop   si
                pop   di
                add   di, 320
                add   si, 320
                add   bx, 10*2*8
                cmp   bx, 360*2*8
                jb    SinOK
                sub   bx, 360*2*8
SinOK:
                dec   dx
                jnz   YLoop

                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   eax, MTime
                shr   eax, 5
                inc   ax
                add   WAmp, ax
                cmp   WAmp, 150
                jb    DoneBack
                mov   WobblyF, 0
                jmp   DoneBack
NoWobbly:

                xor   si, si
                xor   di, di
                mov   cx, 16000
                mov   ax, Canvas
                mov   es, ax
                mov   ax, Data5
                mov   ds, ax
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
DoneBack:

                or    DingsF, 0
                jz    NoDings

;----------- Moving object
                movzx  eax, AngMoveX
                mul    MTime

                add    AngleXR, eax
                cmp    AngleXR, 360 * 256 * 8
                jb     AngleXOK
                sub    AngleXR, 360 * 256 * 8
AngleXOK:

                mov   eax, AngleXR
                shr   eax, 8
                shl   eax, 1
                mov   AngleX, ax

                movzx  eax, AngMoveY
                mul    MTime

                add    AngleYR, eax
                cmp    AngleYR, 360 * 256 * 8
                jb     AngleYOK
                sub    AngleYR, 360 * 256 * 8
AngleYOK:

                mov   eax, AngleYR
                shr   eax, 8
                shl   eax, 1
                mov   AngleY, ax

                movzx  eax, AngMoveZ
                mul    MTime

                add    AngleZR, eax
                cmp    AngleZR, 360 * 256 * 8
                jb     AngleZOK
                sub    AngleZR, 360 * 256 * 8
AngleZOK:

                mov   eax, AngleZR
                shr   eax, 8
                shl   eax, 1
                mov   AngleZ, ax

                movsx eax, ObjMoveX
                imul  MTime
                add   ObjXR, eax
                mov   eax, ObjXR
                sar   eax, 8
                mov   ObjX, ax

                movsx eax, ObjMoveY
                imul  MTime
                add   ObjYR, eax
                mov   eax, ObjYR
                sar   eax, 8
                mov   ObjY, ax

                movsx eax, ObjMoveZ
                imul  MTime
                add   ObjZR, eax
                mov   eax, ObjZR
                sar   eax, 8
                mov   ObjZ, ax

                call  Rotation
                call  StoreCl
                call  StoreP
                call  SortPolys
                call  DrawPolys

NoDings:

                mov   ax, 0A000h
                mov   es, ax
                mov   ax, Canvas
                mov   ds, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd

                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax


                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break                     ;OK, go home!

;-------------------------------- Order-ACTIONS 1 ----------------------------------
                or    NoSound, 0
                jz    Sound
                mov   AFlag, 1
                mov   DingsF, 1
                jmp   NoOrder
Sound:
                mov   bx, OCounter


                mov   ah, 0FFh
                call  MusicOrder
                cmp   ax, [bx]
                jb    NoOrder
                call  MusicRow
                cmp   ax, [bx + 2]
                jb    NoOrder
                jmp   WORD PTR [bx + 4]

O1:
                mov   AFlag, 1
                mov   DingsF, 1
                mov   RTime, 0
                add   OCounter, 6
                jmp   NoOrder

O2:
                mov   AFlag, 1
                mov   DingsF, 1
                mov   RTime, 0
                add   OCounter, 6
                jmp   NoOrder

NoOrder:

;------------------


;-------------------------------- ACTIONS 1 ----------------------------------
                or    AFlag, 0
                jz    NoAction
                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction

                jmp   WORD PTR [bx + 4]

A1:
                mov   ObjMoveX, 0
                mov   ObjMoveZ, 0
                add   TCounter, 6
                jmp   Blow

A5:
                mov   DingsF, 1
                add   TCounter, 6
                jmp   NoAction

A6:
                mov   ObjMoveY, 0
                add   TCounter, 6
                jmp   Blow
A10:
                add   TCounter, 6
                mov   DingsF, 1
                jmp   NoAction
A11:
                mov   ObjMoveX, 0
                add   TCounter, 6
                jmp   Blow
A15:
                mov   DingsF, 1
                add   TCounter, 6
                jmp   NoAction
A16:
                mov   BumpF, 1
                mov   ObjMoveY, 0
                mov   ObjMoveX, 7
                mov   ObjMoveZ, -3
                mov   AngMoveX, 55
                mov   AngMoveZ, 27
                add   TCounter, 6
                jmp   NoAction

A17:
                mov   BumpF, 0
                mov   AngMoveX, 0
                mov   AngMoveY, 0
                mov   ObjMoveX, 0
                mov   ObjMoveZ, 0
                add   TCounter, 6
                jmp   Blow
                jmp   NoAction
A18:
                mov   ObjMoveZ, 0
                add   TCounter, 6
                jmp   Blow

A22:
                mov   DingsF, 1
                add   TCounter, 6
                jmp   NoAction

A23:
                mov   ObjMoveY, 0
                mov   ObjMoveZ, 0
                mov   ObjMoveX, 0
                add   TCounter, 6
                jmp   Blow
NoAction:


                or    BumpF, 0
                jz    NoBump
                mov   eax, RTime
                sub   eax, 130000-125000
                cwd
                mov   bx, 10
                div   bx
                shl   ax, 1
                mov   bx, ax
                mov   ax, [bx + OFFSET SinTabl]
                neg   ax
                cwde
                sal   eax, 9
                add   eax, 130*256
                mov   ObjYR, eax
NoBump:

                jmp   MoveLoop                     ;No? Let's do another roll!

;---------------- Explosion...

Blow:

                call  GetTimer
                mov   LastTime, eax

;--------- Setting greyscale-palette
                mov   cx, (90+128)
                mov   si, OFFSET Palette
                mov   bx, OFFSET Pal2
GLoop:
                mov   al, [si]
                cmp   al, [si + 1]
                jg    G1
                mov   al, [si + 1]
G1:
                cmp   al, [si + 2]
                jg    G2
                mov   al, [si + 2]
G2:
                mov   ah, 63
                sub   ah, al
                mov   [bx], ah
                mov   [bx + 1], ah
                mov   [bx + 2], ah
                add   si, 3
                add   bx, 3
                dec   cx
                jnz   GLoop

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   FadeF2, 1

                mov   ax, Data4
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   si, 20000
                xor   di, di
                mov   cx, 8000
FLoop:
                lodsb
                mov   dl, 8
                mov   ah, 00000001b
ILoop:
                test  al, ah
                jz    NoPix
                mov   BYTE PTR es:[di], 0
NoPix:
                shl   ah, 1
                inc   di
                dec   dl
                jnz   ILoop

                dec   cx
                jnz   FLoop

                mov   ax, 0A000h
                mov   es, ax
                mov   ax, Canvas
                mov   ds, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

DelayL:
                call  GetTimer
                sub   eax, LastTime
                cmp   eax, 600
                jb    DelayL

                call  GetTimer
                mov   LastTime, eax



PLoop:                                          ;Frameloop
                call  GetTimer
                mov   ecx, LastTime
                mov   LastTime, eax
                sub   eax, ecx
                mov   MTime, eax
                add   RTime, eax

;----------- Moving object
                movsx eax, ObjMoveX
                imul  MTime
                add   ObjXR, eax
                mov   eax, ObjXR
                sar   eax, 8
                mov   ObjX, ax

                movsx eax, ObjMoveY
                imul  MTime
                add   ObjYR, eax
                mov   eax, ObjYR
                sar   eax, 8
                mov   ObjY, ax

                movsx eax, ObjMoveZ
                imul  MTime
                add   ObjZR, eax
                mov   eax, ObjZR
                sar   eax, 8
                mov   ObjZ, ax

                or    GoWobbly, 0
                jz    NoW2

                call  MusicRow
                cmp   WobblyC, 0
                jne   NoWFix2
                cmp   ax, 48
                jb    NoWFix2
                sub   ax, 64
NoWFix2:
                cmp   ax, WobblyC
                jl    NoW2
                mov   WobblyF, 1
                add   WobblyC, 16
                mov   WAmp, 10
                cmp   WobblyC, 60
                jb    NoW2
                mov   WobblyC, 0
NoW2:

                or    WobblyF, 0
                jz    NoWobbly2
                mov   ax, Data5
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   dx, 200
                xor   si, si
                xor   di, di
                mov   bx, gs:WobblyC
YLoop2:
                push  di
                push  si
                mov   ax, gs:[bx + OFFSET SinTabl]
                push  dx
                cwd
                idiv  gs:WAmp
                pop   dx
                cmp   ax, 0
                jg    Incdi2
                neg   ax
                add   si, ax
                jmp   DoneSin2
Incdi2:
                add   di, ax
DoneSin2:

                mov   cx, 320/4
                rep   movsd
                pop   si
                pop   di
                add   di, 320
                add   si, 320
                add   bx, 10*2*8
                cmp   bx, 360*2*8
                jb    SinOK2
                sub   bx, 360*2*8
SinOK2:
                dec   dx
                jnz   YLoop2

                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   eax, MTime
                shr   eax, 5
                inc   ax
                add   WAmp, ax
                cmp   WAmp, 150
                jb    DoneBack2
                mov   WobblyF, 0
                jmp   DoneBack2
NoWobbly2:


                xor   si, si
                xor   di, di
                mov   cx, 16000
                mov   ax, Canvas
                mov   es, ax
                mov   ax, Data5
                mov   ds, ax
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
DoneBack2:
                call  StoreSP
                call  SortPolys
                call  DrawPolys


                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break                      ;OK, go home!

;-------------------------------- ACTIONS 2 ----------------------------------
                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction2

                jmp   WORD PTR [bx + 4]

A2:
                mov   ax, Data2
                mov   es, ax
                mov   di, OFSTempNV
                mov   cx, (MaxPolys * 6)/4
                xor   eax, eax
                rep   stosd
                mov   ax, Canvas
                mov   es, ax
                mov   ObjMoveY, -10
                mov   SpeedUpF, 1
                add   TCounter, 6
                jmp   NoAction2


A3:
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction2

A4:
;------------------- Setting up for second object... ------------------------
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 16888                 ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx

                int   21h
                pop   ds

;----------------- Loading normals
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, (938*6)+(MaxPolys*6)         ;Size of nuts-file

                push  ds
                mov   dx, Data2
                mov   ds, dx
                mov   dx, OFSTempNV
                int   21h
                pop   ds

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 1876*30                 ;Size of nuts-file

                push  ds
                mov   dx, Data3
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;----------------- Loading "XENON Developments"

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 8000        ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                mov   dx, 20000
                int   21h
                pop   ds

                mov   ax, Data5
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                mov   AmbientR, 15
                mov   AmbientG, 0
                mov   AmbientB, 5
                mov   DiffuseR, 30
                mov   DiffuseG, 0
                mov   DiffuseB, 5
                mov   SpecR, 15
                mov   SpecG, 0
                mov   SpecB, 5
                mov   Shiny, 20

                mov   si, OFFSET Palette
                call  SetPhong

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   ObjectP, OFFSET Object2

                mov   ObjZR, 700*256
                mov   ObjXR, 0
                mov   ObjYR, 350 * 256
                mov   ObjMoveZ, 0
                mov   ObjMoveY, -7

                mov   SpeedUpF, 0
                mov   FadeF1, 0
                mov   DingsF, 0
                mov   AFlag, 0
                mov   RTime, 0

                call  GetTimer
                mov   LastTime, eax

                add   TCounter, 6
                jmp   MoveLoop

A7:
                mov   ax, Data2
                mov   es, ax
                mov   di, OFSTempNV
                mov   cx, 3000
                xor   eax, eax
                rep   stosd
                mov   ax, Canvas
                mov   es, ax
                mov   ObjMoveY, -10
                mov   SpeedUpF, 1
                add   TCounter, 6
                jmp   NoAction2

A8:
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction2

A9:
;------------------- Setting up for third object... ------------------------
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 14878                 ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx

                int   21h
                pop   ds

;----------------- Loading normals
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, (829*6)+(MaxPolys*6)         ;Size of nuts-file

                push  ds
                mov   dx, Data2
                mov   ds, dx
                mov   dx, OFSTempNV
                int   21h
                pop   ds

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 1650*30                 ;Size of nuts-file

                push  ds
                mov   dx, Data3
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;----------------- Loading "Proxima"
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 8000        ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                mov   dx, 20000
                int   21h
                pop   ds

                mov   ax, Data5
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                mov   AmbientR, 6
                mov   AmbientG, 6
                mov   AmbientB, 6
                mov   DiffuseR, 6
                mov   DiffuseG, 6
                mov   DiffuseB, 6
                mov   SpecR, 23
                mov   SpecG, 23
                mov   SpecB, 23
                mov   Shiny, 15

                mov   si, OFFSET Palette
                call  SetPhong

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   ObjectP, OFFSET Object3

                mov   ObjZR, 900*256
                mov   ObjXR, 700*256
                mov   ObjYR, 0
                mov   AngMoveX, 34
                mov   AngMoveZ, 17
                mov   AngMoveY, 0
                mov   AngleXR, 0
                mov   AngleYR, 0
                mov   AngleZR, 180*8*256
                mov   ObjMoveZ, 0
                mov   ObjMoveY, 0
                mov   ObjMoveX, -8

                mov   SpeedUpF, 0
                mov   FadeF1, 0
                mov   DingsF, 0
                mov   AFlag, 0
                mov   RTime, 0

                or    NoSound, 0
                jnz   NoWbl
                mov   GoWobbly, 1
NoWbl:

                call  GetTimer
                mov   LastTime, eax

                add   TCounter, 6
                jmp   MoveLoop

A12:
                mov   ax, Data2
                mov   es, ax
                mov   di, OFSTempNV
                mov   cx, (MaxPolys * 6)/4
                xor   eax, eax
                rep   stosd
                mov   ax, Canvas
                mov   es, ax
                mov   ObjMoveY, -10
                mov   SpeedUpF, 1
                add   TCounter, 6
                jmp   NoAction2


A13:
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction2

A14:
;------------------- Setting up for fourth object... ------------------------
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 10696                 ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx

                int   21h
                pop   ds

;----------------- Loading normals
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, (548*6)+(MaxPolys*6)         ;Size of nuts-file

                push  ds
                mov   dx, Data2
                mov   ds, dx
                mov   dx, OFSTempNV
                int   21h
                pop   ds

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 1234*30                 ;Size of nuts-file

                push  ds
                mov   dx, Data3
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;----------------- Loading "Spin"
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 8000        ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                mov   dx, 20000
                int   21h
                pop   ds

                mov   ax, Data5
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                mov   AmbientR, 11
                mov   AmbientG, 11
                mov   AmbientB, 11
                mov   DiffuseR, 11
                mov   DiffuseG, 11
                mov   DiffuseB, 25
                mov   SpecR, 11
                mov   SpecG, 21
                mov   SpecB, 11
                mov   Shiny, 27

                mov   si, OFFSET Palette
                call  SetPhong

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   ObjectP, OFFSET Object5

                mov   ObjZR, 900*256
                mov   ObjXR, -400*256
                mov   ObjYR, -500*256
                mov   AngMoveX, 8
                mov   AngMoveZ, 0
                mov   AngMoveY, 0
                mov   AngleXR, 0
                mov   AngleYR, 0
                mov   AngleZR, 180*8*256
                mov   ObjMoveZ, 0
                mov   ObjMoveY, 35
                mov   ObjMoveX, 6

                mov   SpeedUpF, 0
                mov   FadeF1, 0
                mov   DingsF, 0
                mov   AFlag, 0
                mov   RTime, 0

                call  GetTimer
                mov   LastTime, eax

                add   TCounter, 6
                jmp   MoveLoop

A19:
                mov   ax, Data2
                mov   es, ax
                mov   di, OFSTempNV
                mov   cx, (MaxPolys * 6)/4
                xor   eax, eax
                rep   stosd
                mov   ax, Canvas
                mov   es, ax
                mov   ObjMoveY, -10
                mov   SpeedUpF, 1
                add   TCounter, 6
                jmp   NoAction2


A20:
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction2

A21:
;------------------- Setting up for fifth object... ------------------------
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 13060                 ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx

                int   21h
                pop   ds

;----------------- Loading normals
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, (724*6)+(MaxPolys*6)         ;Size of nuts-file

                push  ds
                mov   dx, Data2
                mov   ds, dx
                mov   dx, OFSTempNV
                int   21h
                pop   ds

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 1452*30                 ;Size of nuts-file

                push  ds
                mov   dx, Data3
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;----------------- Loading "infernal"
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 8000        ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                mov   dx, 20000
                int   21h
                pop   ds

                mov   ax, Data5
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                mov   AmbientR, 5
                mov   AmbientG, 10
                mov   AmbientB, 15
                mov   DiffuseR, 5
                mov   DiffuseG, 10
                mov   DiffuseB, 15
                mov   SpecR, 5
                mov   SpecG, 15
                mov   SpecB, 10
                mov   Shiny, 1

                mov   si, OFFSET Palette
                call  SetPhong

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   ObjectP, OFFSET Object1

                mov   ObjZR, 240*256
                mov   ObjXR, 260*256
                mov   ObjYR, -150*256
                mov   AngMoveX, 0
                mov   AngMoveZ, 0
                mov   AngMoveY, 13
                mov   AngleXR, 0
                mov   AngleYR, (85*8)*256
                mov   AngleZR, 0
                mov   ObjMoveZ, 2
                mov   ObjMoveY, 1
                mov   ObjMoveX, -2

                mov   SpeedUpF, 0
                mov   FadeF1, 0
                mov   DingsF, 0
                mov   AFlag, 0
                mov   RTime, 0

                call  GetTimer
                mov   LastTime, eax

                add   TCounter, 6
                jmp   MoveLoop

A24:
                mov   ax, Data2
                mov   ds, ax
                mov   si, OFSTempNV
                mov   cx, (MaxPolys * 3)
TurnL:
                mov   ax, [si]
                neg   ax
                sar   ax, 1
                mov   [si], ax
                add   si, 2
                dec   cx
                jnz   TurnL
                mov   ax, MainData
                mov   ds, ax
                mov   ObjMoveY, 0
                mov   ObjMoveX, 0
                mov   ObjMoveZ, 0
                mov   CrashF, 1
                add   TCounter, 6
                jmp   NoAction2


A25:
                mov   ax, Data2
                mov   es, ax
                mov   di, OFSTempNV
                mov   cx, (MaxPolys * 6)/4
                xor   eax, eax
                rep   stosd
                mov   ax, Canvas
                mov   es, ax
                add   TCounter, 6
                mov   AngMoveX, 0
                mov   AngMoveY, 0
                mov   AngMoveZ, 0
                jmp   Done

NoAction2:
;----------------------------------------------------------------------------
                or    FadeF1, 0
                jz    NoFade1

                mov   si, OFFSET Palette
                mov   eax, MTime
                shr   eax, 6
                mov   cx, (90*3)
Fade1:
                sub   [si], al
                cmp   BYTE PTR [si], 0
                jg    COK
                mov   BYTE PTR [si], 0
COK:
                inc   si
                dec   cx
                jnz   Fade1

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx, 90*3                 ;3*256 (RGB)=768 colors
                rep   outsb

NoFade1:
                or    FadeF2, 0
                jz    NoFade2

                mov   edx, MTime
                shr   edx, 7

                mov   si, OFFSET Palette
                mov   bx, OFFSET Pal2

                mov   cx, (128+90)*3
F2L:
                lodsb
                cmp   [bx], al
                je    ColOK
                jg    CDec
                add   [bx], dl
                cmp   [bx], al
                jle   ColOK
                mov   [bx], al
                jmp   ColOK
CDec:
                sub   [bx], dl
                cmp   [bx], al
                jge   ColOK
                mov   [bx], al
ColOK:
                inc   bx
                dec   cx
                jnz   F2L

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

NoFade2:
                or    SpeedUpF, 0
                jz    NoSpeedUp
                mov   eax, MTime
                shr   eax, 4
                add   ObjMoveZ, ax
NoSpeedUp:

                mov   ax, 0A000h
                mov   es, ax
                mov   ax, Canvas
                mov   ds, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                jmp   PLoop

Break:
                mov   al, 1
                jmp   Done2
Done:
                xor   al, al
Done2:
                ret
P5Main        ENDP

Initialize    PROC
                mov   ax, MainData                ;Point ds to data-segment
                mov   gs, ax
                mov   ds, ax
                mov   ax, Data2
                mov   fs, ax

;----------------- Loading object...
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 16306                 ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx

                int   21h
                pop   ds

;----------------- Loading object...

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, (1003*6)+(MaxPolys*6)         ;Size of nuts-file

                push  ds
                mov   dx, Data2
                mov   ds, dx
                mov   dx, OFSTempNV
                int   21h
                pop   ds

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 1714*30                 ;Size of nuts-file

                push  ds
                mov   dx, Data3
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;----------------- Loading background

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 64000        ;Size of nuts-file

                push  ds
                mov   dx, Data5
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;----------------- Loading "greetings"
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 8000        ;Size of nuts-file

                push  ds
                mov   dx, Data4
                mov   ds, dx
                mov   dx, 20000
                int   21h
                pop   ds

                mov   AmbientR, 2
                mov   AmbientG, 7
                mov   AmbientB, 15
                mov   DiffuseR, 20
                mov   DiffuseG, 2
                mov   DiffuseB, 15
                mov   SpecR, 5
                mov   SpecG, 7
                mov   SpecB, 18
                mov   Shiny, 9

                mov   si, OFFSET Palette
                call  SetPhong

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx, (90+128)*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   ax, Canvas                ;Set es to canvas
                mov   es, ax

                xor   di, di                    ;Blank the canvas
                mov   cx, 16000
                xor   eax, eax
                rep   stosd

                ret
Initialize    ENDP

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

Code1         ENDS

Data1         SEGMENT PUBLIC
;The segment for the calculated polygons and the sorting arrays.

OFSFStart       EQU 0 + 5000
OFSFOfs         EQU (256 * 2) + 5000
OFSPoly         EQU 1024 + 5000                 ;The starting offset of the
                                                ;faces.
Data1         ENDS

Data2         SEGMENT PUBLIC
;Place for different calculated data.

OFSCValues      EQU 0
OFSTempNV       EQU MaxPolys
OFSNormalV      EQU OFSTempNV + (MaxPolys * 6)
OFSTempCoords   EQU OFSNormalV + (MaxPoints * 6)

Data2         ENDS

Data3         SEGMENT PUBLIC
Data3         ENDS

Data4         SEGMENT PUBLIC
Data4         ENDS

Data5         SEGMENT PUBLIC
Data5         ENDS

;----------------------- The double buffer for screen ------------------------

Canvas        SEGMENT PUBLIC
Canvas        ENDS

END           P5Main