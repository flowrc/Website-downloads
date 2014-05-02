//Arduino sketch to record the switching of the reed switch in the rain gauge
//The sketch works by counting the number of times the reed switch has been in the high position

const int REED = 9;      //The reed switch outputs to digital pin 9

int val = 0;            //Current value of reed switch
int old_val = 0;        //Old value of reed switch

int REEDCOUNT = 0;      //The intial count is zero

void setup(){
  
  Serial.begin(9600);
  pinMode (REED, INPUT_PULLUP);    //This activates the internal pull up resistor

}

void loop(){
  
  val = digitalRead(REED);                   //Read the status of the Reed swtich
  
  if ((val == LOW) && (old_val == HIGH)){    //Check to see if the status has changed
    
 delay(10);                                  // Delay put in to deal with any "bouncing" in the switch.
 
 REEDCOUNT = REEDCOUNT + 1;                  //Add 1 to the count of the number of times the bucket has tipped if the status changes
 
 
 old_val = val;
 
 
 Serial.print("Count = ");
 Serial.println(REEDCOUNT);                  //Output the count to the serial monitor
  
}
  else {
    old_val = val;
  }

  
 
}
