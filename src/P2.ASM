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

MaxPolys        EQU 6000
MaxPoints       EQU 3500

;The viewport...
ViewMinX        EQU 1
ViewMaxX        EQU 319
ViewMinY        EQU 0
ViewMaxY        EQU 199

ASSUME cs : Code1, ds : MainData

include         bwsb.inc
include         gdmtype.inc

PUBLIC          P2Main

MainData      SEGMENT PUBLIC

EXTRN           SinTabl : WORD, StartTime : DWORD, NewX : WORD, NewZ : WORD
EXTRN           LastTime : DWORD, Handle : WORD, ModHead : WORD
EXTRN           NoSound : BYTE

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

Palette         DB 0, 0, 0
                DB  48,  26,  16,  48,  26,  16,  48,  26,  16,  48,  26,  16,  48,  26,  16,  48,  26,  16,  48,  26,  16,  48,  26,  16,  48,  26,  16
                DB  47,  26,  16,  47,  26,  16,  47,  26,  16,  47,  25,  16,  47,  25,  16,  47,  25,  15,  46,  25,  15,  46,  25,  15,  46,  25,  15
                DB  46,  25,  15,  46,  25,  15,  45,  24,  15,  45,  24,  15,  45,  24,  15,  44,  24,  15,  44,  24,  15,  44,  24,  14,  44,  24,  14
                DB  43,  23,  14,  43,  23,  14,  42,  23,  14,  42,  23,  14,  42,  22,  14,  41,  22,  14,  41,  22,  13,  41,  22,  13,  40,  22,  13
                DB  40,  21,  13,  39,  21,  13,  39,  21,  13,  38,  21,  12,  38,  20,  12,  37,  20,  12,  37,  20,  12,  37,  20,  12,  36,  19,  12
                DB  36,  19,  11,  35,  19,  11,  35,  19,  11,  34,  18,  11,  34,  18,  11,  33,  18,  11,  33,  17,  10,  32,  17,  10,  32,  17,  10
                DB  31,  17,  10,  31,  16,  10,  30,  16,   9,  30,  16,   9,  29,  16,   9,  29,  15,   9,  28,  15,   9,  28,  15,   9,  27,  15,   8
                DB  27,  14,   8,  26,  14,   8,  26,  14,   8,  25,  13,   8,  25,  13,   7,  24,  13,   7,  24,  13,   7,  23,  12,   7,  23,  12,   7
                DB  22,  12,   7,  22,  12,   6,  22,  11,   6,  21,  11,   6,  21,  11,   6,  20,  11,   6,  20,  10,   6,  19,  10,   6,  19,  10,   5
                DB  18,  10,   5,  18,  10,   5,  18,   9,   5,  17,   9,   5,  17,   9,   5,  16,   9,   5,  16,   9,   4,  16,   8,   4,  15,   8,   4


                DB  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25
                DB  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  25,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24
                DB  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  24,  23,  23,  23,  23,  23,  23,  23,  23,  23,  23,  23,  23
                DB  23,  23,  23,  23,  23,  23,  23,  23,  23,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22,  22
                DB  21,  21,  21,  21,  21,  21,  21,  21,  21,  21,  21,  21,  21,  21,  21,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20,  20
                DB  20,  20,  20,  19,  19,  19,  19,  19,  19,  19,  19,  19,  19,  19,  19,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18,  18
                DB  18,  18,  18,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  17,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16,  16
                DB  16,  16,  16,  15,  15,  15,  15,  15,  15,  15,  15,  15,  15,  15,  15,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14,  14
                DB  14,  14,  14,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,  13,  12,  12,  12,  12,  12,  12,  12,  12,  12
                DB  12,  12,  12,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  11,  10,  10,  10,  10,  10,  10

                DB   0,   0,   4,   0,   0,   0,   4,   4,   4,  32,  32,  36
                DB  28,  28,  40,  32,  32,  40,  28,  28,  36,  24,  24,  36
                DB  28,  28,  32,  20,  20,  32,  24,  24,  32,  20,  20,  28
                DB  16,  16,  28,  16,  16,  20,   8,   8,   8,   4,   4,   8
                DB  24,  24,  28,  20,  20,  24,   8,   8,  12,  20,  20,  20
                DB   8,   8,  16,  12,  12,  12,  12,  12,  20,  16,  16,  24
                DB  12,  12,  16,  16,  16,  16,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
                DB   5,   5,   8,  29,  29,  38,  28,  28,  35,  17,  17,  26
                DB  16,  16,  17,  30,  30,  37,  31,  31,  40,  26,  26,  31
                DB  21,  21,  32,  14,  14,  15,  32,  32,  39,  22,  22,  25
                DB  28,  28,  33,  18,  18,  19,  20,  52,   8,  32,  52,   8
                DB  44,  52,   8,  56,  52,   8,   6,  62,   8,  18,  62,   8
                DB  30,  62,   8,  42,  62,   8,  54,  62,   8,  62,   0,  14
                DB   0,   8,  14,  62,  18,  14,   0,  28,  14,  62,  38,  14
                DB   0,  48,  14,  62,  58,  14,  12,   0,  16,  24,   0,  16

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
Ph_Col          DB 0

