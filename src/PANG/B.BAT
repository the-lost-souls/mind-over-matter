@ECHO OFF
tasm %1
tlink %1 nuts
%1
