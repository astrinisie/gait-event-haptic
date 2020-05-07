import settings
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

"""
    This function defines the connection properties of QTM
"""
async def shutdown(delay, connection, receiver_future, queue):

    # wait desired time before exiting
    await asyncio.sleep(delay)

    # make sure package_receiver task exits
    queue.put_nowait(None)
    await receiver_future

    # tell qtm to stop streaming
    await connection.stream_frames_stop()

    # stop the event loop, thus exiting the run_forever call
    loop.stop()

    
"""
    This function determines data formatting to spit out from QTM.
    It is a callback function that is called everytime a data packet arrives from QTM
"""
def on_packet(packet):
    global zForceAll
    
    print("Framenumber: {}".format(packet.framenumber))
    
    # This function returns at every frame:
    # list of all the markers that consists of: x, y, z positions of the marker
    # these markers are arranged in the same order as shown on the right hand panel of QTM software
    header_markers, markers_all = packet.get_3d_markers()
    print("Component info: {}".format(header_markers))
    #for marker in markers_all:
    #    print("\t", marker)
    
    settings.frameNumber.append(packet.framenumber)
    xlHeel = markers_all[4][0]  # this is x position of L_FT1
    xrHeel = markers_all[24][0]  # this is x position of R_FT1
    settings.xlHeelAll.append(xlHeel)
    settings.xrHeelAll.append(xrHeel)
    print("x L_FT1", xlHeel)
    print("x R_FT1", xrHeel)
    
    # This function returns at every frame: 
    # 1) header that descsribes what component this is
    # 2) list of force that consists of: a) force plate info and b) forces info on that plate
    header_force, force_all = packet.get_force_single()
    print("Component info: {}".format(header_force)) 
    zForceH = []
    for plate, force in force_all:
        #print("\t", plate)
        #print("\t", force)
        
        # We want to extract the z-axis force information as this is the most important value that
        # determines whether the person is stepping on the force plate.
        # There are 9 elements inside force (x,y,z forces; x,y,z moment; x,y,z COP).
        # z force will be the 3rd component of index 2 of the list force.
        # To access which for plate it is, access the plate id which is the only element in the list.
        print("z-force is for plate", plate[0], "is", force[2])
        zForceH = np.hstack((zForceH, force[2]))
        
        # Check if motor has been vibrated previously (such that we only send vibration command once only)
        # Check if current plate is equal to target forceplate (such that we call vibration function only when 
        # target forceplate is correct to reduce computation load)
        if settings.has_vibrate == 0 and plate[0] - settings.target_forceplate == 0:
            functionsVibro.force_calculation(force[2], xlHeel, xrHeel, packet.framenumber)

    settings.zForceAll = np.vstack((settings.zForceAll,zForceH))   
    
    
"""
    This function is the 'main' loop function that connects to QTM and streams 3D data forever
    (start QTM first, load file, Play->Play with Real-Time output)
"""        
async def setup():
    """ Main function """
    connection = await qtm.connect("127.0.0.1")
    if connection is None:
        return
    
    # Start recording / playing file in RT when main loop is called in Python
    #await connection.start(rtfromfile=True)

    # Start streaming frames
    await connection.stream_frames(components=["forcesingle","3d"], on_packet=on_packet)

    # This command will make this code run for 5 seconds of real time data on qualisys and stop streaming
    await asyncio.sleep(15)  # Wait/run for 5 seconds
    await connection.stream_frames_stop()  # Stop streaming
    
    logToFile.plot_graphs()
    logToFile.save_to_csv()
    print("GRAPHS PLOTTED AND LOGFILE SAVED")
    
    await connection.stop() # Stop recording RT