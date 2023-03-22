const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

const Point = struct {
    x: i32 = 0,
    y: i32 = 0,
};

const Line = struct {
    p1: Point = Point{},
    p2: Point = Point{},
};

const World = struct {
    map: std.AutoHashMap(Point, u32),

    pub fn init(allocator: std.mem.Allocator) World {
        return World{
            .map = std.AutoHashMap(Point, u32).init(allocator),
        };
    }

    pub fn deinit(self: *World) void {
        self.map.deinit();
    }

    pub fn plotLine(self: *World, line: Line) !void {
        var x_change: i32 = 0;
        var y_change: i32 = 0;

        if (line.p1.x - line.p2.x < 0) {
            x_change = 1;
        } else if (line.p1.x - line.p2.x > 0) {
            x_change = -1;
        }

        if (line.p1.y - line.p2.y < 0) {
            y_change = 1;
        } else if (line.p1.y - line.p2.y > 0) {
            y_change = -1;
        }

        var curr_x: i32 = line.p1.x;
        var curr_y: i32 = line.p1.y;

        while (true) {
            const key = Point{
                .x = curr_x,
                .y = curr_y,
            };

            if (self.map.get(key)) |value| {
                try self.map.put(key, value + 1);
            } else {
                try self.map.put(key, 1);
            }

            if (curr_x == line.p2.x and curr_y == line.p2.y) {
                break;
            }

            curr_x += x_change;
            curr_y += y_change;
        }
    }

    pub fn countOverlappingPoints(self: World) u32 {
        var count: u32 = 0;
        var map_iter = self.map.iterator();
        while (map_iter.next()) |entry| {
            if (entry.value_ptr.* >= 2) {
                count += 1;
            }
        }
        return count;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var world = World.init(allocator);
    defer world.deinit();

    var line_iter = std.mem.split(u8, bytes, "\n");

    while (line_iter.next()) |input_line| {
        log.debug("Line: {s}", .{input_line});

        var line = Line{};

        var point_iter = std.mem.split(u8, input_line, " -> ");
        if (point_iter.next()) |point| {
            log.debug("Point 1: {s}", .{point});
            var xy_iter = std.mem.split(u8, point, ",");

            if (xy_iter.next()) |x| {
                line.p1.x = try std.fmt.parseInt(i32, x, 10);
            }

            if (xy_iter.next()) |y| {
                line.p1.y = try std.fmt.parseInt(i32, y, 10);
            }
        }

        if (point_iter.next()) |point| {
            log.debug("Point 2: {s}", .{point});
            var xy_iter = std.mem.split(u8, point, ",");

            if (xy_iter.next()) |x| {
                line.p2.x = try std.fmt.parseInt(i32, x, 10);
            }

            if (xy_iter.next()) |y| {
                line.p2.y = try std.fmt.parseInt(i32, y, 10);
            }
        }

        try world.plotLine(line);
    }

    var num_overlapping_points: u32 = world.countOverlappingPoints();
    log.info("Number of overlapping points: {d}", .{num_overlapping_points});
}
