;----------------------------- ASSEMBLER SOURCE -----------------------------
;Name            : P1.ASM
;Author          : Cyberfish of The Lost Souls
;Last update     :
;Action          : MOM - First part
;
;
;Using Libraries             :
;Using external files/macros :
;
;Notes :
;
;
;----------------------------------------------------------------------------

ASSUME cs : Code1, ds : MainData

include        bwsb.inc
include        gdmtype.inc

PUBLIC          P1Main

MainData      SEGMENT PUBLIC

EXTRN           Pal : BYTE, Font : BYTE, StartTime : DWORD, LastTime : DWORD
EXTRN           Handle : WORD, NoSound : BYTE, FOffsets : DWORD

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

C1              DW 0                            ;Div variables for sines...
C2              DW 180
C3              DW 0
C4              DW 270

;--------------- Input-variables to set the palette
RUL             DB 0
GUL             DB 0
BUL             DB 0

RLL             DB 0
GLL             DB 0
BLL             DB 0

RUR             DB 0
GUR             DB 0
BUR             DB 0

RLR             DB 0
GLR             DB 0
BLR             DB 0

;--------------- Timer variables

RTime           DD 0

TextOnOff       DB 0
FadeF1          DB 0
FadeF2          DB 0
FadeF3          DB 0
FadeF4          DB 0
FadeF5          DB 0                            ;End flags
FadeF6          DB 0                            ;/

TCounter        DW OFFSET TLimits
TLimits         DD 000
                DW OFFSET Fade1                 ;fade in first picture

                DD 32000
                DW OFFSET Fade2                 ;fade in second picture

                DD 60000
                DW OFFSET TextOn                ;proudly presents

                DD 65000
                DW OFFSET Fade3                 ;fade to red

                DD 84000
                DW OFFSET TextOff1

                DD 96500
                DW OFFSET TextOn                ;a contribution

                DD 116000
                DW OFFSET TextOff2

                DD 120000
                DW OFFSET Fade4

                DD 132000
                DW OFFSET TextOn                ;The gathering...

                DD 150000
                DW OFFSET TextOff3

                DD 155000
                DW OFFSET Fade5

                DD 156000
                DW OFFSET Fade6

                DD 50000000


;------------------------------------ TEXT ------------------------------

TPos            DW 28184
TLength         DW 16
TOffs           DW OFFSET TextOffs
TextOffs        DW OFFSET T1, OFFSET T2, OFFSET T3

T1              DB 16, 18, 15, 21, 4, 12, 25, 37, 16, 18, 5, 19, 5, 14, 20, 19
;proudly presents
T2              DB 1, 37, 3, 15, 14, 20, 18, 9, 2, 21, 20, 9, 15, 14, 37, 20, 15
;a contribution to
T3              DB 20, 8, 5, 37, 7, 1, 20, 8, 5, 18, 9, 14, 7, 37, 36, 33

MainData        ENDS


Code1        SEGMENT PUBLIC
.386
EXTRN           GetTimer : PROC, ViewPCX : PROC

P1Main        PROC
                call  Initialize
                or    NoSound, 0
                jnz   NoMusic
                call  StartMusic
NoMusic:

                call  GetTimer
                mov   LastTime, eax
                mov   StartTime, eax
                mov   RTime, 0

Delay5:
                call GetTimer

                mov  ecx, LastTime
                mov  LastTime, eax
                sub  eax, ecx
                add  RTime, eax
                cmp  RTime, 18000
                jb   Delay5
                mov  RTime, 0


;--------------------------- Fading picture up ------------------------------

                mov   ax, Canvas
                mov   es, ax
                mov   ds, ax
                mov   si, (54287-768)                ;Offset to palette
                mov   di, si
                mov   cx, 768                  ;Converting palette...
CPal:
                lodsb
                shr   al, 2
                stosb
                loop  CPal

                xor   di, di                    ;Create a black palette at
                xor   eax, eax                  ;/es:0000
                mov   cx, 768/4
                rep   stosd

;-------------------- Fading palette up from es:0000 to es:35258
FadeUp:
                xor   bl, bl
                mov   cx, 768
                mov   si, (54287-768)                 ;Real palette at ds:35258
                xor   di, di                    ;Fading palette at es:0000
FLoop:
                lodsb
                cmp   [di], al
                je    NoFade
                inc   BYTE PTR [di]
                mov   bl, 1
