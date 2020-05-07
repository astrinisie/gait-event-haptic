/* wristHaptic_rev0.ino

   This program is based on motorMux_Rev2-2_Benchtop_SPP_Vibro.ino
   All communication and serial port is done through USB.
   For Bluetooth SPP serial port, use Serial1 instead of Serial.
   This version is updated in wristHaptic_SPP_rev1.ino

   Programmer: Astrini Sie
   Date: 06.04.2019
*/

#include <SdFat.h>
#include <SPI.h>
#include <Wire.h>
#include "Adafruit_DRV2605.h"

//// DEFINITIONS AND DECLARATIONS FOR DATA LOGGING

// how many milliseconds between grabbing data and logging it. 1000 ms is once a second
#define LOG_INTERVAL  10 // mills between entries (reduce to take more/faster data)
uint32_t logTime = 0; // time since last log

// how many milliseconds before writing the logged data permanently to disk
#define SYNC_INTERVAL 1000 // mills between calls to flush() - to write data to the card
uint32_t syncTime = 0; // time of last sync()

#define ECHO_TO_SERIAL   0 // echo data to serial port
#define WAIT_TO_START    0 // Wait for serial input in setup()

// SD Chip Select is pin 4 for Adafruit Feather M0 Adalogger
const int chipSelect = 4;

// the logging file
SdFat sd;
SdFile logfile;

// user and experimental information
int hasRead = 0;
int subjectNo = 0;
int incomingByte;
int test;

//// DEFINITIONS AND DECLARATIONS FOR HAPTIC DRIVER

#define TCAADDR 0x70  // address of the multiplexer
Adafruit_DRV2605 drv;

char userInput;
char userInputConv;
int motorStatus;
unsigned long startTime = 0;
unsigned long currentTime;
unsigned long interval = 2000;

// change these numbers to the correct SCL and SDA channels at the TCA9458A
int frontMotor = 2;
int backMotor = 3;

//// DEFINITIONS AND DECLARATIONS FOR ANALOG INPUTS
#define clickerTopPin 11
#define clickerFrontPin 12
#define laserVibroPin 14

#define clickerTopLED 18
#define clickerFrontLED 17

int clickerTopInput;
int clickerFrontInput;
int ledTop = 0;
int ledFront = 0;
unsigned long ledStartTime;
long laserVibroInput;

//// USER DEFINED FUNCTIONS

void tcaselect(uint8_t i) {
  // =====
  // This function determines the multiplexer setting for I2C
  // =====

  if (i > 7) return;

  Wire.beginTransmission(TCAADDR);  // multiplexer address
  Wire.write(1 << i);
  Wire.endTransmission();
}

void motorMode() {
  // =====
  // This function sets the different waveforms for the ERM motor according to the
  // profile in the DRV2605L datasheet from TI
  // =====

  drv.setWaveform(0, 14);
  drv.setWaveform(1, 0);
  drv.go();
}

void motorOff() {
  // =====
  // This function turns off motor, opposite of motorMode()
  // =====

  drv.setWaveform(0, 0);
  drv.go();
}

void error(char *str)
{
  // =====
  // Error handling function
  // =====

  Serial1.print("error: ");
  Serial1.println(str);

  // red LED indicates error
  digitalWrite(13, HIGH);

  while (1);
}

