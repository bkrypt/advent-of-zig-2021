const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

const num_days: u32 = 80;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var lanternfish = std.ArrayList(i8).init(allocator);
    defer lanternfish.deinit();

    var fish_iter = std.mem.split(u8, bytes, ",");

    while (fish_iter.next()) |fish_age_str| {
        const fish_age = try std.fmt.parseInt(i8, fish_age_str, 10);
        try lanternfish.append(fish_age);
    }

    log.debug("Initial number of lanternfish: {d}", .{lanternfish.items.len});

    var lanternfish_spawn = std.ArrayList(i8).init(allocator);
    defer lanternfish_spawn.deinit();

    for (0..num_days) |day| {
        for (lanternfish.items) |*fish_age| {
            fish_age.* -= 1;

            if (fish_age.* < 0) {
                fish_age.* = 6;
                try lanternfish_spawn.append(8);
            }
        }

        log.debug("Lanternfish spawned on day {d}: {d}", .{ day + 1, lanternfish_spawn.items.len });

        try lanternfish.appendSlice(lanternfish_spawn.items);
        lanternfish_spawn.clearRetainingCapacity();
    }

    log.info("Total lanternfish after {d} days: {d}", .{ num_days, lanternfish.items.len });
}
