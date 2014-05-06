/*
Arduino sketch to record the switching of the reed switch in the rain gauge
The sketch work by counting the number of times the reed switch has changed position
The sketch has been extended to include code to log the analogue reading from the rain detector
Version XB - code has been reduce to remove the rain sensor functionality
*/


#include <SD.h>          //Ensure that you downlaod these libraries and store them in your Arduino libraries folder 
#include <Wire.h>        //Remember no semi-colon after these commands
#include "RTClib.h"


const int REED = 9;     //The reed switch outputs to digital pin 9

int val = 0;            //Current value of reed switch
int old_val = 0;        //Old value of reed switch

int REEDCOUNT = 0;      //The intial count is zero

const int chipSelect = 10;
File logfile;
#define SYNC_INTERVAL 60000
uint32_t syncTime = 0; // time of last sync()

const int redLEDpin = 3;
const int greenLEDpin = 2;

RTC_DS1307 RTC; // define the Real Time Clock object

/////////////Program Set-up/////////////////////////////////////////////////////////////////////

void setup(void){
  
  Serial.begin(9600);
  pinMode (REED, INPUT_PULLUP);  //Activate the internal pull-up resistor
  pinMode(greenLEDpin, OUTPUT);
  pinMode(redLEDpin, OUTPUT);

  
/////////////Setting up the file on the SD Card///////////////////////////////

  Serial.println("Initializing SD card...");
  pinMode(10, OUTPUT);  // make sure that the default chip select pin is set to output
  
  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
  }
  Serial.println("card initialized.");
  
  // create a new file
  char filename[] = "LOGGER00.CSV";      //The file names must be in the 8.3 format
  for (uint8_t i = 0; i < 100; i++) {
    filename[6] = i/10 + '0';
    filename[7] = i%10 + '0';
    if (! SD.exists(filename)) {
      // only open a new file if it doesn't exist
      logfile = SD.open(filename, FILE_WRITE); 
      break;  // leave the loop!
    }
  }
  
  if (! logfile) {
    Serial.println("could not create file");
  }
  
  Serial.print("Logging to: ");
  Serial.println(filename);

//Connect to RTC
Wire.begin();
  if (!RTC.begin()) {
    logfile.println("RTC failed");
  }
Serial.println("channel, Reading/count, date, time");
logfile.println("channel, Reading/count, date, time");  
}
///////////////////The Program Loop//////////////////////////////////////////////////////////////////////
void loop(){
  
 DateTime now;    // and record date/time of change
  
  val = digitalRead(REED);
 
 //Low means that the Reed switch is open (which happens when the magnet passess).
  
  if ((val == LOW) && (old_val == HIGH)){
    
 delay(10);    // Delay put in to deal with any "bouncing" in the switch.
 
 REEDCOUNT = REEDCOUNT + 1;
 
now = RTC.now();
 
 old_val = val;
 
 digitalWrite(redLEDpin, HIGH);
  
 char buf1[50];
 
 Serial.print("Reedcount");
 Serial.print(", ");
 Serial.print(REEDCOUNT);
 Serial.print(", ");
 
 sprintf(buf1, "%02d/%02d/%02d, %02d:%02d:%02d", now.day(), now.month(), now.year(), now.hour(), now.minute(), now.second());
 Serial.println(buf1);
 
 logfile.print("Reedcount");
 logfile.print(", ");
 logfile.print(REEDCOUNT);
 logfile.print(", ");
 logfile.println(buf1);
 
 digitalWrite(redLEDpin, LOW);

}
  else {
    old_val = val;
  }

  if ((millis() - syncTime) < SYNC_INTERVAL) return;
  digitalWrite(greenLEDpin, HIGH);
  delay(10);
  logfile.flush();
  digitalWrite(greenLEDpin, LOW);
  syncTime = millis();
 
 }
 
