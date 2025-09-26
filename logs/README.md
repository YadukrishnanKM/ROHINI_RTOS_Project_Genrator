# Zig CSV Log File Dynamic Library (v2.1.0)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](../LICENSE)

A cross-platform Zig dynamic library for **creating, checking, appending to, initializing, and emptying CSV log files**.
All functions are **C-callable** and designed for easy integration with other languages through **FFI**.

<p align="center">
  <img src="../RTOS.png" alt="Logo" width="400"/>
</p>

---

## Features

* **Cross-platform dynamic library**: Works on Linux and Windows.
* **CSV-specific utilities**: Initializes CSV files with headers, appends log entries, and clears content.
* **C-compatible API**: All exported functions use `callconv(.C)` for seamless FFI usage.
* **Structured error handling**: Returns consistent error codes via the `FileError` enum.
* **Lightweight and efficient**: Suitable for embedded logging applications.

---

## Usable Enums

### `FileError`

| Code              | Meaning                                             |
| ----------------- | --------------------------------------------------- |
| `Sucess`          | Operation completed successfully                    |
| `UnableToOpen`    | File could not be opened for writing or truncation  |
| `EmptyFile`       | File is empty or no data provided                   |
| `CreateFileError` | Failed to create a new file                         |
| `FileNotExist`    | File not found at the given path                    |
| `CSVFileExists`   | CSV file already exists (not an error, informative) |

**Usage:**
All exported functions return a `u32` code corresponding to a value from `FileError`.

---

## Usable Structures

| Struct     | Description                                                                                                                                   |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `FileData` | Holds the file path and its length.<br>• `Path: [*]const u8` — pointer to file path string<br>• `PathLenght: u16` — length of the path string |
| `Data`     | Holds data to be appended.<br>• `data: [*]const u8` — pointer to data buffer<br>• `DataLenght: u16` — length of the data buffer               |

---

## Functions Overview

### Initialize CSV File (First Time)

```zig
pub export fn initFirstTime(Fd: FileData) callconv(.C) u32
```

* Checks if the CSV file exists at the given path.
* If not, creates a new file and appends a default CSV header:

  ```
  Time,day,month,year,log_data
  ```
* Returns `FileError.Sucess` on success or an appropriate error code on failure.

---

### Create CSV File

```zig
pub export fn CreateCSVFile(Fd: FileData) callconv(.C) u32
```

* Creates a new empty CSV file at the specified path.
* Returns `FileError.Sucess` on success or `FileError.CreateFileError` if creation fails.

---

### Check File Existence

```zig
pub export fn CheckFileExists(Fd: FileData) callconv(.C) u32
```

* Checks if a file exists at the specified path.
* Returns `FileError.Sucess` if the file exists or `FileError.FileNotExist` otherwise.

---

### Append Data to CSV File

```zig
pub export fn AppendToCSV(Fd: FileData, data: Data) callconv(.C) u32
```

* Appends a new log entry or data row to the CSV file.
* Returns `FileError.Sucess` on success or an error code if appending fails.

---

### Empty CSV File

```zig
pub export fn EmptyFile(Fd: FileData) callconv(.C) u32
```

* Truncates the file content, effectively clearing all data.
* Returns `FileError.Sucess` on success or an error code if the file cannot be opened.

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

| Target          | Output Library               |
| --------------- | ---------------------------- |
| Linux x86_64    | `libcsvlog_linux_x86_64.so`  |
| Linux aarch64   | `libcsvlog_linux_aarch64.so` |
| Windows x86_64  | `csvlog_windows_x86_64.dll`  |
| Windows aarch64 | `csvlog_windows_aarch64.dll` |

---

## Example Usage in C

```c
#include "csvlog.h"

int main() {
    FileData fd = {
        .Path = "log.csv",
        .PathLenght = 8
    };

    // Initialize CSV file with header if it doesn't exist
    if (initFirstTime(fd) != 0) return -1;

    // Append a log entry
    Data log_entry = {
        .data = "12:00,26,09,2025,Temperature=30C\n",
        .DataLenght = 33
    };

    if (AppendToCSV(fd, log_entry) != 0) return -1;

    // Optionally clear the file
    // if (EmptyFile(fd) != 0) return -1;

    return 0;
}
```

---

## Versioning

* Current version: **2.1.0**
* Semantic versioning: `MAJOR.MINOR.PATCH`

### Changelog (v2.1.0)

* Initial release of **CSV Log File Dynamic Library**.
* Added:

  * Automatic CSV file creation with header via `initFirstTime`.
  * Functions to append log entries and clear CSV files.
* Integrated consistent error handling via `FileError` enum.
* All functions exported with `callconv(.C)` for easy FFI integration.

---

## License

GPL 3.0 [LICENSE](../LICENSE)
