const std = @import("std");
const kgk = @import("kgk.zig");
const DynamicBitSet = std.bit_set.DynamicBitSet;
const log = std.log;
const assert = std.debug.assert;

const CalculateBasinSizeRecursiveContext = struct {
    heightmap: std.ArrayList(u8),
    grid_width: usize,
    grid_height: usize,
    visited_cells: DynamicBitSet,
};

fn calculateBasinSizeRecursive(context: *CalculateBasinSizeRecursiveContext, x: i32, y: i32) usize {
    if (x < 0 or x >= context.grid_width or y < 0 or y >= context.grid_height) {
        return 0;
    }

    const index: usize = @intCast(u32, y) * context.grid_width + @intCast(u32, x);
    if (context.visited_cells.isSet(index)) {
        return 0;
    }

    context.visited_cells.set(index);

    if (context.heightmap.items[index] == 9) {
        return 0;
    }

    return 1 +
        calculateBasinSizeRecursive(context, x, y - 1) +
        calculateBasinSizeRecursive(context, x + 1, y) +
        calculateBasinSizeRecursive(context, x, y + 1) +
        calculateBasinSizeRecursive(context, x - 1, y);
}

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

    var visited_cells = try DynamicBitSet.initEmpty(allocator, grid_width * grid_height);
    defer visited_cells.deinit();

    var basins = std.ArrayList(usize).init(allocator);
    defer basins.deinit();

    var calculate_basin_size_context = CalculateBasinSizeRecursiveContext{
        .heightmap = heightmap,
        .grid_width = grid_width,
        .grid_height = grid_height,
        .visited_cells = visited_cells,
    };

    for (heightmap.items, 0..) |_, index| {
        const height: u8 = heightmap.items[index];
        const x = index % grid_width;
        const y = index / grid_width;

        if (x > 0 and height >= heightmap.items[y * grid_width + (x - 1)]) {
            continue;
        }

        if (x + 1 < grid_width and height >= heightmap.items[y * grid_width + (x + 1)]) {
            continue;
        }

        if (y > 0 and height >= heightmap.items[(y - 1) * grid_width + x]) {
            continue;
        }

        if (y + 1 < grid_height and height >= heightmap.items[(y + 1) * grid_width + x]) {
            continue;
        }

        const basin_size: usize = calculateBasinSizeRecursive(&calculate_basin_size_context, @intCast(i32, x), @intCast(i32, y));
        try basins.append(basin_size);

        log.debug("Basin: {d} Size: {d}", .{ basins.items.len, basin_size });
    }

    log.info("Number of basins: {d}", .{basins.items.len});

    std.sort.sort(usize, basins.items, {}, comptime std.sort.desc(usize));
    const largest_3_basins: []usize = basins.items[0..3];

    log.info("Largest 3 basins: {any}", .{largest_3_basins});

    const product_of_largest_3_basins = largest_3_basins[0] * largest_3_basins[1] * largest_3_basins[2];
    log.info("Product of largest 3 basins: {d}", .{product_of_largest_3_basins});
}
