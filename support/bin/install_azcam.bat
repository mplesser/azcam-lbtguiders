@echo off

pip install rich
pip install ipython

echo Installing azcam code in edit mode
cd ..\..\..


pip install -e azcam
pip install -e azcam-fastapi
pip install -e azcam-arc
pip install -e azcam-ds9
pip install -e azcam-imageserver
pip install -e azcam-mag
pip install -e azcam-webtools

pip install -e azcam-lbtguiders

pause
