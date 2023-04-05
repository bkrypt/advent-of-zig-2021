const std = @import("std");
const kgk = @import("kgk.zig");
const DynamicBitSet = std.bit_set.DynamicBitSet;
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

    var basins = std.ArrayList(usize).init(allocator);
    defer basins.deinit();

    var visited_set = try DynamicBitSet.initEmpty(allocator, grid_width * grid_height);
    defer visited_set.deinit();

    var visit_stack = std.ArrayList(usize).init(allocator);
    defer visit_stack.deinit();

    for (heightmap.items, 0..) |_, cell_index| {
        const height: u8 = heightmap.items[cell_index];
        const cell_x = cell_index % grid_width;
        const cell_y = cell_index / grid_width;

        if ((cell_x > 0 and height >= heightmap.items[cell_y * grid_width + (cell_x - 1)]) or
            (cell_x + 1 < grid_width and height >= heightmap.items[cell_y * grid_width + (cell_x + 1)]) or
            (cell_y > 0 and height >= heightmap.items[(cell_y - 1) * grid_width + cell_x]) or
            (cell_y + 1 < grid_height and height >= heightmap.items[(cell_y + 1) * grid_width + cell_x]))
        {
            continue;
        }

        try visit_stack.append(cell_index);

        var current_basin_size: usize = 0;

        while (visit_stack.items.len > 0) {
            const index: usize = visit_stack.pop();

            if (visited_set.isSet(index)) {
                continue;
            }

            visited_set.set(index);
            current_basin_size += 1;

            const x = index % grid_width;
            const y = index / grid_width;

            if (x > 0) {
                if (heightmap.items[index - 1] != 9) {
                    try visit_stack.append(index - 1);
                }
            }

            if (x < grid_width - 1) {
                if (heightmap.items[index + 1] != 9) {
                    try visit_stack.append(index + 1);
                }
            }

            if (y > 0) {
                if (heightmap.items[index - grid_width] != 9) {
                    try visit_stack.append(index - grid_width);
                }
            }

            if (y < grid_height - 1) {
                if (heightmap.items[index + grid_width] != 9) {
                    try visit_stack.append(index + grid_width);
                }
            }
        }

        try basins.append(current_basin_size);
        log.debug("Basin: {d} Size: {d}", .{ basins.items.len, current_basin_size });
    }

    log.info("Number of basins: {d}", .{basins.items.len});

    std.sort.sort(usize, basins.items, {}, comptime std.sort.desc(usize));
    const largest_3_basins: []usize = basins.items[0..3];

    log.info("Largest 3 basins: {any}", .{largest_3_basins});

    const product_of_largest_3_basins = largest_3_basins[0] * largest_3_basins[1] * largest_3_basins[2];
    log.info("Product of largest 3 basins: {d}", .{product_of_largest_3_basins});
}
