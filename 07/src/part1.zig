const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var crab_positions = std.ArrayList(i32).init(allocator);
    defer crab_positions.deinit();

    var input_position_iter = std.mem.split(u8, bytes, ",");

    while (input_position_iter.next()) |input_position| {
        const position: i32 = try std.fmt.parseInt(i32, input_position, 10);
        try crab_positions.append(position);
    }

    var chosen_alignment: i32 = undefined;
    var chosen_alignment_fuel_cost: u32 = std.math.maxInt(u32);

    std.sort.sort(i32, crab_positions.items, {}, comptime std.sort.asc(i32));

    const min_position = crab_positions.items[0];
    const max_position = crab_positions.getLast();

    log.debug("Min: {d} Max: {d}", .{ min_position, max_position });

    var alignment_target: i32 = min_position;
    outer: while (alignment_target <= max_position) : (alignment_target += 1) {
        var alignment_fuel_cost: u32 = 0;

        for (crab_positions.items) |crab_position| {
            const position_delta: i32 = crab_position - alignment_target;
            alignment_fuel_cost += std.math.absCast(position_delta);

            if (alignment_fuel_cost >= chosen_alignment_fuel_cost) {
                continue :outer;
            }
        }

        chosen_alignment = alignment_target;
        chosen_alignment_fuel_cost = alignment_fuel_cost;
    }

    log.info("Target position: {d} Fuel cost: {d}", .{ chosen_alignment, chosen_alignment_fuel_cost });
}
