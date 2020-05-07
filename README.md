# gait-event-haptic
Triggering haptic cues on a wrist-worn Arduino system based on real-time gait events detected by Qualisys (QTM) motion capture

Qualisys (QTM) <====> PC (Python interface code) <===Bluetooth SPP===> Adafruit Feather <====> Haptic Motors / Electronics

Python files communicates in real-time with the QTM software and the Arduino modules that controls the wrist-worn haptic motors. QTM software sends real-time force and marker data into the Python code. The Python code detects real-time gait events based on these sensor data, and send appropriate command to Arduino. Arduino receives command from Python via Bluetooth SPP, and activate haptic motors accordingly.

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