ObjX            DW 900
ObjY            DW 600
ObjZ            DW 1000
ObjXR           DD 850 * 256
ObjYR           DD 600 * 256
ObjZR           DD 1000 * 256
MoveX           DW -6
MoveY           DW -3
MoveZ           DW 0

MoveAng         DW 0
AngleY          DW 0
AngleYR         DD 36 * 256 * 8

SinVal2         DW 0
CosVal2         DW 0

XMax            DW 0
XMin            DW 0
YMax            DW 0
YMin            DW 0

RTime           DD 0
FadeF1          DB 0
FadeF2          DB 0
MapF            DB 0

TCounter        DW OFFSET TLimits
TLimits         DD 35000
                DW OFFSET A1                    ;Move in cow

                DD 55000
                DW OFFSET A2                    ;Move back

                DD 130000
                DW OFFSET A3                    ;Move forward

                DD 167000
                DW OFFSET A4                    ;Slow down rotation

                DD 50000000

MainData        ENDS


Code1        SEGMENT PUBLIC
.386
EXTRN           F3DTo2D : PROC, GetTimer : PROC, ViewPCX : PROC
;----------------------------------------------------------------------------
;A procedure which manages the calculating of the points.
;si = OFFSET Object
;----------------------------------------------------------------------------

;ds, gs = MainData
;es     = Data3

Rotation      PROC
                mov   ax, Data3
                mov   es, ax
                mov   ax, Data4
                mov   fs, ax
                mov   di, OFSTempCoords         ;Constant
                mov   si, 2
                mov   bp, 3112           ;Load NumOfVertexes

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 90 * 8 * 2]
                mov   CosVal2, ax

RotateLoop:

;----------- Rotating...
                pusha                           ;Save registers

;----------------------------------------------------------------------------
;Let's swing the Y-axis :
;----------------------------------------------------------------------------

                mov   ax, fs:[si + 4]                     ;Put Z-coordinate in ax
                shl   ax, 4

                imul  CosVal2                        ;Multiply Z with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si]                     ;Put X-coordinate in ax
                shl   ax, 4

                imul  SinVal2                        ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8

                sub   bx, ax                    ;Done
                mov   NewZ, bx                  ;Save NewZ

;----------------------------------------------------------------------------
;Done calculating the new Z-coordinate rotated Y_Angle degrees
;----------------------------------------------------------------------------

                mov   ax, fs:[si + 4]
                shl   ax, 4
                imul  SinVal2                        ;Multiply Z (ax) with Sinvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[si]                     ;Put X-coordinate in ax
                shl   ax, 4

                imul  CosVal2                        ;Multiply X (ax) with Cosvalue

                shrd  ax, dx, 8

                add   bx, ax
                mov   NewX, bx                  ;Save NewX

;----------------------------------------------------------------------------
;Done calculating the new X-coordinate rotated Y_Angle degrees
;----------------------------------------------------------------------------
                popa                            ;Load registers

                mov   ax, NewX                  ;Put the calculated
                mov   bx, fs:[si + 2]           ;values back in to the
                mov   cx, NewZ                  ;registers
                sar   ax, 4
                sar   cx, 4

;---------- Done rotation...

                add   ax, ObjX                  ;Add objects position
                add   bx, ObjY                  ;You may remove them if they
                add   cx, ObjZ                  ;are zero

                mov   es:[di], ax               ;Put the calculated X,
                mov   es:[di + 2], bx           ;Y
                mov   es:[di + 4], cx           ;and Z coords in Data3

                add   di, 6                     ;Point to next record
                add   si, 6
                dec   bp
                jnz   RotateLoop                ;Next coordinate

                ret
Rotation      ENDP

;ds, gs = MainData
;fs, es = Data2

