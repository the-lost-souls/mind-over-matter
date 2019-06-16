;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            : P6.ASM
;Author          : Cyberfish of The Lost Souls
;Last update     : March 1996
;Action          : Mind over Matter - Part 6
;
;
;Using Libraries             :
;Using external files/macros : An object file with the object...
;
;Notes : Hmmm... I don't like this one much...
;----------------------------------------------------------------------------

MaxPolys        EQU 2000
MaxPoints       EQU 1000

;The viewport...
ViewMinX        EQU 5
ViewMaxX        EQU 250
ViewMinY        EQU 5
ViewMaxY        EQU 250


ASSUME cs : Code1, ds : MainData

include        bwsb.inc
include        gdmtype.inc

PUBLIC          P6Main

MainData        SEGMENT PUBLIC

EXTRN           AmbientR : BYTE, AmbientG : BYTE, AmbientB : BYTE, DiffuseR : BYTE, DiffuseG : BYTE, DiffuseB : BYTE
EXTRN           SpecR : BYTE, SpecG : BYTE, SpecB : BYTE, Shiny : BYTE, NoSound : BYTE
EXTRN           SinTabl : WORD, LastTime : DWORD

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
                DB 00, 00, 00

;The blue palette :

Palette         DB 0, 0, 0
                DB  63,  63,  63,  62,  62,  63,  60,  60,  63,  57,  57,  62,  54,  54,  62,  51,  51,  61,  48,  48,  61,  45,  45,  60,  45,  45,  60
                DB  42,  42,  60,  41,  41,  60,  40,  40,  60,  40,  40,  59,  40,  40,  59,  39,  39,  59,  39,  39,  59,  39,  39,  59,  39,  39,  59
                DB  39,  39,  59,  39,  39,  58,  39,  39,  58,  39,  39,  58,  39,  39,  58,  38,  38,  58,  38,  38,  57,  38,  38,  57,  38,  38,  57
                DB  38,  38,  57,  38,  38,  56,  37,  37,  56,  37,  37,  56,  37,  37,  56,  37,  37,  55,  37,  37,  55,  37,  37,  55,  36,  36,  55
                DB  36,  36,  54,  36,  36,  54,  36,  36,  54,  36,  36,  53,  35,  35,  53,  35,  35,  53,  35,  35,  52,  35,  35,  52,  34,  34,  52
                DB  34,  34,  51,  34,  34,  51,  34,  34,  50,  33,  33,  50,  33,  33,  50,  33,  33,  49,  33,  33,  49,  32,  32,  48,  32,  32,  48
                DB  32,  32,  48,  31,  31,  47,  31,  31,  47,  31,  31,  46,  31,  31,  46,  30,  30,  45,  30,  30,  45,  30,  30,  45,  29,  29,  44
                DB  29,  29,  44,  29,  29,  43,  28,  28,  43,  28,  28,  42,  28,  28,  42,  27,  27,  41,  27,  27,  41,  27,  27,  40,  27,  27,  40
                DB  26,  26,  39,  26,  26,  39,  26,  26,  38,  25,  25,  38,  25,  25,  37,  24,  24,  37,  24,  24,  36,  24,  24,  36,  23,  23,  35
                DB  23,  23,  35,  23,  23,  34,  22,  22,  34,  22,  22,  33,  22,  22,  33,  21,  21,  32,  21,  21,  32,  21,  21,  31,  20,  20,  31
                DB 0, 0, 0

Pal2            DB (92*3) DUP (63)

RTime           DD 0
MTime           DD 0

IncX            DW 0
IncY            DW 0

ZValue          DW 0
ZValueR         DD 320 * 256
MoveZR          DW 2
RValue          DW 0
RValueR         DD 90*8*256

PosX            DW 0
PosY            DW 0
Dings           DW 1

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
ObjY            DW 00
ObjZ            DW 450

AngleX          DW 0
AngleY          DW 0
AngleZ          DW 0
AngleXR         DD 0
AngleYR         DD 0
AngleZR         DD 0
MoveX           DW 5             ;10
MoveY           DW 0             ;70
MoveZ           DW 0             ;40

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

FadeF1          DB 1
FadeF2          DB 0
SpeedF          DB 0
SpeedF2         DB 0
GreyF           DB 1
GreyC           DW 16

