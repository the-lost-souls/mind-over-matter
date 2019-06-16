@echo off
tasm %1 /m2
tlink %1 duck
td %1
