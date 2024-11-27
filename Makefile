.phony:

build-go:
	go build go/main.go && ./main

build-rust:
	rustc rust/main.rs && ./main

build-rust-server:
	cargo run --release ./rust/simple-server

build-multi-rust2:
	rustc rust/multi-thread2.rs && ./multi-thread2

build-rust-release:
	rustc rust/main.rs -C opt-level=3 -C lto && ./main

build-multi-rust2-release:
	rustc rust/multi-thread2.rs -C opt-level=3 -C lto && ./multi-thread2

build-zig:
	zig build-exe zig/main.zig && ./main

run-go:
	go run go/main.go

run-deno:
	deno run --allow-net deno/main.ts


bench-go:
	ab -k -c 10 -n 1000 http://127.0.0.1:3000/ > bench/go.txt

bench-rust:
	ab -k -c 10 -n 1000 http://127.0.0.1:3000/ > bench/rust.txt

bench-deno:
	ab -k -c 10 -n 1000 http://127.0.0.1:3000/ > bench/deno.txt

bench-zig:
	ab -k -c 10 -n 1000 http://127.0.0.1:3000/ > bench/zig.txt

check-port:
	echo 'sudo lsof -i :3000'

clone-abe:
	wget \
		-P ./abe \
    --recursive \
    --no-parent http://abehiroshi.la.coocan.jp

abench:
	ab -k -c 10 -n 1000 http://127.0.0.1:3000/
