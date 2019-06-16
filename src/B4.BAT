@ECHO OFF
tasm m4 /m3
tasm p4 /m3
tasm p5 /m3
tlink m4 p4 p5 mse_asm lib1
smartdrv /c
m4
