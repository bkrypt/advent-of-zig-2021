const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

const num_days: u32 = 256;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var lanternfish = [_]u64{0} ** 9;
    var fish_iter = std.mem.split(u8, bytes, ",");

    while (fish_iter.next()) |fish_str| {
        const group_index = try std.fmt.parseInt(u8, fish_str, 10);
        lanternfish[group_index] += 1;
    }

    for (0..num_days) |day| {
        const num_to_spawn = lanternfish[0];

        for (1..lanternfish.len) |group_index| {
            lanternfish[group_index - 1] += lanternfish[group_index];
            lanternfish[group_index] = 0;
        }

        if (num_to_spawn > 0) {
            lanternfish[8] += num_to_spawn;
            lanternfish[6] += num_to_spawn;
            lanternfish[0] -= num_to_spawn;
        }

        log.debug("Lanternfish spawned on day {d}: {d}", .{ day + 1, num_to_spawn });
    }

    var total_lanternfish: u64 = 0;
    for (lanternfish) |count| {
        total_lanternfish += count;
    }

    log.info("Total lanternfish after {d} days: {d}", .{ num_days, total_lanternfish });
}
