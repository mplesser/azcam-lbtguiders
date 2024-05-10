import os
import socket

import azcam
import azcam.exceptions


def lbtguiders_send(self, localfile, remotefile=None):
    """
    Send image to an LBT guider image server.
    """

    # open image file on disk
    with open(localfile, "rb") as gfile:
        if not gfile:
            raise azcam.exceptions.AzcamError(f"Could not open local image file")
        lSize = os.path.getsize(localfile)
        buff = gfile.read()

    # open socket to LBT image server
    guidesocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    guidesocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 0)

    try:
        guidesocket.connect(
            (self.remote_imageserver_host, self.remote_imageserver_port)
        )
    except Exception as message:
        guidesocket.close()
        raise azcam.exceptions.AzcamError(
            f"LBT guider ImageServer not opened: {message}"
        )

    # send filesize in bytes, \r\n terminated
    sockBuf = "%d\r\n" % lSize
    if guidesocket.send(str.encode(sockBuf)) != len(sockBuf):
        raise azcam.exceptions.AzcamError(f"GuideSocket send error")

    # send file data
    if guidesocket.send(buff) != len(buff):
        raise azcam.exceptions.AzcamError(
            f"Could not send all image file data to LBT ImageServer"
        )

    # close socket
    guidesocket.close()

    return
