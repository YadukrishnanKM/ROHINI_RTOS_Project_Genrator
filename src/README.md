# Zig Git Clone Dynamic Library

A small Zig dynamic library providing C-compatible functions for cloning Git repositories.  
It supports full repository cloning as well as cloning specific branches (e.g., `dev`) with user-provided inputs.

---

## Features

- Clone a Git repository to a specified local path.
- Clone a specific branch (`dev`) from a repository.
- C-compatible interface for integration with other languages.
- Returns standardized error codes for easy error handling.

---

## Error Codes

All functions return a `u32` representing a `ProjectError_t`:

| Code | Meaning |
|------|---------|
| 0    | `Success` - Operation completed successfully |
| 1    | `zeroLength` - Input length was zero |
| 2    | `IndexOutOfBounds` - Index exceeded valid bounds |
| 3    | `InvalidUrl` - URL provided was invalid or malformed |
| 4    | `LengthTooShort` - Input string length was too short |
| 5    | `InvalidDestination` - Destination path invalid or inaccessible |

---

## Data Structures

### `UserInputStruct_t`

Represents user input from external code:

```zig
const UserInputStruct_t = extern struct {
    GitRepoUrl: [*]const u8,
    GitRepoUrlLen: u32,
    CloneDestinationPath: [*]const u8,
    CloneDestinationPathLen: u8,
};
````

### `PathLinkStruct_t`

Internal struct used to hold paths and links:

```zig
const PathLinkStruct_t = struct {
    GitPath: []const u8,        // Path to Git executable
    UrlLink: []const u8,        // Repository URL
    DestinationPath: []const u8 // Local clone destination
};
```

---

## Functions

### `init`

Initializes repository URL and destination path.

```zig
pub fn init(UsrInput: UserInputStruct_t) callconv(.C) u32
```

* Validates the lengths of input strings.
* Returns `ProjectError_t.Success` on success or `LengthTooShort` if inputs are too short.

---

### `CloneRepo`

Clones the full Git repository.

```zig
pub fn CloneRepo() callconv(.C) u32
```

* Uses the initialized URL and destination path.
* Returns `ProjectError_t.Success` on success.

---

### `CloneDevRepo`

Clones the `dev` branch of the repository.

```zig
pub fn CloneDevRepo() callconv(.C) u32
```

* Uses the initialized URL and destination path.
* Returns `ProjectError_t.Success` on success.

---

## Example Usage (C)

```c
#include "zig_git_clone.h"

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

---


