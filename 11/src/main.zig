const std = @import("std");
const kgk = @import("kgk.zig");
const DynamicBitSet = std.bit_set.DynamicBitSet;
const LinearFifo = std.fifo.LinearFifo;
const log = std.log;
const assert = std.debug.assert;

fn print_grid(grid: std.ArrayList(u8), grid_width: usize) void {
    for (grid.items, 0..) |energy, index| {
        if (index % grid_width == 0) {
            std.debug.print("\n", .{});
        }

        std.debug.print("{d} ", .{energy});
    }
    std.debug.print("\n", .{});
}

fn get_adjacent_indices(index: usize, grid_width: usize, grid_height: usize) !std.BoundedArray(usize, 8) {
    var result = try std.BoundedArray(usize, 8).init(0);

    const x = index % grid_width;
    const y = index / grid_width;

    if (x > 0) {
        // Left
        try result.append(index - 1);

        // Top left
        if (y > 0) try result.append(index - grid_width - 1);

        // Bottom left
        if (y < grid_height - 1) try result.append(index + grid_width - 1);
    }

    if (x < grid_width - 1) {
        // Right
        try result.append(index + 1);

        // Top right
        if (y > 0) try result.append((index - grid_width) + 1);

        // Bottom left
        if (y < grid_height - 1) try result.append(index + grid_width + 1);
    }

    // Top
    if (y > 0) try result.append(index - grid_width);

    // Bottom
    if (y < grid_height - 1) try result.append(index + grid_width);

    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var grid = std.ArrayList(u8).init(allocator);
    defer grid.deinit();

    var grid_width: usize = 0;
    var grid_height: usize = 0;

    var line_iter = std.mem.split(u8, bytes, "\n");

    grid_width = line_iter.first().len;
    log.debug("Grid width: {d}", .{grid_width});

    line_iter.reset();
    while (line_iter.next()) |line| {
        assert(line.len == grid_width);

        for (line) |energy_char| {
            const energy_level: u8 = energy_char - '0';
            try grid.append(energy_level);
        }

        grid_height += 1;
    }

    log.debug("Grid size: {d} x {d}", .{ grid_width, grid_height });

    const total_octopuses: usize = grid_width * grid_height;
    var step_number: usize = 1;

    while (true) : (step_number += 1) {
        var flash_queue: LinearFifo(usize, .Dynamic) = LinearFifo(usize, .Dynamic).init(allocator);
        defer flash_queue.deinit();

        var flashed_set = try DynamicBitSet.initEmpty(allocator, grid_width * grid_height);
        defer flashed_set.deinit();

        for (grid.items, 0..) |*energy, index| {
            energy.* += 1;

            if (energy.* > 9) {
                try flash_queue.writeItem(index);
                flashed_set.set(index);
            }
        }

        while (flash_queue.readItem()) |index| {
            const adjacent_indices = try get_adjacent_indices(index, grid_width, grid_height);

            for (adjacent_indices.slice()) |adjacent| {
                if (flashed_set.isSet(adjacent)) {
                    continue;
                }

                grid.items[adjacent] += 1;

                if (grid.items[adjacent] > 9) {
                    try flash_queue.writeItem(adjacent);
                    flashed_set.set(adjacent);
                }
            }
        }

        if (flashed_set.count() == total_octopuses) {
            break;
        }

        var flashed_set_iter = flashed_set.iterator(.{});
        while (flashed_set_iter.next()) |index| {
            grid.items[index] = 0;
        }
    }

    log.info("Fist step at which all octopuses flash: {d}", .{step_number});
}
