;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            : P4.ASM
;Author          : Cyberfish of The Lost Souls
;Last update     : 28.02.1996
;Action          : MOM - Part four
;
;
;Using Libraries             :
;Using external files/macros :
;
;----------------------------------------------------------------------------

;.Model  Small
;.Stack  100h

MaxPolys        EQU 6000
MaxPoints       EQU 3500

;The viewport...
ViewMinX        EQU 1
ViewMaxX        EQU 319
ViewMinY        EQU 0
ViewMaxY        EQU 199

ASSUME cs : Code1, ds : MainData

include        bwsb.inc
include        gdmtype.inc

PUBLIC          P4Main

MainData      SEGMENT PUBLIC
EXTRN           SinTabl : WORD, Palette : BYTE, OldIntSeg : WORD, Handle : WORD
EXTRN           OldIntOffs : WORD, LastTime : DWORD, StartTime : DWORD
EXTRN           AmbientR : BYTE, AmbientG : BYTE, AmbientB : BYTE, DiffuseR : BYTE, DiffuseG : BYTE, DiffuseB : BYTE
EXTRN           SpecR : BYTE, SpecG : BYTE, SpecB : BYTE, Shiny : BYTE
EXTRN           R_T : BYTE, G_T : BYTE, B_T : BYTE, R_L : BYTE, G_L : BYTE, B_L : BYTE
EXTRN           BPC : WORD, NoSound : BYTE

ACos            DB   1 ,  2 ,  3 ,  5 ,  6 ,  8 ,  9 , 11 , 13
                DB  14 , 16 , 17 , 19 , 20 , 22 , 23 , 25 , 26
                DB  28 , 29 , 31 , 32 , 34 , 35 , 37 , 38 , 39
                DB  41 , 42 , 44 , 45 , 46 , 48 , 49 , 50 , 52
                DB  53 , 54 , 55 , 57 , 58 , 59 , 60 , 61 , 63
                DB  64 , 65 , 66 , 67 , 68 , 69 , 70 , 71 , 72
                DB  73 , 74 , 75 , 75 , 76 , 77 , 78 , 79 , 79
                DB  80 , 81 , 82 , 82 , 83 , 83 , 84 , 85 , 85
                DB  86 , 86 , 87 , 87 , 87 , 88 , 88 , 88 , 89
                DB  89 , 89 , 89 , 89 , 89 , 89 , 89 , 89 , 89
                DB  92, 92, 92

                DB  92 , 92 , 93 , 94, 96 , 98 , 99 ,101 ,103
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

;----------------------------------------------------------------------------
;The sinus table for angles in 1 - 360 degrees. All values are multiplied
;by 256 to save decimals.
;----------------------------------------------------------------------------



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
ObjZ            DW 0
ObjXR           DD 0
ObjYR           DD 0
ObjZR           DD 8000 * 256
OMoveX          DW 0
OMoveY          DW 0
OMoveZ          DW -100
AngleX          DW 0
AngleY          DW 0
AngleZ          DW 0
AngleXR         DD 0
AngleYR         DD 0
AngleZR         DD 0
MoveX           DW 80
MoveY           DW 30
MoveZ           DW 20

RTime           DD 0
MTime           DD 0

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

;----------- Colors to fade phongpalette to
NAmbientR       DB 0
NAmbientG       DB 0
NAmbientB       DB 0
NDiffuseR       DB 0
NDiffuseG       DB 0
NDiffuseB       DB 0
NSpecR          DB 0
NSpecG          DB 0
NSpecB          DB 0
NShiny          DB 0

RAm             DW 0
GAm             DW 0
BAm             DW 0
RDi             DW 0
GDi             DW 0
BDi             DW 0
RSp             DW 0
GSp             DW 0
BSp             DW 0
Sh              DW 0

FadeF1          DB 0
CZeroF          DB 0
EndF            DB 0
WobblyF         DB 0
DiscoF          DB 0
DiscoC1         DD 25100
DiscoC2         DW 0

