
---

# ROG Zig Src

**ROG Zig Src** is a Zig library providing utilities for **Git repository handling**, **URL validation**, **directory management**, **logging**, and **debug server support**. It is designed to simplify working with Git repositories, file systems, and logs in Zig applications, with strong typing and structured error handling.

## Features

* **Initialize repository paths** with user-defined URLs and local destination paths.
* **Validate Git repository URLs** using HTTP requests.
* **Check network connectivity** to GitHub.
* **Directory management**:

  * Check if a directory exists.
  * Create directories.
* **Logging and CSV support**:

  * Create CSV files.
  * Log errors with timestamps to CSV.
* **Debug server support**:

  * Initialize a local log server for streaming debug messages.
  * Automatic port checking and fallback.
* **Strongly typed structs** for configuration, input, and error handling.

---

## Library Structs

### `UserInputStruct_t`

Used to pass repository input data to the library.

| Field                     | Type          | Description                                              |
| ------------------------- | ------------- | -------------------------------------------------------- |
| `GitRepoUrl`              | `[*]const u8` | Pointer to the Git repository URL string.                |
| `GitRepoUrlLen`           | `u32`         | Length of the Git repository URL string.                 |
| `CloneDestinationPath`    | `[*]const u8` | Pointer to the local path where the repo will be cloned. |
| `CloneDestinationPathLen` | `u8`          | Length of the destination path string.                   |

---

### `PathLinkStruct_t`

Stores internal state for repository paths and links.

| Field             | Type         | Description                                  |
| ----------------- | ------------ | -------------------------------------------- |
| `GitPath`         | `[]const u8` | Path to the Git executable (`/usr/bin/git`). |
| `UrlLink`         | `[]const u8` | URL of the Git repository.                   |
| `DestinationPath` | `[]const u8` | Local destination path for cloning.          |

---

### `RepoUrlCheckStruct_t`

Used to validate Git repository URLs.

| Field    | Type          | Description                    |
| -------- | ------------- | ------------------------------ |
| `Url`    | `[*]const u8` | Pointer to the repository URL. |
| `length` | `u32`         | Length of the URL string.      |

---

### `PathDirStruct_t`

Represents directory paths in the file system.

| Field    | Type          | Description                    |
| -------- | ------------- | ------------------------------ |
| `Path`   | `[*]const u8` | Pointer to the directory path. |
| `length` | `u32`         | Length of the path string.     |

---

### `Server_t`

Represents a debug log server.

| Field     | Type              | Description                              |
| --------- | ----------------- | ---------------------------------------- |
| `server`  | `*std.net.Server` | Pointer to the running server.           |
| `port`    | `u32`             | Port number the server is listening on.  |
| `err_val` | `u32`             | Error code during server initialization. |

---

### `LogError_t`

Represents an error message to be logged.

| Field    | Type          | Description                          |
| -------- | ------------- | ------------------------------------ |
| `err`    | `[*]const u8` | Pointer to the error message string. |
| `length` | `u32`         | Length of the error string.          |

---

### `ProjectError_t` Enum

All library-specific error codes.

| Enum Value            | Description                           |
| --------------------- | ------------------------------------- |
| `Success`             | Operation succeeded.                  |
| `zeroLength`          | Provided string length is zero.       |
| `IndexOutOfBounds`    | Array or string access out of bounds. |
| `InvalidUrl`          | URL validation failed.                |
| `LengthTooShort`      | Provided input string is too short.   |
| `InvalidDestination`  | Destination path invalid.             |
| `FileWriteError`      | File write operation failed.          |
| `PortError`           | Port binding failed.                  |
| `PortUnavilable`      | Port is unavailable.                  |
| `IterationTimeOut`    | Port iteration timed out.             |
| `InvalidUrlFormat`    | URL parsing failed.                   |
| `DnsResolutionFailed` | DNS lookup failed.                    |

---

## Installation

Include the library in your Zig project:

```zig
const rog = @import("path/to/rog_zig_src.zig");
```

Requires **Zig 0.11.0 or higher** for `std.net` and `std.http` features.

---

## Usage Examples

### 1. Initialization

```zig
const input = rog.UserInputStruct_t{
    .GitRepoUrl = "https://github.com/user/repo.git",
    .GitRepoUrlLen = 30,
    .CloneDestinationPath = "/home/user/repos",
    .CloneDestinationPathLen = 16,
};

const result = rog.init(input);
if (result != @intFromEnum(rog.ProjectError_t.Success)) {
    // handle error
}
```

---

### 2. Check GitHub Connection

```zig
const status = rog.CheckConnection();
if (status == @intFromEnum(rog.ProjectError_t.Success)) {
    // connection successful
} else {
    // handle connection failure
}
```

---

### 3. Validate Repository URL

```zig
const url_check = rog.RepoUrlCheckStruct_t{
    .Url = "https://github.com/user/repo.git",
    .length = 30,
};

const result = rog.ValidateURL(url_check);
```

---

### 4. Directory Operations

```zig
const path = rog.PathDirStruct_t{
    .Path = "/home/user/repos",
    .length = 16,
};

if (rog.DirExists(path) != @intFromEnum(rog.ProjectError_t.Success)) {
    rog.MakeDir(path);
}
```

---

### 5. Logging to CSV

```zig
rog.createCsvFile(path);

const error_log = rog.LogError_t{
    .err = "Failed to clone repository",
    .length = 27,
};

rog.logErrorToCsv(path, error_log);
```

---

### 6. Debug Server

```zig
const server = rog.InitLogServer(8080);
if (server.err_val != @intFromEnum(rog.ProjectError_t.Success)) {
    // handle server initialization error
}
```

---

## Notes

* Git operations depend on the Git executable (default: `/usr/bin/git`).
* The debug server listens on `127.0.0.1` and automatically finds a free port if the requested port is unavailable.
* Timestamps in CSV logs are **Unix seconds**.

---

## License

This project is licensed under **GPL-3.0 License** – see [LICENSE](/LICENCE) for details.

