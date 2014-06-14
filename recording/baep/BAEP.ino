// digital pin 2 is interrupt pin
int clockInt = 0;
// counts rising edge clock signals
int masterClock = 0;

int triggerPin = 12;
int digitalinPin = 10;

// pulse counter
unsigned int pCounter = 0;

boolean statePulse = false;
boolean prevStatePulse = false;


void setup() {
  // clockCounter fucntion is called on a rising clock edge
  attachInterrupt(clockInt, clockCounter, RISING);
  
  pinMode(triggerPin, OUTPUT);
  // this starts our PWM clock at 980 Hz with a 50% duty cycle
  analogWrite(3, 127);
  
  analogReference(DEFAULT);
}

// called by interrupt
void clockCounter() {
  int sensorValue = analogRead(A0);
  float voltage = sensorValue * (5.0 / 1023.0);
  
  if (voltage >= 0.0000001) {
    statePulse = true;
    
    if (statePulse != prevStatePulse) {
      prevStatePulse = true;
      pCounter += 1;
      if (pCounter == 1) {
        digitalWrite(triggerPin, HIGH);
        digitalWrite(digitalinPin, HIGH);
      }
    }    

  } else {
    statePulse = false;
    if (statePulse != prevStatePulse) {
      prevStatePulse = false;
      if (pCounter == 11) {
        digitalWrite(triggerPin, LOW);
        digitalWrite(digitalinPin, LOW);
        pCounter = 0;
      }
    }
    
  }    
    
}

void loop() {
  
}