LR              DB 4*200 DUP (160)
Remove          DW 0
RemoveR         DD 0
M               DW 0
MR              DD 0

TCounter        DW OFFSET TLimits
TLimits         DD 6000
                DW OFFSET A1

                DD 25100                        ;Stop blob
                DW OFFSET A2

                DD 30000
                DW OFFSET A3

                DD 50000
                DW OFFSET A4

                DD 70000
                DW OFFSET A5

                DD 78000
                DW OFFSET A6

                DD 82000
                DW OFFSET A7

                DD 90000
                DW OFFSET A8

                DD 100000
                DW OFFSET A9

                DD 130000
                DW OFFSET A10

                DD 160000
;                DD 400000
                DW OFFSET A11

                DD 50000000


MainData        ENDS

Code1         SEGMENT PUBLIC
.386
EXTRN           GetTimer : PROC, SetPhong : PROC, F3DTo2D : PROC, SetCol : PROC

;----------------------------------------------------------------------------
;A procedure which manages the calculating of the points.
;si = OFFSET Object
;----------------------------------------------------------------------------

;ds, gs = MainData
;es     = Data3
;

Rotation      PROC
                mov   ax, Data3
                mov   es, ax
                mov   ax, Data4
                mov   gs, ax
                mov   di, OFSTempCoords         ;Constant
;                mov   si, OFFSET Coords         ;Real offset
                mov   si, 2
                mov   bp, 514           ;Load NumOfVertexes

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
                cmp   di, 514
                jb    StoreCLoop                ;Next coordinate
                ret
StoreCl       ENDP


;gs, ds = MainData
;es     = Data1
;fs     = Data2

StoreP        PROC
                mov   ax, Data4
                mov   gs, ax
                mov   ax, Data1
                mov   es, ax
                mov   ax, Data3
                mov   fs, ax
;                mov   si, OFFSET PolyDefs
                mov   si, 2 + (514*6) + 2
                mov   di, OFSPoly
                xor   bp, bp

StoreLoop:
                mov   XMax, -32768
                mov   XMin, 32767
                mov   YMax, -32768
                mov   YMin, 32767

                mov   BYTE PTR es:[di + 4], 90           ;Save color

                mov   ax, di
                add   ax, 20
                mov   es:[di], ax

;----------------- Rotated normal vector, done. ----------------------------

                mov   ax, gs:[si]                  ;Load first vertex
                mov   bx, ax                    ;\
                mov   cl, es:[bx]
                mov   es:[di + 5], cl
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   bx, fs:[OFSTempCoords + bx + 2]         ;Load Y

                mov   dx, cx
                add   dx, 15000                 ;Make all z-values positive
                mov   es:[di + 2], dx           ;Save Z-value to sort

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

                mov   ax, gs:[si + 2]              ;Load second vertex
                mov   bx, ax                    ;\
                mov   cl, es:[bx]
                mov   es:[di + 6], cl
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   bx, fs:[OFSTempCoords + bx + 2]         ;Load Y

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

                mov   ax, gs:[si + 4]              ;Load third vertex
                mov   bx, ax                    ;\
                mov   cl, es:[bx]
                mov   es:[di + 7], cl
                shl   bx, 2                     ;Mul by 6
                shl   ax, 1                     ;/
                add   bx, ax                    ;/
                mov   ax, fs:[OFSTempCoords + bx]             ;Load X
                mov   cx, fs:[OFSTempCoords + bx + 4]         ;Load Z
                mov   bx, fs:[OFSTempCoords + bx + 2]         ;Load Y

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
                cmp   bp, 1024                 ;NumOfFaces
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

;-------------------------------- _Main loop ----------------------------------

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

                push  bp
                push  eax
                shl   bp, 2
                add   bp, OFFSET LR

                mov   eax, ecx
                sar   eax, 8
                cmp   ax, ds:[bp]
                jg    NoLeft1
                mov   ds:[bp], ax
