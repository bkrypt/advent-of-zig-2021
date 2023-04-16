const std = @import("std");
const assert = std.debug.assert;

pub fn loadFile(allocator: std.mem.Allocator, file_path: []const u8) ![]u8 {
    const file = try std.fs.cwd().openFile(file_path, .{ .mode = std.fs.File.OpenMode.read_only });
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    const bytes_read = try file.readAll(buffer);

    assert(bytes_read == file_size);

    return buffer;
}
