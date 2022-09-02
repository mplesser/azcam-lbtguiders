# Starts one or more AzCamServer processes using AzCamServerStartUpConfig.txt file.
# 19Aug13 last change MPL

import os,socket
from AzCamServerVersion import AZCAMSERVERVERSION
StartupFile='LBTGuidersConfiguration.txt'

# get local hostname
hostname=socket.gethostbyname_ex(socket.gethostname())[0]

f=open(StartupFile,'r')
lines=f.readlines()
f.close()

# tokenize data
tokens=[]
for line in lines:

    line=line.strip()

    # skip blank lines and those which start with #
    if line.startswith('#') or len(line)==0:
        continue
    
    toks=line.split()
    tokens.append(toks)
    
# find lines to start
col_Name=0
col_ConType=1
col_DSP=2
col_CmdServerPort=3
col_CSHost=4
col_CSPort=5
col_StartupFlag=6
col_AZHost=7

for pars in tokens:
        Name=pars[col_Name]
        if Name=='server':
            StandAloneServer=pars[1]
            continue
        ConType=pars[col_ConType]
        DSP=pars[col_DSP]
        CmdServerPort=pars[col_CmdServerPort]
        CSHost=pars[col_CSHost]
        CSPort=pars[col_CSPort]
        AZHost=pars[col_AZHost]
        
        # start AzCamServer if startup flag is 1 and this is the AZHost specified
        if pars[col_StartupFlag]=='1':
            if hostname==AZHost:
                s='python %s CommandServerPort:%s WindowName:%s Module:lbtguiders ConType:%s DSP:%s CSHost:%s CSPort:%s' % (AZCAMSERVERVERSION,
                    CmdServerPort,Name,ConType,DSP,CSHost,CSPort)
                os.system(s)

        # start AzCamServer if startup flag is 2 and this is the stand along AzCamServer
        elif pars[col_StartupFlag]=='2':
            if hostname==StandAloneServer:
                s='python %s CommandServerPort:%s WindowName:%s Module:lbtguiders ConType:%s DSP:%s CSHost:%s CSPort:%s' % (AZCAMSERVERVERSION,
                    CmdServerPort,Name,ConType,DSP,CSHost,CSPort)
                os.system(s)

        elif pars[col_StartupFlag]=='3':
            s='python %s CommandServerPort:%s WindowName:%s Module:lbtguiders ConType:%s DSP:%s CSHost:%s CSPort:%s' % (AZCAMSERVERVERSION,
                CmdServerPort,Name,ConType,DSP,CSHost,CSPort)
            os.system(s)
