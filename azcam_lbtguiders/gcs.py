"""
Contains the GCS class for LBTO guiders commands from GCS.
"""

import inspect

import azcam

"""
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

    from GCS:
     CloseConnection # Close the connection between the AZCAM server and the image server.
     SetExposure # Sets the exposure time, msec.
     Guide thread_num num_images # Number of images the image server should acquire.
     ReadTemperature n # Reads the CCD temp and dewar temp from camera n.
     SetROI x1 x2 y1 y2 # Sets the region of Interest for the CCD readout in pixels.
     GetDetPars # Returns the geometry of the next readout image in pixels.
     SetMode n m  # Opens/closes camera's shutter.
     SetGainSpeed g s # Amplification factor
     GetPixelCount # Returns number of pixels in an image.
     SetSyntheticImage n # Argument is 0 or 1, used to make a fake image for testing.
     SetSocket n # Open socket from AZCAM server to image server.
     Get version # Returns the version number.
     Set SystemName s # Sets a system name in the server - only used for documentation purposes.
     Get SystemName # Returns the system name.
     Get vispixels # Returns the X and Y size of the detector.
     setParameter item "value" "comment" # Adds an item as a header item to subsequent images.
     getParameter item # Returns the value of  a. header item.
     setParameter CLEARALL "" "" # Clears all header items.
        

"""