NoFade:
                inc   di
                loop  FLoop


;--------------- Setting palette
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                xor   si, si

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black

;---------------- Getting timervalue...
                mov   gs:RTime, 0
Delay1:
                call GetTimer

                mov  ecx, gs:LastTime
                mov  gs:LastTime, eax
                sub  eax, ecx
                add  gs:RTime, eax
                cmp  gs:RTime, 400
                jb   Delay1

                or    bl, bl                    ;Test flag
                jnz   FadeUp

;---------------- Getting timervalue...
                mov   gs:RTime, 0
Delay3:
                call GetTimer

                mov  ecx, gs:StartTime
                sub  eax, ecx
                cmp  eax, 48000
                jb   Delay3

;-------------- Fading palette down from es:35258 to black
FadeDown:
                xor   bl, bl
                mov   cx, 768
                mov   si, (54287-768)                 ;Real palette
FDLoop:
                or    BYTE PTR [si], 0
                jz    NoFadeD
                dec   BYTE PTR [si]
                mov   bl, 1
NoFadeD:
                inc   si
                loop  FDLoop

                mov   dx,3C8h                   ;Port to send out startingcolor
                mov   al,0                      ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, (54287-768)                 ;PCX-palette

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black

;---------------- Getting timervalue...
                mov   gs:RTime, 0
Delay2:
                call GetTimer
                mov  ecx, gs:LastTime
                mov  gs:LastTime, eax
                sub  eax, ecx
                add  gs:RTime, eax
                cmp  gs:RTime, 500
                jb   Delay2

                or    bl, bl
                jnz   FadeDown

                mov  ax, 0A000h                 ;Blank screen
                mov  es, ax
                xor  di, di
                xor  eax, eax
                mov  cx, 16000
                rep  stosd
                mov  ax, Canvas
                mov  es, ax

                mov  ax, MainData
                mov  ds, ax

Delay4:                                         ;Wait for checkpoint
                call  GetTimer
                sub   eax, StartTime
                cmp   eax, 72000
                jb    Delay4

;Getting timer startvalue...

                call GetTimer                   ;Zero variables
                mov  LastTime, eax
                mov  RTime, 0

;------------------------------ MAIN LOOP ---------------------------------
PLoop:
                call GetTimer

                mov  ebx, LastTime
                mov  LastTime, eax
                sub  eax, ebx
                add  RTime, eax


;--------------------- Sine me all over!!! (First picture) -----------------
                mov   ax, Data1
                mov   ds, ax
                mov   ax, Data3
                mov   es, ax
                xor   di, di

                mov   ax, 204                   ;204 rows
                xor   dx, dx
MLoop:
                mov   bx, dx                    ;Get sine for Y-wave
                mov   si, gs:C1
                mov   bp, gs:[OFFSET SinTabl + si + bx]
                add   bp, 256
                shr   bp, 1

                add   bx, bp                    ;Move to top again?
                cmp   bx, 204
                jb    YOK
                sub   bx, 204
YOK:

                mov   si, gs:C2                 ;Get sine for X-wave
                add   si, dx
                mov   bp, gs:[OFFSET SinTabl + si]
                add   bp, 256
                shr   bp, 1

                mov   si, bx                    ;Mul by 320
                shl   si, 8
                shl   bx, 6
                add   si, bx
                add   si, bp

                mov   cx, 320
                rep   movsb

                add   dx, 4

                dec   ax                        ;Decrease Y-counter
                jnz   MLoop

;----------------- Sine me into the gro-ho-hove! (Second picture) -----------
                mov   ax, Data2
                mov   ds, ax
                mov   ax, Data3
                mov   es, ax
                xor   di, di

                mov   ax, 204
                xor   dx, dx
MLoop2:
                mov   bx, dx
                mov   si, gs:C2
                mov   bp, gs:[OFFSET SinTabl + si + bx]
                add   bp, 256
                shr   bp, 1

                sub   bx, bp
                cmp   bx, 204
                jb    YOK2
                sub   bx, 204
YOK2:

                mov   si, gs:C1
                add   si, dx
                mov   bp, gs:[OFFSET SinTabl + si]
                add   bp, 256
                shr   bp, 1

                mov   si, bx
                shl   si, 8
                shl   bx, 6
                add   si, bx
                sub   si, bp

                push  ax
                mov   cx, 320
