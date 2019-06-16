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
EXTRN           Handle : WORD
;---------------------------- Data for the player ---------------------------

ModHead         GDMHeader   <?>

MSEConfigFile  struc
  SoundCard     DW      5                       ;5 = SB16, 1 = GUS
  BaseIO        DW      0FFFFh                  ;Autodetect
  IRQ           DB      0FFh
  DMA           DB      0FFh
  SoundQuality  DB      44                      ;44 khz
MSEConfigFile   ends

MSEConfig       MSEConfigFile   <?>
MSEFile         DB 'SB16.MSE', 0
;MSEFile         DB 'GUS.MSE', 0
ModFile         db 'start.GDM', '$', 0

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

MainData      ENDS

;----------------------------- THE FIRST CODE SEGMENT -----------------------
Code1         SEGMENT PUBLIC
.386

EXTRN         P1Main : PROC

Main          PROC
                call  MainInit

                call  P1Main

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

                ret
MainInit      ENDP

ShutDown      PROC NEAR
                mov   bx, Handle
                mov   ah, 3Eh                   ;Close mapfile
                int   21h

                pop   dx                        ;Dump ret-adress
                or    al, al
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
