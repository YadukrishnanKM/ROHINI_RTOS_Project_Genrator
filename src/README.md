# Zig RPG  Dynamic library Version 2.0.0

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENCE)

A lightweight Zig library to perform Git repository operations, directory management, URL validation, and TCP server logging.

## Features

* Initialize repository paths and destination directories.
* Validate Git repository URLs.
* Check connectivity to `github.com`.
* Check if directories exist and create them if needed.
* Start a simple TCP log server on localhost.
* Stream logs to TCP connections.
* Handles common project errors with `ProjectError_t`.

## Usage

### Initialize Paths

```zig
var userInput = UserInputStruct_t{
    .GitRepoUrl = "https://github.com/user/repo.git",
    .GitRepoUrlLen = 29,
    .CloneDestinationPath = "/tmp/repo",
    .CloneDestinationPathLen = 9,
};

const result = gitutil.init(userInput);
if (result != @intFromEnum(ProjectError_t.Success)) {
    std.debug.print("Initialization failed: {}\n", .{result});
}
```

### Check Connection

```zig
const connResult = gitutil.CheckConnection();
if (connResult == @intFromEnum(ProjectError_t.Success)) {
    std.debug.print("Connection to GitHub successful!\n", .{});
}
```

### Validate URL

```zig
const repoUrl = RepoUrlCheckStruct_t{
    .Url = "https://github.com/user/repo.git",
    .length = 29,
};
const validateResult = gitutil.ValidateURL(repoUrl);
```

### Directory Operations

```zig
const path = PathDirStruct_t{ .Path = "/tmp/testdir", .length = 12 };
const existsResult = gitutil.DirExists(path);
if (existsResult != @intFromEnum(ProjectError_t.Success)) {
    gitutil.MakeDir(path);
}
```

### Start Log Server

```zig
const server = gitutil.InitLogServer(8080);
if (server.err_val == @intFromEnum(ProjectError_t.Success)) {
    std.debug.print("Server started on port {}\n", .{server.port});
}
```

## Error Handling

The library uses the `ProjectError_t` enum for all return codes:

| Error                | Meaning                          |
| -------------------- | -------------------------------- |
| `Success`            | Operation completed successfully |
| `zeroLength`         | Input has zero length            |
| `IndexOutOfBounds`   | Index out of bounds              |
| `InvalidUrl`         | URL is invalid                   |
| `LengthTooShort`     | Input length too short           |
| `InvalidDestination` | Invalid destination path         |
| `FileWriteError`     | Failed to write file             |
| `PortError`          | Generic port error               |
| `PortUnavilable`     | Port not available               |
| `IterationTimeOut`   | Port search timed out            |

## License

This library is licensed under [GPL-3.0 License](/LICENCE).

--