

#include "Repetier.h"




void setup()
{
  SET_OUTPUT(LED_PIN);
  WRITE(LED_PIN, 0);

  Communication com;


  for (;;) {
    com.communication_loop();
  }

}

void loop()
{
}