StoreCl        PROC
                mov   ax, Data2
                mov   fs, ax
                mov   ax, Data4
                mov   es, ax
                mov   di, OFSCValues
                mov   bp, OFSNormalV            ;Segment Data2

                mov   bx, AngleY
                add   bx, OFFSET SinTabl
                mov   ax, [bx]
                mov   SinVal2, ax
                mov   ax, [bx + 90 * 8 * 2]
                mov   CosVal2, ax

StoreCLoop:

;-----------Rotating the normal vector...


;----------------------------------------------------------------------------
;Let's swing the Y-axis :
;----------------------------------------------------------------------------

                mov   ax, fs:[bp + 4]
                sal   ax, 3

                imul  CosVal2                   ;Multiply Y with Cosvalue

                mov   bl, ah                    ;Shift right by 8
                mov   bh, dl                    ;

                mov   ax, fs:[bp]               ;Put X-coordinate in ax
                sal   ax, 3

                imul  SinVal2                   ;Multiply X (ax) with Sinvalue

                shrd  ax, dx, 8
;                mov   al, ah                   ;Shift right by 8
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
                                                ;in segment Data2!!!

                add   bp, 6
                cmp   di, 3112 + OFSCValues     ;NumOfVertexes
                jb    StoreCLoop                ;Next coordinate
                ret
StoreCl       ENDP


;gs, ds = MainData
;es     = Data1
;fs     = Data2

StoreP        PROC
                mov   ax, MainData
                mov   gs, ax
                mov   ax, Data4
                mov   ds, ax
                mov   ax, Data1
                mov   es, ax
                mov   ax, Data3
                mov   fs, ax
;                mov   si, OFFSET PolyDefs
                mov   si, 18676                 ;Offset PolyDefs 18676
                mov   di, OFSPoly
                xor   bp, bp

StoreLoop:
                mov   gs:XMax, -32768
                mov   gs:XMin, 32767
                mov   gs:YMax, -32768
                mov   gs:YMin, 32767

                mov   al, [si]                  ;Load color
                mov   es:[di + 4], al           ;Save color

                mov   ax, di
                add   ax, 20
                mov   es:[di], ax

;----------------- Rotated normal vector, done. ----------------------------

                mov   ax, [si + 1]              ;Load first vertex
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, cx
                add   bx, 15000                 ;Make all z-values positive
                mov   es:[di + 2], bx           ;Save Z-value to sort

                mov   bx, [si + 1]              ;Load first vertex again
                mov   bl, [OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 5], dl           ;Save color
                call  F3DTo2D                   ;Project
                add   ax, 160
                add   bx, 100
                mov   es:[di + 8], ax           ;Save 2D-X
                mov   es:[di + 10], bx          ;Save 2D-Y

                cmp   ax, gs:XMax
                jle   XLower1
                mov   gs:XMax, ax
XLower1:
                cmp   ax, gs:XMin
                jge   XHigher1
                mov   gs:XMin, ax
XHigher1:
                cmp   bx, gs:YMax
                jle   YLower1
                mov   gs:YMax, bx
YLower1:
                cmp   bx, gs:YMin
                jge   YHigher1
                mov   gs:YMin, bx
YHigher1:


;Done first vertex/angle

                mov   ax, [si + 3]              ;Load second vertex
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, [si + 3]              ;Load second vertex again
                mov   bl, [OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 6], dl
                call  F3DTo2D
                add   ax, 160
                add   bx, 100
                mov   es:[di + 12], ax             ;Save 2D-X
                mov   es:[di + 14], bx             ;Save 2D-Y

                cmp   ax, gs:XMax
                jle   XLower2
                mov   gs:XMax, ax
XLower2:
                cmp   ax, gs:XMin
                jge   XHigher2
                mov   gs:XMin, ax
XHigher2:
                cmp   bx, gs:YMax
                jle   YLower2
                mov   gs:YMax, bx
YLower2:
                cmp   bx, gs:YMin
                jge   YHigher2
                mov   gs:YMin, bx
YHigher2:

;Done second vertex/angle

                mov   ax, [si + 5]              ;Load third vertex
                mov   bx, ax                    ;\
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   dx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   bx, [si + 5]              ;Load third vertex again
                mov   bl, [OFSCValues + bx]
                xchg  bx, dx
                mov   es:[di + 7], dl
                call  F3DTo2D
                add   ax, 160
                add   bx, 100
                mov   es:[di + 16], ax           ;Save 2D-X
                mov   es:[di + 18], bx           ;Save 2D-Y

                cmp   ax, gs:XMax
                jle   XLower3
                mov   gs:XMax, ax
