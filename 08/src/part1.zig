const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

fn isUniqueDigitPattern(signalGroup: []const u8) bool {
    return switch (signalGroup.len) {
        2, 3, 4, 7 => true,
        else => false,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var total_digits: usize = 0;
    var unique_pattern_count: usize = 0;

    var line_iter = std.mem.split(u8, bytes, "\n");

    while (line_iter.next()) |line| {
        var entry_parts = std.mem.split(u8, line, " | ");

        // Discard the 10 observed unique patterns
        _ = entry_parts.first();

        if (entry_parts.next()) |value| {
            var digit_iter = std.mem.split(u8, value, " ");

            while (digit_iter.next()) |digit| {
                total_digits += 1;

                if (isUniqueDigitPattern(digit)) {
                    unique_pattern_count += 1;
                }
            }
        }
    }

    log.info("Unique signal patterns occur {d} times in {d} total digits", .{ unique_pattern_count, total_digits });
}
