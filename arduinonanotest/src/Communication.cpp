
#include "Repetier.h"



Communication::Communication()
    : state(WaitingForCmdType)
    , expected_data_length(0)
    , current_command_type(NoCmd)
    , next_byte_index(0)
    , last_error(Error)
{
    this->init();
}

void blink() {
    WRITE(LED_PIN, 1);
    delay(30);
    WRITE(LED_PIN, 0);
    delay(30);
    WRITE(LED_PIN, 1);
    delay(30);
    WRITE(LED_PIN, 0);
    delay(30);
}

void Communication::init() {
    RFSERIAL.begin(115200);
    blink();
    RFSERIAL.println("EGGBOT");
    blink();

    // expect response EGGCTRL (blocking)
    char eggctrl[8];
    eggctrl[0] = read_blocking(100);
    for (uint8_t i = 1; i < sizeof(eggctrl); i++) {
        eggctrl[i] = read_blocking(20);
    }

    if (strncmp(eggctrl, "EGGCTRL", sizeof(eggctrl)) == 0) {
        WRITE(LED_PIN, 1);
        RFSERIAL.println("UNKNOWN HOST. LOOP FOREVER.");
        for(;;) { }
    }
    blink();
    this->state = WaitingForCmdType;

}

int Communication::read_blocking(uint16_t timeout) {
    while (RFSERIAL.available() == 0 && timeout != 0) {
        timeout -= 1;
        delay(1);
    }
    return RFSERIAL.read();
}


uint8_t Communication::get_data_length(CmdType type) {
    switch (type) {
        case SetServoCmdId:
            return sizeof(SetServoCmd);
    }
    return 0;
}

void Communication::communication_loop() {
    while (RFSERIAL.available() > 0) {
        uint8_t incomingByte = static_cast<uint8_t>(RFSERIAL.read());

        if (incomingByte == 255
         && this->state != ExpectingEndOfTransmission) {
            RFSERIAL.print(static_cast<char>(this->last_error));
            this->state = WaitingForCmdType;
            WRITE(LED_PIN, 0);
            continue;
        }

        switch (this->state) {
            case WaitingForCmdType:
                this->current_command_type = static_cast<CmdType> (incomingByte);
                this->expected_data_length = this->get_data_length(this->current_command_type);
                if (this->expected_data_length == 0) {
                    WRITE(LED_PIN, 1);
                    this->state = WaitingForEndOfTransmissionBecauseOfError;
                    this->last_error = ErrorUnknownType;
                }
                this->state = ReceivingCmdData;
                this->next_byte_index = 0;
                break;
            case ReceivingCmdData:
                if (incomingByte == 27) {
                    this->state = ReceivingCmdDataEscaped;
                    break;
                }
                this->current_command.raw[this->next_byte_index] = incomingByte;
                this->next_byte_index += 1;
                if (this->next_byte_index == this->expected_data_length) {
                    this->state = ExpectingEndOfTransmission;
                }
                break;
            case ReceivingCmdDataEscaped:
                if (incomingByte == 28) {
                    this->current_command.raw[this->next_byte_index] = 27;
                } else if (incomingByte == 29) {
                    this->current_command.raw[this->next_byte_index] = 255;
                } else {
                    WRITE(LED_PIN, 1);
                    this->state = WaitingForEndOfTransmissionBecauseOfError;
                    this->last_error = ErrorIllegalEscape;
                    break;
                }
                this->next_byte_index += 1;
                if (this->next_byte_index == this->expected_data_length) {
                    this->state = ExpectingEndOfTransmission;
                }
            case ExpectingEndOfTransmission:
                if (incomingByte == 255) {
                    this->process_current_cmd();
                    RFSERIAL.print(static_cast<char>(Success));
                    this->state = WaitingForCmdType;
                } else {
                    WRITE(LED_PIN, 1);
                    this->state = WaitingForEndOfTransmissionBecauseOfError;
                    this->last_error = ErrorMissedEndOfTransmission;
                }
                break;
            case WaitingForEndOfTransmissionBecauseOfError:
                // handled by the first if in this while loop
                break;
        }
    }

}


void Communication::process_current_cmd() {
    blink();
}
