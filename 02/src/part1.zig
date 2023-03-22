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

    var hzpos: i32 = 0;
    var depth: i32 = 0;

    var line_iter = std.mem.split(u8, bytes, "\n");

    while (line_iter.next()) |line| {
        var course_iter = std.mem.split(u8, line, " ");

        const direction_param = course_iter.next() orelse return error.UnexpectedEndOfInput;
        const direction: []const u8 = direction_param;

        const units_param = course_iter.next() orelse return error.UnexpectedEndOfInput;
        const units: i32 = try std.fmt.parseInt(i32, units_param, 10);

        if (std.mem.eql(u8, direction, "forward")) {
            hzpos += units;
        } else if (std.mem.eql(u8, direction, "down")) {
            depth += units;
        } else if (std.mem.eql(u8, direction, "up")) {
            depth -= units;
        } else {
            unreachable;
        }
    }

    const puzzle_answer = hzpos * depth;
    log.info("Hzpos: {d} Depth: {d} Answer: {d}", .{ hzpos, depth, puzzle_answer });
}
