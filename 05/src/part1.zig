const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

const Point = struct {
    x: u32 = 0,
    y: u32 = 0,
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
        // Vertical line
        if (line.p1.x == line.p2.x) {
            const x = line.p1.x;
            const y_min = std.math.min(line.p1.y, line.p2.y);
            const y_max = std.math.max(line.p1.y, line.p2.y);

            for (y_min..y_max + 1) |y| {
                const key = Point{
                    .x = x,
                    .y = @intCast(u32, y),
                };

                if (self.map.get(key)) |value| {
                    try self.map.put(key, value + 1);
                } else {
                    try self.map.put(key, 1);
                }
            }
            // Horizontal line
        } else if (line.p1.y == line.p2.y) {
            const y = line.p1.y;
            const x_min = std.math.min(line.p1.x, line.p2.x);
            const x_max = std.math.max(line.p1.x, line.p2.x);

            for (x_min..x_max + 1) |x| {
                const key = Point{
                    .x = @intCast(u32, x),
                    .y = y,
                };

                if (self.map.get(key)) |value| {
                    try self.map.put(key, value + 1);
                } else {
                    try self.map.put(key, 1);
                }
            }
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
                line.p1.x = try std.fmt.parseInt(u32, x, 10);
            }

            if (xy_iter.next()) |y| {
                line.p1.y = try std.fmt.parseInt(u32, y, 10);
            }
        }

        if (point_iter.next()) |point| {
            log.debug("Point 2: {s}", .{point});
            var xy_iter = std.mem.split(u8, point, ",");

            if (xy_iter.next()) |x| {
                line.p2.x = try std.fmt.parseInt(u32, x, 10);
            }

            if (xy_iter.next()) |y| {
                line.p2.y = try std.fmt.parseInt(u32, y, 10);
            }
        }

        try world.plotLine(line);
    }

    var num_overlapping_points: u32 = world.countOverlappingPoints();
    log.info("Number of overlapping points: {d}", .{num_overlapping_points});
}
