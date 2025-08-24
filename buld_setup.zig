const std = @import("std");
const mn = @import("src/main.zig");

pub fn LinnuxAarch64 (b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .aarch64, .os_tag = .linux} },);
    
    const optimize = std.builtin.OptimizeMode.ReleaseSafe;

    const libfizzbuzz = b.addLibrary(.{
        .name = "proj_gen_linux_aarch64",
        .linkage = .dynamic,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(libfizzbuzz);
}

pub fn Linnux_X86_64 (b:*std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .x86_64, .os_tag = .linux} },);
    
    const optimize = std.builtin.OptimizeMode.ReleaseSafe;

    const libfizzbuzz = b.addLibrary(.{
        .name = "proj_gen_linux_x86_64",
        .linkage = .dynamic,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(libfizzbuzz);
}

pub fn Windows_X86_64 (b:*std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .x86_64, .os_tag = .windows} },);
    
    const optimize = std.builtin.OptimizeMode.ReleaseSafe;

    const libfizzbuzz = b.addLibrary(.{
        .name = "proj_gen_windows_x86_64",
        .linkage = .dynamic,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(libfizzbuzz);
}

pub fn WindowsAarch64 (b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .cpu_arch = .aarch64, .os_tag = .windows} },);
    
    const optimize = std.builtin.OptimizeMode.ReleaseSafe;

    const libfizzbuzz = b.addLibrary(.{
        .name = "proj_gen_windows_aarch64",
        .linkage = .dynamic,
        .version = .{ .major = 1, .minor = 2, .patch = 3 },
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(libfizzbuzz);
}