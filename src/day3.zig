const std = @import("std");
const common = @import("common.zig");

fn Banks(comptime row_size: usize) type {
    return struct {
        const Self = @This();
        batteries: [row_size]u8,

        pub fn init(batteries: [row_size]u8) Self {
            return .{ .batteries = batteries };
        }
    };
}

fn parseInput(comptime line_len: usize, input: []const u8, banks: []Banks(line_len)) void {
    var i: usize = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) continue;
        var batteries: [line_len]u8 = undefined;
        std.mem.copyForwards(u8, &batteries, line);
        for (&batteries) |*bat| {
            bat.* = bat.* - '0';
        }
        banks[i] = Banks(line_len).init(batteries);
        i += 1;
    }
}

fn solve(bats: []const u8, size: usize) usize {
    if (size == 0) return 0;

    var i_max: usize = 0;
    for (bats, 0..) |bat, i| {
        if (bat > bats[i_max] and i <= bats.len - size) {
            i_max = i;
        }
    }

    return bats[i_max] * std.math.pow(usize, 10, size - 1) + solve(bats[i_max + 1 ..], size - 1);
}

fn part1(comptime line_len: usize, banks: []Banks(line_len)) usize {
    var total: usize = 0;
    for (banks) |bank| {
        total += solve(&bank.batteries, 2);
    }
    return total;
}

fn part2(comptime line_len: usize, banks: []Banks(line_len)) usize {
    var total: usize = 0;
    for (banks) |bank| {
        total += solve(&bank.batteries, 12);
    }
    return total;
}

pub fn main() !void {
    const src = @src();
    const input = @embedFile(comptime common.getFileName(src));

    const line_count = common.countChar(input, '\n');
    const line_len = comptime std.mem.indexOfScalar(u8, input, '\n').?;
    var banks: [line_count]Banks(line_len) = undefined;
    parseInput(line_len, input, &banks);
    std.log.default.info("Part 1: {}", .{part1(line_len, &banks)});
    std.log.default.info("Part 2: {}", .{part2(line_len, &banks)});
}

const INPUT =
    \\987654321111111
    \\811111111111119
    \\234234234234278
    \\818181911112111
;

test "part 1" {
    var banks: [4]Banks(15) = undefined;
    parseInput(15, INPUT, &banks);
    try std.testing.expectEqual(357, part1(15, &banks));
}

test "part 2" {
    var banks: [4]Banks(15) = undefined;
    parseInput(15, INPUT, &banks);
    try std.testing.expectEqual(3121910778619, part2(15, &banks));
}
