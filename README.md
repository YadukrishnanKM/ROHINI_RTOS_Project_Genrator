# Rohini RTOS Project Generator - Zig Dynamic Library (v1.3.0)

A cross-platform Zig dynamic library to generate and manage RTOS project skeletons by cloning GitHub repositories as tarballs.
Provides C-compatible functions for initializing repository paths and downloading repositories or specific branches.

<p align="center">
  <img src="RTOS.png" alt="Logo" width="500"/>
</p>

---

## Features

* **Cross-platform dynamic library**: Supports Linux (x86\_64 & aarch64) and Windows (x86\_64 & aarch64).
* **GitHub repository cloning**: Clone the `main` or `dev` branch of a repository as a tarball.
* **C-compatible API**: Functions can be used in C or other languages via FFI.
* **Standardized error codes**: Provides structured error handling.
* **Pure Zig implementation**: No external scripting or shell dependencies.

---

## API Overview

### Error Codes (`ProjectError_t`)

| Code | Meaning                                                         |
| ---- | --------------------------------------------------------------- |
| 0    | `Success` - Operation completed successfully                    |
| 1    | `zeroLength` - Input length was zero                            |
| 2    | `IndexOutOfBounds` - Index exceeded valid bounds                |
| 3    | `InvalidUrl` - URL provided was invalid or malformed            |
| 4    | `LengthTooShort` - Input string length was too short            |
| 5    | `InvalidDestination` - Destination path invalid or inaccessible |
| 6    | `NetworkError` - HTTP request failed                            |
| 7    | `FileWriteError` - Failed to write downloaded file              |

---

### Structures

#### `UserInputStruct_t`

```zig
const UserInputStruct_t = extern struct {
    GitRepoUrl: [*]const u8,
    GitRepoUrlLen: u32,
    CloneDestinationPath: [*]const u8,
    CloneDestinationPathLen: u8,
};
```

Used for passing repository URL and clone destination from external programs.

#### `PathLinkStruct_t`

```zig
const PathLinkStruct_t = struct {
    GitPath: []const u8,        // Unused, kept for ABI compatibility
    UrlLink: []const u8,        // Repository URL
    DestinationPath: []const u8 // Local clone destination
};
```

Internal structure used to store repository URLs and local paths.

---

### Functions

#### `init`

```zig
pub fn init(UsrInput: UserInputStruct_t) callconv(.C) u32
```

* Initializes repository URL and local destination path.
* Validates input lengths.
* Returns `ProjectError_t.Success` or `ProjectError_t.LengthTooShort`.

---

#### `CloneRepo`

```zig
pub fn CloneRepo() callconv(.C) u32
```

* Downloads the `main` branch tarball of the repository.
* Returns `ProjectError_t.Success` on success or a network/file error.

---

#### `CloneDevRepo`

```zig
pub fn CloneDevRepo() callconv(.C) u32
```

* Downloads the `dev` branch tarball of the repository.
* Returns `ProjectError_t.Success` on success or a network/file error.

---

## Build Instructions

### Prerequisites

* Zig compiler (>= 0.14.0)
* Git installed (optional, only if you want to validate URLs manually)

---

### Building for Linux x86\_64

```bash
zig build-lib src/main.zig -dynamic -OReleaseSafe -target x86_64-linux
```

* Produces `libproj_gen_linux_x86_64.so`
* Library version: **1.3.0**

### Building for Linux aarch64

```bash
zig build-lib src/main.zig -dynamic -OReleaseSafe -target aarch64-linux
```

* Produces `libproj_gen_linux_aarch64.so`

### Building for Windows x86\_64

```bash
zig build-lib src/main.zig -dynamic -OReleaseSafe -target x86_64-windows
```

* Produces `proj_gen_windows_x86_64.dll`

### Building for Windows aarch64

```bash
zig build-lib src/main.zig -dynamic -OReleaseSafe -target aarch64-windows
```

* Produces `proj_gen_windows_aarch64.dll`

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
    if (CloneRepo() != 0) return -1;

    return 0;
}
```

* Replace `/tmp/clone_dir` with your desired destination path.
* The tarball of the repository branch will be downloaded to the specified path.

---

## Versioning

* Current version: **1.3.0**
* Semantic versioning: `MAJOR.MINOR.PATCH`

### Changelog (1.3.0)

* Replaced shell `git clone` with HTTP tarball download via Zig `std.http.Client`.
* Added proper handling for `main` and `dev` branch downloads.
* Updated C-compatible FFI for safer string and buffer handling.
* Added `NetworkError` and `FileWriteError` in `ProjectError_t`.

---

## License

GPL 3.0 [LICENSE](/LICENSE)

---

## Notes

* All public functions are **C-callable exports** with strong linkage.
* Designed for embedding in RTOS project generators or external scripts.
* Can be extended for additional branches or repository operations.

