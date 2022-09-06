@echo off

set cameras="4g" "4w"

(for %%a in (%cameras%) do (

start "%%a" ipython.exe --profile azcamserver --TerminalInteractiveShell.term_title_format=%%a -i -m azcam_lbtguiders.server -- -system "%%a"

))