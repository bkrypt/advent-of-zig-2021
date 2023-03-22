const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var line_iter = std.mem.split(u8, bytes, "\n");
    var depth_window: [3]i32 = undefined;
    var current_measurement: i32 = 0;

    for (0..3) |index| {
        const line = line_iter.next() orelse return error.Overflow;
        const current_depth = try std.fmt.parseInt(i32, line, 10);

        depth_window[index] = current_depth;
        current_measurement += current_depth;
    }

    var increase_count: i32 = 0;
    var previous_measurement: i32 = current_measurement;

    while (line_iter.next()) |line| {
        const depth_to_minus = depth_window[0];
        const depth_to_add = try std.fmt.parseInt(i32, line, 10);

        depth_window[0] = depth_window[1];
        depth_window[1] = depth_window[2];
        depth_window[2] = depth_to_add;

        current_measurement -= depth_to_minus;
        current_measurement += depth_to_add;

        if (current_measurement > previous_measurement) {
            increase_count += 1;
        }

        previous_measurement = current_measurement;
    }

    log.info("Number of increases: {d}", .{increase_count});
}
