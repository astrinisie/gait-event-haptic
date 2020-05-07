import settings
import functionsQTM
import functionsVibro
import logToFile

# Importing QTM modules
import asyncio
import qtm

# Importing serial communication modules
import serial
import time

# Importing other modules
import numpy as np
import pandas as pd

settings.init()

"""
    Running the program indefinitely
    NOTE: Make sure that before running this:
    1) QTM is up and running
    2) If using an existing file, click Play > Play with Real-Time Output
"""

# Arduino setup
ArduinoSerial = serial.Serial('COM5', 9600, timeout=0)

"""
ArduinoSerial.write(b'1')
time.sleep(2)
ArduinoSerial.write(b'2')
time.sleep(2)
"""


# Running and logging setup
settings.has_vibrate = 0
settings.force_prevFrame = 0
settings.frame_elapsed = 0

# Entering Subject and Experiment number for filename saving
settings.experiment_name = str(input("Please enter subject and experiment number (S000E000): "))

# Defining stimulation phase
settings.stim_phase = int(input("Please enter stimulation condition (1 to 6): "))

# Defining target_forceplate as global variable obtained from user input through keyboard
settings.target_forceplate = int(input("Please enter target force plate (1 to 4): "))

# Defining target_motor as global variable obtained from user input through keyboard.
# This value is to be sent to Arduino via serial.
settings.target_motor = int(input("Please enter motor to vibrate (1 for dorsal, 2 for palmar): "))


# Running QTM
if __name__ == "__main__":
    asyncio.ensure_future(functionsQTM.setup())
    asyncio.get_event_loop().run_forever()
    
    print("HERE TOO") # never printed
    #asyncio.get_event_loop().run_until_complete(setup())
    

    
