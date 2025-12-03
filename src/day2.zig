const std = @import("std");
const Allocator = std.mem.Allocator;
const common = @import("common.zig");

const IDRange = struct {
    low: usize,
    high: usize,

    pub fn invalidIds(self: IDRange, gpa: Allocator, check_all: bool) ![]usize {
        var invalid: std.ArrayList(usize) = .empty;
        defer invalid.deinit(gpa);
        const max_digits = std.math.log10(self.high) + 1;

        var digits: usize = 1;
        while (digits <= max_digits) : (digits += 1) {
            var repeat_size: usize = 2;
            while (repeat_size <= if (check_all) max_digits / digits else 2) : (repeat_size += 1) {
                const pow10_digit = std.math.pow(u128, 10, digits);
                const expander = (std.math.pow(u128, 10, digits * repeat_size) - 1) / (pow10_digit - 1);
                if (expander > self.high) continue;
                const min_left = std.math.pow(usize, 10, digits - 1);
                const max_left = pow10_digit - 1;

                const potential_low = @max((self.low + expander - 1) / expander, min_left);
                const potential_high = @min(self.high / expander, max_left);

                if (potential_low > potential_high) continue;

                var potential = potential_low;
                while (potential <= potential_high) : (potential += 1) {
                    const num: usize = @intCast(potential * expander);
                    if (num >= self.low and num <= self.high and std.mem.indexOf(usize, invalid.items, &.{num}) == null) {
                        try invalid.append(gpa, num);
                    }
                }
            }
        }

        return try invalid.toOwnedSlice(gpa);
    }
};

fn parseInput(input: []const u8, ids: []IDRange) void {
    var i: usize = 0;
    var it = std.mem.splitScalar(u8, input[0 .. input.len - 1], ',');
    while (it.next()) |line| {
        if (line.len == 0) continue;
        if (std.mem.find(u8, line, "-")) |index| {
            ids[i] = .{
                .low = common.parseOrFail(usize, line[0..index]),
                .high = common.parseOrFail(usize, line[index + 1 ..]),
            };
        }
        i += 1;
    }
}

fn run(gpa: Allocator, ids: []IDRange, check_all: bool) !usize {
    var total: usize = 0;
    for (ids) |id| {
        const invalid = try id.invalidIds(gpa, check_all);
        defer gpa.free(invalid);
        for (invalid) |num| {
            total += num;
        }
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

    const comma_count = common.countChar(input, ',');
    var turns: [comma_count + 1]IDRange = undefined;
    parseInput(input, &turns);
    std.log.default.info("Part 1: {}", .{try run(gpa, &turns, false)});
    std.log.default.info("Part 2: {}", .{try run(gpa, &turns, true)});
}

const INPUT = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124\n";

test "part 1" {
    var instructions: [11]IDRange = undefined;
    parseInput(INPUT, &instructions);
    try std.testing.expectEqual(1227775554, try run(std.testing.allocator, &instructions, false));
}

test "part 2" {
    var instructions: [11]IDRange = undefined;
    parseInput(INPUT, &instructions);
    try std.testing.expectEqual(4174379265, try run(std.testing.allocator, &instructions, true));
}
