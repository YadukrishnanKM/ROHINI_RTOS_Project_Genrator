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
    InvalidUrlFormat,
    DnsResolutionFailed,
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

const LogError_t = extern struct {
    err: [*]const u8,
    length: u32,
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

    // GitHub's public IPv4 address (one of them: 140.82.121.3)
    const github_ip =  std.net.Address.parseIp4("140.82.121.3", 443) catch |err| {
        std.debug.print("\nCheck connection pharse error : {s}", .{@errorName(err)});
        return @intFromError(err);
    };

    var socket = std.net.tcpConnectToAddress(github_ip) catch |err| {
        std.debug.print("\nCheck socket error : {s}", .{@errorName(err)});
        return @intFromError(err);
    };

    defer socket.close();

    // If we reach here, connection is successful
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
//                            Debug Server Private functions                            //
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

fn ResolveIPAddress(allocator: std.mem.Allocator, host: []const u8, port_in: u32) std.net.GetAddressListError![]std.net.Address {

    const port = @as(u16, @intCast(port_in));

    var Addresses =  std.net.getAddressList(allocator, host, port) 
    catch |err|{
            std.debug.print("ResolveIPAddress get address list  error {s}", .{@errorName(err)});
            return err;
    };
    defer Addresses.deinit();

   return Addresses.*.addrs;

}

//--------------------------------------------------------------------------------------//

fn PharseURL(url: []const u8) []const u8{

    const scheme_end_index = std.mem.indexOf(u8, url, "://") orelse {
        std.debug.print("\nParsing error: '://' not found in URL.\n", .{});
    };
    const host_start_index = scheme_end_index + 3; // Length of "://"

    // Find the end of the host, which is the next '/' or end of string
    const host_end_index = std.mem.indexOf(u8, url[host_start_index..(url.len-1)], "/") orelse url.len;
    
    return url[host_start_index..host_end_index];
}


//--------------------------------------------------------------------------------------//
//                                  Write logs in file                                  //
//--------------------------------------------------------------------------------------//

pub export fn createCsvFile(path_t: PathDirStruct_t) callconv(.C) u32 {

    const path = path_t.Path[0..path_t.length-1];

    if (fileExists(path)) {
        std.debug.print("\nFile already exists: {s}\n", .{path});
        return @intFromEnum(ProjectError_t.FileWriteError);
    }

    var cwd = std.fs.cwd();
    var file = cwd.createFile(path, .{ .read = true, .truncate = false, .exclusive = true }) catch |err| {
        std.debug.print("\nCreate csv file error : {s}", .{@errorName(err)});
        return @intFromError(err);
    };
    defer file.close();

    // Write header line to CSV
    file.writeAll("timestamp,error\n") catch |err|{
        std.debug.print("\nCreateCSV writeall error : {s}", .{@errorName(err)});
        return @intFromError(err);
    };

    std.debug.print("\nCSV file created: {s}\n", .{path});

    return @intFromEnum(ProjectError_t.Success);
}

//--------------------------------------------------------------------------------------//

pub export fn logErrorToCsv(file_path_t: PathDirStruct_t, error_name_t: LogError_t) callconv(.C) bool {
    const file_path = file_path_t.Path[0..file_path_t.length-1];
    const error_name = error_name_t.err[0..error_name_t.length-1];

    // Get current time from OS
    const now = std.time.Instant.now() catch |err| {
        std.debug.print("logErrorToCsv: failed to get time: {s}\n", .{@errorName(err)});
        return false;
    };
    const timestamp: i64 = now.timestamp.sec; // Unix timestamp in seconds

    var cwd = std.fs.cwd();
    var file: std.fs.File = undefined;

    var file_con:bool = true;

    // Check if file exists
    cwd.access(file_path, .{}) catch |err| {
        if (std.mem.eql(u8, @errorName(err),"FileNotFound")) file_con = false;
    };

    if (file_con) {
        // Open file for append
        file = cwd.openFile(file_path, .{ .mode = .write_only }) catch |err| {
            std.debug.print("logErrorToCsv: openFile error {s}\n", .{@errorName(err)});
            return false;
        };
    } else {
        // Create new file with header
        file = cwd.createFile(file_path, .{}) catch |err| {
            std.debug.print("logErrorToCsv: createFile error {s}\n", .{@errorName(err)});
            return false;
        };
        defer file.close();

        file.writeAll("timestamp,error\n") catch |err| {
            std.debug.print("logErrorToCsv: write all error {s}\n", .{@errorName(err)});
            return false;
        };

        // Reopen in append mode
        file = cwd.openFile(file_path, .{ .mode = .write_only }) catch |err| {
            std.debug.print("logErrorToCsv: reopen error {s}\n", .{@errorName(err)});
            return false;
        };
    }
    defer file.close();

    // Write timestamp and error name
    file.writer().print("{d},{s}\n", .{ timestamp, error_name }) catch |err| {
            std.debug.print("logErrorToCsv: writter error {s}\n", .{@errorName(err)});
            return false;
        };

    return true;
}

//--------------------------------------------------------------------------------------//
//                                  File Private functions                              //
//--------------------------------------------------------------------------------------//

pub fn fileExists(path: []const u8) bool {
    var cwd = std.fs.cwd();
    cwd.access(path, .{.mode = .read_only}) catch |err| {
        std.debug.print("fileExists acess error : {s}", .{@errorName(err)});
        return false;
    };
    return true;
}

//--------------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------------//

