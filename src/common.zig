const std = @import("std");
// var dbg = std.heap.DebugAllocator(.{}).init;
// const allocator = switch (@import("builtin").mode) {
//     .Debug => dbg.allocator(),
//     .ReleaseSafe, .ReleaseFast, .ReleaseSmall => std.heap.smp_allocator,
// };
// defer if (@import("builtin").mode == .Debug) std.debug.assert(dbg.deinit() == .ok);
//

pub const File = struct {
    buffer: []u8,
    reader: std.Io.File.Reader,
    file: std.Io.File,

    pub fn deinit(self: *File, gpa: std.mem.Allocator, io: std.Io) void {
        self.file.close(io);
        gpa.free(self.buffer);
    }
};

pub fn readFile(gpa: std.mem.Allocator, io: std.Io, zig_file: []const u8) !File {
    const size = std.mem.replacementSize(u8, zig_file, "zig", "txt");
    const input_file_name = try gpa.alloc(u8, size);
    defer gpa.free(input_file_name);
    _ = std.mem.replace(u8, zig_file, "zig", "txt", input_file_name);
    const input_file = try std.fmt.allocPrint(gpa, "input/{s}", .{input_file_name});
    defer gpa.free(input_file);

    var file = try std.Io.Dir.cwd().openFile(io, input_file, .{});
    const stat = try file.stat(io);
    const buffer = try gpa.alloc(u8, stat.size);
    const reader = file.reader(io, buffer);
    return .{ .buffer = buffer, .reader = reader, .file = file };
}
