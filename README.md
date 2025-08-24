# Rohini RTOS Project Generator - Zig Dynamic Library

A cross-platform Zig dynamic library to generate and manage RTOS project skeletons by cloning Git repositories.  
It provides C-compatible functions for initializing repository paths and cloning repositories or branches.

<p align="center">
  <img src="RTOS.png" alt="Logo" width="500"/>
</p>

---

## Features

- **Cross-platform dynamic library**: Supports Linux (x86_64 & aarch64) and Windows (x86_64 & aarch64).  
- **Git repository cloning**: Clone any repository or a specific branch (e.g., `dev`).  
- **C-compatible API**: Functions can be used in C or other languages via FFI.  
- **Standardized error codes**: Provides structured error handling.

---

## API Overview

### Error Codes (`ProjectError_t`)

| Code | Meaning |
|------|---------|
| 0    | `Success` - Operation completed successfully |
| 1    | `zeroLength` - Input length was zero |
| 2    | `IndexOutOfBounds` - Index exceeded valid bounds |
| 3    | `InvalidUrl` - URL provided was invalid or malformed |
| 4    | `LengthTooShort` - Input string length was too short |
| 5    | `InvalidDestination` - Destination path invalid or inaccessible |

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
````

Holds user input from external programs for repository URL and clone path.

#### `PathLinkStruct_t`

```zig
const PathLinkStruct_t = struct {
    GitPath: []const u8,        // Path to Git executable
    UrlLink: []const u8,        // Repository URL
    DestinationPath: []const u8 // Local clone destination
};
```

Internal structure used to store paths and links for cloning.

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

* Clones the full Git repository to the destination path.
* Returns `ProjectError_t.Success` on success.

---

#### `CloneDevRepo`

```zig
pub fn CloneDevRepo() callconv(.C) u32
```

* Clones only the `dev` branch of the repository.
* Returns `ProjectError_t.Success` on success.

---

## Build Instructions

### Prerequisites

* Zig compiler (>= 0.12)
* Git installed and available on system PATH

---

### Building for Linux x86\_64

```zig
const std = @import("std");
const bld = @import("buld_setup.zig");


pub fn build(b: *std.Build) void {

    bld.Linnux_X86_64(b);
}
```

* Produces `libproj_gen_linux_x86_64.so`
* Library version: `1.2.3`

### Building for Linux aarch64

```zig
const std = @import("std");
const bld = @import("buld_setup.zig");


pub fn build(b: *std.Build) void {

    bld.LinnuxAarch64(b);
}
```

* Produces `libproj_gen_linux_aarch64.so`

### Building for Windows x86\_64

```zig
const std = @import("std");
const bld = @import("buld_setup.zig");


pub fn build(b: *std.Build) void {

    bld.Windows_X86_64(b);
}
```

* Produces `proj_gen_windows_x86_64.dll`

### Building for Windows aarch64

```zig
const std = @import("std");
const bld = @import("buld_setup.zig");


pub fn build(b: *std.Build) void {

    bld.WindowsAarch64(b);
}
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
* Ensure the Git path in `PathLinkStruct_t` matches your system.

---

## Versioning

* Current version: **1.2.3**
* Follows semantic versioning: `MAJOR.MINOR.PATCH`

---

## License

GPL 3.0 [LICENCE](/LICENCE)

---

## Notes

* All public functions are exported with **strong linkage** for FFI.
* Suitable for embedding in other languages or RTOS project scripts.
* Can be extended for additional branches or repository operations.

```
