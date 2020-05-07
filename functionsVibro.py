import settings

# Importing QTM modules
import asyncio
import qtm

# Importing serial communication modules
import serial
import time

# Importing other modules
import numpy as np
import pandas as pd


"""
    This function takes in the force plate number (plate) and the actual z-force value (force)
    to determine when heel strike happened at that particular force plate number.
    If heel strikes the target force plate given by user (target_forceplate), then vibrate motor.
"""
def force_calculation(force, xlHeel, xrHeel, framenumber):
    
    # S1: Right Heel Strike
    if settings.stim_phase == 1:
        if force >= 0:  # heel strikes force plate
            if xlHeel > xrHeel: # safety condition to check if that's the right foot. right heel in front of left heel (lower x coord value)
                print("S1: Right Heel Strike")
                settings.vibration_frame = framenumber
                vibrate_motor()
                settings.has_vibrate = 1
    
    # S2: Left Toe Off
    elif settings.stim_phase == 2:
        if settings.force_prevFrame > 0 and force < 0:  # toe lifting off force plate
            if xlHeel > xrHeel:  # safety condition to check if that's the left foot
                print("S2: Left Toe Off")
                settings.vibration_frame = framenumber
                vibrate_motor()
                settings.has_vibrate = 1
            
    # S3: Left Foot Midswing
    elif settings.stim_phase == 3:
        if force >= 0:
            if xlHeel <= xrHeel:  # when left heel crosses right heel (start from +x coordinate, decreases to 0 towards the furthest away force plate)
                print("S3: Left Foot Midswing")
                settings.vibration_frame = framenumber
                vibrate_motor()
                settings.has_vibrate = 1
    
    # S4: Left Heel Strike
    if settings.stim_phase == 4:
        if force >= 0:
            if xlHeel < xrHeel:
                print("S4: Left Heel Strike")
                settings.vibration_frame = framenumber
                vibrate_motor()
                settings.has_vibrate = 1
                
    # S5: Right Toe Off
    if settings.stim_phase == 5:
        if force_prevFrame > 0 and force < 0:
            if xlHeel < xrHeel:
                print("S5: Right Toe Off")
                settings.vibration_frame = framenumber
                vibrate_motor()
                settings.has_vibrate = 1
                
    # S6: Right Foot Midswing
    elif settings.stim_phase == 6:
        if force > 0:
            if xlHeel >= xrHeel:
                print("S6: Right Foot Midswing")
                settings.vibration_frame = framenumber
                vibrate_motor()
                settings.has_vibrate = 1
    
    print("Force prev frame", settings.force_prevFrame)
    settings.force_prevFrame = force
    print("Force now", settings.force_prevFrame)
    print("Frame elapsed", settings.frame_elapsed)
    

"""
    This function vibrates the motor by sending appropriate command to the Arduino.
    The Arduino has been pre-programmed earlier using the Arduino IDE. Python solely provides serial input to the Arduino.
"""
def vibrate_motor():
    if settings.target_motor == 1:
        ArduinoSerial.write(b'1')
        time.sleep(2)
        print("Vibrating motor 1", target_motor)
    elif settings.target_motor == 2:
        ArduinoSerial.write(b'2')
        time.sleep(2)
        print("Vibrating motor 2", target_motor)
       
    
    time.sleep(2)