const std = @import("std");
const kgk = @import("kgk.zig");
const IntegerBitSet = std.bit_set.IntegerBitSet;
const assert = std.debug.assert;
const log = std.log;

const SignalPattern = IntegerBitSet(7);

fn stringToSignalPattern(pattern: []const u8) SignalPattern {
    var result = SignalPattern.initEmpty();

    for (pattern) |bit| {
        result.set(bit - 'a');
    }

    return result;
}

fn initSignalWireMap(out_map: *[10]SignalPattern, patterns_str: []const u8) void {
    var unknown_pattern_count: usize = 0;
    var unknown_patterns: [6]SignalPattern = undefined;

    var pattern_iter = std.mem.split(u8, patterns_str, " ");

    while (pattern_iter.next()) |pattern_str| {
        const signal_pattern = stringToSignalPattern(pattern_str);
        switch (signal_pattern.count()) {
            2 => out_map[1] = signal_pattern,
            3 => out_map[7] = signal_pattern,
            4 => out_map[4] = signal_pattern,
            7 => out_map[8] = signal_pattern,
            else => {
                unknown_patterns[unknown_pattern_count] = signal_pattern;
                unknown_pattern_count += 1;
            },
        }
    }

    assert(unknown_pattern_count == 6);

    for (unknown_patterns) |unknown| {
        switch (unknown.count()) {
            5 => { // 2, 3, 5
                if (unknown.supersetOf(out_map[1])) {
                    out_map[3] = unknown;
                } else if (out_map[4].differenceWith(unknown).count() == 1) {
                    out_map[5] = unknown;
                } else {
                    out_map[2] = unknown;
                }
            },
            6 => { // 0, 6, 9
                if (out_map[7].differenceWith(unknown).count() == 1) {
                    out_map[6] = unknown;
                } else if (out_map[4].differenceWith(unknown).count() == 0) {
                    out_map[9] = unknown;
                } else {
                    out_map[0] = unknown;
                }
            },
            else => unreachable,
        }
    }

    for (out_map.*, 0..) |pattern, value| {
        log.debug("[{d}] {b}", .{ value, pattern.mask });
    }
}

fn getDisplayIntegerValue(display_str: []const u8, signal_wire_map: [10]SignalPattern) usize {
    var result: usize = 0;
    var display_digit_iter = std.mem.split(u8, display_str, " ");

    while (display_digit_iter.next()) |digit_str| {
        const signal_pattern: SignalPattern = stringToSignalPattern(digit_str);

        for (signal_wire_map, 0..) |digit_pattern, value| {
            if (signal_pattern.eql(digit_pattern)) {
                result = result * 10 + value;
                break;
            }
        }
    }

    return result;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var total_display_readings: u32 = 0;
    var sum_of_all_display_values: usize = 0;

    var line_iter = std.mem.split(u8, bytes, "\n");

    while (line_iter.next()) |line| {
        var entry_parts = std.mem.split(u8, line, " | ");

        var signal_wire_map = [_]SignalPattern{SignalPattern.initEmpty()} ** 10;
        if (entry_parts.next()) |patterns_str| {
            initSignalWireMap(&signal_wire_map, patterns_str);
        }

        if (entry_parts.next()) |display_str| {
            const display_value: usize = getDisplayIntegerValue(display_str, signal_wire_map);
            log.debug("{s} = {d}", .{ display_str, display_value });

            sum_of_all_display_values += display_value;
        }

        total_display_readings += 1;
    }

    log.info("The sum of all {d} display values is {d}", .{ total_display_readings, sum_of_all_display_values });
}
