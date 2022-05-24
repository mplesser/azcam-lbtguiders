rem Create .lod file for Gen3 timing board

rem Usage: tim_host.bat

rem ROOT3 is for 563 DSPs and ROOT0 is for 56000 DSPs
set DSPROOT= \AzCam\MotorolaDSPTools\
set ROOT3= %DSPROOT%CLAS563\BIN\
set ROOT0= %DSPROOT%CLAS56\BIN\

%ROOT3%asm56300 -b -ltim3.ls -d DOWNLOAD HOST tim3.asm

%ROOT3%dsplnk -b tim3.cld -v tim3.cln 

del tim3.cln

%ROOT3%cldlod tim3.cld > tim3.lod

del tim3.cld

pause


