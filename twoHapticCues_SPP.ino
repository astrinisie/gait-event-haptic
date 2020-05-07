/* motorMux.ino
 * 
 * This program controls the vibration motor through the DRV2605 (based on Adafruit's Library)
 * using the TCA9548 I2C Multiplexer.
 * 
 * Programmer: Astrini Sie
 * Date: 12.11. 2017
 * 
 * Rev 1 dated 12.11.2017
 * Simplifying the motorMode() function so that it can be declared once and used repeatedly.
 * 
 * Rev 2 dated 11.07.2018
 * Turning 2 motors ON/OFF based on a command from serial
 * 
 * Rev 2 SPP dated 11.20.2018
 * Integrating Bluetooth SPP to communicate with PC without a USB cable.
 * 
 * Rev 2 SPP Feather
 * Changing Bluetooth (software serial) to Serial1 to accommodate Feather's mode of communication
 * using bluetooth.
 * Serial = USB / keyboard
 * Serial1 = Bluetooth
 * 
 * Rev 3 dated 01.22.2019
 * Removing all the unneccessary print characters in Serial1.
 * With Rev2, after about 5 cycle of vibration, the motors stop vibrating.
 * This is either due to bluetooth connection stall, or Serial input stopped being read.
 * When I tested in the UNO by not printing any characters in Bluetooth Serial, the continuous vibration
 * mode (infinite_vibro cell) works.
 */

#include <Wire.h>
#include "Adafruit_DRV2605.h"

#define TCAADDR 0x70
Adafruit_DRV2605 drv;

//#include <SoftwareSerial.h>
//SoftwareSerial Bluetooth(10, 9); // TX is Digital 10 and RX is Digital 9

char userInput;
char userInputConv;
int motorStatus;
unsigned long startTime = 0;
unsigned long currentTime;
unsigned long interval = 2000;

int frontMotor = 2;
int backMotor = 3;

void tcaselect(uint8_t i) {
  if (i > 7) return;
 
  Wire.beginTransmission(TCAADDR);  // multiplexer address
  Wire.write(1 << i);
  Wire.endTransmission();  
}

void motorMode() {
  drv.setWaveform(0, 14);
  drv.setWaveform(1, 0);
  drv.go();  
}

void motorOff() {
  drv.setWaveform(0,0);
  drv.go();
}

void setup() {
  Wire.begin();
  
  Serial1.begin(9600);
  //Serial1.println("Setting Up");

  //Serial.begin(38400);
  //Serial.println("Setting Up");
  
  tcaselect(frontMotor);
  drv.selectLibrary(1);
  drv.setMode(DRV2605_MODE_INTTRIG);  // haptic driver address connected to channel 2 of multiplexer
  //drv.useLRA(); // commenting this line as it will cause error to some of the motors
  drv.begin();

  tcaselect(backMotor);
  drv.selectLibrary(1);
  drv.setMode(DRV2605_MODE_INTTRIG);
  //drv.useLRA();
  drv.begin();
  
  //Serial1.println("Motor initialized");
  //Serial1.println("To turn on front motor, enter 1");
  //Serial1.println("To turn on back motor, enter 2");
  //Serial1.println("To turn off motor, enter 0");
}

void loop() {
  //Serial.print("loop");
    
  // Reading from serial to get user input on motor vibration
  if (Serial1.available() > 0) {
    
    userInput = Serial1.read();
    //Serial1.println(userInput, DEC);
    userInputConv = userInput - 48;
    
    if (userInputConv == 1) {
      motorStatus = 1;
      Serial1.println("1");
      startTime = millis();
      //Serial1.print("Start time of front motor is ");
      //Serial1.println(startTime);
    }
    else if (userInputConv == 2) {
      motorStatus = 2;
      Serial1.println("2");
      startTime = millis();
      //Serial1.print("Start time of back motor is ");
      //Serial1.println(startTime);
    }
    else if (userInputConv == 0) {
      motorStatus = 0;
    }
    else if (userInputConv == 3) {
      motorStatus = 3;
    }
  }

  // Send appropriate command to motor after reading from Serial.
  // Note that this has to be in a separate if loop such that the motor vibration
  // will still be executed even though user is not continuously inputting a command
  // into serial. So, user command has to be only executed once.
  if (motorStatus == 1) {
    //Serial1.println("Vibrate front motor");
      
    // Front Motor
    tcaselect(frontMotor);
    motorMode();
  }
  else if (motorStatus == 2) {
    //Serial1.println("Vibrate back motor");

    // Back Motor
    tcaselect(backMotor);
    motorMode();
  }
  else if (motorStatus == 0) {
    //Serial1.println("Motor off");
      
    tcaselect(frontMotor);
    motorOff();
    tcaselect(backMotor);
    motorOff();
  }

  // Check timing
  currentTime = millis();
  //Serial1.println(currentTime);
  if ( (currentTime - startTime > interval) ) {
    //Serial1.print("Elapsed time is ");
    //Serial1.println(currentTime - startTime);
    //Serial1.println("Interval passed, turning motor off");
    motorStatus = 0;
  }

  // wait a bit
  delay(100);
}