class GCS(object):
    """
    Class definition for lbtguider commands from GCS.
    These methods are called remotely thorugh the command server
    with syntax such as:
    gcs.expose 1.0 "zero" "/home/obs/a.001.fits" "some image title".
    """

    def __init__(self):
        """
        Creates gcs tool.
        """

        azcam.db.tools["gcs"] = self

        self.status = "OK"

        return

    def expose(self, flag, exposuretime, filename):
        """
        Make a complete exposure.
        flag is ignored.
        exposuretime is the exposure time in seconds
        filename is remote filename (do not use periods)
        """

        azcam.db.parameters.set_par("imagetest", 0)
        azcam.db.parameters.set_par("imageautoname", 0)
        azcam.db.parameters.set_par("imageincludesequencenumber", 0)
        azcam.db.parameters.set_par("imageautoincrementsequencenumber", 0)

        azcam.db.tools["exposure"].set_filename(filename)
        azcam.db.tools["exposure"].expose(exposuretime, "object", "LBT Guider Image")

        return self.status

    def expose1(self, flag, exposuretime, filename):
        """
        Make a complete exposure, returning immediately after start.
        flag is ignored.
        exposuretime is the exposure time in seconds
        filename is remote filename (do not use periods)
        """

        azcam.db.parameters.set_par("imagetest", 0)
        azcam.db.parameters.set_par("imageautoname", 0)
        azcam.db.parameters.set_par("imageincludesequencenumber", 0)
        azcam.db.parameters.set_par("imageautoincrementsequencenumber", 0)

        azcam.db.tools["exposure"].set_filename(filename)
        azcam.db.tools["exposure"].expose1(exposuretime, "object", "LBT Guider Image")

        return self.status

    def guide(self, flag, number_exposures=1):
        azcam.db.tools["exposure"].guide(number_exposures)
        return self.status

    def reset(self):
        azcam.db.tools["exposure"].reset()
        return self.status

    def resetcontroller(self):
        azcam.db.tools["controller"].reset()
        return self.status

    def abort(self):
        azcam.db.tools["exposure"].abort()
        return self.status

    def abortexposure(self):
        azcam.db.tools["exposure"].abort()
        return self.status

    def cleararray(self):
        azcam.db.tools["exposure"].flush()
        return self.status

    def getdetpars(self):
        nc = azcam.db.tools["exposure"].image.focalplane.numcols_image
        nr = azcam.db.tools["exposure"].image.focalplane.numrows_image
        return nc, nr

    def get(self, attribute):

        if attribute == "version":
            reply = azcam.__version__
        elif attribute == "cameratype":
            reply = azcam.db.tools["controller"].controller_type
        elif attribute == "servername":
            reply = azcam.db.hostname
        elif attribute == "vispixels":
            nc = azcam.db.tools["exposure"].image.focalplane.numcols_image
            nr = azcam.db.tools["exposure"].image.focalplane.numrows_image
            reply = nc, nr
        else:
            reply = self.status

        return reply

    def setexposure(self, exposure_time: int):
        """
        exposure_time is in msec.
        """
        et = float(exposure_time) / 1000.0
        azcam.db.tools["exposure"].set_exposuretime(et)
        return self.status

    def setroi(
        self,
        first_col: int,
        last_col: int,
        first_row: int,
        last_row: int,
        col_bin: int,
        row_bin: int,
    ):
        azcam.db.tools["exposure"].set_roi(
            first_col,
            last_col,
            first_row,
            last_row,
            col_bin,
            row_bin,
        )
        return self.status

    def set_format(
        self,
        ns_total: int,
        ns_predark: int,
        ns_underscan: int,
        ns_overscan: int,
        np_total: int,
        np_predark: int,
        np_underscan: int,
        np_overscan: int,
        np_frametransfer: int,
    ) -> None:

        azcam.db.tools["exposure"].set_format(
            ns_total,
            ns_predark,
            ns_underscan,
            ns_overscan,
            np_total,
            np_predark,
            np_underscan,
            np_overscan,
            np_frametransfer,
        )
        return self.status

    def getpixelcount(self):
        count = azcam.db.tools["exposure"].get_pixels_remaining()
        return count

    def gettemp(self):
        temps = azcam.db.tools["tempcon"].get_temperatures()
        return temps[1]

    def readtemperature(self, flag=0):
        temps = azcam.db.tools["tempcon"].get_temperatures()
        if len(temps)>1:
            return temps[0], temps[1]
        else:
            return temps[0], temps[0]

    def setsocket(self, flag, host, port=6543):
        if flag == -1:
            azcam.db.tools["sendimage"].set_remote_imageserver()
        else:
            azcam.db.tools["sendimage"].set_remote_imageserver(host, port, "lbtguider")
        return self.status

    def setparameter(self, keyword, value, comment=""):
        if keyword == "CLEARALL":
            azcam.db.tools["exposure"].header.delete_all_keywords()
        else:   
            azcam.db.tools["exposure"].set_keyword(keyword, value, comment)
        return self.status

    def resetserver(self):
        azcam.db.tools["controller"].camserver.reset_server()
        return self.status

    ###########################################################################
    # Commands below are accepted but do nothing
    ###########################################################################

    def loadfile(self, flag1: int = 0, dspfile: str = ""):
        """not used"""
        return self.status

    def setsyntheticimage(self,flag=0):
        """not used"""
        return self.status

    def resumeidle(self):
        """not used"""
        return self.status

    def poweron(self):
        """not used"""
        return self.status

    def setbiasvoltage(self):
        """not used"""
        return self.status

    def setmode(self, flag1: int = 0, flag2: int = 0):
        """not used"""
        return self.status

    def settemperature(self, flag: int = 0, control_temperature: float = -200):
        """not used"""
        return self.status

    def settempcal(
        self,
        flag1: int = 0,
        flag2: int = 0,
        flag3: int = 0,
    ):
        """not used"""
        return self.status

    def setconfiguration(
        self,
        flag1: int = 0,
        flag2: int = 0,
        flag3: int = 0,
        flag4: int = 0,
        flag5: int = 0,
    ):
        """not used"""
        return self.status

    def setgainspeed(
        self,
        gain: int = 0,
        speed: int = 0,
    ):
        """not used"""
        return self.status

    def writememory(
        self,
        flag1: str = "Y",
        flag2: int = 0,
        flag3: int = 0,
        flag4: int = 0,
    ):
        """not used"""
        return self.status

    def closeconnection(self):
        """not used"""
        return self.status

    def loadwaveform(self, flag1):
        """not used"""
        return self.status
