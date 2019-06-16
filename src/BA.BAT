@ECHO OFF
tasm m /m9
tasm p1 /m9
tasm p2 /m9
tasm p3 /m9
tasm p4 /m9
tasm p5 /m9
tasm p6 /m9
tasm p7 /m9
tasm lib1 /m9
tlink m p1 p2 p3 p4 p5 p6 p7 mse_asm font p1_pal lib1
smartdrv /c
m
