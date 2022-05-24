@echo off

set cameras="1g" "1w" "2g" "2w" "4g" "4w" "5g" "5w"

(for %%a in (%cameras%) do (

start "%%a" ipython.exe --profile azcamserver --TerminalInteractiveShell.term_title_format=%%a -i -m azcam_lbtguiders.server -- -system "%%a"

))