const std = @import("std");
const common = @import("common.zig");

const Direction = enum(u8) {
    LEFT = 'L',
    RIGHT = 'R',
};

const Turns = struct {
    dir: Direction,
    count: u16,
};

fn parseInput(input: []const u8, turn: []Turns) void {
    var i: usize = 0;
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        if (line.len == 0) continue;
        turn[i] = .{
            .dir = @enumFromInt(line[0]),
            .count = common.parseOrFail(u16, line[1..]),
        };
        i += 1;
    }
}

fn part1(turns: []Turns) usize {
    var pos: i32 = 50;
    var total: usize = 0;
    for (turns) |turn| {
        switch (turn.dir) {
            .LEFT => pos = @mod(pos - turn.count, 100),
            .RIGHT => pos = @mod(pos + turn.count, 100),
        }
        if (pos == 0) total += 1;
    }
    return total;
}

fn part2(turns: []Turns) usize {
    var pos: i32 = 50;
    var total: usize = 0;
    for (turns) |turn| {
        total += @divTrunc(turn.count, 100);
        const count = @rem(turn.count, 100);
        if (pos + count >= 100 or (pos > 0 and pos + count <= 0)) {
            total += 1;
        }
        switch (turn.dir) {
            .LEFT => pos = @mod(pos - turn.count, 100),
            .RIGHT => pos = @mod(pos + turn.count, 100),
        }
    }
    return total;
}

pub fn main() !void {
    const src = @src();
    const input = @embedFile(comptime common.getFileName(src));

    const line_count = common.countChar(input, '\n');
    var turns: [line_count]Turns = undefined;
    parseInput(input, &turns);
    std.log.default.info("Part 1: {}", .{part1(&turns)});
    std.log.default.info("Part 2: {}", .{part2(&turns)});
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
    var instructions: [10]Turns = undefined;
    parseInput(INPUT, &instructions);
    try std.testing.expectEqual(3, part1(&instructions));
}

test "part 2" {
    var instructions: [10]Turns = undefined;
    parseInput(INPUT, &instructions);
    try std.testing.expectEqual(7, part2(&instructions));
}
