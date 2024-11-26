use std::io::prelude::*;
use std::net::TcpListener;
use std::net::TcpStream;
use std::sync::mpsc::channel;
use threadpool::ThreadPool;

fn main() {
    let listener = TcpListener::bind("127.0.0.1:3000").unwrap();
    let pool = ThreadPool::new(4);

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        pool.execute(|| {
            handle_connection(stream);
        });
    }
}

fn handle_connection(mut stream: TcpStream) {
    let mut buffer = [0; 1024];

    stream.read(&mut buffer).unwrap();
    stream.write(b"HTTP/1.1 200 OK\r\n\r\n<h1>Hello World</h1>");
}