OrLoop:
                lodsb
                or    es:[di], al
                inc   di
                dec   cx
                jnz   OrLoop
                pop   ax

                add   dx, 2

                dec   ax
                jnz   MLoop2

                mov   bx, gs:C3
                mov   ax, gs:[OFFSET SinTabl + bx]
                add   ax, 256
                shr   ax, 7
                shl   ax, 1
                add   gs:C1, 6
                cmp   gs:C1, 400 * 2
                jbe   C1OK
                sub   gs:C1, 360 * 2
C1OK:
                mov   bx, gs:C4
                mov   ax, gs:[OFFSET SinTabl + bx]
                add   ax, 256
                shr   ax, 6
                shl   ax, 1
                add   gs:C2, 4
                cmp   gs:C2, 360 * 2
                jb    C2OK
                sub   gs:C2, 360 * 2
C2OK:
                add   gs:C3, 2
                cmp   gs:C3, 360 * 2
                jb    C3OK
                sub   gs:C3, 360 * 2
C3OK:
                add   gs:C4, 2
                cmp   gs:C4, 360 * 2
                jb    C4OK
                sub   gs:C4, 360 * 2
C4OK:

;---------------------------- Done making picture ----------------------------

                mov   si, Data3
                mov   ds, si
                mov   si, Data4               ;Render upper half
                mov   fs, si
                mov   si, Canvas
                mov   es, si

                xor   di, di                    ;Pointer
                xor   bx, bx                    ;Pointer
                mov   cx, 320 * 100             ;Counter
RLoop1:
                mov   si, fs:[bx]               ;Load offset
                add   bx, 2                     ;Move pointer

                movsb                           ;Transfer pixel
                dec   cx
                jnz   RLoop1

                mov   si, Data5               ;Render lower half
                mov   fs, si

                mov   di, 32000
                xor   bx, bx                    ;Pointer
                mov   cx, 320 * 100             ;Counter

RLoop2:
                mov   si, fs:[bx]               ;Load offset
                add   bx, 2                     ;Move pointer

                movsb                           ;Transfer pixel
                dec   cx
                jnz   RLoop2

;------------------------------ ACTIONS ------------------------------------

                mov   ax, MainData
                mov   ds, ax

                mov   bx, TCounter

                mov   eax, RTime
                cmp   eax, [bx]                 ;Test limit
                jb    NoAction

                jmp   WORD PTR [bx + 4]

TextOn:
                mov   TextOnOff, 1              ;1 = turn text on
                add   TCounter, 6
                jmp   NoAction
TextOff1:
                mov   TextOnOff, 0              ;0 = turn text off
                add   TOffs, 2
                mov   TPos, 28175
                mov   TLength, 17
                add   TCounter, 6
                jmp   NoAction
TextOff2:
                mov   TextOnOff, 0              ;0 = turn text off
                add   TOffs, 2
                mov   TPos, 28184
                mov   TLength, 16
                add   TCounter, 6
                jmp   NoAction
TextOff3:
                mov   TextOnOff, 0              ;0 = turn text off
                add   TCounter, 6
                jmp   NoAction

Fade1:
                mov   FadeF1, 1
                add   TCounter, 6
                jmp   NoAction
Fade2:
                mov   FadeF2, 1
                add   TCounter, 6
                jmp   NoAction
Fade3:
                mov   FadeF3, 1
                add   TCounter, 6
                jmp   NoAction
Fade4:
                mov   FadeF4, 1
                add   TCounter, 6
                jmp   NoAction
Fade5:
                mov   FadeF5, 1
                add   TCounter, 6
                jmp   NoAction
Fade6:
                mov   FadeF6, 1
                add   TCounter, 6
                jmp   NoAction

NoAction:

;-------------------------------- Fading ------------------------------------
                or    FadeF1, 0
                jz    NoFade1
                mov   eax, RTime
                shr   eax, 9
                mov   BLL, al

                mov  si, OFFSET Pal
                call Gradient

                mov   si, OFFSET Pal
                mov   dx, 3C8h                  ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black                cmp   BUL

                cmp   BLL, 35
                jb    NoFade1
                mov   FadeF1, 0
NoFade1:

;----------------- Second fading phase...
                or    FadeF2, 0
                jz    NoFade2
                mov   eax, RTime
                sub   eax, 32000
                shr   eax, 9
                mov   BUR, al

                mov  si, OFFSET Pal
                call Gradient

                mov   si, OFFSET Pal
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   cx,240*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black                cmp   BUL

                cmp   BUR, 35
                jb    NoFade2
                mov   FadeF2, 0
