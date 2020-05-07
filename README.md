# gait-event-haptic
Triggering haptic cues on a wrist-worn Arduino system based on real-time gait events detected by Qualisys (QTM) motion capture

This package communicates in real-time with QTM. Real-time force and marker data from QTM are fed here, and based on the values, appropriate vibration commands will be sent to the motor via Arduino. Communication with Arduino is through Serial Bluetooth (Bluetooth SPP) that acts as a COM port connection.

Files contained:<br>
main.py<br>
This is the main function to be executed. Edit the COM port and BAUD rate to match the Arduino device accordingly.

settings.py<br>
This file contains all the global variables used throughout.

functionsQTM.py<br>
Contains functions to control and obtain information from Qualisys. Based on https://github.com/qualisys/qualisys_python_sdk.

functionsVibro.py<br>
Contains functions to determine real-time gait event based on information from functionsQTM.py, and send digital signal to Arduino accordingly.

Arduino Files:<br>
twoHapticCues_SPP.ino<br>
Main Arduino code, communicating with PC via Bluetooth SPP.

reactionTimes.ino<br>
Separate Arduino code to log delay between onset of haptic cue delivery and users' reaction.
