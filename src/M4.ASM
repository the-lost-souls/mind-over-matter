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

.Model  Small
.Stack  100h

ASSUME cs : Code1, ds : MainData

include        bwsb.inc
include        gdmtype.inc

;-------------------------- THE COMMON/MAIN DATASEGMENT ---------------------
MainData      SEGMENT PUBLIC
EXTRN           OldIntSeg : WORD, OldIntOffs : WORD, SinTabl : WORD, Handle : WORD
PUBLIC          Palette, BPC
;---------------------------- Data for the player ---------------------------

ModHead         GDMHeader   <?>

MSEConfigFile  struc
  SoundCard     DW      1                       ;5 = SB16, 1 = GUS
  BaseIO        DW      0FFFFh                  ;Autodetect
  IRQ           DB      0FFh
  DMA           DB      0FFh
  SoundQuality  DB      44                      ;44 khz
MSEConfigFile   ends

MSEConfig       MSEConfigFile   <?>
MSEFile         DB 'SB16.MSE', 0
;MSEFile         DB 'GUS.MSE', 0
ModFile         db 'main.GDM', '$', 0

Temp            DW 0

ErrorUnknown    db 'Unknown error',13,10,'$'

MSEErrorTable   dw offset MSE1, offset MSE2, offset MSE3, offset MSE4
                dw offset ErrorUnknown, offset MSE6, offset MSE7
                dw offset MSE8, offset MSE9, offset MSE10, offset MSE11
                dw offset MSE12

MSE1            db 'Base I/O address autodetection failure',13,10,'$'
MSE2            db 'IRQ level autodetection failure',13,10,'$'
MSE3            db 'DMA channel autodetection failure',13,10,'$'
MSE4            db 'DMA channel not supported',13,10,'$'

MSE6            db 'Sound device does not respond',13,10,'$'
MSE7            db 'Memory control blocks destroyed',13,10,'$'
MSE8            db 'Insufficient memory for mixing buffers',13,10,'$'
MSE9            db 'Insufficient memory for MSE file',13,10,'$'
MSE10           db 'MSE has invalid ID string (corrupt/non-existant)',13,10,'$'
MSE11           db 'MSE disk read failure',13,10,'$'
MSE12           db 'MVSOUND.SYS not loaded (required for PAS use)',13,10,'$'

GDMErrorTable   dw offset GDM1, offset GDM2, offset GDM3, offset GDM4
                dw offset GDM5, offset GDM6

GDM1            db 'Module is corrupt',13,10,'$'
GDM2            db 'Could not autodetect module type',13,10,'$'
GDM3            db 'Bad format ID',13,10,'$'
GDM4            db 'Out of memory',13,10,'$'
GDM5            db 'Cannot unpack samples',13,10,'$'
GDM6            db 'AdLib samples not supported',13,10,'$'


CantFindFile    db "Can't find file: $"
SayLoadModule   db 'Loading Module: $'

CRLF            db 13,10,'$'
;----------------------------------------------------------------------------

;The blue palette :

Palette         DB  63,  53,  63,  63,  53,  63,  63,  53,  61,  63,  52,  60,  63,  52,  57,  62,  51,  54,  62,  50,  50,  62,  49,  46,  62,  49,  46
                DB  61,  48,  38,  61,  47,  34,  61,  46,  29,  61,  45,  25,  60,  44,  22,  60,  43,  18,  60,  42,  15,  59,  42,  12,  59,  42,  12
                DB  59,  41,   8,  59,  40,   6,  58,  40,   5,  58,  39,   4,  58,  39,   3,  58,  39,   2,  57,  39,   2,  57,  38,   1,  57,  38,   1
                DB  57,  38,   1,  57,  38,   0,  56,  38,   0,  56,  37,   0,  56,  37,   0,  55,  37,   0,  55,  37,   0,  55,  37,   0,  55,  36,   0
                DB  54,  36,   0,  54,  36,   0,  54,  36,   0,  53,  36,   0,  53,  35,   0,  53,  35,   0,  52,  35,   0,  52,  35,   0,  52,  34,   0
                DB  51,  34,   0,  51,  34,   0,  50,  34,   0,  50,  33,   0,  50,  33,   0,  49,  33,   0,  49,  33,   0,  48,  32,   0,  48,  32,   0
                DB  48,  32,   0,  47,  31,   0,  47,  31,   0,  46,  31,   0,  46,  31,   0,  45,  30,   0,  45,  30,   0,  45,  30,   0,  44,  29,   0
                DB  44,  29,   0,  43,  29,   0,  43,  28,   0,  42,  28,   0,  42,  28,   0,  41,  27,   0,  41,  27,   0,  40,  27,   0,  40,  27,   0
                DB  39,  26,   0,  39,  26,   0,  38,  26,   0,  38,  25,   0,  37,  25,   0,  37,  24,   0,  36,  24,   0,  36,  24,   0,  35,  23,   0
                DB  35,  23,   0,  34,  23,   0,  34,  22,   0,  33,  22,   0,  33,  22,   0,  32,  21,   0,  32,  21,   0,  0,  63,   0,  0,  63,   0