TCounter        DW OFFSET TLimits
TLimits         DD 1000
                DW OFFSET A1

                DD 4000
                DW OFFSET A2

                DD 75000
                DW OFFSET A3

                DD 82000
                DW OFFSET A4

                DD 50000000

MainData      ENDS

Code1        SEGMENT PUBLIC
.386

EXTRN           F3DTo2D : PROC, GetTimer : PROC, SetPhong : PROC

;----------------------------------------------------------------------------
;A procedure which manages the calculating of the points.
;si = OFFSET Object
;----------------------------------------------------------------------------

;ds, gs = MainData
;fs     = Data2

Rotation      PROC
                mov   ax, Data3
                mov   es, ax
                mov   ax, Data4
                mov   gs, ax
                mov   di, OFSTempCoords         ;Constant
;                mov   si, OFFSET Coords         ;Real offset
                mov   si, 2
                mov   bp, 724           ;Load NumOfVertexes

                mov   bx, AngleX
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal1, ax
                mov   ax, [bx + (90*2*8)]
                mov   CosVal1, ax

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + (90*2*8)]
                mov   CosVal2, ax

                mov   bx, AngleZ
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal3, ax
                mov   ax, [bx + (90*2*8)]
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
                mov   es:[di + 4], cx              ;and Z coords in Data3

                add   di, 6                     ;Point to next record
                add   si, 6
                dec   bp
                jnz   RotateLoop                ;Next coordinate

                ret
Rotation      ENDP


;ds, gs = MainData
;fs, es = Data2

StoreCl       PROC
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
                mov   ax, [bx + (90*2*8)]
                mov   CosVal1, ax

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + (90*2*8)]
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
                cmp   di, 724
                jb    StoreCLoop                ;Next coordinate
                ret
StoreCl       ENDP


;gs, ds = MainData
;es     = Data1
;fs     = Data2

StoreP        PROC
                mov   ax, Data1
                mov   es, ax
                mov   ax, Data3
                mov   fs, ax
                mov   ax, Data4
                mov   gs, ax
;                mov   si, OFFSET PolyDefs
                mov   si, 4 + (724*6)
                mov   di, OFSPoly
                xor   bp, bp

StoreLoop:
                mov   XMax, -32768
                mov   XMin, 32767
                mov   YMax, -32768
                mov   YMin, 32767

                mov   BYTE PTR es:[di + 4], 0   ;Save color

                mov   ax, di
                add   ax, 20
                mov   es:[di], ax

;----------------- Rotated normal vector, done. ----------------------------

                mov   ax, gs:[si]               ;Load first vertex
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
                add   ax, 125
                add   bx, 125
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

                mov   ax, gs:[si + 2]           ;Load second vertex
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, gs:[si + 2]           ;Load second vertex again
                mov   bl, es:[OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 6], dl
                call  F3DTo2D
                add   ax, 125
                add   bx, 125
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

                mov   ax, gs:[si + 4]           ;Load third vertex
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, gs:[si + 4]           ;Load third vertex again
                mov   bl, es:[OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 7], dl
                call  F3DTo2D
                add   ax, 125
                add   bx, 125
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
                cmp   bp, 1452
                jb    StoreLoop                ;Next coordinate
                mov   WORD PTR es:[di - 20], 0

                mov   ax, Canvas
                mov   es, ax
                mov   ax, MainData
                mov   gs, ax

                ret
StoreP        ENDP

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
                mov   al, [bx + OFFSET ACos]
                stosb
                add   dx, si
GoLoop:

Ph_HorLoop:
                mov   bl, dh
                mov   al, [bx + OFFSET ACos]
                add   dx, si
                mov   bl, dh
                mov   ah, [bx + OFFSET ACos]
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
                mov   ax, Data1
                mov   ds, ax

                ret
DrawPTri      ENDP

P6Main         PROC
                call  Initialize                ;Init palette, screen etc...

;                mov   ah, 33
;                call  MusicOrder
;                call  StartMusic


;MusicTiming:
;                mov   ah, 0FFh
;                call  MusicOrder
;                cmp   ax, 32
;                jb    MusicTiming

                call  GetTimer
                mov   LastTime, eax
                mov   RTime, 0

PLoop:                                          ;Frameloop
                call  GetTimer
                mov   ecx, LastTime
                mov   LastTime, eax
                sub   eax, ecx
                mov   MTime, eax
                add   RTime, eax

                xor   eax, eax                  ;Blank canvas
                xor   di, di
                mov   cx, 16384
                rep   stosd

                call  Rotation
                call  StoreCl
                call  StoreP
                call  SortPolys
                call  DrawPolys

