const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const test_step = b.step("test", "Run all tests");

    const check_step = b.step("check", "Check if all source files compile");

    var src_dir = std.fs.cwd().openDir("src", .{ .iterate = true }) catch |err| {
        std.debug.print("Failed to open src directory: {}\n", .{err});
        return;
    };
    defer src_dir.close();

    var iterator = src_dir.iterate();
    while (iterator.next() catch null) |entry| {
        if (entry.kind != .file) continue;
        if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;

        const file_path = b.fmt("src/{s}", .{entry.name});

        // Add test for this file
        const unit_tests = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = b.path(file_path),
                .target = target,
                .optimize = optimize,
            }),
        });

        const run_unit_tests = b.addRunArtifact(unit_tests);
        test_step.dependOn(&run_unit_tests.step);

        // Add check for this file
        const check_exe = b.addExecutable(.{
            .name = entry.name[0 .. entry.name.len - 4],
            .root_module = b.createModule(.{
                .root_source_file = b.path(file_path),
                .target = target,
                .optimize = optimize,
            }),
        });
        check_step.dependOn(&check_exe.step);
    }

    const run_step = b.step("run", "Run a specific day (e.g., 'zig build run -- day1')");

    const args = b.args orelse {
        std.debug.print("Usage: zig build run -- dayX\n", .{});
        return;
    };

    if (args.len == 0) {
        std.debug.print("Usage: zig build run -- dayX\n", .{});
        return;
    }

    const day_arg = args[0];
    const day_file = b.fmt("src/{s}.zig", .{day_arg});

    const exe = b.addExecutable(.{
        .name = day_arg,
        .root_module = b.createModule(.{
            .root_source_file = b.path(day_file),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    run_step.dependOn(&run_cmd.step);
}
