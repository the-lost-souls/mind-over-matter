@ECHO OFF
tasm m2 /m3
tasm p2 /m3
tasm p3 /m3
tlink m2 p2 p3 mse_asm lib1
smartdrv /c
m2
