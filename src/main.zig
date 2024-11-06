const std = @import("std");
const testing = std.testing;

const stdio = @import("zzbox").stdio;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var arg_iter = try std.process.argsWithAllocator(allocator);

    // Currently assuming the first arg is always the name of the executable,
    // and for now, we are not handling any link options.
    {
        const arg0 = try allocator.dupeZ(u8, arg_iter.next().?);
        defer allocator.free(arg0);
        std.debug.print("arg0: {s}\n", .{arg0});
    }

    if (arg_iter.next()) |arg| {
        const cmd = CommandName.fromString(arg) catch {
            // There is only one possible error.
            // Time to dump out the known commands.
            std.debug.print("unknown command {s}\nknown commands: ", .{arg});
            var is_first_print = true;
            for (known_commands) |kc| {
                if (is_first_print) {
                    std.debug.print("{s}", .{kc});
                    is_first_print = false;
                } else {
                    std.debug.print(", {s}", .{kc});
                }
            }
            return;
        };

        const code = switch (cmd) {
            .cat => @import("./cmd/cat.zig").execute(stdio.os(), arg_iter),
            .true => 0,
            .false => 1,
        };

        std.process.exit(code);
    } else {
        std.debug.print("usage: ???\n", .{});
    }
}

/// Enum of all the commands we support.
const CommandName = enum {
    // These entries must be in alphabetical order.

    cat,
    false,
    true,

    pub fn fromString(cmd: []const u8) !CommandName {
        if (std.sort.binarySearch([]const u8, &known_commands, cmd, nameCmp)) |idx| {
            return std.enums.values(CommandName)[idx];
        } else {
            return error.UnrecognizedCommand;
        }
    }

    fn nameCmp(a: []const u8, b: []const u8) std.math.Order {
        return std.mem.order(u8, a, b);
    }

    test "fromString" {
        const e = try CommandName.fromString("cat");
        try testing.expectEqual(e, .cat);
        try testing.expectError(error.UnrecognizedCommand, CommandName.fromString("not a command"));
    }
};

// Just pulling this into a const for readability,
// to use with known_commands.
const n_commands = @typeInfo(CommandName).@"enum".fields.len;

// All available commands.
const known_commands: [n_commands][]const u8 = generate: {
    var known: [n_commands][]const u8 = undefined;
    for (@typeInfo(CommandName).@"enum".fields, 0..) |field, idx| {
        known[idx] = field.name;
    }

    if (!std.sort.isSorted([]const u8, &known, {}, asciiLT)) {
        for (known, 0..) |k, idx| {
            if (idx == 0) {
                continue;
            }

            if (!asciiLT(void{}, known[idx - 1], k)) {
                @compileError(
                    "CommandName enum isn't sorted; first item out of order: " ++
                        k ++
                        " (should be before " ++ known[idx - 1] ++ ")",
                );
            }
        }
        unreachable;
    }
    break :generate known;
};

// Used for confirming that the Commands enum is sorted.
fn asciiLT(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
