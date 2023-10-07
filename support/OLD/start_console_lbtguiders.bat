@echo off

ipython.exe --profile azcamconsole --TerminalInteractiveShell.term_title_format=azcamconsole -i -m azcam_lbtguiders.console -- -lab -system lbtguiders