NoFade2:

;----------------- Third fading phase...
                or    FadeF3, 0
                jz    NoFade3
                mov   eax, RTime
                sub   eax, 65000
                shr   eax, 10
                mov   RLL, al
                mov   RUR, al

                shr   al, 2
                mov   ah, 35
                sub   ah, al
                mov   BLL, ah
                mov   BUR, ah

                mov  si, OFFSET Pal
                call Gradient

                mov   si, OFFSET Pal
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   cx,240*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black                cmp   BUL

                cmp   BLL, 25
                ja    NoFade3
                mov   FadeF3, 0
NoFade3:

;----------------- Fourth fading phase...
                or    FadeF4, 0
                jz    NoFade4
                mov   eax, RTime
                sub   eax, 120000
                shr   eax, 11
                mov   ah, 25
                sub   ah, al
                mov   BLL, ah
                mov   BUR, ah

                mov  si, OFFSET Pal
                call Gradient

                mov   si, OFFSET Pal
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   cx,240*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black                cmp   BUL

                cmp   BUR, 1
                jg    NoFade4
                mov   FadeF4, 0
NoFade4:

;----------------- Fifth fading phase...
                or    FadeF5, 0
                jz    NoFade5
                mov   eax, RTime
                sub   eax, 151000
                shr   eax, 8

                mov   ah, 40
                sub   ah, al
                mov   RUR, ah

                mov  si, OFFSET Pal
                call Gradient

                mov   si, OFFSET Pal
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   cx,240*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black                cmp   BUL

                cmp   RUR, 1
                jg    NoFade5
                mov   FadeF5, 0
NoFade5:

;----------------- Sixth fading phase...
                or    FadeF6, 0
                jz    NoFade6
                mov   eax, RTime
                sub   eax, 152000
                shr   eax, 8

                mov   ah, 40
                sub   ah, al
                mov   RLL, ah

                mov  si, OFFSET Pal
                call Gradient

                mov   si, OFFSET Pal
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   cx,240*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black                cmp   BUL

                cmp   RLL, 1
                jg    NoFade6
                jmp   ViewDLogo
NoFade6:

;------------------------------- Viewing text ----------------------------

                or    TextOnOff, 0
                jz    NoText

                mov   si, TOffs
                mov   si, [si]
                mov   di, TPos
                mov   dx, TLength                    ;Number of characters
TLoop:
                lodsb                           ;Load character
                push  si
                push  di

                push  dx
                dec   al
                movzx ax, al                    ;Extend...
                mov   si, (19*27)
                mul   si
                mov   si, ax
                add   si, OFFSET Font
                pop   dx

                mov   bx, 27
TYLoop:
                mov   cx, 19
TXLoop:
                lodsb
                or    al, al
                jz    NoPix
                mov   BYTE PTR es:[di], al
NoPix:
                inc   di
                dec   cx
                jnz   TXLoop

                add   di, 301
                dec   bx
                jnz   TYLoop

                pop   di
                pop   si
                add   di, 17

                dec   dx
                jnz   TLoop

NoText:

;------------------------------ TEXT DONE ----------------------------------

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   di, di
                xor   si, si
                mov   cx, 16000
                rep   movsd
                mov   ax, MainData
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax

                mov   ah, 0Bh                   ;Check keyboard
                int   21h                       ;
                cmp   al, 00h                   ;Have somebody pressed a key?
                jne   Break                      ;OK, go home!
                jmp   PLoop                     ;No? Let's do another roll!

ViewDLogo:
;------------------ Loading "mind over matter"
FSize EQU 63817
                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, FSize                 ;Bytes to read
                push  ds
                mov   dx, Data1
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

                mov   ax, Data1
                mov   ds, ax
                mov   ax, Canvas
                mov   es, ax
                xor   si, si
                xor   di, di
                call  ViewPCX

;--------------------------- Fading picture up ------------------------------

                mov   ax, Data1
                mov   es, ax
                mov   ds, ax
                mov   si, FSize-768            ;Offset to palette
                mov   di, si
                mov   cx, 768                  ;Converting palette...
CPal2:
                lodsb
                shr   al, 2
                stosb
                loop  CPal2

                xor   di, di                    ;Create a black palette at
                xor   eax, eax                  ;/es:0000
                mov   cx, 768/4
                rep   stosd

