@echo off

set camera=1g

ipython.exe --profile azcamserver --TerminalInteractiveShell.term_title_format=%camera% -i -m azcam_lbtguiders.server -- -system %camera%
