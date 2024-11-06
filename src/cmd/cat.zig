const std = @import("std");
const testing = std.testing;
const stdio = @import("zzbox").stdio;

const buf_size = 4096;

/// Executes cat with the command line options.
/// https://pubs.opengroup.org/onlinepubs/9799919799/utilities/cat.html
pub fn execute(
    io: anytype,
    args: anytype, // Not yet used.

    // TODO: read-only FS.
) u8 {
    _ = args;

    var buf: [buf_size]u8 = undefined;

    var r_in = io.in.reader();
    while (true) {
        const n = r_in.read(&buf) catch return 1;
        if (n == 0) {
            return 0;
        }

        io.out.writer().writeAll(buf[0..n]) catch {
            return 2;
        };
    }
}

test "plain stdin written to stdout" {
    var io = stdio.Mock.init(testing.allocator);
    defer io.deinit();

    var args = try std.process.ArgIteratorGeneral(.{}).init(testing.allocator, "");
    defer args.deinit();

    try io.in.write("hello world");

    // Exit 0.
    try testing.expectEqual(0, execute(&io, args));

    // Only wrote to stdout.
    try testing.expectEqualStrings("hello world", io.out.items);
    try testing.expectEqual(0, io.err.items.len);
}

test "stdin longer than buffer size" {
    var io = stdio.Mock.init(testing.allocator);
    defer io.deinit();

    var args = try std.process.ArgIteratorGeneral(.{}).init(testing.allocator, "");
    defer args.deinit();

    var xs: [buf_size + 8]u8 = undefined;
    @memset(&xs, 'x');
    try io.in.write(&xs);

    // Exit 0.
    try testing.expectEqual(0, execute(&io, args));

    // Only wrote to stdout.
    try testing.expectEqualStrings(&xs, io.out.items);
    try testing.expectEqual(0, io.err.items.len);
}

test "empty stdin" {
    var io = stdio.Mock.init(testing.allocator);
    defer io.deinit();

    var args = try std.process.ArgIteratorGeneral(.{}).init(testing.allocator, "");
    defer args.deinit();

    // Exit 0.
    try testing.expectEqual(0, execute(&io, args));

    // Nothing written.
    try testing.expectEqual(0, io.out.items.len);
    try testing.expectEqual(0, io.err.items.len);
}
