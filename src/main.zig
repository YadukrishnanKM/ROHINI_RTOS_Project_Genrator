const std = @import("std");
const net = std.net;

const ProjectError_t = enum {
    Success,
    zeroLength,
    IndexOutOfBounds,
    InvalidUrl,
    LengthTooShort,
    InvalidDestination,
    FileWriteError,
    PortError,
    PortUnavilable,
    IterationTimeOut,
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

const RepoUrlCheckStruct_t = extern struct {
    Url: [*]const u8,
    length: u32,
};

const PathDirStruct_t = extern struct {
    Path: [*]const u8,
    length: u32,
};

const Server_t = extern struct {
    server: *std.net.Server,
    port: u32,
    err_val: u32,
};
//--------------------------------------------------------------------------------------//

var PathAndLink = PathLinkStruct_t{
    .GitPath = "/usr/bin/git",
    .UrlLink = "https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git",
    .DestinationPath = "",
};

var DefaultPort = 8080;

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


pub export fn CheckConnection() callconv(.c) u32 {
    // Try to resolve github.com:443
    const address = net.Address.resolveIp("github.com", 443)
        catch |err| {
            std.debug.print("address error: {s}\n", .{@errorName(err)});
            return @intFromError(err);
        };

    
    const socket = net.tcpConnectToAddress(address)
        catch |err| {
            std.debug.print("CheckConnection socket error: {s}\n", .{@errorName(err)});
            return @intFromError(err);
        };
    defer socket.close();

    return @intFromEnum(ProjectError_t.Success);
}

//--------------------------------------------------------------------------------------//

pub export fn ValidateURL(GitRepoUrl: RepoUrlCheckStruct_t) callconv(.C) u32 {

    const allocator = std.heap.page_allocator;

    var client = std.http.Client{ .allocator = allocator };
    defer client.deinit();


    const uri = std.Uri.parse(GitRepoUrl.Url[0..GitRepoUrl.length])
        catch |err| {
            std.debug.print("\nValidateURL Uri Pharse error {s}",.{@errorName(err)});
            return @intFromError(err);
        };

    var server_header_buffer: [4096]u8 = undefined;

    var req = client.open(.GET, uri, .{.server_header_buffer = &server_header_buffer})
        catch |err| {
            std.debug.print("\nValidateURL client reqest error {s}",.{@errorName(err)});
            return @intFromError(err);
        };
    defer req.deinit();

    req.send() 
        catch |err| {
            std.debug.print("\nValidateURL reqest send error {s}",.{@errorName(err)});
            return @intFromError(err);
        };

    req.finish()
        catch |err| {
            std.debug.print("\nValidateURL reqest finish error {s}",.{@errorName(err)});
            return @intFromError(err);
        };

    req.wait()
        catch |err| {
            std.debug.print("\nValidateURL reqest wait error {s}",.{@errorName(err)});
            return @intFromError(err);
        };

    const status= req.response.status;

    
    return if(status.class() == .success or status.class() == .redirect) @intFromEnum(ProjectError_t.Success) 
                else @intFromEnum(ProjectError_t.InvalidUrl);
}

//--------------------------------------------------------------------------------------//

pub export fn DirExists(pathDir: PathDirStruct_t) callconv(.C) u32 {
    var cwd = std.fs.cwd();
    var dir = cwd.openDir(pathDir.Path[0..pathDir.length], .{}) catch |err| {
        std.debug.print("\nDirectory error {s}",.{@errorName(err)});
        return @intFromError(err);            
    };
    defer dir.close();
    return  @intFromEnum(ProjectError_t.Success);
}

//--------------------------------------------------------------------------------------//

pub export fn MakeDir(pathDir: PathDirStruct_t) callconv(.C) u32{ 
    std.fs.cwd().makeDir(pathDir.Path[0..pathDir.length]) catch |err| {
        std.debug.print("\nMakeDir error {s}",.{@errorName(err)});
        return @intFromError(err); 
    }; 

    return @intFromEnum(ProjectError_t.Success);
}

//--------------------------------------------------------------------------------------//
//                                      debug Server                                    //                    
//--------------------------------------------------------------------------------------//

pub export fn InitLogServer(start_port: u16) callconv(.C) Server_t {
    const port = @as(u16, @intCast(CheckPort(start_port)));
    const address = std.net.Address.parseIp4("127.0.0.1", port) catch |err| {
            std.debug.print("\nInitLogServer address error {s}",.{@errorName(err)});
            return Server_t{ .server = undefined, .port = port , .err_val = @intFromError(err)};
    };

    var server = address.listen(.{ .reuse_port = true,  }) catch |err| {
            std.debug.print("\nInitLogServer server error {s}",.{@errorName(err)});
            return Server_t{ .server = undefined, .port = port , .err_val = @intFromError(err)};
        };
        defer server.deinit();

    return Server_t{ .server = &server, .port = port , .err_val = @intFromEnum(ProjectError_t.Success)};
}

//--------------------------------------------------------------------------------------//

fn StreamLog(conn: *std.net.Server.Connection, msg: []const u8) !void {
    try conn.stream.writeAll(msg);
    try conn.stream.writeAll("\n");
}

//--------------------------------------------------------------------------------------//

fn CheckPort(port: u32) u32 {
    var candidate = @as(u16, @intCast(port));
    const MAX_PORT_ITTR = 20;

    for (0..MAX_PORT_ITTR) |i| {

        std.debug.print("\nAttempt {d}\n", .{i});

        const address = std.net.Address.parseIp4("127.0.0.1", candidate) catch |err| {
            std.debug.print("\nCheckPort address error {s}", .{@errorName(err)});
            return @intFromError(err);
        };

        var listener = address.listen(.{ .reuse_port = true }) catch |err| {
            // if binding fails → try next port
            std.debug.print("\nCheckPort listener error on port {}: {s}", .{ candidate, @errorName(err) });
            candidate += 1;
            if (candidate == 0) return @intFromEnum(ProjectError_t.PortUnavilable);
            continue;
        };
        defer listener.deinit();

        // if we reached here, the port is free
        return candidate;
    }

    return @intFromEnum(ProjectError_t.IterationTimeOut);
}


//--------------------------------------------------------------------------------------//
//                                  Write logs in file                                  //
//--------------------------------------------------------------------------------------//



//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//