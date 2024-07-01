"""
Python process start file
"""

import subprocess

OPTIONS = "-system 1g"
CMD = f"ipython --profile azcamserver -i -m azcam_lbtguiders.server -- {OPTIONS}"

p = subprocess.Popen(
    CMD,
    creationflags=subprocess.CREATE_NEW_CONSOLE,
)