NoLeft1:
                cmp   ax, ds:[bp + 2]
                jl    NoRight1
                mov   ds:[bp + 2], ax
NoRight1:
                mov   eax, edx
                sar   eax, 8
                cmp   ax, ds:[bp]
                jg    NoLeft2
                mov   ds:[bp], ax
NoLeft2:
                cmp   ax, ds:[bp + 2]
                jl    NoRight2
                mov   ds:[bp + 2], ax
NoRight2:

                pop   eax
                pop   bp


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
                mov   ax, Data1
                mov   ds, ax

                ret
DrawPTri      ENDP

P4Main          PROC
                call  Initialize                ;Init palette, screen etc...

;                mov   ah, 17
;                call  MusicOrder
;                call  StartOutPut
;                call  StartMusic

                or    NoSound, 0
                jnz   DoneTiming
MusicTiming2:
                mov   ah, 0FFh
                call  MusicOrder
                cmp   ax, 17
                jb    MusicTiming2
                call  MusicRow
                cmp   ax, 56
                jb    MusicTiming2
DoneTiming:

                call  GetTimer
                mov   LastTime, eax
                mov   RTime, 0

;------------------------------ Done normals --------------------------------

PLoop:                                          ;Frameloop
                call  GetTimer
                mov   ecx, LastTime
                mov   LastTime, eax
                sub   eax, ecx
                mov   MTime, eax
                add   RTime, eax

                mov   si, OFFSET LR
                mov   cx, 200
LRLoop:
                mov   WORD PTR [si], 320
                mov   WORD PTR [si + 2], 0
                add   si, 4
                loop  LRLoop

                or    WobblyF, 0
                jz    NoWobbly

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

                movsx eax, OMoveX
                imul  MTime
                add   ObjXR, eax
                mov   eax, ObjXR
                sar   eax, 8
                mov   ObjX, ax

                movsx eax, OMoveY
                imul  MTime
                add   ObjYR, eax
                mov   eax, ObjYR
                sar   eax, 8
                mov   ObjY, ax

                movsx eax, OMoveZ
                imul  MTime
                add   ObjZR, eax
                mov   eax, ObjZR
                sar   eax, 8
                mov   ObjZ, ax

                xor   eax, eax
                xor   di, di
                mov   cx, 16000
                rep   stosd

                mov   ax, MainData
                mov   ds, ax

                call  Rotation
                call  StoreCl
                call  StoreP
                call  SortPolys
                call  DrawPolys

NoWobbly:
                mov   ax, MainData
                mov   ds, ax

                mov   si, OFFSET LR + (100*4)
                mov   cx, 101
LRFix:
                cmp   WORD PTR [si], 320
                jne   LOK
                mov   ax, [si + 4]
                add   ax, [si + 6]
                shr   ax, 1
                mov   WORD PTR [si], ax
                mov   WORD PTR [si + 2],ax
LOK:
                mov   ax, Remove
                mov   bx, WORD PTR [si + 2]
                add   WORD PTR [si], ax
                cmp   WORD PTR [si], bx
                jl    OK1
                mov   WORD PTR [si], bx
OK1:
                mov   bx, WORD PTR [si]
                sub   WORD PTR [si + 2], ax
                cmp   WORD PTR [si + 2], bx
                jg    OK2
                mov   WORD PTR [si + 2], bx
OK2:
                sub   si, 4
                loop  LRFix

                mov   si, OFFSET LR + (101*4)
                mov   cx, 99
LRFix2:
                cmp   WORD PTR [si], 320
                jne   LOK2
                mov   ax, [si - 4]
                add   ax, [si - 2]
                shr   ax, 1
                mov   WORD PTR [si], ax
                mov   WORD PTR [si + 2], ax
LOK2:
                mov   ax, Remove
                mov   bx, WORD PTR [si + 2]
                add   WORD PTR [si], ax
                cmp   WORD PTR [si], bx
                jl    OK3
                mov   WORD PTR [si], bx