XLower3:
                cmp   ax, gs:XMin
                jge   XHigher3
                mov   gs:XMin, ax
XHigher3:
                cmp   bx, gs:YMax
                jle   YLower3
                mov   gs:YMax, bx
YLower3:
                cmp   bx, gs:YMin
                jge   YHigher3
                mov   gs:YMin, bx
YHigher3:

                add   si, 7

;Done third vertex/angle

                cmp   gs:XMax, ViewMinX
                jl    DumpPoly
                cmp   gs:XMin, ViewMaxX
                jg    DumpPoly
                cmp   gs:YMax, ViewMinY
                jl    DumpPoly
                cmp   gs:YMin, ViewMaxY
                jg    DumpPoly

                call  Visible

                cmp   ax, 0
                jge   DumpPoly

                add   di, 20
DumpPoly:
                inc   bp
                cmp   bp, 5804                 ;NumOfFaces
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
;                mov   al, [si - 1]
;                mov   gs:Col, al
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
                mov   al, [si - 1]
                mov   gs:Ph_Col, al             ;Transfer color

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
                add   dh, Ph_Col
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
                mov   ax, Data1
                mov   ds, ax

                ret
DrawPTri      ENDP


P2Main        PROC
                call  Initialize                ;Init palette, screen etc...

                or    NoSound, 0
                jne   NoMusic
                call  StartMusic

MusicTiming:
                mov   ah, 0FFh
                call  MusicOrder
                cmp   ax, 1
                jne   MusicTiming
NoMusic:

                call   GetTimer
                mov    LastTime, eax
                mov    RTime, 0


;------------------------------ Done normals --------------------------------

PLoop:                                          ;Frameloop
                call   GetTimer
                mov    ebx, LastTime
                mov    LastTime, eax
                sub    eax, ebx
                mov    ecx, eax
                add    RTime, eax

                movzx  ebx, MoveAng
                mul    ebx

                add    AngleYR, eax
                cmp    AngleYR, 360 * 256 * 8
                jb     AngOK
                sub    AngleYR, 360 * 256 * 8
AngOK:

                mov   eax, AngleYR
                shr   eax, 8
                shl   eax, 1
                mov   AngleY, ax

                movsx eax, MoveX
                imul  ecx
                add   ObjXR, eax
                mov   eax, ObjXR
                sar   eax, 8
                mov   ObjX, ax

                movsx eax, MoveY
                imul  ecx
                add   ObjYR, eax
                mov   eax, ObjYR
                sar   eax, 8
                mov   ObjY, ax

                movsx eax, MoveZ
                imul  ecx
                add   ObjZR, eax
                mov   eax, ObjZR
                sar   eax, 8
                mov   ObjZ, ax

;-------------- Transferring background...
                mov   ax, Data5
                mov   ds, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax

                call  Rotation
                call  StoreCl
                call  StoreP
                call  SortPolys
                call  DrawPolys

;----------------------------- ACTIONS -----------------------------------
                mov   ax, Canvas                ;Remove?!?
                mov   es, ax

                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction

                jmp   WORD PTR [bx + 4]

A1:
                mov   MoveX, 0                  ;Move back and start rotation
                mov   MoveY, -1
                mov   MoveAng, 5
                mov   MoveZ, 5
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction
A2:
                mov   MoveZ, 0                  ;Stop moving
                mov   MoveY, 0
                add   TCounter, 6
                jmp   NoAction
A3:
                mov   MoveZ, -3                 ;Move forward
                mov   MoveY, 1
                mov   FadeF1, 0
                add   TCounter, 6
                jmp   NoAction
A4:
                mov   MoveZ, 0
                mov   MoveY, 0
                mov   MoveAng, 4
                mov   MapF, 1
                add   TCounter, 6
                jmp   NoAction

NoAction:


;---------------- Fading in background
                or    FadeF1, 0
                jz    NoFade1

                mov   ax, Data2
                mov   es, ax

                mov   si, OFFSET Palette + (181 * 3)
                xor   di, di

                xor   ah, ah
                mov   cx, (256 - 181) * 3
FadeL1:
                mov   al, [si]
                cmp   al, es:[di]
                je    NoF
                inc   BYTE PTR [si]
                mov   ah, 1
NoF:
                inc   si
                inc   di
                loop  FadeL1

                or    ah, ah
                jnz   MFade1
                mov   FadeF1, 0
MFade1:
                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,181                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette + (181 * 3)

                mov   cx,(256-181)*3            ;3*256 (RGB)=768 colors
                rep   outsb

