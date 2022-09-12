"""
Start all azcamserver in Windows Terminal using a virtual environoment.
"""

import os

systems=["1g", "1w", "2g", "2w", "3g", "3w", "4g", "4w", 
"5g", "5w", "6g", "6w", "7g", "7w", "8g", "8w"]

shell = f"ipython --profile azcamserver -i -m azcam_lbtguiders.server"

for name in systems:
    wt = f"wt -w azcam --title {name}"
    cl = f"poetry run {wt} {shell} -- -- -system {name}"
    os.system(cl)