OK3:
                mov   bx, WORD PTR [si]
                sub   WORD PTR [si + 2], ax
                cmp   WORD PTR [si + 2], bx
                jg    OK4
                mov   WORD PTR [si + 2], bx
OK4:

                add   si, 4
                loop  LRFix2

                mov   ax, MainData
                mov   gs, ax
                mov   ax, Data5
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                mov   bp, OFFSET LR
                xor   si, si
                xor   dx, dx
TL:
                xor   ax, ax
                mov   bx, gs:[bp]
                push  dx
                push  si

                call  MapLine

                pop   si
                pop   dx
                add   si, 160
                mov   ax, gs:[bp + 2]
                mov   bx, 320
                push  dx
                push  si

                call  MapLine

                pop   si
                pop   dx

                add   si, 160
                add   bp, 4

                inc   dx
                cmp   dx, 200
                jb    TL

                or    gs:EndF, 0
                jz    NoEnd

                mov   ax, 0A000h
                mov   es, ax
                mov   ax, Canvas
                mov   ds, ax
                mov   bx, 320
                sub   bx, gs:M
                xor   eax, eax
                xor   si, si
                xor   di, di
                mov   bp, 100
MYL:
                mov   cx, bx
                shr   cx, 2
                add   si, gs:M
                rep   movsd
                mov   cx, gs:M
                shr   cx, 2
                rep   stosd
                mov   cx, gs:M
                shr   cx, 2
                rep   stosd
                mov   cx, bx
                shr   cx, 2
                rep   movsd
                add   si, gs:M

                dec   bp
                jnz   MYL

                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   eax, MTime
                add   MR, eax
                mov   eax, MR
                shr   eax, 7
                shl   ax, 2
                mov   M, ax
                cmp   M, 320
                jb    DoneMove
                mov   M, 320
                xor   al, al
                jmp   Done
NoEnd:

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
;-------------------------------- ACTIONS ----------------------------------
                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction

                jmp   WORD PTR [bx + 4]

A1:
                mov   WobblyF, 1
                add   TCounter, 6
                jmp   NoAction

A2:
                mov   OMoveZ, 0                 ;Stop it!
                mov   DiscoF, 1
                add   TCounter, 6
                jmp   NoAction
A3:
                mov   NAmbientR, 0
                mov   NAmbientG, 0
                mov   NAmbientB, 10
                mov   NDiffuseR, 0
                mov   NDiffuseG, 0
                mov   NDiffuseB, 20
                mov   NSpecR, 0
                mov   NSpecG, 0
                mov   NSpecB, 0
                mov   NShiny, 50

                mov   CZeroF, 1
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction

A4:
                mov   NAmbientR, 0
                mov   NAmbientG, 0
                mov   NAmbientB, 10
                mov   NDiffuseR, 0
                mov   NDiffuseG, 20
                mov   NDiffuseB, 20
                mov   NSpecR, 0
                mov   NSpecG, 0
                mov   NSpecB, 0
                mov   NShiny, 5

                mov   CZeroF, 1
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction
A5:
                mov   NAmbientR, 10
                mov   NAmbientG, 0
                mov   NAmbientB, 10
                mov   NDiffuseR, 20
                mov   NDiffuseG, 0
                mov   NDiffuseB, 20
                mov   NSpecR, 20
                mov   NSpecG, 0
                mov   NSpecB, 0
                mov   NShiny, 1

                mov   CZeroF, 1
                mov   FadeF1, 1

                add   TCounter, 6
                jmp   NoAction

A6:
;                mov   DiscoF, 0
;                mov   DiscoC2, 0
                add   TCounter, 6
                jmp   NoAction
A7:
;                mov   DiscoF, 1
                add   TCounter, 6
                jmp   NoAction

