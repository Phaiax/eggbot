
#include "Repetier.h"



// Symbols from Repetier stuff
unsigned int counterPeriodical;
volatile uint8_t executePeriodical;


Eggbot::Eggbot() {

}


void Eggbot::move_pen_to_drawing_position() {
    analogWrite(SERVO1_PIN, 10);
}

void Eggbot::move_pen_to_pause_position() {
    analogWrite(SERVO1_PIN, 240);
}