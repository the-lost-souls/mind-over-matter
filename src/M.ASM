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
EXTRN           ModFile1 : BYTE, NoSound : BYTE, Handle : WORD, FOffsets : DWORD


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
DataFile        db 'mom.tls',0

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

NoEMSErr        DB 'No EMS. Plenty EMS required.', 13, 10, '$'

CantFindFile    db "Can't find file: $"
SayLoadModule   db 'Loading Module: $'

CRLF            db 13,10,'$'

;----------------------------------------------------------------------------
Text            DB 13, 10
                DB '----------------------- The Lost Souls - Mind over Matter ---------------------', 13, 10
                DB '                          Released at the Gathering 1996', 13, 10
                DB 13, 10
                DB 'Select Soundcard :', 13, 10
                DB '        Gravis Ultrasound - 0', 13, 10
                DB '        Sound Blaster 16  - 1', 13, 10
                DB '        Sound Blaster Pro - 2', 13, 10
                DB '        Sound Blaster 2.0 - 3', 13, 10
                DB '        Nosound           - 4', 13, 10, '$'

MainData      ENDS

;----------------------------- THE FIRST CODE SEGMENT -----------------------
Code1         SEGMENT PUBLIC
.386

EXTRN         P1Main : PROC, P2Main : PROC, P3Main : PROC, P4Main : PROC, P5Main : PROC
EXTRN         P6Main : PROC, P7Main : PROC

Main          PROC
                call  MainInit

                call  P1Main
                or    al, al
                jnz   TheEnd
                call  P2Main
                or    al, al
                jnz   TheEnd
                call  P3Main
                or    al, al
                jnz   TheEnd
                call  P4Main
                or    al, al
                jnz   TheEnd
                call  P5Main
                or    al, al
                jnz   TheEnd
                call  P6Main
                or    al, al
                jnz   TheEnd
                call  P7Main
TheEnd:
                xor   al, al                    ;Stop music!
                call  ShutDown

Main          ENDP

MainInit      PROC NEAR
                mov   ax, MainData
                mov   ds, ax

                mov  ah, 4Ah                    ;Shrink program memory for more free
                mov  bx, 29000                  ;Keep a pile of memory
                int  21h

                mov     ax, 3D00h               ;Open data-file for read only
                mov     dx, OFFSET DataFile
                int     21h
                mov     Handle, ax

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
                mov   cl, al
                mov   bx, Handle
                mov   ah, 3Eh                   ;Close file
                int   21h

                pop   dx                        ;Dump ret-adress
                or    cl, cl
                jnz   MusErr

                mov   ah, 0                     ;Initialize screenmode
                mov   al, 3h                    ;80x25x16
                int   10h

                or    NoSound, 0
                jnz   MusErr

                call    StopMusic
                call    StopOutput
                call    UnloadModule
                call    StopBanner
                call    FreeMSE

MusErr:

                mov   ax, 4C00h
                int   21h                       ;And we're done... :)
ShutDown      ENDP

Music    PROC

SoundCardSelect:
                mov  dx, OFFSET Text            ;Get offset of correct error message
                mov  ah, 9                      ;Display error message
                int  21h

                mov  ah, 7
                int  21h
                cmp  al, '0'
                jne  Next1
                mov  al, 0
                jmp  SoundCardOK
Next1:
                cmp  al, '1'
                jne  Next2
                mov  al, 1
                jmp  SoundCardOK
Next2:
                cmp  al, '2'
                jne  Next3
                mov  al, 2
                jmp  SoundCardOK
Next3:
                cmp  al, '3'
                jne  Next4
                mov  al, 3
                jmp  SoundCardOK
Next4:
                cmp  al, '4'
                jne  Next5
                xor  al, al
                mov  NoSound, 1
                ret
Next5:
                cmp  al, 1Bh
                jne  SoundCardErr
                pop  ax                         ;Dump ret-adress
                mov  al, 1
                call ShutDown

SoundCardErr:
                jmp  SoundCardSelect
SoundCardOK:

                movzx bx, al
                shl  bx, 2
                add  bx, OFFSET FOffsets
                mov  edi, [bx]                  ;Set offset to load from

                mov  bx, offset DataFile        ;ds:bx - ASCIIZ filename of MSE to load

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

                call    EmsExist                ;Find out if EMS memory exists
                or      al, al
                jnz     EmsOK

                mov     dx, OFFSET NoEMSErr
                mov  ah, 9                      ;Display error message
                int  21h
                mov  al, 1                      ;Indicate error

                jmp     Exit
EmsOK:
                mov     bl, 1
                mov     ax, Handle              ;File Handle to load from
                mov     ecx, FOffsets[4*4]        ;File offset to load from
                mov     dx, ds
                mov     di, OFFSET ModHead
                call    LoadGDM

                mov     al, 12
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
                DB 0FFFFh DUP (?)
Canvas        ENDS

END           Main
