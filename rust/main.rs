use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

fn main() {
    let listener = TcpListener::bind("127.0.0.1:3000").unwrap();
    println!("Server running on 127.0.0.1:3000");

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        thread::spawn(move || {
            handle_connection(stream);
        });
    }
}

fn handle_connection(mut stream: TcpStream) {
    let mut buffer = [0; 1024];

    // request
    if let Err(e) = stream.read(&mut buffer) {
        eprintln!("Failed to read from stream: {}", e);
        return;
    }

    // HTTPレスポンス
    let response = b"HTTP/1.1 200 OK\r\n\r\n<h1>Hello World</h1>";

    if let Err(e) = stream.write(response) {
        eprintln!("Failed to write to stream: {}", e);
        return;
    }

    if let Err(e) = stream.flush() {
        eprintln!("Failed to flush stream: {}", e);
        return;
    }
}
