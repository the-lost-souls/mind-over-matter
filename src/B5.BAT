@ECHO OFF
tasm m5 /m3
tasm p5 /m3
tasm p6 /m3
tasm p7 /m3
tlink m5 p5 p6 p7 mse_asm lib1
smartdrv /c
m5