;The red palette :
                DB  30,   0,  20,  30,   0,  20,  30,   0,  20,  30,   0,  20,  29,   0,  19,  29,   0,  19,  29,   0,  19,  29,   0,  19,  29,   0,  19
                DB  28,   0,  18,  27,   0,  17,  27,   0,  17,  27,   0,  17,  26,   0,  16,  26,   0,  16,  26,   0,  16,  25,   0,  15,  25,   0,  15
                DB  25,   0,  15,  25,   0,  15,  24,   0,  14,  24,   0,  14,  24,   0,  14,  24,   0,  14,  24,   0,  14,  24,   0,  14,  24,   0,  14
                DB  23,   0,  13,  23,   0,  13,  23,   0,  13,  23,   0,  13,  23,   0,  13,  23,   0,  13,  23,   0,  13,  22,   0,  12,  22,   0,  12
                DB  22,   0,  12,  22,   0,  12,  22,   0,  12,  22,   0,  12,  21,   0,  11,  21,   0,  11,  21,   0,  11,  21,   0,  11,  21,   0,  11
                DB  21,   0,  11,  20,   0,  10,  20,   0,  10,  20,   0,  10,  20,   0,  10,  20,   0,  10,  19,   0,   9,  19,   0,   9,  19,   0,   9
                DB  19,   0,   9,  19,   0,   9,  18,   0,   8,  18,   0,   8,  18,   0,   8,  18,   0,   8,  18,   0,   7,  17,   0,   7,  17,   0,   7
                DB  17,   0,   7,  17,   0,   7,  16,   0,   6,  16,   0,   6,  16,   0,   6,  16,   0,   6,  15,   0,   5,  15,   0,   5,  15,   0,   5
                DB  15,   0,   5,  14,   0,   4,  14,   0,   4,  14,   0,   4,  14,   0,   4,  13,   0,   3,  13,   0,   3,  13,   0,   3,  13,   0,   3
                DB  12,   0,   2,  12,   0,   2,  12,   0,   2,  12,   0,   2,  11,   0,   1,  11,   0,   1,  11,   0,   1,  11,   0,   1,  10,   0,   0
                DB  50 DUP (0)

FileName        DB 'Rawfile.raw',0

BPC             DW OFFSET Palette + (29*3)

;------------- PROC SetCol
R_T             DB 30
G_T             DB 10
B_T             DB 0
R_L             DW 5            *(2*2*2*2*2*2)
G_L             DW 5             *(2*2*2*2*2*2)
B_L             DW 5            *(2*2*2*2*2*2)

;------------- PROC SetPhong
AmbientR        DB 15
AmbientG        DB 0
AmbientB        DB 5
DiffuseR        DB 20
DiffuseG        DB 0
DiffuseB        DB 15
SpecR           DB 5
SpecG           DB 0
SpecB           DB 5
Shiny           DB 10
DataFile      DB 'Main.dat',0

MainData      ENDS

;----------------------------- THE FIRST CODE SEGMENT -----------------------


Code1         SEGMENT PUBLIC
.386

EXTRN         P1Main : PROC, P2Main : PROC, P3Main : PROC, P4Main : PROC, P5Main : PROC

Main          PROC
                call  MainInit

;                call  P1Main
;                call  P2Main
;                call  P3Main
                call  P4Main
                or    al, al
                jnz   TheEnd
                call  P5Main
TheEnd:
                xor   al, al                    ;Stop music!
                call  ShutDown

Main          ENDP