A8:
                mov   NAmbientR, 0
                mov   NAmbientG, 0
                mov   NAmbientB, 0
                mov   NDiffuseR, 15
                mov   NDiffuseG, 15
                mov   NDiffuseB, 15
                mov   NSpecR, 0
                mov   NSpecG, 0
                mov   NSpecB, 0
                mov   NShiny, 20

                mov   CZeroF, 1
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction
A9:
                mov   NAmbientR, 15
                mov   NAmbientG, 10
                mov   NAmbientB, 10
                mov   NDiffuseR, 30
                mov   NDiffuseG, 20
                mov   NDiffuseB, 10
                mov   NSpecR, 15
                mov   NSpecG, 10
                mov   NSpecB, 5
                mov   NShiny, 5

                mov   CZeroF, 1
                mov   FadeF1, 1

                add   TCounter, 6
                jmp   NoAction
A10:
                mov   EndF, 1
                mov   CZeroF, 0
                add   TCounter, 6
                jmp   NoAction
A11:
                jmp   Done
                jmp   NoAction

NoAction:

                or    DiscoF, 0
                jz    NoDisco

                mov   R_L, 0
                mov   G_L, 0
                mov   B_L, 0
                mov   R_T, 25
                mov   G_T, 0
                mov   B_T, 5
                call  SetCol

                or    NoSound, 0
                jz    MusicTiming

                mov   eax, RTime
                cmp   eax, DiscoC1
                jb    NoDisco

Disco:
                add   DiscoC1, 1740
                add   DiscoC2, 4
                cmp   DiscoC2, 64
                jb    DiscoOK
                mov   DiscoC2, 0
DiscoOK:
                mov   R_T, 50
                mov   G_T, 0
                mov   B_T, 0
                call  SetCol

;--------------- Flashing palette...
                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, BPC

                mov   cx,32*3                  ;3*256 (RGB)=768 colors
                rep   outsb
                jmp   NoDisco

MusicTiming:
                call  MusicRow
                cmp   DiscoC2, 0
                jne   RowOK
                cmp   ax, 60
                jb    RowOK
                sub   ax, 64
RowOK:
                cmp   ax, DiscoC2
                jge   Disco

NoDisco:

                or    CZeroF, 0
                jz    NoCZero

                xor   ax, ax
                mov   ah, AmbientR
                mov   RAm, ax
                mov   ah, AmbientG
                mov   GAm, ax
                mov   ah, AmbientB
                mov   BAm, ax
                mov   ah, DiffuseR
                mov   RDi, ax
                mov   ah, DiffuseG
                mov   GDi, ax
                mov   ah, DiffuseB
                mov   BDi, ax
                mov   ah, SpecR
                mov   RSp, ax
                mov   ah, SpecG
                mov   GSp, ax
                mov   ah, SpecB
                mov   BSp, ax
                mov   ah, Shiny
                mov   Sh, ax

                mov   CZeroF, 0
NoCZero:

;--------------- Fading phongpalette
                or    FadeF1, 0
                jz    NoPhFade

                xor   ax, ax
                mov   ebx, MTime
                shr   ebx, 1

;---------------- The ambient colors
                mov   ah, NAmbientR             ;Load color to fade to
                cmp   AmbientR, ah
                je    DoneAR                    ;If equal then done
                jg    ARDec                     ;If greater, then decrease
                add   RAm, bx                   ;Add timerelative counter
                cmp   RAm, ax
                jl    DoneAR
                mov   RAm, ax
                jmp   DoneAR
ARDec:
                sub   RAm, bx
                cmp   RAm, ax
                jg    DoneAR
                mov   RAm, ax
DoneAR:

                mov   ah, NAmbientG             ;Load color to fade to
                cmp   AmbientG, ah
                je    DoneAG                    ;If equal then done
                jg    AGDec                     ;If greater, then decrease
                add   GAm, bx                   ;Add timerelative counter
                cmp   GAm, ax
                jl    DoneAG
                mov   GAm, ax
                jmp   DoneAG
AGDec:
                sub   GAm, bx
                cmp   GAm, ax
                jg    DoneAG
                mov   GAm, ax
