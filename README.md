# Rohini RTOS Project Generator - Zig Dynamic Library (v2.0.0)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENCE)

A cross-platform Zig dynamic library to manage RTOS project skeletons, check network connectivity, validate URLs, manage directories, and start TCP log servers.
All functions are C-callable and usable via FFI.

<p align="center">
  <img src="RTOS.png" alt="Logo" width="500"/>
</p>

---

## Features

* **Cross-platform dynamic library**: Supports Linux (x86\_64 & aarch64) and Windows (x86\_64 & aarch64).
* **Network utilities**: Check connectivity to GitHub.
* **URL validation**: Validate HTTP URLs for repositories.
* **Filesystem operations**: Check or create directories.
* **TCP debug server**: Initialize a simple local server and stream logs.
* **C-compatible API**: Functions can be used in C or other languages via FFI.
* **Structured error handling**: Uses `ProjectError_t` enum for consistent error codes.

---

## Usable Enums

### `ProjectError_t`

| Code                 | Meaning                                  |
| -------------------- | ---------------------------------------- |
| `Success`            | Operation completed successfully         |
| `zeroLength`         | Input length was zero                    |
| `IndexOutOfBounds`   | Index exceeded valid bounds              |
| `InvalidUrl`         | URL provided was invalid or unreachable  |
| `LengthTooShort`     | Input string length too short            |
| `InvalidDestination` | Destination path invalid or inaccessible |
| `FileWriteError`     | Failed to write downloaded file          |
| `PortError`          | Generic port error                       |
| `PortUnavilable`     | Port not available for binding           |
| `IterationTimeOut`   | Port search timed out                    |

**Usage:** Returned by most functions to indicate success or type of error.

---

## Usable Structures

| Struct                 | Description                                                                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `UserInputStruct_t`    | Input from external programs for repo cloning. Fields: `GitRepoUrl`, `GitRepoUrlLen`, `CloneDestinationPath`, `CloneDestinationPathLen`. |
| `PathLinkStruct_t`     | Internal storage of repository paths. Fields: `GitPath`, `UrlLink`, `DestinationPath`.                                                   |
| `RepoUrlCheckStruct_t` | For URL validation. Fields: `Url`, `length`.                                                                                             |
| `PathDirStruct_t`      | For filesystem operations. Fields: `Path`, `length`.                                                                                     |
| `Server_t`             | TCP server information. Fields: `server` (pointer), `port`, `err_val`.                                                                   |

---

## Functions Overview

### Initialization

```zig
pub fn init(UsrInput: UserInputStruct_t) callconv(.C) u32
```

* Initializes repository URL and local destination path.
* Validates input lengths.

### Network

```zig
pub fn CheckConnection() callconv(.C) u32
pub fn ValidateURL(GitRepoUrl: RepoUrlCheckStruct_t) callconv(.C) u32
```

* `CheckConnection()` — test connectivity to `github.com:443`.
* `ValidateURL()` — validate the HTTP URL; ensures server responds with success or redirect status.

### Filesystem

```zig
pub fn DirExists(pathDir: PathDirStruct_t) callconv(.C) u32
pub fn MakeDir(pathDir: PathDirStruct_t) callconv(.C) u32
```

* Check if a directory exists.
* Create a directory if it does not exist.

### Debug Server

```zig
pub fn InitLogServer(start_port: u16) callconv(.C) Server_t
```

* Initialize a TCP server on `127.0.0.1`.
* Returns `Server_t` containing the server pointer, port, and error value.
* `StreamLog()` — internal helper to stream messages to connected clients.

---

## Build Instructions

### Using `build.zig` / `build_setup.zig`

Default build targets Linux x86\_64:

```bash
zig build
```

### Building Specific Targets

```bash
zig build -Dtarget=x86_64-linux    # Linux x86_64
zig build -Dtarget=aarch64-linux   # Linux aarch64
zig build -Dtarget=x86_64-windows  # Windows x86_64
zig build -Dtarget=aarch64-windows # Windows aarch64
```

**Artifacts Produced:**

| Target          | Output Library                 |
| --------------- | ------------------------------ |
| Linux x86\_64   | `libproj_gen_linux_x86_64.so`  |
| Linux aarch64   | `libproj_gen_linux_aarch64.so` |
| Windows x86\_64 | `proj_gen_windows_x86_64.dll`  |
| Windows aarch64 | `proj_gen_windows_aarch64.dll` |

---

## Example Usage in C

```c
#include "proj_gen_xx_yy.h"

int main() {
    UserInputStruct_t input = {
        .GitRepoUrl = "https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git",
        .GitRepoUrlLen = 54,
        .CloneDestinationPath = "/tmp/clone_dir",
        .CloneDestinationPathLen = 14
    };

    if (init(input) != 0) return -1;
    if (CheckConnection() != 0) return -1;

    RepoUrlCheckStruct_t url_check = {
        .Url = input.GitRepoUrl,
        .length = input.GitRepoUrlLen
    };

    if (ValidateURL(url_check) != 0) return -1;

    PathDirStruct_t dir = { .Path = "/tmp/clone_dir", .length = 14 };
    if (DirExists(dir) != 0) MakeDir(dir);

    return 0;
}
```

---

## Versioning

* Current version: **2.0.0**
* Semantic versioning: `MAJOR.MINOR.PATCH`

### Changelog (2.0.0)

* Upgraded library to **v2.0.0** with enhanced API stability and cross-platform support.
* Refined **network connectivity** and **URL validation** functions for improved reliability.
* Enhanced **directory handling** with safer checks and creation operations.
* Redesigned **TCP debug server** initialization and streaming for better logging performance.
* Updated **enums and structs** for more consistent **error handling**, improved C FFI compatibility, and clearer developer usage.
* Optimized internal handling of repository paths and user input structures.

---

## License

GPL 3.0 [LICENSE](/LICENCE)

