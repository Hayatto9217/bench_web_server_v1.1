#  Deno, Go, Rust, Zig: A Benchmark 考察入り

## Intro

Zig のOS自作中にふと気がついたのですが,Webでベンチマークするとどれぐらいの比較があるのか確認したくなりました。


## ベンチマーク

| Language | Requests per second     | Time per request  |
| :------- | :---------------------- | :---------------- |
| deno     |          [#/sec] (mean) |  [ms] (mean) |
| go       |          [#/sec] (mean) |  [ms] (mean) |
| rust     |          [#/sec] (mean) |  [ms] (mean) |
| zig      |          [#/sec] (mean) |  [ms] (mean) |

ということで、** **です。


## **注意**

**この計測は、特定の言語やフレームワークを批判するものではないです。
それぞれの言語やフレームワークには、それぞれの良いところ、悪いところがあると思っています。
また、計測方法や各言語の最適化ができていないと思います。
間違いがあったときは申し訳ございません。**

## ベンチマークの実行

### install(MacOSで検証)


```sh
brew install httpd
```

### run

```sh
ab -k -c 10 -n 100000 http://127.0.0.1:3000/
```

## ベンチマークのコード

### Go

```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Add("Content-Type", "text/html")
		fmt.Fprintf(w, "<h1>Hello World</h1>")
	})
	http.ListenAndServe(":3000", nil)
}

```

### Rust

```rust
use std::io::prelude::*;
use std::net::TcpListener;
use std::net::TcpStream;

fn main() {
		let listener = TcpListener::bind("127.0.0.1:3000").unwrap();
		for stream in listener.incoming() {
				let stream = stream.unwrap();
				handle_connection(stream);
		}
}

fn handle_connection(mut stream: TcpStream) {
		let mut buffer = [0; 512];
		stream.read(&mut buffer).unwrap();
		let response = "HTTP/1.1 200 OK\r\n\r\n<h1>Hello World</h1>";
		stream.write(response.as_bytes()).unwrap();
		stream.flush().unwrap();
}

```

### Zig

```zig
const std = @import("std");
const net = std.net;
const StreamServer = net.StreamServer;
const Address = net.Address;
pub const io_mode = .evented;

pub fn main() anyerror!void {
  var stream_server = StreamServer.init(.{});
  defer stream_server.close();
  const address = try Address.resolveIp("127.0.0.1", 3000);
  try stream_server.listen(address);
  while (true) {
    const client = try stream_server.accept();
      const response = "HTTP/1.1 200 OK\r\n\r\n<h1>Hello World</h1>";
      try client.write(response);
    }
}

```

### Deno

```ts
const server = Deno.listen({ port: 3000 });

for await (const conn of server) {
  serveHttp(conn);
}

async function serveHttp(conn: Deno.Conn) {
  const httpConn = Deno.serveHttp(conn);
  for await (const requestEvent of httpConn) {
    const body = "<h1>Hello World</h1>";
    requestEvent.respondWith(
      new Response(body, {
        status: 200,
      })
    );
  }
}
```

### Makefile

```makefile
.phony:

build-go:
	go build go/main.go && ./main

build-rust:
	rustc rust/main.rs && ./main

build-zig:
	zig build-exe zig/main.zig && ./main

run-go:
	go run go/main.go

run-deno:
	deno run --allow-net deno/main.ts

bench:
	ab -k -c 10 -n 100000 http://127.0.0.1:3000/

bench-go:
	ab -k -c 10 -n 100000 http://127.0.0.1:3000/ > bench/go.txt

bench-rust:
	ab -k -c 10 -n 100000 http://127.0.0.1:3000/ > bench/rust.txt

bench-deno:
	ab -k -c 10 -n 100000 http://127.0.0.1:3000/ > bench/deno.txt

bench-zig:
	ab -k -c 10 -n 100000 http://127.0.0.1:3000/ > bench/zig.txt

check-port:
	echo 'sudo lsof -i :3000'

stop apachectl stop command
         'sudo apachectl stop'

```