;--------------- Setting palette
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                xor   si, si

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 16000
                rep   movsd
                mov   ax, Data1
                mov   es, ax
                mov   ds, ax

Delay9:                                         ;Wait for Checkpoint
                call GetTimer

                mov  ecx, gs:StartTime
                sub  eax, ecx
                cmp  eax, 240000
                jb   Delay9


;-------------------- Fading palette up from es:0000 to es:35258
FadeUp2:
                xor   bl, bl
                mov   cx, 768
                mov   si, FSize-768                 ;Real palette
                xor   di, di                    ;Fading palette
FLoop2:
                lodsb
                cmp   [di], al
                je    NoPFade2
                inc   BYTE PTR [di]
                mov   bl, 1
NoPFade2:
                inc   di
                loop  FLoop2


;--------------- Setting palette
                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                xor   si, si

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black

;---------------- Getting timervalue...
                mov   gs:RTime, 0
Delay6:
                call GetTimer

                mov  ecx, gs:LastTime
                mov  gs:LastTime, eax
                sub  eax, ecx
                add  gs:RTime, eax
                cmp  gs:RTime, 400
                jb   Delay6

                or    bl, bl
                jnz   FadeUp2

;---------------- Getting timervalue...
Delay7:                                         ;Wait for Checkpoint
                call GetTimer

                mov  ecx, gs:StartTime
                sub  eax, ecx
                cmp  eax, 270000
                jb   Delay7
                mov  gs:RTime, 0

;-------------- Fading palette down to black
FadeDown2:
                xor   bl, bl
                mov   cx, 768
                mov   si, FSize-768                 ;Real palette
FDLoop2:
                or    BYTE PTR [si], 0
                jz    NoFadeD2
                dec   BYTE PTR [si]
                mov   bl, 1
NoFadeD2:
                inc   si
                loop  FDLoop2

                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                mov   si, FSize-768                 ;PCX-palette

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black

;---------------- Getting timervalue...
Delay8:
                call GetTimer
                mov  ecx, gs:LastTime
                mov  gs:LastTime, eax
                sub  eax, ecx
                add  gs:RTime, eax
                cmp  gs:RTime, 500
                jb   Delay8
                mov  gs:RTime, 0

                or    bl, bl
                jnz   FadeDown2

                mov   ax, MainData
                mov   ds, ax

                or    NoSound, 0
                jnz   NoMusic2

                call  StopMusic
                call  StopOutPut
                call  UnLoadModule
NoMusic2:

                xor   al, al                    ;al = 0 = NoError
                jmp   Done2

Break:
                mov   ax, MainData
                mov   ds, ax
                mov   al, 1                     ;1 = User break

Done2:
                ret
P1Main        ENDP

Gradient      PROC
                push  WORD PTR RUL
                push  WORD PTR BUL
                push  WORD PTR GLL

                mov   bp, 15
GLoop:
                mov   al, RLL
                sub   al, RUL
                cbw
                sal   ax, 4

                movsx bx, RUL
                shl   bx, 8

                push  si
                mov   cx, 16
RL:
                mov   [si], bh
                add   si, 3
                add   bx, ax
                loop  RL

                pop   si

                mov   al, GLL
                sub   al, GUL
                cbw
                sal   ax, 4

                movsx bx, GUL
                shl   bx, 8

                push  si
                mov   cx, 16
GL:
                mov   [si + 1], bh
                add   si, 3
                add   bx, ax
                loop  GL

                pop   si

                mov   al, BLL
                sub   al, BUL
                cbw
                sal   ax, 4

                movsx bx, BUL
                shl   bx, 8

                push  si
                mov   cx, 16
_BL:
                mov   [si + 2], bh
                add   si, 3
                add   bx, ax
                loop  _BL

                pop   si

;---------------- Horisontal gradient, upper
                mov   al, RUR
                sub   al, RUL
                cbw
                cwd
                idiv  bp
                add   RUL, al

                mov   al, GUR
                sub   al, GUL
                cbw
                cwd
                idiv  bp
                add   GUL, al

                mov   al, BUR
                sub   al, BUL
                cbw
                cwd
                idiv  bp
                add   BUL, al

