
#ifndef COMMUNICATION_H
#define COMMUNICATION_H

/// Protocol
///
/// Bytevalue 255 indicates end of transmission
/// If Bytevalue 255 is send during data stage, it has to be escaped
/// Escaping value is 27.
/// Valid escape sequences are: [27 28] which means 27
///                             [27 29] which means 255


enum ReceivingState {
    WaitingForCmdType = 1,
    ReceivingCmdData = 2,
    ReceivingCmdDataEscaped = 3,
    ExpectingEndOfTransmission = 4,
    WaitingForEndOfTransmissionBecauseOfError = 5
};

enum CmdType {
    NoCmd = 0,
    SetServoCmdId = 1
};

enum Response {
    Success = 1,
    Error = 2,
    ErrorUnknownType = 3,
    ErrorIllegalEscape = 4,
    ErrorMissedEndOfTransmission = 5
};

struct SetServoCmd {
    uint8_t servoid;
    uint8_t value;
};

union Cmd {
    uint8_t raw[32];
    SetServoCmd setServo;
};

class Communication {
    ReceivingState state;
    uint8_t expected_data_length;
    Cmd current_command;
    CmdType current_command_type;
    uint8_t next_byte_index;
    Response last_error;
public:
    /// Init
    Communication();
    void init();
    int read_blocking(uint16_t timeout);
    void communication_loop();
    uint8_t get_data_length(CmdType type);
    void process_current_cmd();
};


#endif