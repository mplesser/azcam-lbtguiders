"""
CLI commands for lbtguiders
"""

import azcam


# controller commands
def ControllerType():
    return azcam.db.tools["controller"].controller_type


azcam.db.tools["controller"].ControllerType = ControllerType


def Reset_controller():
    azcam.db.tools["controller"].reset()
    return


azcam.db.tools["controller"].Reset = Reset_controller


# exposure commands
def Expose(exposure_time=-1, imagetype="", title=""):
    azcam.db.tools["exposure"].expose(exposure_time, imagetype, title)
    return


azcam.db.tools["exposure"].Expose = Expose


def GuideMode():
    return azcam.db.tools["exposure"].guide_mode


azcam.db.tools["exposure"].GuideMode = GuideMode


def Reset_exposure():
    azcam.db.tools["exposure"].reset()
    return


azcam.db.tools["exposure"].Reset = Reset_exposure


# non-tool CLI commands
def SetExposureTime(et):
    azcam.db.tools["exposure"].set_exposuretime(et)
    return


def getstatus():
    reply = azcam.db.tools["exposure"].get_status()
    return reply


def ResetController():
    azcam.db.tools["controller"].reset()
    return


# add to cli
azcam.db.cli.update(
    {
        "SetExposureTime": SetExposureTime,
        "getstatus": getstatus,
        "ResetController": ResetController,
    }
)
