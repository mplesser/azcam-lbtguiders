# LBTCommandParser for AzCam 5.1
# 12sep13 last change MPL

import shlex,socket,time
from AzCamServerCommands import *
from AzCamCommandParser import AzCamCommandParser
from ExecuteParserCommand import ExecuteParserCommand,GetDataType

# get localhost name (done once)
Globals.LocalHost=socket.gethostbyname_ex(socket.gethostname())[2][0]

def LBTCommandParser(Command):
    """
    Command parser for LBT guiders.
        Command recognized are:
    reset
    resetcontroller
    abort
    cleararray
    abortexposure
    getdetpars
    get version
    get cameratype
    get servername
    get vispixels
    setexposure
    setroi
    getpixelcount
    gettemp
    readtemperature
    closeconnection
    setsocket
    setsyntheticimage
    setparameter
    guide
    expose
    expose1
    resetserver
        
    PLUS all AzCamServer commands through AzCamServerParser.
    """
    
    # timer example
    #if self.TimeReadout:
    #    Globals.start_time=time.time()

    #if self.TimeReadout:
    #    end_time=time.time()
    #    print 'Timer at finish: %.3f sec' % (end_time-Globals.start_time)

    # timestamp example, now for all commands
    #print 'timestamp: ',time.time()    # tokenize
  
    # load all defined objects
    for name in Globals.Objects.keys(): 
	globals()[name] = Globals.Objects[name]

    tokens=shlex.split(Command)
    token=[]
    for t in tokens:
        token.append(str(t))
    cmd=token[0].lower()
    
    if cmd=='reset':
        reply=controller.Reset()
	
    elif cmd=='resetcontroller':
        reply=controller.Reset()
	
    elif cmd=='cleararray':
        reply=exposure.Flush()
	
    elif cmd=='abortexposure':
        reply=exposure.Abort()
	
    elif cmd=='getdetpars':
        reply=[]
        reply.append(Globals.OK)
        reply.append(str(focalplane.NumColsImage))
        reply.append(str(focalplane.NumRowsImage))
	
    elif cmd=='get' and token[1].lower()=='version':
	reply=[Globals.OK,Globals.Version]
	
    elif cmd=='get' and token[1].lower()=='cameratype':
	r=controller.ControllerType
	reply=[Globals.OK,r]
	
    elif cmd=='get' and token[1].lower()=='servername':
	reply=[Globals.OK,Globals.LocalHost]
	
    elif cmd=='get' and token[1].lower()=='vispixels':
        reply=[]
        reply.append(Globals.OK)
        reply.append(str(focalplane.NumColsImage))
        reply.append(str(focalplane.NumRowsImage))
	
    elif cmd=='setexposure':
	et=int(token[1])/1000.                             # millisecs to seconds
        reply=exposure.SetExposureTime(et)
	
    elif cmd=='setroi':
        reply=focalplane.SetRoi(int(token[1]),int(token[2]),int(token[3]),int(token[4]),
		    int(token[5]),int(token[6]))
	
    elif cmd=='getpixelcount':
        reply=[Globals.OK,str(exposure.PixelsRemaining)]
	
    elif cmd=='gettemp':
	reply=tempcon.GetTemperatures()
	camtemp=float(reply[1])
	s1='%0.1f' % camtemp
	reply=[reply[0],s1]    
    
    elif cmd=='readtemperature':                     # Flag is ignored, returns camtemp and dewtemp in Celsius
	reply=tempcon.GetTemperatures()
	camtemp=float(reply[1])
	dewtemp=float(reply[2])
	s1='%0.1f' % camtemp
	s2='%0.1f' % dewtemp
	reply=[reply[0],s1,s2]    
    	
    elif cmd=='setsocket':                           # Flag HostName HostPort, ignores Flag except -1 cancels remote mode
        if token[1]=='-1':
            exposure.RemoteImageServer=0
        else:
            exposure.RemoteImageServer=1
	exposure.RemoteImageServerHost=token[2]
	exposure.RemoteImageServerPort=int(token[3])
        reply=[Globals.OK]
	
    elif cmd=='setsyntheticimage':                   # set synthetic image NOT SUPPORTED
        reply=[Globals.OK]
    
    elif cmd=='setmode':                             # set mode NOT SUPPORTED
        reply=[Globals.OK]
    
    elif cmd=='setparameter':                        # set keyword
	keyword=token[1]
	value=token[2]
	comment=token[3]
	reply=controller.header.SetKeyword(keyword,value,comment)
    
    elif cmd=='guide':                               # Flag NumberExposures, ignores Flag
	flag=int(token[1])
	NumExposures=int(token[2])
	Set('ImageType','object')
	Set('ImageTitle','LBT Guide Image')
	while(exposure.ExposureFlag!=exposure.EF_NONE):
	    time.sleep(.1)
        reply=exposure.Guide1(NumExposures,1)  # explicitly set
    
    elif cmd=='expose':                             # Flag ExpTime(ms) FileName(in double quotes), ignores Flag
        et=int(token[2])/1000.
	SetFilename(token[3])
        reply=Expose(et,'OBJECT','LBT Guider Image')
    
    elif cmd=='expose1':                            # Flag ExpTime(ms) FileName(in double quotes), ignores Flag
        et=int(token[2])/1000.
	SetFilename(token[3])
        reply=exposure.Expose1(et,'OBJECT','LBT Guider Image')
    
    elif cmd=='resetserver':
        reply=controller.conserver.ResetServer()

    # other commands execute on AzCamCommandParser
    else:
	reply=AzCamCommandParser(Command)
	return reply   # already a string
    
    # make list reply into a string
    s=' '.join(reply)    
    return s

