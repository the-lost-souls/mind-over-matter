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

ASSUME cs : MyCode, ds : MyData

MyData        SEGMENT

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

FileName1       DB 'MapFile3.bin',0
FileName2       DB 'RawFile2.raw',0
FileName3       DB 'MapFile4.bin',0
FileName4       DB 'RawFile3.raw',0
FileName5       DB 'Shade.bin',0
Handle          DW 0000h

Offs1           DW 0
Offs2           DW 0

MyData        ENDS

MyCode        SEGMENT
.386

Main          PROC
                call  Initialize

                mov   Offs1, 319
                mov   Offs2, 0
                cld

PLoop:
                mov   si, Picture
                mov   ds, si
                mov   si, MapSeg
                mov   fs, si
                mov   dx, Offs1

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

                sub   Offs1, 2
                cmp   Offs1, 0
                ja    MOK
                mov   Offs1, 319
MOK:

;----------------------------------- SHADOW ----------------------------------
                mov   si, Picture2
                mov   ds, si

                mov   dx, Offs2
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
                mov   si, Picture2
                mov   ds, si
                mov   si, MapSeg2
                mov   fs, si

                mov   dx, Offs2
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

                add   Offs2, 4
                cmp   Offs2, 319
                jb    MOK2
                mov   Offs2, 0
MOK2:

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

                xor   di, di                    ;Blank the canvas
                mov   cx, 16000
                xor   eax, eax
                rep   stosd


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
                mov   ds, ax
                mov   ax, Canvas                ;Set es to screen
                mov   es, ax
                mov   ax, MapSeg
                mov   fs, ax
                mov   ax, Shade
                mov   gs, ax

;Loading data...
                mov   ah, 3Dh                   ;Open file
                xor   al, al                    ;Read access
                mov   dx, OFFSET FileName1
                int   21h
                mov   Handle, ax

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                 ;Bytes to read
                push  ds
                mov   dx, MapSeg
                mov   ds, dx                    ;Store at MapSeg:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close mapfile
                int   21h

                mov   ah, 3Dh                   ;Open file
                xor   al, al                    ;Read access
                mov   dx, OFFSET FileName2
                int   21h
                mov   Handle, ax

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 65535                 ;Bytes to read
                push  ds
                mov   dx, Picture
                mov   ds, dx                    ;Store at Picture:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close mapfile
                int   21h

                mov   ah, 3Dh                   ;Open file
                xor   al, al                    ;Read access
                mov   dx, OFFSET FileName3
                int   21h
                mov   Handle, ax

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                 ;Bytes to read
                push  ds
                mov   dx, MapSeg2
                mov   ds, dx                    ;Store at MapSeg2:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close mapfile
                int   21h

                mov   ah, 3Dh                   ;Open file
                xor   al, al                    ;Read access
                mov   dx, OFFSET FileName4
                int   21h
                mov   Handle, ax

                mov   ax, Picture2
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
                mov   dx, Picture2
                mov   ds, dx                    ;Store at Picture2:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close mapfile
                int   21h

                mov   ah, 3Dh                   ;Open file
                xor   al, al                    ;Read access
                mov   dx, OFFSET FileName5
                int   21h
                mov   Handle, ax

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 32000                 ;Bytes to read
                push  ds
                mov   dx, Shade
                mov   ds, dx                    ;Store at Picture2:0000
                xor   dx, dx
                int   21h
                pop   ds

                mov   bx, Handle
                mov   ah, 3Eh                   ;Close mapfile
                int   21h

;Data loaded!

                mov   al, 13h                   ;320x200x256
                mov   ah, 00h                   ;set screenmode
                int   10h

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,1                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette

                mov   cx,200*3                  ;3*256 (RGB)=768 colors
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


MyCode        ENDS

MapSeg        SEGMENT
                DB 64000 DUP (?)
MapSeg        ENDS

MapSeg2       SEGMENT
                DB 64000 DUP (?)
MapSeg2       ENDS

Picture       SEGMENT
                DB 0FFFFh DUP (?)
Picture       ENDS

Picture2      SEGMENT
                DB 0FFFFh DUP (?)
Picture2      ENDS

Shade         SEGMENT
                DB 32000 DUP (?)
Shade         ENDS

Canvas        SEGMENT
                DB 64000 DUP (?)
Canvas        ENDS

END           Main
