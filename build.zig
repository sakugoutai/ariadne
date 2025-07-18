const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const ariadne_mod = b.addModule("ariadne", .{
        .root_source_file = b.path("src/ariadne.zig"),
        .target           = target,
        .optimize         = optimize,
    });

    const string_test = b.addTest(.{
        .root_source_file = b.path("test/test_string.zig"),
        .target           = target,
        .optimize         = optimize,
    });
    string_test.root_module.addImport("ariadne", ariadne_mod);

    const run_string_test = b.addRunArtifact(string_test);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_string_test.step);
}