;----------- Moving object
                movzx  eax, MoveX
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

                movzx  eax, MoveY
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

                movzx  eax, MoveZ
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

;-------------------------------- ACTIONS 1 ----------------------------------
                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction

                jmp   WORD PTR [bx + 4]

A1:
                mov   SpeedF, 1
                add   TCounter, 6
                jmp   NoAction

A2:
                mov   FadeF1, 0
                mov   SpeedF, 0
                add   TCounter, 6
                jmp   NoAction

A3:
                mov   SpeedF2, 1
                add   TCounter, 6
                jmp   NoAction
A4:
                mov   SpeedF2, 0
                add   TCounter, 6
                jmp   NoAction
NoAction:

                or    GreyF, 0
                jz    NoGrey

                or    NoSound, 0
                jnz   NoGrey

                call  MusicRow
                cmp   GreyC, 0
                jne   NoGFix
                cmp   ax, 48
                jb    NoGFix
                sub   ax, 64
NoGFix:
                cmp   ax, GreyC
                jl    NoGrey
                add   GreyC, 16
                cmp   GreyC, 64
                jb    NoG
                mov   GreyC, 0
NoG:
                mov   FadeF1, 0

;--------- Setting greyscale-palette
                mov   cx, 91
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
                mov   BYTE PTR [bx], 1
                mov   BYTE PTR [bx + 1], 1
                mov   BYTE PTR [bx + 2], 1

                add   si, 3
                add   bx, 3
                dec   cx
                jnz   GLoop

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 0                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx, 91*3                 ;3*256 (RGB)=768 colors
                rep   outsb

                mov   FadeF2, 1
NoGrey:

                or     FadeF1, 0
                jz     NoFade1
                mov    eax, MTime
                sar    eax, 5

                mov    bx, OFFSET Palette
                mov    si, OFFSET Pal2
                mov    bp, (91*3)
F1L:
                sub   BYTE PTR [si], al
                mov   cl, [bx]

                cmp   BYTE PTR [si], cl
                jg    COK1
                mov   BYTE PTR [si], cl
COK1:
                inc   si
                inc   bx
                dec   bp
                jnz   F1L

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 0                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx, 91*3                 ;3*256 (RGB)=768 colors
                rep   outsb
NoFade1:

                or    FadeF2, 0
                jz    NoFade2

                mov   edx, MTime
                shr   edx, 7

                mov   si, OFFSET Palette
                mov   bx, OFFSET Pal2

                mov   cx, 91*3
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
                mov   al, 0                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx, 91*3                 ;3*256 (RGB)=768 colors
                rep   outsb

NoFade2:

                or    SpeedF, 0
                jz    NoSpeed
                mov   eax, RTime
                sub   eax, 1000
                cdq
                mov   ebx, 100
                div   ebx

                mov   MoveZR, ax
                mov   Dings, ax
                mov   MoveX, ax
                shl   ax, 1
                mov   MoveY, ax
                mov   MoveZ, ax

NoSpeed:

                or    SpeedF2, 0
                jz    NoSpeed2
                mov   eax, RTime
                sub   eax, 75000
                cdq
                mov   ebx, 300
                div   ebx
                mov   ebx, 35
                sub   ebx, eax
                mov   ax, bx
                neg   ax

                mov   MoveZR, bx
                mov   MoveX, bx
                mov   Dings, ax
                shl   bx, 1
                mov   MoveY, bx
                mov   MoveZ, bx

NoSpeed2:


;---------- The texturemapping...
                movsx  eax, Dings
                imul   MTime

                add    ZValueR, eax
                cmp    ZValueR, 5300 * 256
                jb     ZValueOK1
                neg    Dings
ZValueOK1:
                cmp   ZValueR, 50 * 256
                ja    ZValueOK2
                xor   al, al
                jmp   Done
ZValueOK2:

                mov   eax, ZValueR
                shr   eax, 8
                mov   ZValue, ax

                movzx  eax, MoveZR
                mul    MTime

                add    RValueR, eax
                cmp    RValueR, 360 * 256 * 8
                jb     RValueOK
                sub    RValueR, 360 * 256 * 8
