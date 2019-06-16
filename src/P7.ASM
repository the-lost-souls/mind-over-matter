;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            :
;Author          :
;Last update     :
;Action          :
;
;
;Using Libraries             :
;Using external files/macros :
;
;Notes :
;
;
;----------------------------------------------------------------------------

DOSSEG
.Model  Small
.Stack  100h

ASSUME cs : Code1, ds : MainData

include        bwsb.inc
include        gdmtype.inc

PUBLIC          P7Main

MainData      SEGMENT PUBLIC

EXTRN           Handle : WORD, NoSound : BYTE

Palette         DB   0,   0,   0,  11,   0,  11,  11,   0,  11,  11,   0,  12
                DB  12,   0,  12,  12,   0,  13,  12,   0,  13,  12,   0,  14
                DB  13,   0,  14,  13,   0,  15,  13,   0,  16,  13,   0,  16
                DB  14,   0,  17,  14,   0,  17,  14,   1,  18,  14,   1,  18
                DB  14,   1,  19,  14,   1,  19,  15,   1,  20,  15,   1,  21
                DB  15,   1,  21,  15,   1,  22,  15,   1,  22,  15,   2,  23
                DB  15,   2,  23,  15,   2,  24,  15,   2,  24,  15,   3,  25
                DB  15,   3,  26,  16,   3,  26,  16,   3,  27,  15,   4,  27
                DB  16,   4,  28,  16,   4,  28,  16,   4,  29,  16,   5,  29
                DB  15,   5,  30,  16,   5,  31,  16,   6,  31,  16,   6,  32
                DB  15,   6,  32,  16,   7,  33,  15,   7,  33,  16,   7,  34
                DB  15,   8,  34,  15,   8,  35,  15,   8,  36,  15,   9,  36
                DB  15,   9,  37,  15,   9,  37,  15,  10,  38,  15,  10,  38
                DB  15,  11,  39,  15,  11,  39,  15,  11,  40,  15,  12,  40
                DB  15,  12,  41,  15,  13,  42,  15,  13,  42,  15,  13,  43
                DB  15,  14,  43,  15,  14,  44,  15,  15,  44,  15,  16,  45
                DB  16,  17,  45,  16,  18,  46,  17,  19,  47,  17,  20,  47
                DB  18,  21,  48,  18,  22,  48,  19,  23,  49,  19,  24,  49
                DB  20,  25,  50,  20,  26,  50,  21,  27,  51,  21,  28,  52
                DB  22,  29,  52,  22,  30,  53,  23,  31,  53,  24,  32,  54
                DB  24,  33,  54,  25,  34,  55,  25,  36,  55,  26,  36,  56
                DB  27,  38,  57,  27,  39,  57,  28,  40,  58,  28,  41,  58
                DB  29,  42,  59,  30,  43,  59,  30,  44,  60,  31,  45,  60
                DB  32,  46,  61,  32,  48,  62,  33,  49,  62,  34,  50,  63
                DB  34,  50,  63,  34,  50,  63,  34,  50,  63,  34,  50,  63
                DB   0,   0,   0,   4,   4,   4,  52,  52,  52,  12,  12,  12
                DB  60,  60,  60,   8,   8,   8,  56,  56,  56,  28,  28,  28
                DB  16,  16,  16,  36,  36,  36,  32,  32,  32,  20,  20,  20
                DB  40,  40,  40,  24,  24,  24,  44,  44,  44,  48,  48,  48

Pal2            DB (116*3) DUP (0)

Offs1           DW 0
Offs1R          DD 0
Offs2           DW 0
Offs2R          DD 0

RTime           DD 0
MTime           DD 0
LastTime        DD 0

FadeF1          DB 1
FadeF2          DB 0

TCounter        DW OFFSET TLimits
TLimits         DD 12000
                DW OFFSET A1

                DD 50000
                DW OFFSET A2

                DD 5000000

MainData        ENDS

Code1        SEGMENT PUBLIC
.386

EXTRN           GetTimer : PROC

P7Main          PROC
                call  Initialize

;                mov   ah, 37
;                call  MusicOrder
;                call  StartMusic

                or    NoSound, 0
                jnz   NoMusicTiming
