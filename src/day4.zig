const std = @import("std");
const Allocator = std.mem.Allocator;
const common = @import("common.zig");

const Pos = struct {
    const Self = @This();

    x: usize,
    y: usize,

    pub fn init(x: usize, y: usize) Self {
        return .{ .x = x, .y = y };
    }
};

fn parseInput(gpa: Allocator, input: []const u8) !std.AutoHashMap(Pos, bool) {
    var map: std.AutoHashMap(Pos, bool) = .init(gpa);
    var y: usize = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        for (line, 0..) |c, x| {
            if (c == '@') try map.put(.init(x, y), true);
        }
        y += 1;
    }
    return map;
}

fn getAdjacent(map: std.AutoHashMap(Pos, bool), x: usize, y: usize) usize {
    var adjacent: usize = 0;
    if (x > 0) {
        if (y > 0 and map.get(.{ .x = x - 1, .y = y - 1 }) != null) adjacent += 1;
        if (map.get(.{ .x = x - 1, .y = y }) != null) adjacent += 1;
        if (map.get(.{ .x = x - 1, .y = y + 1 }) != null) adjacent += 1;
    }
    if (y > 0 and map.get(.{ .x = x, .y = y - 1 }) != null) adjacent += 1;
    if (map.get(.{ .x = x, .y = y + 1 }) != null) adjacent += 1;
    if (y > 0 and map.get(.{ .x = x + 1, .y = y - 1 }) != null) adjacent += 1;
    if (map.get(.{ .x = x + 1, .y = y }) != null) adjacent += 1;
    if (map.get(.{ .x = x + 1, .y = y + 1 }) != null) adjacent += 1;
    return adjacent;
}

fn part1(map: std.AutoHashMap(Pos, bool), rows: usize, cols: usize) usize {
    var total: usize = 0;
    for (0..cols) |x| {
        for (0..rows) |y| {
            if (map.get(.{ .x = x, .y = y }) != null) {
                const adjacent = getAdjacent(map, x, y);
                if (adjacent < 4) total += 1;
            }
        }
    }
    return total;
}

fn part2(map: *std.AutoHashMap(Pos, bool), rows: usize, cols: usize) usize {
    var total: usize = 0;
    while (true) {
        var did_remove = false;
        for (0..cols) |x| {
            for (0..rows) |y| {
                if (map.get(.{ .x = x, .y = y }) != null) {
                    const adjacent = getAdjacent(map.*, x, y);
                    if (adjacent < 4) {
                        total += 1;
                        _ = map.remove(.{ .x = x, .y = y });
                        did_remove = true;
                    }
                }
            }
        }
        if (!did_remove) break;
    }
    return total;
}

pub fn main() !void {
    var dbg = std.heap.DebugAllocator(.{}).init;
    const gpa = switch (@import("builtin").mode) {
        .Debug => dbg.allocator(),
        .ReleaseSafe, .ReleaseFast, .ReleaseSmall => std.heap.smp_allocator,
    };
    defer if (@import("builtin").mode == .Debug) std.debug.assert(dbg.deinit() == .ok);

    const src = @src();
    const input = @embedFile(comptime common.getFileName(src));

    const rows = common.countChar(input, '\n');
    const cols = std.mem.indexOfScalar(u8, input, '\n') orelse return;

    var map = try parseInput(gpa, input);
    defer map.deinit();
    std.log.default.info("Part 1: {}", .{part1(map, rows, cols)});
    std.log.default.info("Part 2: {}", .{part2(&map, rows, cols)});
}

const INPUT =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

test "part 1" {
    var map = try parseInput(std.testing.allocator, INPUT);
    defer map.deinit();
    try std.testing.expectEqual(13, part1(map, 10, 10));
}

test "part 2" {
    var map = try parseInput(std.testing.allocator, INPUT);
    defer map.deinit();
    try std.testing.expectEqual(43, part2(&map, 10, 10));
}
