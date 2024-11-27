#  Deno, Go, Rust, Zig: A Benchmark 考察入り

## Intro

Zig のOS自作中にふと気がついたのですが,Webでベンチマークするとどれぐらいの比較があるのか確認したくなりました。
*ZigのVersionが変更されたことによって、標準ライブラリーが削除されているという...(先月修正したばかりなのに）
StreamServerライブラリが削除されている.....
<img width="1712" alt="スクリーンショット 2024-11-27 10 26 57" src="https://github.com/user-attachments/assets/a3d012a1-8871-4a4d-855f-9d5e0ae87cf9">



## ベンチマーク

| Language | Requests per second     | Time per request  |
| :------- | :---------------------- | :---------------- |
| deno     | 32913.58 [#/sec] (mean) | 0.304 [ms] (mean) |
| go       | 85736.82 [#/sec] (mean) | 0.117 [ms] (mean) |
| node     | 11187.35 [#/sec] (mean) | 0.894 [ms] (mean) |
| rust     | 20267.08 [#/sec] (mean) | 0.493 [ms] (mean) |
| zig      | **測定不能**              | **測定不能**        |

ということで、**Go が一番速い**


## **注意**

**この計測は、特定の言語やフレームワークを批判するものではないので
それぞれの言語やフレームワークには、それぞれの良いところ、悪いところがあると思っていますのでご了承ください。
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


## 考察
各処理系のバージョンを明記しておいて他の方が同じ条件で追試を行うことが重要かと思った。

abだと遅いので、他のベンチマークツールがあると教えていただきたいです。

そもそもベンチマークまとめたリポジトリとかってあるのかな...

自分が知る限りはShell自作するとかしてやりたいところ

試したいリスト
https://github.com/codesenberg/bombardier

bunもやってみるといいのかもしれない
Denoも'Deno.serve'を使うと速いかなと思ったりして。

