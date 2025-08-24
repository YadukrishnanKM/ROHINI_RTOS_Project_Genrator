const std = @import("std");

const ProjectError_t = enum {
    Success,
    zeroLength,
    IndexOutOfBounds,
    InvalidUrl,
    LengthTooShort,
    InvalidDestination,
    NetworkError,
    FileWriteError,
};

const PathLinkStruct_t = struct {
    GitPath: []const u8, // unused, kept for ABI compatibility
    UrlLink: []const u8,
    DestinationPath: []const u8,
};

const UserInputStruct_t = extern struct {
    GitRepoUrl: [*]const u8,
    GitRepoUrlLen: u32,
    CloneDestinationPath: [*]const u8,
    CloneDestinationPathLen: u8,
};

var PathAndLink = PathLinkStruct_t{
    .GitPath = "",
    .UrlLink = "",
    .DestinationPath = "",
};

//--------------------------------------------------------------------------------------//

pub export fn init(UsrInput: UserInputStruct_t) callconv(.C) u32 {
    PathAndLink.UrlLink = if (UsrInput.GitRepoUrlLen >= 15)
        UsrInput.GitRepoUrl[0..UsrInput.GitRepoUrlLen]
    else
        return @intFromEnum(ProjectError_t.LengthTooShort);

    PathAndLink.DestinationPath = if (UsrInput.CloneDestinationPathLen >= 3)
        UsrInput.CloneDestinationPath[0..UsrInput.CloneDestinationPathLen]
    else
        return @intFromEnum(ProjectError_t.LengthTooShort);

    return @intFromEnum(ProjectError_t.Success);
}

//--------------------------------------------------------------------------------------//


fn download_tarball(url_str: []const u8, dest_path: []const u8) u32 {
    const gpa = std.heap.page_allocator;
    var client = std.http.Client{ .allocator = gpa };
    defer client.deinit();

    var server_header_buffer: [1024]u8 = undefined;

    // Parse the URL string into a Uri
    const uri =  std.Uri.parse(url_str) catch |err| return @intFromError(err);

    // Open request using the Uri
   var req = client.open(.GET, uri, .{.server_header_buffer = server_header_buffer[0..], }) catch |err| return @intFromError(err);
    defer req.deinit();

    // Send the request
    req.send() catch |err| return @intFromError(err);

    // Create or overwrite the destination file
    const file = std.fs.cwd().createFile(dest_path, .{ .truncate = true }) catch |err| return @intFromError(err);
    defer file.close();

    return @intFromEnum(ProjectError_t.Success);
}



//--------------------------------------------------------------------------------------//

pub export fn CloneRepo() callconv(.C) u32 {
    var gpa = std.heap.page_allocator;

    const buf_len = PathAndLink.UrlLink.len + 50;
    const buf = gpa.alloc(u8, buf_len) catch |err| return @intFromError(err);
    defer gpa.free(buf);

    _ = std.fmt.bufPrint(buf, "{s}/archive/refs/heads/main.tar.gz", .{ PathAndLink.UrlLink }) catch return @intFromEnum(ProjectError_t.InvalidUrl);
    const writtenSlice = std.fmt.bufPrint(buf, "{s}/archive/refs/heads/main.tar.gz", .{ PathAndLink.UrlLink }) 
                                catch |err| return @intFromError(err);

    return download_tarball(writtenSlice, PathAndLink.DestinationPath);
}

pub export fn CloneDevRepo() callconv(.C) u32 {
    var gpa = std.heap.page_allocator;

    const buf_len = PathAndLink.UrlLink.len + 50;
    const buf =  gpa.alloc(u8, buf_len) catch |err| return @intFromError(err);
    defer gpa.free(buf);

    _ = std.fmt.bufPrint(buf, "{s}/archive/refs/heads/dev.tar.gz", .{ PathAndLink.UrlLink }) catch |err| return @intFromError(err);
    const writtenSlice =  std.fmt.bufPrint(buf, "{s}/archive/refs/heads/main.tar.gz", .{ PathAndLink.UrlLink }) 
                        catch |err| return @intFromError(err);

    return download_tarball(writtenSlice, PathAndLink.DestinationPath);
}

//--------------------------------------------------------------------------------------//