MainInit      PROC NEAR
                mov   ax, MainData
                mov   ds, ax

                mov  ah, 4Ah                     ;Shrink program memory for more free
                mov  bx, 28000                  ;Keep 64K of memory
                int  21h

                call  Music
;                xor   al, al
                or    al, al
                jz    NoMusicErr
                pop   ax                        ;Dump ret adress
                mov   al, 1
                call  ShutDown                  ;Halt everything
NoMusicErr:

;--------------- Initializing the timer...
                mov  al,00110100b
                out  43h,al                     ;Port number of timer control
                xor  al,al
                out  40h,al                     ;Port number of timer 0
                out  40h,al
;---------------

                mov   ah, 0                     ;Set screenmode
                mov   al, 13h                   ;320x200x256
                int   10h

;-------- Loading background...
                mov   ah, 3dh
                mov   al, 2
                mov   dx, OFFSET FileName
                int   21h
                mov   Handle, ax

                push  ds
                mov   bx, Handle
                mov   ax, Data5
                mov   ds, ax
                mov   cx, 64000
                xor   dx, dx
                mov   ah, 3Fh
                int   21h
                pop   ds

                mov   ah, 3Eh
                mov   bx, Handle
                int   21h

                mov     ax, 3D00h               ;Open data-file for read only
                mov     dx, OFFSET DataFile
                int     21h
                mov     Handle, ax

                mov   ah, 42h                   ;Move file-pointer
                mov   al, 0
                mov   bx, Handle
                mov   edx, 951059
                mov   ecx, edx
                shr   ecx, 16
                int   21h

                call  SetCol

                mov   si, OFFSET Palette + (91*3)
                call  SetPhong

                mov   si, OFFSET Palette
                mov   dx, 3C8h                  ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values

                mov   cx,180*3                  ;180 colors
                rep   outsb

;--------------- Replacing timerinterrupt
                push    es
                mov     al, 1Ch                 ;Get user timer-tick
                mov     ah, 35h
                int     21h
                mov     OldIntSeg, es           ;es:bx = user timer tick
                mov     OldIntOffs, bx
                pop     es

                push    ds
                mov     ax, Code1
                mov     ds, ax
                mov     dx, OFFSET NewTimer
                mov     al, 1Ch
                mov     ah, 25h
                int     21h                     ;ds:dx = new interrupt
                pop     ds
;-------------------

                ret
MainInit      ENDP

ShutDown      PROC NEAR
                mov   cl, al
                mov   bx, Handle
                mov   ah, 3Eh                   ;Close file
                int   21h

                pop   dx                        ;Dump ret-adress
                or    cl, cl
                jnz   MusErr

                call    StopMusic
                call    StopOutput
                call    UnloadModule
                call    StopBanner
                call    FreeMSE

                mov   ah, 0                     ;Initialize screenmode
                mov   al, 3h                    ;80x25x16
                int   10h
MusErr:

                mov   ax, 4C00h
                int   21h                       ;And we're done... :)

ShutDown      ENDP

Music    PROC
                mov  bx, offset MSEFile         ;ds:bx - ASCIIZ filename of MSE to load

                xor  edi, edi                   ;load from offset 0
                xor  eax, eax
                mov  ah, MSEConfig.SoundQuality ;Load kHz
                mov  al, 10h                    ;4096 byte mixing buffer
                mov  dx, MSEConfig.BaseIO       ;Base I/O Address of sound card
                mov  ch, MSEConfig.IRQ          ;IRQ level of sound card
                mov  cl, MSEConfig.DMA          ;DMA channel of sound card

                call LoadMSE                    ;Load the MSE file
                or   ax, ax                     ;Was there an error loading the MSE?
                jz   NoMSEError                 ;Skip over error if none

;------------------------------- Display error message -----------------------
                mov  bx, ax
                dec  bx
                shl  bx, 1                      ;Multiply by two for table
                mov  dx, [MSEErrorTable + bx]   ;Get offset of correct error message
                mov  ah, 9                      ;Display error message
                int  21h
                mov  al, 1                      ;Indicate error
                jmp  Exit                       ;Return to caller
;----------------------------------------------------------------------------

NoMSEError:
                mov  MSEConfig.BaseIO, dx       ;save autodetected information
                mov  byte ptr MSEConfig.IRQ, ch ;...
                mov  byte ptr MSEConfig.DMA, cl ;...