void logToFile() {
  // =====
  // This function setup the logging process to SD card
  // =====

  // SETTING UP SD CARD
  // ---------------------------------------------------------------------------------------------
  // initialize the SD card
  Serial1.println("Initializing SD card...");
  // make sure that the default chip select pin is set to
  // output, even if you don't use it:
  pinMode(chipSelect, OUTPUT);

  // see if the card is present and can be initialized:
  if (!sd.begin(chipSelect, SD_SCK_MHZ(50))) {
    sd.initErrorHalt();
  }
  Serial1.println("card initialized.");

  // ENTERING USER AND EXPERIMENT INFO
  // ---------------------------------------------------------------------------------------------
  Serial1.print("Enter subject number (from 0 to 999): \n");

  // keeps looping until user enters a number. this is required otherwise if there
  // is nothing in the serial monitor, the subsequent lines of codes will be skipped
  // because this is not in the loop class.
  //
  // for entering multi digit integers in serial monitor, follow this tutorial:
  // https://www.baldengineer.com/arduino-multi-digit-integers.html
  //
  // ******************VERY IMPORTANT***********************
  // Change the line ending setting of the serial monitor to "Newline" instead of the default "Both NL & CR".
  // Otherwise the numbers read from the serial port will show error.
  while (!hasRead) {
    if (Serial1.available() > 0) {   // something came across serial
      hasRead = 1;
      subjectNo = 0;         // throw away previous subjectNo
      while (1) {            // force into a loop until '\n' is received
        incomingByte = Serial1.read();
        Serial1.print(incomingByte);
        if (incomingByte == '\n') break;   // exit the while(1), we're done receiving. CHANGE THE SERIAL MONITOR SETTING TO NEWLINE
//        if (incomingByte == -1) continue;  // if no characters are in the buffer read() returns -1
//        if (incomingByte > 57) {           // check if all the characters input are valid (from 0 to 9)
//          error("Character input is invalid. Reset the program and try again.");
//        }
//
//        subjectNo *= 10;  // shift left 1 decimal place. this line will only work when there is multiple digits (second encounter in while loop)
//        // convert ASCII to integer, add, and shift left 1 decimal place
//        subjectNo = ((incomingByte - 48) + subjectNo);
//        if (subjectNo > 999) {
//          error("Max subject number is 999.");
        }
      }

      if (incomingByte){
        Serial1.print("Subject number entered: ");
        Serial1.println(incomingByte);   // Do something with the value
      }
  }

  // SETTING UP DATA LOG
  // ---------------------------------------------------------------------------------------------
  // create a new file
  subjectNo = incomingByte;
  char filename[] = "S000E000.csv";
  filename[1] = subjectNo / 100 + '0';
  filename[2] = (subjectNo % 100) / 10 + '0';
  filename[3] = (subjectNo % 100) % 10 + '0';
  for (uint8_t i = 0; i < 1000; i++) {
    filename[5] = i / 100 + '0';
    filename[6] = (i % 100) / 10 + '0';
    filename[7] = (i % 100) % 10 + '0';
    if (! sd.exists(filename)) {
      break;
      // only assigns a name for a new file if it doesn't exist
    }
  }

  if (!logfile.open(filename, O_CREAT | O_WRITE | O_EXCL)) {
    error("couldnt create file");
  }

  Serial1.print("Logging to: ");
  Serial1.println(filename);
}

void setup() {
  Wire.begin();
  Serial1.begin(9600);
  Serial1.print("Setting Up");

  // Setting up log file
  logToFile();

  // Setting up multiplexer and motor
  tcaselect(frontMotor);
  drv.selectLibrary(1);
  drv.setMode(DRV2605_MODE_INTTRIG);
  // haptic driver address connected to channel 2 of multiplexer
  drv.begin();

  tcaselect(backMotor);
  drv.selectLibrary(1);
  drv.setMode(DRV2605_MODE_INTTRIG);
  drv.begin();

  // Setting up analog inputs
  pinMode(clickerTopPin, INPUT_PULLUP);
  pinMode(clickerFrontPin, INPUT_PULLUP);
  pinMode(laserVibroPin, INPUT);
  pinMode(clickerTopLED, OUTPUT);
  digitalWrite(clickerTopLED, LOW);
  pinMode(clickerFrontLED, OUTPUT);
  digitalWrite(clickerFrontLED, LOW);

  //logfile.println("millis,motorStatus,clickerTopInput,clickerFrontInput,laserVibroInput");
#if ECHO_TO_SERIAL
  Serial1.println("millis,motorStatus,clickerTopInput,clickerFrontInput,laserVibroInput");
#endif //ECHO_TO_SERIAL
}

