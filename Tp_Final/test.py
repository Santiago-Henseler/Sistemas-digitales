#!/usr/bin/python3

import serial

COORDS_WIDTH = 8

USB = serial.Serial("/dev/ttyUSB0", 115200, timeout=1) # me conecto al puerto usb serie de la pc

USB.write((120).to_bytes(1, "big", signed=False))
USB.write((0).to_bytes(1, "big", signed=False))
USB.write((0).to_bytes(1, "big", signed=False))

USB.close()
