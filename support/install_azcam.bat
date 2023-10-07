@echo off

pip install rich
pip install ipython

echo Installing azcam code in edit mode
cd ..\..\..

git clone https://github.com/mplesser/azcam
git clone https://github.com/mplesser/azcam-fastapi
git clone https://github.com/mplesser/azcam-arc
git clone https://github.com/mplesser/azcam-ds9
git clone https://github.com/mplesser/azcam-imageserver
git clone https://github.com/mplesser/azcam-mag
git clone https://github.com/mplesser/azcam-webtools


pip install -e azcam
pip install -e azcam-fastapi
pip install -e azcam-arc
pip install -e azcam-ds9
pip install -e azcam-imageserver
pip install -e azcam-mag
pip install -e azcam-webtools

pip install -e azcam-lbtguiders

pause