MusicTiming:
                mov   ah, 0FFh
                call  MusicOrder
                cmp   ax, 37
                jb    MusicTiming
NoMusicTiming:

                mov   Offs1R, 319*256
                mov   Offs1, 319
                mov   Offs2R, 150*256

                call  GetTimer
                mov   LastTime, eax
                mov   RTime, 0

PLoop:

;------------- Decompressing first picture...
                push  ds
                push  es
                mov   ax, Data5
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                mov   si, 32000
                xor   di, di
                mov   cx, 32000
Decomp1:
                lodsb
                mov   ah, al
                and   al, 00001111b
                add   al, 101
                stosb
                mov   al, ah
                and   al, 11110000b
                shr   al, 4
                add   al, 101
                stosb

                dec   cx
                jnz   Decomp1

                pop   es
                pop   ds
                mov   ax, MainData
                mov   ds, ax

                call  GetTimer
                mov   ecx, LastTime
                mov   LastTime, eax
                sub   eax, ecx
                mov   MTime, eax
                add   RTime, eax

;-------------------------------- ACTIONS 1 ----------------------------------
                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction

                jmp   WORD PTR [bx + 4]

A1:
                mov   FadeF1, 0
                mov   FadeF2, 1
                add   TCounter, 6
                jmp   NoAction

A2:
                jmp   Done
                add   TCounter, 6
                jmp   NoAction

A3:
                add   TCounter, 6
                jmp   NoAction
A4:
NoAction:

                or    FadeF1, 0
                jz    NoFadeF1
                mov   eax, RTime
                shr   eax, 7

                mov   cx, 116*3
                mov   si, OFFSET Pal2
                mov   bx, OFFSET Palette
FadeL:
                mov   ah, al
                cmp   ah, [bx]
                jbe   COK
                mov   ah, [bx]
COK:
                mov   [si], ah
                inc   bx
                inc   si
                dec   cx
                jnz   FadeL

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,1                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx,116*3                  ;3*256 (RGB)=768 colors
                rep   outsb


NoFadeF1:

                or    FadeF2, 0
                jz    NoFadeF2
                mov   eax, RTime
                sub   eax, 12000
                cdq
                mov   ebx, 600
                div   ebx

                mov   cx, 116*3
                mov   si, OFFSET Pal2
                mov   bx, OFFSET Palette
FadeL2:
                mov   ah, [bx]
                sub   ah, al
                cmp   ah, 0
                jge   COK2
                mov   ah, 0
COK2:
                mov   [si], ah
                inc   bx
                inc   si
                dec   cx
                jnz   FadeL2

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,1                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx,116*3                  ;3*256 (RGB)=768 colors
                rep   outsb


NoFadeF2:

                mov   dx, Offs1
                mov   si, Data3
                mov   ds, si
                mov   si, Data1
                mov   fs, si

                xor   si, si
                xor   di, di
                xor   bx, bx

                mov   bp, 199
VertLoop:
                add   di, 160
                mov   cx, 160
HorLoop:
                mov   si, fs:[bx]
                add   bx, 2
                or    si, si
                jz    NoPix

                add   si, dx
                mov   al, [si]

                push  bx
                shr   bx, 1
                sub   al, gs:[bx]
                cmp   al, 2
                jge   NoFix
                mov   al, 2
NoFix:
                pop   bx

                mov   es:[di], al               ;Transfer pixel
NoPix:
                inc   di
                dec   cx
                jnz   HorLoop
                dec   bp
                jnz   VertLoop

                mov   ax, MainData
                mov   ds, ax

                mov   eax, MTime
                sub   Offs1R, eax
                cmp   Offs1R, 0
                jg    MOK
                mov   Offs1R, 319 * 256
MOK:
                mov   eax, Offs1R
                shr   eax, 7
                mov   Offs1, ax

;----------------------------------- SHADOW ----------------------------------
                mov   dx, Offs2

                mov   si, Data4
                mov   ds, si

                xor   si, si
                xor   di, di
                xor   bx, bx
                cld

                mov   bp, 199
VertLoop3:
                add   di, 160
                mov   cx, 160
