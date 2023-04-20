const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;

const CaveSize = enum {
    small,
    big,
};

const Cave = struct {
    id: []const u8,
    size: CaveSize,
    links: std.ArrayList(*Cave),
    times_visited: usize = 0,
    allocator: std.mem.Allocator,

    fn create(allocator: std.mem.Allocator, cave_id: []const u8) !*Cave {
        const cave: *Cave = try allocator.create(Cave);
        cave.* = Cave{
            .id = cave_id,
            .size = if (std.ascii.isLower(cave_id[0])) .small else .big,
            .links = std.ArrayList(*Cave).init(allocator),
            .allocator = allocator,
        };
        return cave;
    }

    fn destroy(self: *Cave) void {
        self.links.deinit();
        self.allocator.destroy(self);
    }

    fn print(self: Cave) void {
        log.debug("Cave{{ id = {s}, size = {any}, num_links = {d} }}", .{ self.id, self.size, self.links.items.len });
    }
};

fn findCave(caves: []*Cave, cave_id: []const u8) ?*Cave {
    for (caves) |cave| {
        if (std.mem.eql(u8, cave.id, cave_id)) {
            return cave;
        }
    } else {
        return null;
    }
}

fn visitCaveRecursive(cave: *Cave, path_count: *usize, is_double_visit_slot_available: bool) void {
    if (std.mem.eql(u8, cave.id, "end")) {
        path_count.* += 1;
        return;
    }

    if (cave.size == .small) {
        cave.times_visited += 1;
    }

    for (cave.links.items) |linked_cave| {
        if (std.mem.eql(u8, linked_cave.id, "start")) {
            continue;
        } else if (linked_cave.times_visited == 0) {
            visitCaveRecursive(linked_cave, path_count, is_double_visit_slot_available);
        } else if (linked_cave.times_visited == 1 and is_double_visit_slot_available) {
            visitCaveRecursive(linked_cave, path_count, false);
        }
    }

    if (cave.size == .small) {
        cave.times_visited -= 1;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const bytes = try kgk.loadFile(allocator, "input.txt");
    defer allocator.free(bytes);

    var caves = std.ArrayList(*Cave).init(allocator);
    defer caves.deinit();

    var line_iter = std.mem.split(u8, bytes, "\n");

    while (line_iter.next()) |line| {
        var link = std.mem.tokenize(u8, line, "-");

        const cave_id_a: []const u8 = link.next().?;
        const cave_id_b: []const u8 = link.next().?;

        var cave_a: *Cave = findCave(caves.items, cave_id_a) orelse newCave: {
            const cave: *Cave = try Cave.create(allocator, cave_id_a);
            try caves.append(cave);
            break :newCave cave;
        };

        var cave_b: *Cave = findCave(caves.items, cave_id_b) orelse newCave: {
            const cave: *Cave = try Cave.create(allocator, cave_id_b);
            try caves.append(cave);
            break :newCave cave;
        };

        _ = findCave(cave_a.links.items, cave_b.id) orelse {
            try cave_a.links.append(cave_b);
        };

        _ = findCave(cave_b.links.items, cave_a.id) orelse {
            try cave_b.links.append(cave_a);
        };
    }
    defer for (caves.items) |cave| cave.destroy();

    var path_count: usize = 0;

    const start_cave = findCave(caves.items, "start").?;

    visitCaveRecursive(start_cave, &path_count, true);

    log.info("Path count: {d}", .{path_count});
}
