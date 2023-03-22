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

    var line_iter = std.mem.split(u8, bytes, "\n");
    var total_lines: i32 = 0;

    const num_bits = line_iter.first().len;

    var o2_list = std.ArrayList([]const u8).init(allocator);
    defer o2_list.deinit();
    var co2_list = std.ArrayList([]const u8).init(allocator);
    defer co2_list.deinit();

    line_iter.reset();
    while (line_iter.next()) |reading| {
        try o2_list.append(reading);
        try co2_list.append(reading);
        total_lines += 1;
    }

    log.info("Total lines: {d}", .{total_lines});

    // Find O2 rating

    o2_outer_loop: for (0..num_bits) |bit_index| {
        var select_bit: u8 = '1';
        if (mostCommonBitAtIndex(o2_list.items, bit_index) < 0) {
            select_bit = '0';
        }

        var item_index: usize = 0;
        while (item_index < o2_list.items.len) {
            if (o2_list.items.len == 1) {
                break :o2_outer_loop;
            }

            if (o2_list.items[item_index][bit_index] != select_bit) {
                _ = o2_list.swapRemove(item_index);
            } else {
                item_index += 1;
            }
        }
    }

    assert(o2_list.items.len == 1);
    const o2_rating = binaryStringToInt(o2_list.items[0]);

    // Find CO2 rating

    co2_outer_loop: for (0..num_bits) |bit_index| {
        var select_bit: u8 = '0';
        if (mostCommonBitAtIndex(co2_list.items, bit_index) < 0) {
            select_bit = '1';
        }

        var item_index: usize = 0;
        while (item_index < co2_list.items.len) {
            if (co2_list.items.len == 1) {
                break :co2_outer_loop;
            }

            if (co2_list.items[item_index][bit_index] != select_bit) {
                _ = co2_list.swapRemove(item_index);
            } else {
                item_index += 1;
            }
        }
    }

    assert(co2_list.items.len == 1);
    const co2_rating = binaryStringToInt(co2_list.items[0]);

    const life_support_rating: u32 = o2_rating * co2_rating;
    log.info("O2: {d} CO2: {d} Answer: {d}", .{ o2_rating, co2_rating, life_support_rating });
}

fn mostCommonBitAtIndex(reading_list: [][]const u8, index: usize) isize {
    var count: isize = 0;

    for (reading_list) |reading| {
        count += if (reading[index] == '1') 1 else -1;
    }

    return count;
}

fn binaryStringToInt(binary_string: []const u8) u32 {
    var result: u32 = 0;

    for (binary_string) |bit| {
        result <<= 1;
        if (bit == '1') {
            result |= 1;
        }
    }

    return result;
}
