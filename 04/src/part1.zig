const std = @import("std");
const kgk = @import("kgk.zig");
const IntegerBitSet = std.bit_set.IntegerBitSet;
const log = std.log;

const board_size: u8 = 5;
const board_size_sqrd = board_size * board_size;

const Board = struct {
    numbers: [board_size_sqrd]u8,
    marks: IntegerBitSet(board_size_sqrd),
    row_state: [board_size]u8,
    col_state: [board_size]u8,

    pub fn initFromBuffer(buffer: []const u8) !Board {
        var board = Board{
            .numbers = undefined,
            .marks = IntegerBitSet(board_size_sqrd).initEmpty(),
            .row_state = [_]u8{5} ** board_size,
            .col_state = [_]u8{5} ** board_size,
        };

        var index: usize = 0;
        var iter = std.mem.tokenize(u8, buffer, " \n");
        while (iter.next()) |token| : (index += 1) {
            board.numbers[index] = try std.fmt.parseInt(u8, token, 10);
        }

        return board;
    }

    pub fn mark(self: *Board, drawn_number: u8) void {
        for (self.numbers, 0..) |number, index| {
            if (number == drawn_number) {
                const row_index = index / board_size;
                const col_index = index % board_size;

                self.row_state[row_index] -= 1;
                self.col_state[col_index] -= 1;

                self.marks.set(index);
            }
        }
    }

    pub fn isWinner(self: Board) bool {
        for (0..board_size) |index| {
            if (self.col_state[index] == 0 or self.row_state[index] == 0) {
                return true;
            }
        }
        return false;
    }

    pub fn score(self: Board) u32 {
        var unmarked_sum: u32 = 0;

        for (self.numbers, 0..) |number, index| {
            if (self.marks.isSet(index) == false) {
                unmarked_sum += number;
            }
        }

        return unmarked_sum;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var boards = std.ArrayList(Board).init(allocator);
    defer boards.deinit();

    var line_iter = std.mem.split(u8, bytes, "\n\n");

    const draw_inputs: []const u8 = line_iter.first();
    var board_input_iter = line_iter;

    while (board_input_iter.next()) |board_input| {
        const board = try Board.initFromBuffer(board_input);
        try boards.append(board);
    }

    log.info("Total boards: {d}", .{boards.items.len});

    var draw_iter = std.mem.split(u8, draw_inputs, ",");
    outer_loop: while (draw_iter.next()) |draw| {
        const drawn_number = try std.fmt.parseInt(u8, draw, 10);

        for (boards.items, 0..) |*board, index| {
            board.mark(drawn_number);

            if (board.isWinner()) {
                const score: u32 = board.score();
                const final_score: u32 = score * drawn_number;

                log.info("Board {d} is the first winner, with a score of {d}!", .{ index, final_score });

                break :outer_loop;
            }
        }
    }
}
