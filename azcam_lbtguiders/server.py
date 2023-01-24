# azcamserver config file for lbtguiders

import os
import sys

import azcam
import azcam.server
import azcam.shortcuts
from azcam.cmdserver import CommandServer
from azcam.system import System
from azcam.tools.instrument import Instrument
from azcam.tools.telescope import Telescope
from azcam.tools.arc.controller_arc import ControllerArc
from azcam.tools.arc.exposure_arc import ExposureArc
from azcam.tools.arc.tempcon_arc import TempConArc
from azcam.tools.mag.controller_mag import ControllerMag
from azcam.tools.mag.exposure_mag import ExposureMag
from azcam.tools.mag.tempcon_mag import TempConMag
from azcam.tools.ds9display import Ds9Display
from azcam.tools.sendimage import SendImage
from azcam.tools.webserver.fastapi_server import WebServer
from azcam.tools.webtools.status.status import Status

from azcam_lbtguiders.gcs import GCS

# ****************************************************************
# parse command line arguments
# ****************************************************************
try:
    i = sys.argv.index("-system")
    option = sys.argv[i + 1]
except ValueError:
    option = "menu"

# ****************************************************************
# configuration menu
# ****************************************************************
menu_options = {
    "agw1g": "1g",
    "agw1w": "1w",
    "agw2g": "2g",
    "agw2w": "2w",
    "agw3g": "3g",
    "agw3w": "3w",
    "agw4g": "4g",
    "agw4w": "4w",
    "agw5g": "5g",
    "agw5w": "5w",
    "agw6g": "6g",
    "agw6w": "6w",
    "agw7g": "7g",
    "agw7w": "7w",
    "agw8g": "8g",
    "agw8w": "8w",
}
if option == "menu":
    option = azcam.utils.show_menu(menu_options)

# ****************************************************************
# define folders for system
# ****************************************************************
azcam.db.systemname = "lbtguiders"
azcam.db.systemfolder = os.path.dirname(__file__)
azcam.db.systemfolder = azcam.utils.fix_path(azcam.db.systemfolder)

droot = os.environ.get("AZCAM_DATAROOT")
if droot is None:
    droot = "/data"
azcam.db.datafolder = os.path.join(droot, azcam.db.systemname)
azcam.db.datafolder = azcam.utils.fix_path(azcam.db.datafolder)

# ****************************************************************
# enable logging
# ****************************************************************
logfile = os.path.join(azcam.db.datafolder, "logs", "server.log")
azcam.db.logger.start_logging(logfile=logfile)
azcam.log(f"Configuring for {option}")

# ****************************************************************
# read configuration data from file
# ****************************************************************
config_info = {}
cfile = os.path.join(azcam.db.systemfolder, f"lbtguiders_configuration_{azcam.db.hostname}.txt")
if not os.path.exists(cfile):
    cfile = os.path.join(azcam.db.systemfolder, f"lbtguiders_configuration.txt")

with open(cfile) as f:
    azcam.log(f"Reading configuration file {cfile}")

    for line in f.readlines():
        line = line.strip()
        if len(line) == 0 or line.startswith("#"):
            continue
        tokens = line.split(" ")

        # ignore anything after a # for end of line comment
        for i, tok in enumerate(tokens):
            if tok == "#":
                tokens = tokens[:i]

        if tokens[0] == "server":
            standaloneserver = tokens[1]
            continue

        if len(tokens) != 8:
            print(f"invalid configuration data: {tokens}")

        # Name ConType DSP CmdServerPort CSHost CSPort StartUpFlag AZHost Notes

        config_info[tokens[0]] = {
            "name": tokens[0],
            "contype": tokens[1],
            "dsp": tokens[2],
            "cmdserverport": int(tokens[3]),
            "cshost": tokens[4],
            "csport": int(tokens[5]),
            "startupflag": int(tokens[6]),
            "azhost": tokens[7],
        }

# ****************************************************************
# configure system options
# ****************************************************************
azcam.db.config_info = config_info
cmdserverport = config_info[option]["cmdserverport"]
azhost = config_info[option]["azhost"]
startupflag = config_info[option]["startupflag"]
name = config_info[option]["name"]
contype = config_info[option]["contype"]
cshost = config_info[option]["cshost"]
csport = config_info[option]["csport"]
dsp = config_info[option]["dsp"]

template = os.path.join(azcam.db.datafolder, "templates", "fits_template_lbtguiders.txt")
parfile = os.path.join(azcam.db.datafolder, "parameters", "parameters_server_lbtguiders.ini")
azcam.db.servermode = option

