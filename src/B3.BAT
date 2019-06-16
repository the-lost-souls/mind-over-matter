@ECHO OFF
tasm m3 /m3
tasm p3 /m3
tasm p4 /m3
tlink m3 p3 p4 mse_asm lib1
smartdrv /c
m3
