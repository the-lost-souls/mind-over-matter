@ECHO OFF
tasm m1 /m3
tasm p1 /m3
tlink m1 p1 mse_asm font p1_pal lib1
smartdrv /c
rem m1
