const std = @import("std");
const bld = @import("build_setup.zig");

pub fn build(b: *std.Build) void {
    bld.Linux_X86_64(b);
}
