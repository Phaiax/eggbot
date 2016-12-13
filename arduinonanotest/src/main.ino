

int ledPin = 13;                 // LED connected to digital pin 13
bool ledState = false;
int incomingByte = 0;

void setup()
{
  pinMode(ledPin, OUTPUT);      // sets the digital pin as output
  digitalWrite(ledPin, HIGH);   // sets the LED on
  delay(50);                  // waits for a second
  digitalWrite(ledPin, LOW);   // sets the LED on
  delay(50);                  // waits for a second
  digitalWrite(ledPin, HIGH);   // sets the LED on
  delay(50);                  // waits for a second
  digitalWrite(ledPin, LOW);   // sets the LED on
  delay(50);                  // waits for a second
  Serial.begin(115200);
  delay(500);                  // waits for a second
  Serial.println("EGGBOT");
}

void loop()
{
    // send data only when you receive data:
    if (Serial.available() > 0) {
        // read the incoming byte:
        incomingByte = Serial.read();

        // say what you got:
        Serial.print(static_cast<char>(incomingByte));
        if (ledState) {
            digitalWrite(ledPin, HIGH);   // sets the LED on
        } else {
            digitalWrite(ledPin, LOW);    // sets the LED off
        }
        ledState = !ledState;
    }

}