RValueOK:

                mov   eax, RValueR
                shr   eax, 8
                mov   RValue, ax

                mov   bx, RValue
                shl   bx, 1
                mov   bx, [OFFSET SinTabl + bx]
                mov   ax, ZValue
                imul  bx
                shrd  ax, dx, 8
                mov   IncX, ax

                mov   bx, RValue
                shl   bx, 1
                mov   bx, [OFFSET SinTabl + (90*2*8) + bx]
                mov   ax, ZValue
                imul  bx
                shrd  ax, dx, 8
                mov   IncY, ax

                call  PTexture

                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break                      ;OK, go home!
                jmp   PLoop                     ;No? Let's do another roll!
Break:
                mov   al, 1
Done:

                ret
P6Main         ENDP

PTexture      PROC
                push  es
                push  ds

                mov   ax, 0A000h
                mov   es, ax
                mov   ax, Canvas
                mov   ds, ax

                mov   dx, 50                ;ScreenX /2
                mov   ax, gs:IncX
                mul   dx
                mov   gs:PosX, dx

                mov   dx, 200                ;ScreenY /2
                mov   ax, gs:IncY
                mul   dx
                mov   gs:PosY, dx

                mov   ch, 199
                mov   di, 0
VLoop :

                mov   si, gs:IncY
                shl   esi, 16
                mov   si, gs:IncX

                mov   dx, gs:PosY                  ;Middle of picture...?
                shl   edx, 16
                mov   dx, gs:PosX
;                xor   edx, edx

                mov   cl, 320 /4
HLoop :
                add   edx, esi

                mov   ebx, edx
                shr   ebx, 16
                mov   bl, dh
                mov   al, [bx]

                add   edx, esi

                mov   ebx, edx
                shr   ebx, 16
                mov   bl, dh
                mov   ah, [bx]

                shl   eax, 16

                add   edx, esi

                mov   ebx, edx
                shr   ebx, 16
                mov   bl, dh
                mov   al, [bx]

                add   edx, esi

                mov   ebx, edx
                shr   ebx, 16
                mov   bl, dh
                mov   ah, [bx]

                ror   eax, 16

                stosd
                dec   cl
                jnz   HLoop

                mov   ax, gs:IncY
                sub   gs:PosX, ax                  ;PosX + IncY
                mov   ax, gs:IncX
                add   gs:PosY, ax                  ;PosY - IncX
                dec   ch
                jnz   VLoop

                pop   ds
                pop   es

                ret
PTexture      ENDP

Initialize    PROC
                mov   ax, MainData                ;Point ds to data-segment
                mov   gs, ax
                mov   ds, ax
                mov   ax, Data2
                mov   fs, ax
                mov   ax, Canvas                ;Set es to canvas
                mov   es, ax

                mov   AmbientR, 10
                mov   AmbientG, 0
                mov   AmbientB, 15
                mov   DiffuseR, 15
                mov   DiffuseG, 0
                mov   DiffuseB, 20
                mov   SpecR, 5
                mov   SpecG, 0
                mov   SpecB, 10
                mov   Shiny, 10

                mov   si, OFFSET Palette + 3
                call  SetPhong

                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 0                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx, 91*3                 ;3*256 (RGB)=768 colors
;                rep   outsb

                xor   di, di                    ;Blank the canvas
                mov   cx, 65535
                xor   eax, eax
                rep   stosb
                mov   ax, 0A000h
                mov   es, ax
                xor   di, di
                mov   cx, 16000
                xor   eax, eax
                rep   stosd
                mov   ax, Canvas
                mov   es, ax

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

Code1        ENDS

Data1      SEGMENT PUBLIC
;The segment for the calculated polygons and the sorting arrays.

OFSFStart       EQU 0 + 5000
OFSFOfs         EQU (256 * 2) + 5000
OFSPoly         EQU 1024 + 5000                 ;The starting offset of the
                                                ;faces.
Data1      ENDS

Data2       SEGMENT PUBLIC
;Place for different calculated data.

OFSCValues      EQU 0
OFSTempNV       EQU MaxPolys
OFSNormalV      EQU OFSTempNV + (MaxPolys * 6)

Data2       ENDS

Data3    SEGMENT PUBLIC
OFSTempCoords   EQU 0
Data3    ENDS

Data4        SEGMENT PUBLIC
Data4        ENDS

Data5        SEGMENT PUBLIC
Data5        ENDS

;----------------------- The double buffer for screen ------------------------

Canvas        SEGMENT PUBLIC
Canvas        ENDS

END           P6Main
