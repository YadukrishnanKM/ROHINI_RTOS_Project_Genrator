const std = @import("std");
const bld = @import("buld_setup.zig");


pub fn build(b: *std.Build) void {

    bld.Linnux_X86_64(b);
}
