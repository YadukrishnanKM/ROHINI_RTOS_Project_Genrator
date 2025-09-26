Here’s a README for your **Zig File Read/Write Dynamic Library**, following the style and structure of your provided example:

---

# Zig File Read/Write Dynamic Library (v2.1.0)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](../LICENCE)

A cross-platform Zig dynamic library for **file creation, existence checking, appending, and emptying**.
All functions are **C-callable** and can be easily integrated into projects using **FFI**.

<p align="center">
  <img src="../RTOS.png" alt="Logo" width="400"/>
</p>

---

## Features

* **Cross-platform dynamic library**: Compatible with Linux and Windows.
* **Simple file handling**: Create, check, append to, and clear files.
* **C-compatible API**: All exported functions use `callconv(.C)` for FFI compatibility.
* **Structured error handling**: Uses `FileError` enum for consistent return codes.
* **Lightweight and efficient**: Ideal for embedding in other applications.

---

## Usable Enums

### `FileError`

| Code              | Meaning                                            |
| ----------------- | -------------------------------------------------- |
| `Sucess`          | Operation completed successfully                   |
| `UnableToOpen`    | File could not be opened for writing or truncation |
| `EmptyFile`       | File is empty or data provided is empty            |
| `CreateFileError` | Failed to create a new file                        |
| `FileNotExist`    | File not found at the given path                   |

**Usage:**
Every function returns a `u32` code corresponding to a value from `FileError`.

---

## Usable Structures

| Struct     | Description                                                                                                                                    |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| `FileData` | Holds the file path and its length. Fields:<br>• `Path: [*]const u8` — pointer to file path string<br>• `PathLenght: u16` — path string length |
| `Data`     | Holds data to write or append. Fields:<br>• `data: [*]const u8` — pointer to data buffer<br>• `DataLenght: u16` — data length                  |

---

## Functions Overview

### Create File

```zig
pub export fn CreateFile(Fd: FileData) callconv(.C) u32
```

* Creates a new empty file at the specified path.
* Returns `FileError.Sucess` on success or an error code if creation fails.

---

### Check File Existence

```zig
pub export fn CheckFileExists(Fd: FileData) callconv(.C) u32
```

* Checks if a file exists at the specified path.
* Returns `FileError.Sucess` if file exists or `FileError.FileNotExist` otherwise.

---

### Append Data to File

```zig
pub export fn AppendToFile(Fd: FileData, data: Data) callconv(.C) u32
```

* Opens a file in write-only mode and appends provided data.
* Returns `FileError.Sucess` if data is successfully written.

---

### Empty a File

```zig
pub export fn EmptyFile(Fd: FileData) callconv(.C) u32
```

* Opens a file in write-only mode and truncates its content to zero length.
* Returns `FileError.Sucess` on success.

---

## Build Instructions

### Build with `zig build`

Default target (Linux x86_64):

```bash
zig build
```

### Build for Specific Targets

```bash
zig build -Dtarget=x86_64-linux    # Linux x86_64
zig build -Dtarget=aarch64-linux   # Linux aarch64
zig build -Dtarget=x86_64-windows  # Windows x86_64
zig build -Dtarget=aarch64-windows # Windows aarch64
```

**Artifacts Produced:**

| Target          | Output Library                |
| --------------- | ----------------------------- |
| Linux x86_64    | `libfileops_linux_x86_64.so`  |
| Linux aarch64   | `libfileops_linux_aarch64.so` |
| Windows x86_64  | `fileops_windows_x86_64.dll`  |
| Windows aarch64 | `fileops_windows_aarch64.dll` |

---

## Example Usage in C

```c
#include "fileops.h"

int main() {
    FileData fd = {
        .Path = "test.txt",
        .PathLenght = 9
    };

    if (CreateFile(fd) != 0) return -1;

    if (CheckFileExists(fd) != 0) return -1;

    Data d = {
        .data = "Hello World!\n",
        .DataLenght = 13
    };

    if (AppendToFile(fd, d) != 0) return -1;

    if (EmptyFile(fd) != 0) return -1;

    return 0;
}
```

---

## Versioning

* Current version: **2.2.0**
* Semantic versioning: `MAJOR.MINOR.PATCH`

### Changelog (v2.2.0)

* Initial release of **File Read/Write Dynamic Library**.
* Added support for:

  * File creation
  * File existence checking
  * File appending
  * File emptying
* Implemented `FileError` enum for structured error handling.
* Ensured all functions are **C-callable** for seamless FFI usage.

---

## License

GPL 3.0 [LICENSE](../LICENCE)