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

    var previous_depth: i32 = std.math.maxInt(i32);
    var increase_count: i32 = 0;

    while (line_iter.next()) |line| {
        const current_depth = try std.fmt.parseInt(i32, line, 0);

        if (current_depth > previous_depth) {
            increase_count += 1;
        }

        previous_depth = current_depth;
    }

    log.info("Number of increases: {d}", .{increase_count});
}
