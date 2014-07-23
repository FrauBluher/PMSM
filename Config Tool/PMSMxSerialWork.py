#! /usr/bin/env python

import serial

class PlotData:
	def __init__(self, serialPort, maxLength):
		self.s = serial.Serial(serialPort, 115200)

		self.x = deque([0.0]*maxLength)
		self.y = deque([0.0]*maxLength)

		self.maxLength = maxLength

	def 
