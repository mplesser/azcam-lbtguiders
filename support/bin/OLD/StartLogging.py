# StartGuiderLogs
# Starts new log console window from list of AzCamServers and ControllerServers.
# 25Feb1414 last change MPL

# Usage: Run StartLogging
#    or: open in file exporer

import sys,os

sys.path.append('/AzCam/AzCamConsole/AzCamConsole_5.1')
from AzCamCommands import *
AddSearchFolder('/AzCam/AzCamLog')

# *************************************************************
# EDIT THESE LISTS
# *************************************************************
LogFolder='/AzCam/systems/lbtguiders/Logs'
AZCAMSERVERS=[
    ['agw1g','localhost',2442],     
    ['agw1w','localhost',2452], 
    ['agw2g','localhost',2412],    
    ['agw2w','localhost',2402],
#    ['agw3g','localhost',2482],    
#    ['agw3w','localhost',2492],
#    ['agw4g','localhost',2462],
#    ['agw4w','localhost',2472],
    ['agw5g','localhost',2422], 
    ['agw5w','localhost',2432], 
#    ['agw6g','localhost',2502],
#    ['agw6w','localhost',2512],
#    ['agw7g','localhost',2522],
#    ['agw7w','localhost',2532],
#    ['agw8g','localhost',2542],
#    ['agw8w','localhost',2552],
    ]

CONTROLLERSERVERS={
    }

# find the AzCamServerLog module which must be in search path
if len(AZCAMSERVERS)>0:
    reply=FindFile('AzCamLog.py')
    if reply[0]!=Globals.OK:
        print 'AzCamServerLog not found'
        EndScript()
    azp=reply[2]
    azp=os.path.normpath(azp)

if len(CONTROLLERSERVERS)>0:
    reply=FindFile('AzCamLog.py')
    if reply[0]!=Globals.OK:
        print 'AzCamLog not found'
        EndScript()
    csp=reply[2]
    cdp=os.path.normpath(csp)

# start AzCamServerLogs
if len(AZCAMSERVERS)>0:
    for server in AZCAMSERVERS:
        host=server[1]
        port=server[2]
        lport=port+1
        logfolder=os.path.join(LogFolder,server[0])
        #s='start "AzCamServerLog_%d" /D %s python AzCamServerLog.py -s %s -p %d -l %d' % (port,azp,host,port,lport)
        s='start "AzCamLog_%d" /D %s python AzCamLog.py -s %s -p %d -l %d -d 1111 -o %s' % (port,azp,host,port,lport,logfolder)
        os.system(s)

# start AzCamLogs - ControllerServer logs
if len(CONTROLLERSERVERS)>0:
    for server in CONTROLLERSERVERS:
        host=server[1]
        port=server[2]
        lport=port+1
        logfolder=os.path.join(LogFolder,server[0])
        s='start "AzCamLog_%d" /D %s python AzCamLog.py -s %s -p %d -l %d -d 1111 -o %s' % (port,azp,host,port,lport,logfolder)
        os.system(s)
    
# finished
#raw_input('wait')
