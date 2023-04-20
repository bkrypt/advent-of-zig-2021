const std = @import("std");
const kgk = @import("kgk.zig");
const log = std.log;
const assert = std.debug.assert;

const CaveSize = enum {
    small,
    big,
};

const Cave = struct {
    id: []const u8,
    size: CaveSize,
    links: std.ArrayList(*Cave),
    allocator: std.mem.Allocator,

    can_visit: bool = true,

    /// Clean up with `destroy`
    fn create(allocator: std.mem.Allocator, cave_id: []const u8) !*Cave {
        const cave = try allocator.create(Cave);
        cave.* = Cave.init(allocator, cave_id);

        return cave;
    }

    fn destroy(self: *Cave) void {
        self.deinit();
        self.allocator.destroy(self);
    }

    /// Clean up with `deinit`
    fn init(allocator: std.mem.Allocator, cave_id: []const u8) Cave {
        return Cave{
            .id = cave_id,
            .size = if (std.ascii.isLower(cave_id[0])) .small else .big,
            .links = std.ArrayList(*Cave).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Cave) void {
        self.links.deinit();
    }

    pub fn format(self: Cave, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = options;
        _ = fmt;
        try writer.print("{s}{{ id = {s} size = {any} links = [", .{ @typeName(Cave), self.id, self.size });
        for (self.links.items, 0..) |linked_cave, index| {
            try writer.print("{s}", .{linked_cave.id});
            if (index < self.links.items.len - 1) {
                try writer.writeAll(", ");
            }
        }
        try writer.writeAll("] }");
    }
};

fn findCave(cave_array: []*Cave, cave_id: []const u8) ?*Cave {
    for (cave_array) |cave| {
        if (std.mem.eql(u8, cave.id, cave_id)) {
            return cave;
        }
    } else {
        return null;
    }
}

const TraversalNode = struct {
    cave: *Cave,
    next_link_index: usize = 0,
};

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
        var links = std.mem.tokenize(u8, line, "-");

        const cave_id_a = links.next().?;
        const cave_id_b = links.next().?;

        log.debug("{s} <-> {s}", .{ cave_id_a, cave_id_b });

        const cave_a: *Cave = findCave(caves.items, cave_id_a) orelse newCave: {
            const cave = try Cave.create(allocator, cave_id_a);
            try caves.append(cave);
            break :newCave cave;
        };

        const cave_b: *Cave = findCave(caves.items, cave_id_b) orelse newCave: {
            const cave = try Cave.create(allocator, cave_id_b);
            try caves.append(cave);
            break :newCave cave;
        };

        log.debug("{any}", .{cave_a});
        log.debug("{any}", .{cave_b});

        _ = findCave(cave_a.links.items, cave_b.id) orelse {
            try cave_a.links.append(cave_b);
        };

        _ = findCave(cave_b.links.items, cave_a.id) orelse {
            try cave_b.links.append(cave_a);
        };
    }
    defer for (caves.items) |cave| cave.destroy();

    var path_count: usize = 0;

    var traversal_stack = std.ArrayList(TraversalNode).init(allocator);
    defer traversal_stack.deinit();

    const start_cave = findCave(caves.items, "start").?;
    try traversal_stack.append(TraversalNode{ .cave = start_cave });

    while (traversal_stack.items.len > 0) {
        var node: *TraversalNode = &traversal_stack.items[traversal_stack.items.len - 1];

        if (std.mem.eql(u8, node.cave.id, "end")) {
            path_count += 1;
            _ = traversal_stack.pop();
            continue;
        }

        if (node.cave.size == CaveSize.small) {
            node.cave.can_visit = false;
        }

        if (node.next_link_index == node.cave.links.items.len) {
            _ = traversal_stack.pop();
            node.cave.can_visit = true;
        } else {
            const linked_cave: *Cave = node.cave.links.items[node.next_link_index];
            node.next_link_index += 1;

            if (linked_cave.can_visit) {
                try traversal_stack.append(TraversalNode{ .cave = linked_cave });
            }
        }
    }

    log.info("Number of paths: {d}", .{path_count});
}
