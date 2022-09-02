# pytest test_lbtgudiers -sv

import azcam

import azcam_lbtguiders.gcs

def test_gcs():

    import azcam_lbtguiders.server_lbtguiders
    gcs = azcam_lbtguiders.gcs.GCS()

    azcam.db.tools["exposure"].send_image=0

    reply=gcs.reset()
    print(reply)
    reply=gcs.resetcontroller()
    print(reply)

    reply=gcs.abort()
    print(reply)
    reply=gcs.cleararray()
    print(reply)
    reply=gcs.abortexposure()
    print(reply)

    reply=gcs.getdetpars()
    print(reply)

    reply=gcs.get("version")
    print(reply)
    reply=gcs.get("cameratype")
    print(reply)
    reply=gcs.get("servername")
    print(reply)
    reply=gcs.get("vispixels")
    print(reply)

    reply=gcs.getpixelcount()
    print(reply)

    reply=gcs.gettemp()
    print(reply)
    reply=gcs.readtemperature(0)
    print(reply)

    reply=gcs.setexposure(1.234)
    print(reply)
    reply=gcs.setroi(1,100,2,200,1,1)
    print(reply)
    reply=gcs.setparameter("akeyword",42,"a test keyword title")
    print(reply)

    #reply=gcs.guide(1,2)
    #print(reply)
    reply=gcs.expose(1,1.5,"testimage.fits")
    print(reply)
    #reply=gcs.expose1(1,1.5,"testimage.fits")
    #print(reply)

    reply=gcs.setsocket(-1,"myhost",6543)
    print(reply)
    reply=gcs.setsyntheticimage()
    print(reply)

    reply=gcs.resetserver()
    print(reply)

    reply=gcs.closeconnection()
    print(reply)

    return


def test_console():

    import azcam_lbtguiders.console
    assert 1
    return

# run tests
test_gcs()
