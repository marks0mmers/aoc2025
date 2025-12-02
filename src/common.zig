const std = @import("std");
// var dbg = std.heap.DebugAllocator(.{}).init;
// const gpa = switch (@import("builtin").mode) {
//     .Debug => dbg.allocator(),
//     .ReleaseSafe, .ReleaseFast, .ReleaseSmall => std.heap.smp_allocator,
// };
// defer if (@import("builtin").mode == .Debug) std.debug.assert(dbg.deinit() == .ok);
//

// pub const File = struct {
//     buffer: []u8,
//     reader: std.Io.File.Reader,
//     file: std.Io.File,
//
//     pub fn deinit(self: *File, gpa: std.mem.Allocator, io: std.Io) void {
//         self.file.close(io);
//         gpa.free(self.buffer);
//     }
// };

// pub fn readFile(gpa: std.mem.Allocator, io: std.Io, comptime src: std.builtin.SourceLocation) !File {
//     const input_file = comptime getFileName(src);
//     var file = try std.Io.Dir.cwd().openFile(io, input_file, .{});
//     const stat = try file.stat(io);
//     const buffer = try gpa.alloc(u8, stat.size);
//     const reader = file.reader(io, buffer);
//     return .{ .buffer = buffer, .reader = reader, .file = file };
// }

pub fn parseOrFail(comptime T: type, str: []const u8) T {
    return std.fmt.parseInt(T, str, 10) catch {
        std.log.default.err("Invalid Number: {s}", .{str});
        std.process.exit(1);
    };
}

pub fn getFileName(comptime src: std.builtin.SourceLocation) []const u8 {
    var input_file_name: [src.file.len]u8 = undefined;
    _ = std.mem.replace(u8, src.file, "zig", "txt", &input_file_name);
    return "input/" ++ input_file_name;
}

pub fn countChar(comptime input: []const u8, comptime char: u8) comptime_int {
    @setEvalBranchQuota(20000);
    var total = 0;
    for (input) |c| {
        if (c == char) total += 1;
    }
    return total;
}
