const std = @import("std");
const net = std.net;

pub fn main() void {
    var allocator = std.heap.page_allocator;
    const listener = try net.StreamServer.listen(.{}, "127.0.0.1", 3000);
    defer listener.close();

    // クライアントからの接続を待機し、受け入れる
    while (true) {
        const stream = try listener.accept();
        defer stream.close();

        // リクエストの読み込みやレスポンス処理を行う
        const response = "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nHello, Zig!";
        try stream.writeAll(response);
    }
}
