const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var line_count: usize = 0;

    var line_scores = std.ArrayList(usize).init(allocator);
    defer line_scores.deinit();

    var line_iter = std.mem.split(u8, bytes, "\n");

    line_loop: while (line_iter.next()) |line| {
        line_count += 1;

        var close_stack = std.ArrayList(u8).init(allocator);
        defer close_stack.deinit();

        for (line) |char| {
            switch (char) {
                '(' => {
                    try close_stack.append(')');
                },
                '[' => {
                    try close_stack.append(']');
                },
                '{' => {
                    try close_stack.append('}');
                },
                '<' => {
                    try close_stack.append('>');
                },
                else => {
                    const expected_close_char = close_stack.pop();

                    if (char != expected_close_char) {
                        continue :line_loop;
                    }
                },
            }
        }

        log.debug("Line {d} incomplete: {s}", .{ line_count, line });

        var line_score: usize = 0;

        while (close_stack.items.len > 0) {
            line_score *= 5;
            line_score += switch (close_stack.pop()) {
                ')' => 1,
                ']' => 2,
                '}' => 3,
                '>' => 4,
                else => unreachable,
            };
        }

        log.debug("Line {d} score: {d}", .{ line_count, line_score });
        try line_scores.append(line_score);
    }

    std.sort.sort(usize, line_scores.items, {}, comptime std.sort.asc(usize));

    const median_score = line_scores.items[line_scores.items.len / 2];
    log.info("Median/winning score: {d}", .{median_score});
}