;--------------------------- About to load module... -------------------------

                mov     ax, 3D00h               ;Open module for read only
                mov     dx, offset ModFile
                int     21h
                jnc     NoModError

                mov     ah, 9                   ;Display error message
                mov     dx, offset CantFindFile
                int     21h

                mov     dx, offset ModFile
                int     21h
                mov     dx, offset CRLF
                int     21h

                mov     al, 1                   ;Indicate error
                jmp     Exit                    ;Return to caller
;-------
NoModError:
                mov     Temp, ax                ;save file handle

                mov     ah, 9h
                mov     dx, Offset SayLoadModule ;Display message that we're loading
                int     21h

                mov     dx, Offset ModFile
                int     21h
                mov     dx, offset CRLF
                int     21h

                call    EmsExist                ;Find out if EMS memory exists
                and     al, 1                   ;Only keep bit 0
                mov     bl, al                  ;Set load flags

                mov     ax, Temp                ;File Handle to load from
                xor     ecx, ecx                ;File offest to load from: 0
                mov     dx, ds
                mov     di, offset ModHead
                call    LoadGDM

                push    bx
                mov     ah, 3Eh                 ;Close module file handle
                mov     bx, Temp
                int     21h
                pop     bx

                or      bl, bl
                jz      NoCloseError

                movzx   bx, bl
                dec     bx
                shl     bx, 1                   ;Multiply by two for table
                mov     dx, [GDMErrorTable+bx]  ;Get offset of correct error message
                mov     ah, 9                   ;Display error message
                int     21h
                jmp     Exit                    ;Return to caller
;-------
NoCloseError:
                 mov     cx, 32
                 mov     bx, offset ModHead.PanMap
                 xor     al, al                 ;channel counter set to zero
ChanScanLoop:
                 cmp     byte ptr ds:[bx], 0FFh
                 je      @5
                 inc     al                     ;increment channel counter
@5:              inc     bx
                 dec     cx
                 jnz     ChanScanLoop

                 mov     byte ptr Temp, al
                 call    StartOutput            ;StartMusic

                 xor     al, al                 ;No error
Exit :
                ret
Music         ENDP

NewTimer      PROC
                push    ds
                push    eax
                push    dx
                push    cx
                push    si
                mov   ax, MainData
                mov   ds, ax

;--------------- Rotating palette...
                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al, 1                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, BPC

                mov   cx,32*3                  ;3*256 (RGB)=768 colors
                rep   outsb

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al, 92                     ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, OFFSET Palette + (90*3)

                mov   cx,90*3                  ;3*256 (RGB)=768 colors
                rep   outsb


                sub   BPC, 3
                cmp   BPC, OFFSET Palette
                jge   BPOK
                mov   BPC, OFFSET Palette + (29*3)
BPOK:

                pop   si
                pop   cx
                pop   dx
                pop   eax
                pop   ds
                iret
NewTimer      ENDP

SetCol        PROC
;--------
                mov   si, OFFSET Palette

                mov   al, R_T
                mov   ah, G_T
                mov   bl, B_T
                shl   al, 2
                shl   ah, 2
                shl   bl, 2
                mov   cx, R_L
                mov   di, G_L
                mov   bp, B_L

                mov   bh, 15
SetPal1:
                movzx dx, al
                add   cx, dx
                movzx dx, ah
                add   di, dx
                movzx dx, bl
                add   bp, dx

                mov   dx, cx
                shr   dx, 6
                mov   BYTE PTR [si], dl         ;Red
                mov   dx, di
                shr   dx, 6
                mov   BYTE PTR [si + 1], dl     ;Green
                mov   dx, bp
                shr   dx, 6
                mov   BYTE PTR [si + 2], dl     ;Blue

                add   si, 3
                dec   bh
                jnz   SetPal1

                mov   bh, 15
SetPal2:
                movzx dx, al
                sub   cx, dx
                movzx dx, ah
                sub   di, dx
                movzx dx, bl
                sub   bp, dx

                mov   dx, cx
                shr   dx, 6
                mov   BYTE PTR [si], dl         ;Red
                mov   dx, di
                shr   dx, 6
                mov   BYTE PTR [si + 1], dl     ;Green
                mov   dx, bp
                shr   dx, 6
                mov   BYTE PTR [si + 2], dl     ;Blue

                add   si, 3
                dec   bh
                jnz   SetPal2

                mov   bh, 15