HorLoop3:
                mov   si, fs:[bx]
                add   bx, 2
                or    si, si
                jz    NoPix3

                add   si, dx
                mov   al, [si]
                or    al, al
                jz    NoPix3
                sub   BYTE PTR es:[di], 20               ;Set pixel
                cmp   BYTE PTR es:[di], 0
                jg    NoPix3
                mov   BYTE PTR es:[di], 0
NoPix3:
                inc   di
                dec   cx
                jnz   HorLoop3
                dec   bp
                jnz   VertLoop3

;----------------------------------- TEXT ----------------------------------
                mov   ax, MainData
                mov   ds, ax
                mov   dx, Offs2

                mov   si, Data4
                mov   ds, si
                mov   si, Data2
                mov   fs, si

                xor   si, si
                xor   di, di
                xor   bx, bx
                cld

                mov   bp, 199
VertLoop2:
                add   di, 160
                mov   cx, 160
HorLoop2:
                mov   si, fs:[bx]
                add   bx, 2
                or    si, si
                jz    NoPix2

                add   si, dx
                mov   al, [si]

                or    al, al
                jz    NoPix2

                mov   es:[di], al               ;Set pixel
NoPix2:
                inc   di
                dec   cx
                jnz   HorLoop2
                dec   bp
                jnz   VertLoop2

                mov   ax, MainData
                mov   ds, ax

                mov   eax, MTime
                add   Offs2R, eax
                cmp   Offs2R, 319 * 256
                jl    MOK2
                mov   Offs2R, 0
MOK2:
                mov   eax, Offs2R
                cdq
                mov   ebx, 90
                div   ebx
                mov   Offs2, ax

                push  ds
                push  es

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd

                pop   es
                pop   ds

                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Done                      ;OK, go home!
                jmp   PLoop                     ;No? Let's do another roll!
Done:

                ret
;                call  ShutDown
P7Main          ENDP

Initialize    PROC
                mov   ax, MainData                ;Point ds to data-segment
                mov   ds, ax
                mov   ax, Canvas                ;Set es to screen
                mov   es, ax
                mov   ax, Data1
                mov   fs, ax
                mov   ax, Data5
                mov   gs, ax

;Loading data...
                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                 ;Bytes to read
                push  ds
                mov   dx, Data1
                mov   ds, dx                    ;Store at Data1:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 65535                 ;Bytes to read
                push  ds
                mov   dx, Data3
                mov   ds, dx                    ;Store at Data3:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                 ;Bytes to read
                push  ds
                mov   dx, Data2
                mov   ds, dx                    ;Store at Data2:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   ax, Data4
                mov   es, ax
                xor   di, di
                xor   al, al
                mov   cx, 0FFFFh
                rep   stosb
                mov   ax, Canvas
                mov   es, ax

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                 ;Bytes to read
                push  ds
                mov   dx, Data4
                mov   ds, dx                    ;Store at Data4:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 32000                 ;Bytes to read
                push  ds
                mov   dx, Data5
                mov   ds, dx                    ;Store at Data4:0000
                xor   dx, dx
                int   21h
                pop   ds

;Loading background

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 32000                 ;Bytes to read
                push  ds
                mov   dx, Data5
                mov   ds, dx                    ;Store at Data4:0000
                mov   dx, 32000
                int   21h
                pop   ds

;                mov   bx, Handle
;                mov   ah, 3Eh                   ;Close mapfile
;                int   21h

;Data loaded!

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,1                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Pal2

                mov   cx,116*3                  ;3*256 (RGB)=768 colors
                rep   outsb

                ret
Initialize    ENDP

Code1         ENDS

Data1         SEGMENT PUBLIC            ;Mapfile1
Data1         ENDS

Data2         SEGMENT PUBLIC            ;Mapfile2
Data2         ENDS

Data3         SEGMENT PUBLIC            ;Picture1
Data3         ENDS

Data4         SEGMENT PUBLIC            ;Picture2
Data4         ENDS

Data5         SEGMENT PUBLIC            ;Shade
Data5         ENDS

Canvas        SEGMENT PUBLIC
Canvas        ENDS

END           P7Main
