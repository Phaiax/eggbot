use std::boxed::Box;

error_chain! {
    // The type defined for this error. These are the conventional
    // and recommended names, but they can be arbitrarily chosen.
    // It is also possible to leave this block out entirely, or
    // leave it empty, and these names will be used automatically.
    types {
        Error, ErrorKind, ResultExt, Result;
    }

    // Without the `Result` wrapper:
    //
    // types {
    //     Error, ErrorKind, ResultExt;
    // }

    // Automatic conversions between this error chain and other
    // error chains. In this case, it will e.g. generate an
    // `ErrorKind` variant called `Dist` which in turn contains
    // the `rustup_dist::ErrorKind`, with conversions from
    // `rustup_dist::Error`.
    //
    // Optionally, some attributes can be added to a variant.
    //
    // This section can be empty.
    links {
    }

    // Automatic conversions between this error chain and other
    // error types not defined by the `error_chain!`. These will be
    // wrapped in a new error with, in this case, the
    // `ErrorKind::Temp` variant. The description and cause will
    // forward to the description and cause of the original error.
    //
    // Optionally, some attributes can be added to a variant.
    //
    // This section can be empty.
    foreign_links {
        Fmt(::std::fmt::Error);
        Io(::std::io::Error) #[cfg(unix)];
        Serial(::serial::Error);
    }

    // Define additional `ErrorKind` variants. The syntax here is
    // the same as `quick_error!`, but the `from()` and `cause()`
    // syntax is not supported.
    errors {
        NoConnectionToArduino {
            description("Could not reset or connect to arduino")
            display("Could not reset or connect to arduino")
        }
        ArduinoHangUp(s : String) {
            description("Communication with arduino has failed somehow")
            display("Communication with arduino has failed somehow: {}", s)
        }
        ThreadPanic(s : String) {
            description("A thread has paniced")
            display("Thread {} has paniced.", s)
        }
        Multiple(e1 : Box<Error>, e2 : Box<Error>) {
            description("Multiple errors occured")
            display("\r\n>> Error: {}{}\r\n   Backtrace: {:?}\r\n>> Second error: {}{}\r\n   Backtrace: {:?}\r\n",
                e1,
                e1.iter().skip(1).fold("".into(), |s, i| format!("{}\r\n   caused by: {}", s, i)),
                e1.backtrace(),
                e2,
                e2.iter().skip(1).fold("".into(), |s, i| format!("{}\r\n   caused by: {}", s, i)),
                e2.backtrace())
        }
    }
}

pub trait MultipleErrors<T, V> where Self : Sized {
    fn and_1(self, other : Result<V>) -> Result<(T, V)>;
}

impl<T,V> MultipleErrors<T,V> for Result<T> {
    fn and_1(self, other : Result<V>) -> Result<(T, V)> {
        match self {
            Ok(t) => {
                match other {
                    Ok(v) => {
                        Ok((t,v))
                    },
                    Err(ve) => {
                        Err(ve)
                    }
                }
            },
            Err(te) => {
                match other {
                    Ok(_v) => {
                        Err(te)
                    },
                    Err(ve) => {
                        Err(ErrorKind::Multiple(Box::new(te), Box::new(ve)).into())
                    }
                }
            }
        }
    }
}


/* For reference, this is how errors look like

Error(
  Multiple(
    Error(
      Msg("Cound not send cmd to serial thread"),
      State {
        next_error: Some("SendError(..)"),
        backtrace: Some()
      }
    ),
    Error(
      Msg("Serial thread returned with `Error`."),
      State {
        next_error: Some(
          Error(
            ArduinoHangUp("Communication failure: ErrorUnknownType, Try 3 / 3."),
            State {
              next_error: None,
              backtrace: Some()
            }
          )
        ),
        backtrace: Some()
      }
    )
  ),
  State {
    next_error: None,
    backtrace: Some()
  }
)

That means

let e = Error();

e.0 is the ErrorKind
e.1.next_error
e.1.backtrace

// convenience

e.backtrace()
e.iter().next()

*/