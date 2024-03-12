"""
Example to start remote logger for lbtguiders.
"""

from azcam.remote_logger import start_and_serve_tcp

port = 2454

start_and_serve_tcp(port)
