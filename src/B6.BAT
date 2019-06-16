@ECHO OFF
tasm m6 /m3
tasm p6 /m3
tasm p7 /m3
tlink m6 p6 p7 mse_asm lib1
smartdrv /c
m6
