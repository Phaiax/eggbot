
#include "Repetier.h"



// Symbols from Repetier stuff
unsigned int counterPeriodical;
volatile uint8_t executePeriodical;


Eggbot::Eggbot() {

}


void Eggbot::move_servo0(uint8_t position) {
    analogWrite(SERVO0_PIN, position);
}

void Eggbot::move_servo1(uint8_t position) {
    analogWrite(SERVO1_PIN, position);
}
