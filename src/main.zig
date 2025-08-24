const std = @import("std");

//---------------------------------------------------------------------------------------------------//

/// Project-wide error codes returned by functions.
///
/// Each variant represents a possible failure or success state.
/// Use with `@intFromEnum()` or `@enumFromInt()` when interoperating with C.
const ProjectError_t = enum {
    /// Operation completed successfully.
    Success,

    /// Input length was zero.
    zeroLength,

    /// Index exceeded valid bounds.
    IndexOutOfBounds,

    /// URL provided was invalid or malformed.
    InvalidUrl,

    /// Input string length was too short to be valid.
    LengthTooShort,

    /// Destination path provided was invalid or inaccessible.
    InvalidDestination,    
};

//---------------------------------------------------------------------------------------------------//

/// Holds paths and links used for Git repository operations.
///
/// This structure is used to configure the Git executable path,
/// the repository URL to clone, and the target destination path.
const PathLinkStruct_t = struct {
    /// Path to the Git binary (e.g. `/usr/bin/git`).
    GitPath: []const u8,

    /// URL of the Git repository to clone.
    UrlLink: []const u8,

    /// Local destination directory where the repository will be cloned.
    DestinationPath: []const u8,
};

//---------------------------------------------------------------------------------------------------//

/// Holds user-provided input values for Git operations.
///
/// This struct uses raw pointers and explicit lengths instead of
/// Zig slices, making it suitable for FFI (e.g. when data comes
/// from C or external APIs).
const  UserInputStruct_t = extern struct {
    /// Pointer to the Git repository URL string (not null-terminated).
    GitRepoUrl: [*]const u8,

    /// Length of the Git repository URL string.
    GitRepoUrlLen: u32,

    /// Pointer to the local destination path string (not null-terminated).
    CloneDestinationPath: [*]const u8,

    /// Length of the clone destination path string.
    CloneDestinationPathLen: u8,
};

//---------------------------------------------------------------------------------------------------//

var prog_error = ProjectError_t.Success;

var PathAndLink = PathLinkStruct_t{
    .GitPath = "/usr/bin.git",
    .UrlLink = " https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git",
    .DestinationPath = undefined,
};
//---------------------------------------------------------------------------------------------------//

pub fn init (UsrInput :UserInputStruct_t) callconv(.C) u32 {

    PathAndLink.UrlLink         =   if (UsrInput.GitRepoUrlLen >= 15) UsrInput.GitRepoUrl[0..UsrInput.GitRepoUrlLen] 
                                    else  return @intFromEnum(ProjectError_t.LengthTooShort);
    
    PathAndLink.DestinationPath =   if (UsrInput.CloneDestinationPathLen >= 3) UsrInput.CloneDestinationPath[0..UsrInput.CloneDestinationPathLen]
                                    else return @intFromEnum(ProjectError_t.LengthTooShort);
    return @intFromEnum(ProjectError_t.Success); 
}

//---------------------------------------------------------------------------------------------------//

pub fn CloneRepo() callconv(.C) u32 {

    const allocator = std.heap.page_allocator;

    const argv = &[_][]const u8{ 
        PathAndLink.GitPath, 
        "clone",
        PathAndLink.UrlLink,
        PathAndLink.DestinationPath
        };

    const ChildProcess = std.process.Child.run(.{ 
        .allocator = allocator, 
        .argv = argv 
        }) catch |err| {
        return @intFromError(err);
    };

    _ = ChildProcess.stdout;

    return @intFromEnum(ProjectError_t.Success);

}

//---------------------------------------------------------------------------------------------------//

pub fn CloneDevRepo() callconv(.C) u32{

    const allocator = std.heap.page_allocator;

    const argv = &[_][]const u8{ 
        PathAndLink.GitPath, 
        "clone", "--branch", "dev", 
        PathAndLink.UrlLink,
        PathAndLink.DestinationPath 
    };

    const ChildProcess = std.process.Child.run(.{ 
        .allocator = allocator, 
        .argv = argv 
        }) catch |err| {
        return @intFromError(err);
    };

    _ = ChildProcess.stdout;

    return @intFromEnum(ProjectError_t.Success);
}

//---------------------------------------------------------------------------------------------------//

// pub fn tst_child_process() callconv(.C) u32 {

//     const allocator = std.heap.page_allocator;

//     const argv = &[_][]const u8{ 
//         PathAndLink.GitPath, 
//         "clone", "--branch", "dev", 
//         PathAndLink.UrlLink,
//         PathAndLink.DestinationPath 
//     };

//     const ChildProcess = std.process.Child.run(.{ 
//         .allocator = allocator, 
//         .argv = argv 
//         }) catch |err| {
//             return @intFromError(err);
//     };

//     _ = ChildProcess.stdout;

//     return @intFromEnum(ProjectError_t.Success);
// }