# ****************************************************************
# controller
# ****************************************************************
dspfolder = azcam.db.systemfolder  # systemfolder or datafolder
if contype == "ARC":
    controller = ControllerArc()
    controller.timing_board = "arc22"
    controller.clock_boards = ["arc32"]
    controller.video_boards = ["arc45"]
    controller.utility_board = "gen3"
    controller.set_boards()
    controller.utility_file = os.path.join(dspfolder, "dspcode", "dsputility/util3.lod")
    controller.pci_file = os.path.join(dspfolder, "dspcode", "dsppci", "pci3.lod")
    dspcode = f"{dsp}/tim3.lod"
    controller.timing_file = os.path.join(dspfolder, "dspcode", "dsptiming", dspcode)
    controller.video_gain = 5
    controller.video_speed = 1

    tempcon = TempConArc()
    tempcon.set_calibrations([0, 0])

    tempcon.temperature_offsets = 2 * [-76.0]  # from agw2
    tempcon.temperature_scales = 2 * [1.0]
    tempcon.temperature_correction = 1

elif contype == "MAG":
    controller = ControllerMag()
    dspcode = f"{dsp}/gcam_ccd57.s"
    controller.timing_file = os.path.join(dspfolder, "dspcode", "dsptiming", dspcode)
    controller.use_read_lock = 1

    tempcon = TempConMag()
    tempcon.temperature_offsets = 2 * [-170.0]  # from old note
    tempcon.temperature_scales = 2 * [1.0]
    tempcon.temperature_correction = 1

else:
    raise azcam.AzcamError("invalid controller type")

controller.camserver.set_server(cshost, csport)

# ****************************************************************
# exposure
# ****************************************************************
if contype == "ARC":
    exposure = ExposureArc()
elif contype == "MAG":
    exposure = ExposureMag()
else:
    raise azcam.AzcamError("invalid controller type")
sendimage = SendImage()
exposure.filetype = exposure.filetypes["FITS"]
exposure.image.filetype = exposure.filetypes["FITS"]
exposure.display_image = 0

if option == "ITL":
    exposure.send_image = 0
    imagefolder = azcam.db.datafolder
else:
    imagefolder = "/home/lbtguiders"
    exposure.send_image = 1
    remote_imageserver_host = "10.30.7.82"
    remote_imageserver_port = 6543
    sendimage.set_remote_imageserver(remote_imageserver_host, remote_imageserver_port, "lbtguider")
exposure.folder = imagefolder

# ****************************************************************
# detector
# ****************************************************************
detector_ccd57 = {
    "name": "CCD57",
    "description": "e2v CCD57",
    "ref_pixel": [256, 256],
    "format": [560, 24, 0, 0, 528, 14, 0, 0, 528],
    #"format": [536, 15, 0, 0, 528, 16, 0, 0, 528],
    "focalplane": [1, 1, 1, 1, "0"],
    "roi": [1, 512, 1, 512, 1, 1],
    "ext_position": [[1, 1]],
    "jpg_order": [1],
}
exposure.set_detpars(detector_ccd57)

# ****************************************************************
# instrument
# ****************************************************************
instrument = Instrument()
instrument.enabled = 0

# ****************************************************************
# telescope
# ****************************************************************
telescope = Telescope()
telescope.enabled = 0

# ****************************************************************
# system header template
# ****************************************************************
system = System("lbtguiders", template)
system.set_keyword("DEWAR", "lbtguider", "Dewar name")

# ****************************************************************
# display
# ****************************************************************
display = Ds9Display()

# ****************************************************************
# GCS commands
# ****************************************************************
gcs = GCS()
azcam.db.tools["gcs"] = gcs

# ****************************************************************
# parameter file
# ****************************************************************
azcam.db.parameters.read_parfile(parfile)
azcam.db.parameters.update_pars(0, "azcamserver")

# ****************************************************************
# define and start command server
# ****************************************************************
cmdserver = CommandServer()
cmdserver.port = cmdserverport
cmdserver.case_insensitive = 1
azcam.log(f"Starting cmdserver - listening on port {cmdserver.port}")
# cmdserver.welcome_message = "Welcome - azcam-lbtguiders server"
cmdserver.start()
azcam.db.default_tool = "gcs"

# ****************************************************************
# web server
# ****************************************************************
if 0:
    webserver = WebServer()
    webserver.port = 2403  # common port for all configurations
    webserver.index = os.path.join(azcam.db.systemfolder, "index_lbtguiders.html")
    webserver.start()
    webstatus = Status()
    webstatus.initialize()

# ****************************************************************
# GUIs
# ****************************************************************
if 0:
    import azcam_lbtguiders.start_azcamtool

# ****************************************************************
# finish
# ****************************************************************
azcam.log("Configuration complete")
