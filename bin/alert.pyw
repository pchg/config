#!/usr/bin/env python
# -*-coding=utf-8
import sys
import time 
from PyQt4.QtCore import *
from PyQt4.QtGui  import *
app = QApplication(sys.argv)
try:
	due = QTime.currentTime()
	message = "Alerte!"
	if len(sys.argv) < 2:
		raise ValueError
	hours, mins = sys.argv[1].split(":")
	due = QTime(int(hours), int(mins))
	if not due.isValid():
		raise ValueError
	if len(sys.argv) > 2:
		message = " ".join(sys.argv[2:])
except ValueError:
	message = "Usage: %s HH:MM [optional message]" % sys.argv[0]


while QTime.currentTime() < due:
	time.sleep(20)

label = QLabel("<font color=red size=72><b>" + message + "</b></font>")
label.setWindowFlags(Qt.SplashScreen)
label.show()
QTimer.singleShot(10000, app.quit)
app.exec_()


