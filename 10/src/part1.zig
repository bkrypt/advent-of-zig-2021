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

    var line_count: usize = 0;
    var total_failure_score: usize = 0;

    while (line_iter.next()) |line| {
        line_count += 1;

        log.debug("Line {d}: {s}", .{ line_count, line });

        var open_stack = std.ArrayList(u8).init(allocator);
        defer open_stack.deinit();

        var failure_score: usize = 0;

        for (line) |char| {
            switch (char) {
                '(' => {
                    try open_stack.append('(');
                },
                '[' => {
                    try open_stack.append('[');
                },
                '{' => {
                    try open_stack.append('{');
                },
                '<' => {
                    try open_stack.append('<');
                },
                ')' => {
                    if (open_stack.pop() != '(') {
                        failure_score += 3;
                        break;
                    }
                },
                ']' => {
                    if (open_stack.pop() != '[') {
                        failure_score += 57;
                        break;
                    }
                },
                '}' => {
                    if (open_stack.pop() != '{') {
                        failure_score += 1197;
                        break;
                    }
                },
                '>' => {
                    if (open_stack.pop() != '<') {
                        failure_score += 25137;
                        break;
                    }
                },
                else => {
                    unreachable;
                },
            }
        }

        log.debug("Line {d}: Failure score: {d}", .{ line_count, failure_score });
        total_failure_score += failure_score;
    }

    log.info("Total failure score across {d} lines: {d}", .{ line_count, total_failure_score });
}
