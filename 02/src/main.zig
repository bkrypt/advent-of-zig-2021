const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    log.info("File size: {d}", .{bytes.len});

    var aim: i32 = 0;
    var hzpos: i32 = 0;
    var depth: i32 = 0;

    var line_iter = std.mem.split(u8, bytes, "\n");

    while (line_iter.next()) |line| {
        var command_iter = std.mem.split(u8, line, " ");

        const direction_param = command_iter.next() orelse return error.UnexpectedEndOfInput;
        const direction: []const u8 = direction_param;

        const units_param = command_iter.next() orelse return error.UnexpectedEndOfInput;
        const units: i32 = try std.fmt.parseInt(i32, units_param, 10);

        if (std.mem.eql(u8, direction, "forward")) {
            hzpos += units;
            depth += aim * units;
        } else if (std.mem.eql(u8, direction, "down")) {
            aim += units;
        } else if (std.mem.eql(u8, direction, "up")) {
            aim -= units;
        } else {
            unreachable;
        }
    }

    const puzzle_answer = hzpos * depth;
    log.info("Hzpos: {d} Depth: {d} Answer: {d}", .{ hzpos, depth, puzzle_answer });
}
