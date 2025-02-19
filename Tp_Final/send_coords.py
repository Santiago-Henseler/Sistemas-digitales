#!/usr/bin/python3

import serial

COORDS_WIDTH = 8

USB = serial.Serial("/dev/ttyUSB0", 115200, timeout=1) # me conecto al puerto usb serie de la pc

with open("coodenadas.txt") as lines:
    for line in lines:
        x = int(float(line.split("\t")[0])*2**(COORDS_WIDTH-1))
        x_signed = True if x < 0 else False
        y = int(float(line.split("\t")[1])*2**(COORDS_WIDTH-1))
        y_signed = True if y < 0 else False
        z = int(float(line.split("\t")[2])*2**(COORDS_WIDTH-1))
        z_signed = True if z < 0 else False

        USB.write((x).to_bytes(1, "big", signed=x_signed))
        USB.write((y).to_bytes(1, "big", signed=y_signed))
        USB.write((z).to_bytes(1, "big", signed=z_signed))
        print(f"Envio ({x},{y},{z})")

USB.close()