NoFade1:


                or    MapF, 0
                jz    NoMapping

                mov   ecx, RTime

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax

                sub   ecx, 167000
                shr   ecx, 6
                mov   bp, 200
                sub   bp, cx
                cmp   bp, 1
                jg    MoreMap

                xor   di, di
                xor   eax, eax
                mov   cx, 16000
                rep   stosd
                mov   ax, MainData
                mov   ds, ax
                xor   al, al
                jmp   Done
MoreMap:
                xor   dx, dx
                mov   ax, 200 * 256
                div   bp

                xor   bx, bx

                push  ax

                mov   dx, cx
                shl   dx, 6
                shl   cx, 8
                add   cx, dx
                shr   cx, 2
                xor   di, di
                xor   eax, eax
                rep   stosd

                pop   ax
MLoop:
                mov   si, bx
                shr   si, 8
                mov   dx, si
                shl   dx, 6
                shl   si, 8
                add   si, dx

                mov   cx, 320/4
                rep   movsd

                add   bx, ax

                dec   bp
                jnz   MLoop

                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                jmp   DoneMove

NoMapping:

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

DoneMove:
                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break                      ;OK, go home!
                jmp   PLoop                     ;No? Let's do another roll!

Break:
                mov   al, 1
Done:

                ret
P2Main        ENDP

Initialize    PROC
                mov   ax, MainData              ;Point ds to data-segment
                mov   gs, ax
                mov   ds, ax
                mov   ax, Data2
                mov   fs, ax
                mov   ax, 0A000h
                mov   es, ax

                xor   di, di                    ;Blank screen
                xor   eax, eax
                mov   cx, 16000
                rep   stosd


;------------------ LOADING MODULE
                or      NoSound, 0
                jnz     NoMusic2

                mov     bl, 1
                mov     ax, Handle                ;File Handle to load from
                mov     ecx, 1785830              ;File offset to load from
                mov     dx, ds
                mov     di, offset ModHead
                call    LoadGDM

                mov     al, 16
                call    StartOutPut

NoMusic2:
;------------------- LOADING DATA (Loading object)

                mov   ah, 42h                   ;Move file-pointer
                mov   al, 0
                mov   bx, Handle
                mov   edx, 704462
                mov   ecx, edx
                shr   ecx, 16
                int   21h

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 59304

                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx

                int   21h

                pop   ds

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 5804 * 6

                push  ds

                mov   dx, Data2
                mov   ds, dx
                mov   dx, OFSNormalV
                int   21h

                pop   ds

;------------------ Loading background

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 13149                 ;Bytes to read
                push  ds
                mov   dx, Canvas
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, Data5
                mov   es, ax
                xor   si, si
                xor   di, di
                call  ViewPCX

                mov   ax, Data5
                mov   ds, ax
                xor   si, si
                mov   cx, 64000
FixPicture:
                add   BYTE PTR [si], 181
                inc   si
                dec   cx
                jnz   FixPicture
                mov   ax, Canvas
                mov   es, ax
                mov   ax, MainData
                mov   ds, ax

;                mov   bx, Handle
;                mov   ah, 3Eh                   ;Close file
;                int   21h

                mov   ax, Data2
                mov   es, ax
                xor   di, di
                mov   si, OFFSET Palette + (181 * 3)
                mov   cx, (256 - 181) * 3
                rep   movsb
                mov   ax, MainData
                mov   es, ax
                mov   di, OFFSET Palette + (181 * 3)
                xor   al, al
                mov   cx, (256 - 181) * 3
                rep   stosb
                mov   ax, Canvas
                mov   es, ax

                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb

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

Code1         ENDS

Data1         SEGMENT PUBLIC
;The segment for the calculated polygons and the sorting arrays.

OFSFStart       EQU 0
OFSFOfs         EQU 256 * 2
OFSPoly         EQU 1024                        ;The starting offset of the
                                                ;faces.

Data1         ENDS

Data2         SEGMENT PUBLIC
;Place for different calculated data.

OFSTempNV       EQU 0
OFSNormalV      EQU (MaxPolys * 6)

Data2         ENDS

Data3         SEGMENT PUBLIC
OFSTempCoords   EQU 0
Data3         ENDS

Data4         SEGMENT PUBLIC
OFSCValues      EQU 59304

Data4         ENDS

Data5         SEGMENT PUBLIC
Data5         ENDS

Canvas        SEGMENT PUBLIC
Canvas        ENDS

END           P2Main
