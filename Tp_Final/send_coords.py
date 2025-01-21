#!/usr/bin/python3

import serial

COORDS_WIDTH = 8
LINES_TOTAL = 10923

with open('coordenadas.txt') as fp, serial.Serial('/dev/ttyUSB0', 115200, timeout=1) as serial:
    for line in fp:
        x = int(float(line.split('\t')[0])*2**(COORDS_WIDTH-1))
        x_signed = True if x < 0 else False
        y = int(float(line.split('\t')[1])*2**(COORDS_WIDTH-1))
        y_signed = True if y < 0 else False
        z = -1*int(float(line.split('\t')[2])*2**(COORDS_WIDTH-1))
        z_signed = True if z < 0 else False

        serial.write((x).to_bytes(1, 'big', signed=x_signed))
        serial.write((y).to_bytes(1, 'big', signed=y_signed))
        serial.write((z).to_bytes(1, 'big', signed=z_signed))
