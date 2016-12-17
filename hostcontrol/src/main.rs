//!     debug!("this is a debug {}", "message");
//!     error!("this is printed by default");
//!     if log_enabled!(LogLevel::Info) {
//!
//! Start with
//!     RUST_LOG=hostcontrol=info RUST_BACKTRACE=1 cargo run


#![recursion_limit = "1024"]

extern crate serial;
extern crate tokio_core;
extern crate futures;
#[macro_use]
extern crate log;
extern crate env_logger;
#[macro_use]
extern crate error_chain;

pub mod errors;
pub use errors::*;
mod commands;
use commands::Cmds;
mod communication;
use communication::spawn_serial_thread;

use std::io;
use std::sync::mpsc::{Sender};
use std::io::BufReader;

fn main() {
    env_logger::init().unwrap();
    if let Err(ref e) = run_main() {
        print_error(&e);
    }
}

fn print_error(e : &Error) {
    error!("{}", e);

    for e in e.iter().skip(1) {
        error!("caused by: {}", e);
    }

    // The backtrace is not always generated. Try to run this example
    // with `RUST_BACKTRACE=1`.
    if let ErrorKind::Multiple(ref _e1, ref _e2) = e.0 {
        // These print their own backtraces
    } else {
        if let Some(backtrace) = e.backtrace() {
            error!("backtrace: {:?}", backtrace);
        }
    }
}

fn run_main() -> Result<()> {

    let (serialthread, tx) = spawn_serial_thread()?;

    let debug_result = debug_console(tx);

    let serial_result = serialthread.join()
        // Workaround until error_chain supports Result<_, Box>
        .map_err::<Error, _>(|_boxed_err| ErrorKind::ThreadPanic("Serial thread paniced unexpected.".into()).into() )
        .chain_err(|| "Serial thread paniced!")?
        .chain_err(|| "Serial thread returned with `Error`.");


    debug_result.and_1(serial_result)?;

    Ok(())
}





fn debug_console(cmd_tx_chan : Sender<Cmds>) -> Result<()> {

    let reader = BufReader::new(io::stdin());
    print!(">");
    use std::io::{BufRead, Write};
    io::stdout().flush()?;
    for line in reader.lines() {
        let line = line?;
        if line == "h" {
            println!("HELP");
            println!("  q         Quit");
            println!("  w         Servo");
            println!("  i         Invalid");
        } else if line == "q" {
            break;
        } else if line == "w" {
            cmd_tx_chan.send(Cmds::SetServo(commands::SetServoCmd{ servoid : 0, value : 200 }))
                .chain_err(|| "Cound not send cmd to serial thread")?;
        } else if line == "i" {
            cmd_tx_chan.send(Cmds::Invalid(commands::InvalidCmd{ data : [30; 20] }))
                .chain_err(|| "Cound not send cmd to serial thread")?;
        }
        print!(">");
        io::stdout().flush()?;
    }
    Ok(())
}