// digital pin 2 is interrupt pin
int clockInt = 0;
// counts rising edge clock signals
int masterClock = 0;

int triggerPin = 12;
int digitalinPin = 10;

int triggerState = LOW;

int winLen = 548;

// pulse counter
int pCounter = 0;

void setup() {
  // clockCounter fucntion is called on a rising clock edge
  attachInterrupt(clockInt, clockCounter, RISING);
  
  pinMode(triggerPin, OUTPUT);
  // this starts our PWM clock at 980 Hz with a 50% duty cycle
  analogWrite(3, 127);
  
  // initialize state of LED and Digital-in pins    
  digitalWrite(digitalinPin, triggerState);
  digitalWrite(triggerPin, triggerState);
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
  
  if (masterClock == winLen) {
    pCounter += 1;
    triggerState = ! triggerState;
    masterClock = 0;
    if (pCounter <= 180) {
      digitalWrite(digitalinPin, triggerState);
      digitalWrite(triggerPin, triggerState);
    }
  }
  
}

void loop() {
  
}
