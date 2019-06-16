@ECHO OFF
tasm m7 /m3
tasm p7 /m3
tlink m7 p7 mse_asm lib1
smartdrv /c
m7
