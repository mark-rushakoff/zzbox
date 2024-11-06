const std = @import("std");

/// Returns the typical stdin, stdout, and stderr that
/// one would expect in normal production usage.
pub const Os = struct {
    in: std.fs.File,
    out: std.fs.File,
    err: std.fs.File,
};

/// os returns a stdio that is backed by the real
/// stdin, stdout, and stderr associated with the process.
pub fn os() Os {
    return .{
        .in = std.io.getStdIn(),
        .out = std.io.getStdOut(),
        .err = std.io.getStdErr(),
    };
}

/// Mock is provided for use in tests.
/// It acts like an OS-backed stdio,
/// with ArrayLists for output and a fifo for input.
pub const Mock = struct {
    in: std.fifo.LinearFifo(u8, .Dynamic),
    out: std.ArrayList(u8),
    err: std.ArrayList(u8),

    pub fn init(allocator: std.mem.Allocator) Mock {
        const in = std.fifo.LinearFifo(u8, .Dynamic).init(allocator);
        const out = std.ArrayList(u8).init(allocator);
        const err = std.ArrayList(u8).init(allocator);
        return Mock{
            .in = in,
            .out = out,
            .err = err,
        };
    }

    pub fn deinit(self: Mock) void {
        self.in.deinit();
        self.out.deinit();
        self.err.deinit();
    }
};
