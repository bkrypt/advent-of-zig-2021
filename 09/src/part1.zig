const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;
const assert = std.debug.assert;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var heightmap = std.ArrayList(u8).init(allocator);
    defer heightmap.deinit();

    var grid_width: usize = 0;
    var grid_height: usize = 0;

    var line_iter = std.mem.split(u8, bytes, "\n");

    grid_width = line_iter.first().len;
    log.debug("Grid width: {d}", .{grid_width});

    line_iter.reset();
    while (line_iter.next()) |line| {
        assert(line.len == grid_width);

        for (line) |char| {
            const height: u8 = char - '0';
            try heightmap.append(height);
        }

        grid_height += 1;
    }

    log.debug("Grid size: {d} x {d}", .{ grid_width, grid_height });

    var num_low_points: usize = 0;
    var sum_of_risk_levels: usize = 0;

    for (heightmap.items, 0..) |height, index| {
        const x = index % grid_width;
        const y = index / grid_height;

        var min_height: u8 = std.math.maxInt(u8);

        if (x > 0) {
            min_height = std.math.min(min_height, heightmap.items[index - 1]);
        }

        if (x < grid_width - 1) {
            min_height = std.math.min(min_height, heightmap.items[index + 1]);
        }

        if (y > 0) {
            min_height = std.math.min(min_height, heightmap.items[index - grid_width]);
        }

        if (y < grid_height - 1) {
            min_height = std.math.min(min_height, heightmap.items[index + grid_width]);
        }

        if (height < min_height) {
            num_low_points += 1;
            sum_of_risk_levels += height + 1;
            log.debug("{d} ({d}, {d}) *", .{ height, x, y });
        } else {
            log.debug("{d} ({d}, {d})", .{ height, x, y });
        }
    }

    log.info("There are {d} low points, with a combined risk level of {d}", .{ num_low_points, sum_of_risk_levels });
}
