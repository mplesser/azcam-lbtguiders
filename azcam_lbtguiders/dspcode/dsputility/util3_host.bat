rem Create .lod file for utility board
rem MPL 01Jan06

rem Directories - change as needed
set ROOT=\azcam\MotorolaDSPTools\
set ROOT3=%ROOT%CLAS563\BIN\
set ROOT0=%ROOT%CLAS56\BIN\

%ROOT0%asm56000 -b -lutilboot3.ls utilboot3.asm
%ROOT0%asm56000 -b -lutil3.ls -d DOWNLOAD HOST -d POWER R6 util3.asm 

%ROOT0%dsplnk -b util3.cld -v utilboot3.cln util3.cln

rem del util3.lod
del utilboot3.cln
del util3.cln

%ROOT0%cldlod util3.cld > util3.lod

del util3.cld

pause