DoneAG:

                mov   ah, NAmbientB             ;Load color to fade to
                cmp   AmbientB, ah
                je    DoneAB                    ;If equal then done
                jg    ABDec                     ;If greater, then decrease
                add   BAm, bx                   ;Add timerelative counter
                cmp   BAm, ax
                jl    DoneAB
                mov   BAm, ax
                jmp   DoneAB
ABDec:
                sub   BAm, bx
                cmp   BAm, ax
                jg    DoneAB
                mov   BAm, ax
DoneAB:

;---------------- The diffuse colors
                mov   ah, NDiffuseR             ;Load color to fade to
                cmp   DiffuseR, ah
                je    DoneDR                    ;If equal then done
                jg    DRDec                     ;If greater, then decrease
                add   RDi, bx                   ;Add timerelative counter
                cmp   RDi, ax
                jl    DoneDR
                mov   RDi, ax
                jmp   DoneDR
DRDec:
                sub   RDi, bx
                cmp   RDi, ax
                jg    DoneDR
                mov   RDi, ax
DoneDR:

                mov   ah, NDiffuseG             ;Load color to fade to
                cmp   DiffuseG, ah
                je    DoneDG                    ;If equal then done
                jg    DGDec                     ;If greater, then decrease
                add   GDi, bx                   ;Add timerelative counter
                cmp   GDi, ax
                jl    DoneDG
                mov   GDi, ax
                jmp   DoneDG
DGDec:
                sub   GDi, bx
                cmp   GDi, ax
                jg    DoneDG
                mov   GDi, ax
DoneDG:

                mov   ah, NDiffuseB             ;Load color to fade to
                cmp   DiffuseB, ah
                je    DoneDB                    ;If equal then done
                jg    DBDec                     ;If greater, then decrease
                add   BDi, bx                   ;Add timerelative counter
                cmp   BDi, ax
                jl    DoneDB
                mov   BDi, ax
                jmp   DoneDB
DBDec:
                sub   BDi, bx
                cmp   BDi, ax
                jg    DoneDB
                mov   BDi, ax
DoneDB:

;---------------- The specular colors
                mov   ah, NSpecR             ;Load color to fade to
                cmp   SpecR, ah
                je    DoneSR                    ;If equal then done
                jg    SRDec                     ;If greater, then decrease
                add   RSp, bx                   ;Add timerelative counter
                cmp   RSp, ax
                jl    DoneSR
                mov   RSp, ax
                jmp   DoneSR
SRDec:
                sub   RSp, bx
                cmp   RSp, ax
                jg    DoneSR
                mov   RSp, ax
DoneSR:

                mov   ah, NSpecG             ;Load color to fade to
                cmp   SpecG, ah
                je    DoneSG                    ;If equal then done
                jg    GRDec                     ;If greater, then decrease
                add   GSp, bx                   ;Add timerelative counter
                cmp   GSp, ax
                jl    DoneSG
                mov   GSp, ax
                jmp   DoneSG
GRDec:
                sub   GSp, bx
                cmp   GSp, ax
                jg    DoneSG
                mov   GSp, ax
DoneSG:

                mov   ah, NSpecB             ;Load color to fade to
                cmp   SpecB, ah
                je    DoneSB                    ;If equal then done
                jg    SBDec                     ;If greater, then decrease
                add   BSp, bx                   ;Add timerelative counter
                cmp   BSp, ax
                jl    DoneSB
                mov   BSp, ax
                jmp   DoneSB
SBDec:
                sub   BSp, bx
                cmp   BSp, ax
                jg    DoneSB
                mov   BSp, ax
DoneSB:

;------- Shiny
                mov   ah, NShiny             ;Load color to fade to
                cmp   Shiny, ah
                je    DoneSh                    ;If equal then done
                jg    ShDec                     ;If greater, then decrease
                add   Sh, bx                   ;Add timerelative counter
                cmp   Sh, ax
                jl    DoneSh
                mov   Sh, ax
                jmp   DoneSh
ShDec:
                sub   Sh, bx
                cmp   Sh, ax
                jg    DoneSh
                mov   Sh, ax
