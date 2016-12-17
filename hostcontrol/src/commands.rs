

#[repr(C)]
pub struct SetServoCmd {
    pub servoid: u8,
    pub value: u8,
}

#[repr(C)]
pub struct InvalidCmd {
    pub data: [u8; 20],
}

pub enum Cmds {
    SetServo(SetServoCmd),
    Invalid(InvalidCmd),
}


impl Cmds {
    pub fn get_type_id(&self) -> u8 {
        match self {
            &Cmds::SetServo(..) => 1,
            &Cmds::Invalid(..) => 99,
        }
    }
}

#[derive(Debug)]
pub enum Response {
    Success,
    Error,
    ErrorUnknownType,
    ErrorIllegalEscape,
    ErrorMissedEndOfTransmission,
    ErrorOther(u8),
}

impl From<u8> for Response {
    fn from(d : u8) -> Response {
        match d {
            1 => Response::Success,
            2 => Response::Error,
            3 => Response::ErrorUnknownType,
            4 => Response::ErrorIllegalEscape,
            5 => Response::ErrorMissedEndOfTransmission,
            e => Response::ErrorOther(e),
        }
    }
}

