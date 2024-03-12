## New Linux Notes - March, 2024

### Add the follwoing to .bashrc or type in each terminal session

```
export AZCAM_DATAROOT=~/data
alias python=python3.11
alias pip=pip3.11
```

### Install azcam in editable mode so that local changes may be made

```
cd
mkdir azcam
mkdir data
cd azcam
git clone https://github.com/mplesser/azcam
git clone https://github.com/mplesser/azcam-lbtguiders
pip install -e azcam
pip install -e azcam-lbtguiders
```

### Create lbtguider data files

```
cp -r ~/azcam/azcam-lbtguiders/support/datafolder ~/data/lbtguiders
```

### Execution

Several commands will now be installed: `azcamobserve` and `azcammonitor`

The azcamserver for lbtguiders can be started with commands like:

```
python -i -m azcam_lbtguiders.server
python -i -m azcam_lbtguiders.server -- -system 1w
or, if ipython is installed,
ipython -i -m azcam_lbtguiders.server -- -system 1w
```