SetPal3:
                movzx dx, al
                add   cx, dx
                movzx dx, ah
                add   di, dx
                movzx dx, bl
                add   bp, dx

                mov   dx, cx
                shr   dx, 6
                mov   BYTE PTR [si], dl         ;Red
                mov   dx, di
                shr   dx, 6
                mov   BYTE PTR [si + 1], dl     ;Green
                mov   dx, bp
                shr   dx, 6
                mov   BYTE PTR [si + 2], dl     ;Blue

                add   si, 3
                dec   bh
                jnz   SetPal3

                mov   bh, 15
SetPal4:
                movzx dx, al
                sub   cx, dx
                movzx dx, ah
                sub   di, dx
                movzx dx, bl
                sub   bp, dx

                mov   dx, cx
                shr   dx, 6
                mov   BYTE PTR [si], dl         ;Red
                mov   dx, di
                shr   dx, 6
                mov   BYTE PTR [si + 1], dl     ;Green
                mov   dx, bp
                shr   dx, 6
                mov   BYTE PTR [si + 2], dl     ;Blue

                add   si, 3
                dec   bh
                jnz   SetPal4

;------------
                ret
SetCol        ENDP

SetPhong      PROC
                xor   bp, bp
PhCL:
                mov   bx, bp
                shl   bx, 4                     ;8*2 = 16
                mov   ax, [OFFSET SinTabl + (90*8*2) + bx]
                mov   bx, ax                    ;bx = Cos(Angle)

                movzx cx, Shiny
                cwd                             ;ax -> ax:dx
ShinyL:
                imul  bx
                shrd  ax, dx, 8
                loop  ShinyL
                mov   di, ax                    ;di = cos(Angle)^Shiny * 256

;----- Red
                movzx ax, DiffuseR
                imul  bx                        ;DiffuseR * Cos(Angle)
                shrd  ax, dx, 8
                mov   cx, ax                    ;cx = Diffuse-part
                movzx ax, SpecR
                imul  di                        ;SpecR * cos(Angle)^Shiny
                shr   ax, 8                     ;/256
                add   ax, cx
                add   al, AmbientR
                mov   [si], al

;----- Green
                movzx ax, DiffuseG
                imul  bx                        ;DiffuseG * Cos(Angle)
                shrd  ax, dx, 8
                mov   cx, ax                    ;cx = Diffuse-part
                movzx ax, SpecG
                imul  di                        ;SpecG * cos(Angle)^Shiny
                shr   ax, 8                     ;/256
                add   ax, cx
                add   al, AmbientG
                mov   [si + 1], al

;----- Blue
                movzx ax, DiffuseB
                imul  bx                        ;DiffuseB * Cos(Angle)
                shrd  ax, dx, 8
                mov   cx, ax                    ;cx = Diffuse-part
                movzx ax, SpecB
                imul  di                        ;SpecB * cos(Angle)^Shiny
                shr   ax, 8                     ;/256
                add   ax, cx
                add   al, AmbientB
                mov   [si + 2], al

                add   si, 3
                inc   bp
                cmp   bp, 90
                jb    PhCL

                ret
SetPhong      ENDP

Code1         ENDS

;---------------------------- ALLROUND-SEGMENT  NR. 1 ----------------------
Data1         SEGMENT PUBLIC
                DB 0FFFFh DUP (?)
Data1         ENDS

;---------------------------- ALLROUND-SEGMENT  NR. 2 ----------------------
Data2         SEGMENT PUBLIC
                DB 0FFFFh DUP (?)
Data2         ENDS

;---------------------------- ALLROUND-SEGMENT  NR. 3 ----------------------
Data3         SEGMENT PUBLIC
                DB 0FFFFh DUP (?)
Data3         ENDS

;---------------------------- ALLROUND-SEGMENT  NR. 4 ----------------------
Data4         SEGMENT PUBLIC
                DB 0FFFFh DUP (?)
Data4         ENDS

;---------------------------- ALLROUND-SEGMENT  NR. 5 ----------------------
Data5         SEGMENT PUBLIC
                DB 0FFFFh DUP (?)
Data5         ENDS

;----------------------------------- CANVAS --------------------------------
Canvas        SEGMENT PUBLIC
                DB 64000 DUP (?)
Canvas        ENDS

END           Main
