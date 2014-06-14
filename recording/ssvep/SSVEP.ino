// digital pin 2 is interrupt pin
int clockInt = 0;
// counts rising edge clock signals
int masterClock = 0;

int triggerPin = 12;
int digitalinPin = 10;

int triggerState = LOW;

// pulse counter
unsigned int pCounter = 0;

void setup() {
  // clockCounter fucntion is called on a rising clock edge
  attachInterrupt(clockInt, clockCounter, RISING);
  
  pinMode(triggerPin, OUTPUT);
  // this starts our PWM clock at 980 Hz with a 50% duty cycle
  analogWrite(3, 127);
}

// called by interrupt
void clockCounter() {
  masterClock ++;
  // 490  -> 1 Hz
  // 245  -> 2 Hz
  // 98  -> 5 Hz
  // 49  -> 10 Hz
  // 20  -> 24.5
  // 14  -> 35 Hz
  // 12  -> 40 Hz
  // 10  -> 49 Hz
  
  // vep: 550 -> 0.9
  
  // SSVEP:
  // 50 -> 10 Hz
  // 12 -> 40 Hz
  
  if (masterClock == 50) {
    pCounter += 1;
    triggerState = ! triggerState;
    if (pCounter == 1) {
    	digitalWrite(digitalinPin, triggerState);
    }

    if (masterClock == 50) {
      if (pCounter <= 600) {
          digitalWrite(triggerPin, triggerState);
      }
      if (pCounter == 600) {
      	digitalWrite(digitalinPin, triggerState);
      }
    }
    if (masterClock == 12) {
      if (pCounter <= 2400) {
          digitalWrite(triggerPin, triggerState);
      }
      if (pCounter == 2400) {
      	digitalWrite(digitalinPin, triggerState);
      }
    }
    
    masterClock = 0;
  }
  
}

void loop() {
  
}
