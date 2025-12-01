const std = @import("std");
const common = @import("common.zig");

const Direction = enum(u8) {
    LEFT = 'L',
    RIGHT = 'R',
};

const Instructions = struct {
    dir: Direction,
    count: u16,
};

const Parsed = []Instructions;

fn parseInput(gpa: std.mem.Allocator, input: *std.Io.Reader) !Parsed {
    var output: std.ArrayList(Instructions) = .empty;
    defer output.deinit(gpa);
    while (input.takeDelimiter('\n')) |lineOpt| {
        if (lineOpt) |line| {
            try output.append(gpa, .{
                .dir = @enumFromInt(line[0]),
                .count = try std.fmt.parseInt(u16, line[1..], 10),
            });
        } else break;
    } else |err| return err;
    return output.toOwnedSlice(gpa);
}

fn part1(input: Parsed) usize {
    var pos: i32 = 50;
    var total: usize = 0;
    for (input) |ins| {
        const count = ins.count % 100;
        switch (ins.dir) {
            .LEFT => {
                pos -= count;
                if (pos < 0) pos += 100;
            },
            .RIGHT => {
                pos += count;
                if (pos > 99) pos -= 100;
            },
        }
        if (pos == 0) total += 1;
    }
    return total;
}

fn part2(input: Parsed) usize {
    var pos: i32 = 50;
    var total: usize = 0;
    for (input) |ins| {
        total += ins.count / 100;
        const count = ins.count % 100;
        switch (ins.dir) {
            .LEFT => {
                const prev_pos = pos;
                pos -= count;
                if (pos < 0) {
                    pos += 100;
                    if (prev_pos != 0) total += 1;
                }
            },
            .RIGHT => {
                pos += count;
                if (pos > 99) {
                    pos -= 100;
                    if (pos != 0) total += 1;
                }
            },
        }
        if (pos == 0) total += 1;
    }
    return total;
}

pub fn main() !void {
    var dbg: std.heap.DebugAllocator(.{}) = .init;
    const gpa = switch (@import("builtin").mode) {
        .Debug => dbg.allocator(),
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => std.heap.smp_allocator,
    };
    defer if (@import("builtin").mode == .Debug) std.debug.assert(dbg.deinit() == .ok);

    var threaded: std.Io.Threaded = .init(gpa);
    defer threaded.deinit();
    const io = threaded.io();

    const src = @src();

    var file = try common.readFile(gpa, io, src.file);
    defer file.deinit(gpa, io);

    const parsed = try parseInput(gpa, &file.reader.interface);
    defer gpa.free(parsed);
    std.debug.print("Part 1: {}\n", .{part1(parsed)});
    std.debug.print("Part 2: {}\n", .{part2(parsed)});
}

const INPUT =
    \\L168
    \\L30
    \\R48
    \\L5
    \\R60
    \\L55
    \\L1
    \\L99
    \\R14
    \\L82
;

test "part 1" {
    var test_buffer = std.mem.zeroes([37]u8);
    var reader = std.testing.Reader.init(&test_buffer, &.{.{ .buffer = INPUT }});
    const parsed = try parseInput(std.testing.allocator, &reader.interface);
    defer std.testing.allocator.free(parsed);
    try std.testing.expectEqual(3, part1(parsed));
}

test "part 2" {
    var test_buffer = std.mem.zeroes([37]u8);
    var reader = std.testing.Reader.init(&test_buffer, &.{.{ .buffer = INPUT }});
    const parsed = try parseInput(std.testing.allocator, &reader.interface);
    defer std.testing.allocator.free(parsed);
    try std.testing.expectEqual(7, part2(parsed));
}