DoneSh:

                mov   ax, RAm
                mov   AmbientR, ah
                mov   ax, GAm
                mov   AmbientG, ah
                mov   ax, BAm
                mov   AmbientB, ah
                mov   ax, RDi
                mov   DiffuseR, ah
                mov   ax, GDi
                mov   DiffuseG, ah
                mov   ax, BDi
                mov   DiffuseB, ah
                mov   ax, RSp
                mov   SpecR, ah
                mov   ax, GSp
                mov   SpecG, ah
                mov   ax, BSp
                mov   SpecB, ah
                mov   ax, Sh
                mov   Shiny, ah

                mov   si, OFFSET Palette + (90*3)
                call  SetPhong

NoPhFade:

                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break                     ;OK, go home!
                jmp   PLoop                     ;No? Let's do another roll!
Break:
                mov   al, 1
Done:
                push  ax
                mov   ax, 0A000h
                mov   es, ax
                xor   di, di
                xor   eax, eax
                mov   cx, 16000
                rep   stosd

;--------------- Restoring timerinterrupt
                push  ds
                mov   dx, OldIntOffs
                mov   ds, OldIntSeg
                mov   al, 1Ch
                mov   ah, 25h
                int   21h
                pop   ds
                pop   ax

                ret
P4Main        ENDP

Initialize    PROC
                mov   ax, MainData                ;Point ds to data-segment
                mov   gs, ax
                mov   ds, ax
                mov   ax, Data2
                mov   fs, ax
                mov   ax, Canvas                ;Set es to canvas
                mov   es, ax

;----------------- Loading object...

                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 9232
                xor   dx, dx
                push  ds
                mov   bp, Data4
                mov   ds, bp
                int   21h
                pop   ds

;----------------- Loading normalvectors...
                mov   ah, 3Fh
                mov   bx, Handle
                mov   cx, 6144
                mov   dx, OFSNormalV
                push  ds
                mov   bp, Data2
                mov   ds, bp
                int   21h
                pop   ds

                mov   si, OFFSET Palette + (90*3)
                mov   AmbientR, 10
                mov   AmbientG, 0
                mov   AmbientB, 0
                mov   DiffuseR, 20
                mov   DiffuseG, 0
                mov   DiffuseB, 0
                mov   SpecR, 20
                mov   SpecG, 0
                mov   SpecB, 0
                mov   Shiny, 5
                call  SetPhong

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,91                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette + (90*3)

                mov   cx,90*3                  ;3*256 (RGB)=768 colors
                rep   outsb

                xor   di, di                    ;Blank the canvas
                mov   cx, 16000
                xor   eax, eax
                rep   stosd

                ret
Initialize    ENDP

;ax = LeftX (start of line)
;bx = RightX
;[si] = Line to map
;dx = Y
;Length of mapline is assumed to be 160

MapLine       PROC
                mov   cx, bx
                sub   cx, ax                    ;cx = length

                mov   di, dx
                shl   di, 6
                shl   dx, 8
                add   di, dx
                add   di, ax                    ;[di] = where to put pixels

                xor   dx, dx
                mov   ax, 160 * 256
                div   cx

                movzx edx, ax                   ;ax -> eax
                movzx ebx, si                   ;si -> ebx
                shl   ebx, 8

;                mov   cx, 160
MLLoop:
                mov   esi, ebx
                shr   esi, 8
                mov   al, [si]
                stosb
                add   ebx, edx
                dec   cx
                jnz   MLLoop

                ret
MapLine       ENDP

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

Data2         ENDS

Data3         SEGMENT PUBLIC
OFSTempCoords   EQU 0
Data3         ENDS

Data4         SEGMENT PUBLIC
Data4         ENDS

Data5         SEGMENT PUBLIC
Data5         ENDS

;----------------------- The double buffer for screen ------------------------

Canvas        SEGMENT PUBLIC
Canvas        ENDS

END           P4Main