;---------------- Horisontal gradient, lower
                mov   al, RLR
                sub   al, RLL
                cbw
                cwd
                idiv  bp
                add   RLL, al

                mov   al, GLR
                sub   al, GLL
                cbw
                cwd
                idiv  bp
                add   GLL, al

                mov   al, BLR
                sub   al, BLL
                cbw
                cwd
                idiv  bp
                add   BLL, al

                add   si, 16 * 3
                dec   bp
                jnz   GLoop

                pop   WORD PTR GLL
                pop   WORD PTR BUL
                pop   WORD PTR RUL

                ret
Gradient      ENDP

Initialize    PROC
                mov   ax, Canvas
                mov   es, ax
                mov   ax, MainData
                mov   gs, ax

                mov   cx, 768 /4                ;Make a black palette at
                xor   eax, eax                  ;/ es:40000
                xor   di, di
                rep   stosd

                mov   ax, Canvas
                mov   ds, ax

                mov   dx,3C8h                   ;Port to send out startingcolor
                xor   al, al                    ;Starting color = 0
                out   dx, al                    ;Send it!
                inc   dx                        ;Next port = RGB values
                xor   si, si

                mov   cx,256*3                  ;3*256 (RGB)=768 colors
                rep   outsb                     ;Set all colors to black

                mov   ax, MainData
                mov   ds, ax

;------------------ Loading first picture

                mov   ah, 42h                   ;Move file-pointer
                mov   al, 0
                mov   bx, Handle
                mov   edx, FOffsets[5 * 4]
                mov   ecx, edx
                shr   ecx, 16
                int   21h

                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 8000h                 ;Bytes to read
                push  ds
                mov   dx, Data4
                mov   ds, dx
                xor   dx, dx
                int   21h
                pop   ds

;------------- Decompressing first picture...
                push  ds
                push  es
                mov   ax, Data4
                mov   ds, ax
                mov   ax, Data1
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 32768
Decomp1:
                lodsb
                mov   ah, al
                and   al, 00001111b
                stosb
                mov   al, ah
                and   al, 11110000b
                shr   al, 4
                stosb

                dec   cx
                jnz   Decomp1

                pop   es
                pop   ds

;------------------ Loading second picture
                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 08000h                ;Bytes to read
                push  ds
                mov   dx, Data4
                mov   ds, dx                    ;Store at Picture:0000
                xor   dx, dx
                int   21h
                pop   ds

;---------------- Decompressing second picture
                push  ds
                push  es
                mov   ax, Data4
                mov   ds, ax
                mov   ax, Data2
                mov   es, ax
                xor   si, si
                xor   di, di
                mov   cx, 32768
Decomp2:
                lodsb
                mov   ah, al
                and   al, 00001111b
                shl   al, 4
                stosb
                mov   al, ah
                and   al, 11110000b
                stosb

                dec   cx
                jnz   Decomp2

                pop   es
                pop   ds

;---------------- Loading map1
                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                ;Bytes to read
                push  ds
                mov   dx, Data4
                mov   ds, dx                    ;Store at Picture:0000
                xor   dx, dx
                int   21h
                pop   ds

;---------------- Loading map2
                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 64000                ;Bytes to read
                push  ds
                mov   dx, Data5
                mov   ds, dx                    ;Store at Picture:0000
                xor   dx, dx
                int   21h
                pop   ds

;---------------- Loading logo-picture
                mov   ah, 3Fh                   ;Read file
                mov   bx, Handle                ;Load filehandle
                mov   cx, 54287                 ;Bytes to read
                push  ds
                mov   dx, Canvas
                mov   ds, dx                    ;Store at Canvas:0000
                xor   dx, dx
                int   21h
                pop   ds

;-------------------- All data loaded!

                mov   ax, Canvas
                mov   ds, ax
                mov   ax, 0A000h
                mov   es, ax

                xor   si, si
                xor   di, di
                call  ViewPCX

                mov   ax, Canvas
                mov   es, ax
                mov   ax, MainData
                mov   ds, ax

                ret
Initialize    ENDP

Code1        ENDS

Data1         SEGMENT PUBLIC
Data1         ENDS

Data2         SEGMENT PUBLIC
Data2         ENDS

Data3         SEGMENT PUBLIC
Data3         ENDS

Data4         SEGMENT PUBLIC
Data4         ENDS

Data5         SEGMENT PUBLIC
Data5         ENDS

Canvas        SEGMENT PUBLIC
Canvas        ENDS

END           P1Main
