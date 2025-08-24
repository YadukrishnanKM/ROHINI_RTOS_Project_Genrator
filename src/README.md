# Zig Git Repository Downloader

A lightweight Zig library for downloading Git repository archives (tarballs) from GitHub. It provides functions to clone the `main` or `dev` branch of a repository to a local destination path. Written in Zig 0.14.x with C-callable exports for easy integration.

---

## Table of Contents

* [Features](#features)
* [Installation](#installation)
* [Usage](#usage)
* [API Reference](#api-reference)
* [Error Handling](#error-handling)
* [Implementation Details](#implementation-details)
* [License](/LICENCE)

---

## Features

* Initialize with user-specified repository URL and destination path.
* Clone `main` or `dev` branch of a GitHub repository.
* Pure Zig implementation, no external dependencies.
* C-callable interface for interoperability with other languages.
* Handles network and file write errors gracefully.

---

## Installation

Clone this repository and build with Zig:

```bash
git clone https://github.com/yourusername/zig-git-downloader.git
cd zig-git-downloader
zig build-lib src/main.zig -dynamic -OReleaseSafe -target x86_64-linux
```

This will generate a shared library (`.so`/`.dll`) depending on your platform.

---

## Usage

### Initialize with user input

```zig
const UserInputStruct_t = extern struct {
    GitRepoUrl: [*]const u8,
    GitRepoUrlLen: u32,
    CloneDestinationPath: [*]const u8,
    CloneDestinationPathLen: u8,
};

var input = UserInputStruct_t{
    .GitRepoUrl = "https://github.com/username/repo",
    .GitRepoUrlLen = 29,
    .CloneDestinationPath = "./local_repo",
    .CloneDestinationPathLen = 11,
};

const result = init(input);
if (result != @intFromEnum(ProjectError_t.Success)) {
    // Handle initialization error
}
```

### Clone repository

```zig
const clone_result = CloneRepo(); // Clones main branch
const clone_dev_result = CloneDevRepo(); // Clones dev branch
```

---

## API Reference

### `init(UsrInput: UserInputStruct_t) u32`

Initializes the global `PathAndLink` struct with user-provided Git URL and destination path.

* **Parameters**:

  * `UsrInput`: User input struct containing URL and destination path.
* **Returns**:

  * `ProjectError_t.Success` on success.
  * `ProjectError_t.LengthTooShort` if URL or path is too short.

---

### `CloneRepo() u32`

Downloads the `main` branch tarball of the initialized repository to the destination path.

* **Returns**:

  * `ProjectError_t.Success` on success.
  * `ProjectError_t.InvalidUrl` if the URL is invalid.
  * `ProjectError_t.NetworkError` if the network request fails.
  * `ProjectError_t.FileWriteError` if writing to file fails.

---

### `CloneDevRepo() u32`

Downloads the `dev` branch tarball of the initialized repository to the destination path.

* **Returns**: Same as `CloneRepo`.

---

## Error Handling

The library uses `ProjectError_t` for standardized error codes:

| Error                | Description                        |
| -------------------- | ---------------------------------- |
| `Success`            | Operation succeeded                |
| `zeroLength`         | Received an empty string           |
| `IndexOutOfBounds`   | Array or slice index out of bounds |
| `InvalidUrl`         | URL is invalid                     |
| `LengthTooShort`     | URL or path length below minimum   |
| `InvalidDestination` | Destination path invalid           |
| `NetworkError`       | HTTP request failed                |
| `FileWriteError`     | Failed to write file               |

---

## Implementation Details

* Uses Zig's `std.http.Client` and `std.Uri` to download repository tarballs.
* Writes HTTP response directly to a local file.
* Handles mutable buffers using slices (`[]u8`) for `server_header_buffer` and temporary allocations.
* C-callable functions (`pub export`) allow integration with C, C++, or other FFI-capable languages.

---

## License

GPL 3.0 License – see [LICENSE](/LICENCE) for details.

---

This README covers usage, API, error handling, and implementation notes, making it suitable for documentation or GitHub repository display.

