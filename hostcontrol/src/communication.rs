
use serial::prelude::*;
use std::sync::mpsc::{channel, Receiver, Sender};
use commands::{Cmds, Response};
use errors::*;
use serial;
use std;
use std::time::Duration;
use std::io;
use std::thread::{JoinHandle, spawn};

/// Spawns a thread for serial communicaton.
/// The new thread exits with `Err` if an error occured
/// or with `Ok` if the `Sender` side of the channel is dropped.
pub fn spawn_serial_thread() -> Result<(JoinHandle<Result<()>>, Sender<Cmds>)> {
    let (tx, rx) = channel();

    let mut port : Result<_> = Err(ErrorKind::Msg("dummy".into()).into());
    for i in 0..3 {
        let portpath = format!("/dev/ttyUSB{}", i);
        port = serial::open(&portpath).chain_err(|| "Unable to open serial port.");
        if port.is_ok() {
            break;
        }
    }
    let mut port = port?;

    reset_arduino(&mut port)?; // Blocking

    let handle = spawn(move || run_serial(&mut port, rx));

    Ok((handle, tx))
}

/// Main function of the serial communication thread.
///
/// This function takes commands from the mpsc channel and executes them, that means
/// sends them to the arduino.
///
/// On data error it retries three times before giving up with ErrorKind::ArduinoHangUp.
/// This drops the mspc channel so other program parts that may hold a clone of the
/// sender side of the channel can do no direct harm since they send to /dev/null
///
fn run_serial<T: SerialPort>(port: &mut T, cmd_rx_chan: Receiver<Cmds>) -> Result<()> {

    process_cmds(port, &cmd_rx_chan)?;

    Ok(())
}

fn process_cmds<T: SerialPort>(port: &mut T, cmd_rx_chan: &Receiver<Cmds>) -> Result<()> {
    for cmd in cmd_rx_chan.iter() {

        let number_of_tries = 3;

        for i in 1..number_of_tries + 1 {
            match execute_cmd(port, &cmd)? {
                Response::Success => {
                    break;
                },
                e => {
                    let errmsg = format!("Communication failure: {:?}, Try {} / {}.",
                                         e,
                                         i,
                                         number_of_tries);
                    if i == number_of_tries {
                        return Err(ErrorKind::ArduinoHangUp(errmsg).into());
                    } else {
                        info!("{}", errmsg);
                    }
                    continue;
                }
            }
        }
    }
    Ok(())
}

fn reset_arduino<T: SerialPort>(port: &mut T) -> Result<()> {
    port.reconfigure(&|settings| {
            try!(settings.set_baud_rate(serial::Baud115200));
            settings.set_char_size(serial::Bits8);
            settings.set_parity(serial::ParityNone);
            settings.set_stop_bits(serial::Stop1);
            settings.set_flow_control(serial::FlowNone);
            Ok(())
        })
        .chain_err(|| "Unable to configure serial port.")?;

    port.flush()?;
    empty_read_buffer(port)?;
    port.set_timeout(Duration::from_millis(3000))?;
    port.set_dtr(false)?;
    std::thread::sleep(Duration::from_secs(2));
    let mut input = vec![];
    input.resize(6, 0);
    port.read_exact(&mut input[0..6])?;
    port.set_dtr(true)?;
    port.set_timeout(Duration::from_millis(0))?;
    if input == b"EGGBOT" {
        port.write_all(b"EGGCTRL")?;
        Ok(())
    } else {
        Err(ErrorKind::NoConnectionToArduino.into())
    }
}

fn execute_cmd<T: SerialPort>(port: &mut T, cmd: &Cmds) -> Result<Response> {

    empty_read_buffer(port)?;

    let cmdtypeid = cmd.get_type_id();
    let data: &[u8] = extract_data(&cmd);

    port.write_all(&[cmdtypeid])?;
    port.write_all(data)?;
    port.write_all(&[255])?; // 255 = end of transmission
    port.flush()?;

    read_result_byte(port)
}

/// Unsafe but because of the function definition lifetimes the cmd is not moved
/// as long as a pointer to the data exists.
fn extract_data<'a>(cmd: &'a Cmds) -> &'a [u8] {

    // NOTE: Must not use '&' in front of the two occurences of cmd_data

    match cmd {
        &Cmds::SetServo(ref cmd_data) => {
            unsafe {
                std::slice::from_raw_parts(cmd_data as *const _ as *const u8,
                                           std::mem::size_of_val(cmd_data))
            }
        }

        &Cmds::Invalid(ref data) => unsafe {
            std::slice::from_raw_parts(data as *const _ as *const u8, std::mem::size_of_val(data))
        },
    }
}

#[test]
fn test_extract_data() {
    use commands::SetServoCmd;
    let cmd = Cmds::SetServo(SetServoCmd{ servoid : 12, value : 44} );
    let raw = extract_data(&cmd);
    assert_eq!(raw[0], 12);
    assert_eq!(raw[1], 44);
    assert_eq!(raw.len(), 2);
}

fn empty_read_buffer<T: SerialPort>(port: &mut T) -> Result<()> {
    let mut dev_null = [0; 100];
    port.set_timeout(Duration::from_millis(0))?;
    let left_over = match port.read(&mut dev_null[..]) {
        Ok(n) => n,
        Err(ioerror) => {
            match ioerror.kind() {
                io::ErrorKind::TimedOut => 0,
                _ => {
                    return Err(ioerror).chain_err(|| "read got other that TimedOut error (1)");
                }
            }
        }
    };
    if left_over > 0 {
        info!("Read {} left over bytes.", left_over);
    }
    Ok(())
}

fn read_result_byte<T: SerialPort>(port: &mut T) -> Result<Response> {
    let mut result = [0];
    port.set_timeout(Duration::from_millis(500))?;
    match port.read_exact(&mut result[0..1]) {
        Ok(()) => {}
        Err(ioerror) => {
            match ioerror.kind() {
                io::ErrorKind::TimedOut => {
                    result[0] = 99;
                }
                _ => {
                    return Err(ioerror).chain_err(|| "read got other that TimedOut error (2)");
                }
            }
        }
    };
    Ok(result[0].into())
}
