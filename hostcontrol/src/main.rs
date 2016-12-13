extern crate serial;

use std::io;
use std::time::Duration;
use std::thread;

use serial::prelude::*;

fn main() {
    let port = "/dev/ttyUSB0";

    let mut port = serial::open(&port).unwrap();
    let serialthread = thread::spawn(move || {
        interact(&mut port).unwrap();
    });

    serialthread.join().unwrap();
}

fn interact<T: SerialPort>(port: &mut T) -> io::Result<()> {
    try!(port.reconfigure(&|settings| {
        try!(settings.set_baud_rate(serial::Baud115200));
        settings.set_char_size(serial::Bits8);
        settings.set_parity(serial::ParityNone);
        settings.set_stop_bits(serial::Stop1);
        settings.set_flow_control(serial::FlowNone);
        Ok(())
    }));

    reset_arduino(port)?;

    test_speed(port)?;


    Ok(())
}

fn reset_arduino<T: SerialPort>(port: &mut T) -> io::Result<()> {
    port.set_timeout(Duration::from_millis(3000))?;
    println!("Reset Arduino ...");
    port.set_dtr(false)?;
    let mut input = vec![];
    input.resize(6, 0);
    port.read_exact(&mut input[0..6])?;
    port.set_dtr(true)?;
    println!("Got Greeting");
    port.set_timeout(Duration::from_millis(1000))?;
    Ok(())
}

fn test_speed<T: SerialPort>(port: &mut T) -> io::Result<()> {

    let mut

}