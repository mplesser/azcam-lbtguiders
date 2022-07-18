@echo off

set camera=ITL

ipython.exe --profile azcamserver --TerminalInteractiveShell.term_title_format=%camera% -i -m azcam_lbtguiders.server -- -system %camera%
