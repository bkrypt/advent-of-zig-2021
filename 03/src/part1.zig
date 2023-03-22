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

    const num_bits = line_iter.first().len;
    line_iter.reset();

    var bit_scores = try std.ArrayList(i32).initCapacity(allocator, num_bits);
    bit_scores.appendNTimesAssumeCapacity(0, num_bits);
    defer bit_scores.deinit();

    while (line_iter.next()) |reading| {
        for (reading, 0..) |bit, index| {
            bit_scores.items[index] += if (bit == '1') 1 else -1;
        }
    }

    var gamma_rate: i32 = 0;
    var epsilon_rate: i32 = 0;

    for (bit_scores.items) |score| {
        gamma_rate <<= 1;
        epsilon_rate <<= 1;

        if (score > 0) {
            gamma_rate |= 1;
        } else if (score < 0) {
            epsilon_rate |= 1;
        } else {
            unreachable;
        }
    }

    const puzzle_answer = gamma_rate * epsilon_rate;
    log.info("Gamma: {d} Epsilon: {d} Answer: {d}", .{ gamma_rate, epsilon_rate, puzzle_answer });
}
