# Importing QTM modules
import asyncio
import qtm

# Importing serial communication modules
import serial
import time

# Importing other modules
import numpy as np
import pandas as pd

def init():
    # Defining global variables to save gait data recorded
    global frameNumber
    global zForceAll
    global xlHeelAll
    global xrHeelAll
    frameNumber = []
    zForceAll = [0, 0, 0, 0]
    xlHeelAll = []
    xrHeelAll = []

    # Global variables for computation
    global has_vibrate
    global force_prevFrame
    global vibration_frame
    global vibration_frame_arr
    global frame_elapsed
    has_vibrate = 0
    force_prevFrame = 0
    vibration_frame = 0
    frame_elapsed = 0
    
    global experiment_name
    global target_forceplate
    global stim_phase
    global target_motor