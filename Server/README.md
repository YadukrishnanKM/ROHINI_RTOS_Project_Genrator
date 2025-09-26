# Golang TCP Stream Server Dynamic Library (v2.1.0)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](../LICENSE)

A cross-platform **Golang dynamic library** for running a simple **TCP streaming server at `localhost`**.
The server streams a user-defined message periodically to all connected clients.
All functions are **C-callable** for easy integration with C, Python, Zig, Rust, and other FFI-capable languages.

<p align="center">
  <img src="../RTOS.png" alt="Logo" width="400"/>
</p>

---

## Features

* **Cross-platform dynamic library** — build as `.so` (Linux) or `.dll` (Windows).
* **TCP streaming server** that periodically sends a user-defined message to connected clients.
* **C-compatible API** — exported with `cgo` for easy use in other languages.
* **Structured error handling** — consistent error codes for robust integration.
* **Thread-safe** — supports concurrent connections.
* **Configurable port and message** — both can be set at runtime.

---

## Usable Enums

### Error Codes

| Code                   | Meaning                                 |
| ---------------------- | --------------------------------------- |
| `ERR_SUCCESS`          | Operation completed successfully        |
| `ERR_ALREADY_RUNNING`  | Server is already running               |
| `ERR_NOT_RUNNING`      | Server is not running                   |
| `ERR_ADDR_IN_USE`      | Selected port/address is already in use |
| `ERR_INVALID_PORT`     | Invalid port number (must be 1–65535)   |
| `ERR_INTERNAL`         | Internal error occurred                 |
| `ERR_INVALID_ARGUMENT` | Invalid argument passed to a function   |

---

### Status Codes

| Code             | Meaning                 |
| ---------------- | ----------------------- |
| `STATUS_STOPPED` | Server is currently off |
| `STATUS_RUNNING` | Server is running       |

---

## Core Concepts

The server runs on `localhost:<port>` and streams the configured message to each connected client **once per second**.
The port and message can be changed using the provided API.

The library exposes the following global functions to manage the server’s lifecycle.

---

## Functions Overview

### Start the Server

```go
//export StartServer
func StartServer(port C.int, cmsg *C.char) C.int
```

* Starts the server at the given port.
* Optionally sets the initial message to be streamed.
* Returns `ERR_SUCCESS` on success or an error code otherwise.

---

### Stop the Server

```go
//export StopServer
func StopServer() C.int
```

* Stops the server, closes all active connections, and releases resources.
* Returns `ERR_SUCCESS` on success or `ERR_NOT_RUNNING` if the server was already stopped.

---

### Set the Streamed Message

```go
//export SetMessage
func SetMessage(cmsg *C.char) C.int
```

* Updates the message that will be streamed to clients.
* Safe to call even when the server is running.
* Returns `ERR_SUCCESS` or `ERR_INVALID_ARGUMENT` if `cmsg` is `NULL`.

---

### Set the Port

```go
//export SetPort
func SetPort(port C.int) C.int
```

* Sets the TCP port for the server.
* Can only be changed when the server is stopped.
* Returns `ERR_SUCCESS` or `ERR_INVALID_PORT`.

---

### Get Server Status

```go
//export GetStatus
func GetStatus() C.int
```

* Returns the current server status:

  * `STATUS_RUNNING`
  * `STATUS_STOPPED`

---

### Get Last Error

```go
//export LastErrorCode
func LastErrorCode() C.int

//export LastErrorMessage
func LastErrorMessage() *C.char

//export FreeCString
func FreeCString(ptr *C.char)
```

* `LastErrorCode` returns the last error as an error-code enum.
* `LastErrorMessage` returns a dynamically allocated error message string.
* The caller must call `FreeCString` after using the returned string to avoid memory leaks.

---

## Build Instructions

Ensure you have Go ≥1.21 installed.

### Linux (shared library)

```bash
go build -o libtcpserver.so -buildmode=c-shared main.go
```

### Windows (DLL)

```powershell
go build -o tcpserver.dll -buildmode=c-shared main.go
```

**Artifacts Produced:**

| Platform     | Library File      | Header File      |
| ------------ | ----------------- | ---------------- |
| Linux x86_64 | `libtcpserver.so` | `libtcpserver.h` |
| Windows x86  | `tcpserver.dll`   | `tcpserver.h`    |

---

## Example Usage in C

```c
#include "libtcpserver.h"
#include <stdio.h>

int main() {
    // Start the server on port 9090 with an initial message
    if (StartServer(9090, "Hello from Golang TCP Server!") != ERR_SUCCESS) {
        printf("Error: %s\n", LastErrorMessage());
        return -1;
    }

    printf("Server started on port 9090\n");

    // Update the message
    SetMessage("Updated streaming message!");

    // Stop the server after some time
    // ...
    if (StopServer() != ERR_SUCCESS) {
        printf("Error stopping server: %s\n", LastErrorMessage());
        return -1;
    }

    printf("Server stopped successfully\n");
    return 0;
}
```

---

## Example Usage in Python (via `ctypes`)

```python
import ctypes
import time

# Load the shared library
lib = ctypes.CDLL("./libtcpserver.so")

# Define argument and return types
lib.StartServer.argtypes = [ctypes.c_int, ctypes.c_char_p]
lib.StartServer.restype = ctypes.c_int

lib.StopServer.restype = ctypes.c_int
lib.SetMessage.argtypes = [ctypes.c_char_p]
lib.SetMessage.restype = ctypes.c_int

# Start the server
res = lib.StartServer(9090, b"Hello, Python World!")
if res != 0:
    print("Failed to start server")
else:
    print("Server is running on port 9090")

# Change the message
lib.SetMessage(b"New message from Python")

# Let it run for 5 seconds
time.sleep(5)

# Stop the server
lib.StopServer()
print("Server stopped")
```

---

## Versioning

* Current version: **2.1.0**
* Semantic versioning: `MAJOR.MINOR.PATCH`

### Changelog (v2.1.0)

* Added configurable port and dynamic message streaming.
* Implemented structured error handling with enums.
* Added thread-safe server lifecycle management.
* Exposed `LastErrorMessage` and `FreeCString` for better debugging in FFI clients.

---

## License

GPL 3.0 [LICENSE](../LICENSE)