void loop() {
  if (millis() - logTime >= LOG_INTERVAL) {
    logTime = millis();

    // delay for the amount of time we want between readings
     delay((LOG_INTERVAL -1) - (millis() % LOG_INTERVAL));

    // TIMING
    // ---------------------------------------------------------------------------------------------
    // log milliseconds since starting
    logfile.print(logTime);
    logfile.print(", ");
#if ECHO_TO_SERIAL
    Serial1.print(logTime);
    Serial1.print(", ");
#endif

    // MOTOR
    // ---------------------------------------------------------------------------------------------
    // Reading from serial to get user input on motor vibration
    if (Serial1.available() > 0) {

      userInput = Serial1.read();
      userInputConv = userInput - 48;

      if (userInputConv == 1) {
        motorStatus = 1;
        startTime = millis();
      }
      else if (userInputConv == 2) {
        motorStatus = 2;
        startTime = millis();
      }
      else if (userInputConv == 0) {
        motorStatus = 0;
      }
    }

    // Send appropriate command to motor after reading from Serial.
    // Note that this has to be in a separate if loop such that the motor vibration
    // will still be executed even though user is not continuously inputting a command
    // into serial. So, user command has to be only executed once.
    // motorStatus will be reset at the end of the loop if "interval" has passed.
    if (motorStatus == 1) {
      // Front Motor
      tcaselect(frontMotor);
      //Serial.println("Front motor here");
      motorMode();
    }
    else if (motorStatus == 2) {
      // Back Motor
      tcaselect(backMotor);
      motorMode();
    }
    else if (motorStatus == 0) {
      tcaselect(frontMotor);
      motorOff();
      tcaselect(backMotor);
      motorOff();
    }

    logfile.print(motorStatus);
    logfile.print(", ");
#if ECHO_TO_SERIAL
    Serial1.print(motorStatus);
    Serial1.print(", ");
#endif


    // HANDHELD CLICKER
    // ---------------------------------------------------------------------------------------------
    // These digital channels are set to INPUT PULLUP since 
    // the switches are connected to GND. If it's just regular INPUT, we can't
    // distinguish when the switches are connected or not.
    clickerTopInput = digitalRead(clickerTopPin);
    clickerFrontInput = digitalRead(clickerFrontPin);

    // Turning on LED if switches are pressed
    if (clickerTopInput == 0) {
      digitalWrite(clickerTopLED, HIGH);
    }
    else if (clickerTopInput == 1) {
      digitalWrite(clickerTopLED, LOW);
    }
    if (clickerFrontInput == 0) {
      digitalWrite(clickerFrontLED, HIGH);
    }
    else if (clickerFrontInput == 1) {
      digitalWrite(clickerFrontLED, LOW);
    }

    logfile.print(clickerTopInput);
    logfile.print(", ");
    logfile.print(clickerFrontInput);
    logfile.print(", ");
#if ECHO_TO_SERIAL
    Serial1.print(clickerTopInput);
    Serial1.print(", ");
    Serial1.print(clickerFrontInput);
    Serial1.print(", ");
#endif

    // LASER VIBROMETER
    // ---------------------------------------------------------------------------------------------

    laserVibroInput = analogRead(laserVibroPin);

    logfile.print(laserVibroInput);
    logfile.println();
#if ECHO_TO_SERIAL
    Serial1.print(laserVibroInput);
    Serial1.println();
#endif

    // END TIMING
    // ---------------------------------------------------------------------------------------------
    // Check if time interval for motor vibration has elapsed
    currentTime = millis();
    if ( (currentTime - startTime > interval) ) {
      motorStatus = 0;
    }

//    if ( (currentTime - ledStartTime > 2000) ) {
//      ledTop = 0;
//      ledFront = 0;
//    }

    // Check if it is time to sync
    if ((millis() - syncTime) >= SYNC_INTERVAL) {
      syncTime = millis();

      Serial1.print(logTime);
      Serial1.print(", ");
      Serial1.print(motorStatus);
      Serial1.print(", ");
      Serial1.print(clickerTopInput);
      Serial1.print(", ");
      Serial1.print(clickerFrontInput);
      Serial1.print(", ");
      Serial1.print(laserVibroInput);
      Serial1.println();
    }
  }
  logfile.flush();
}
