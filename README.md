
# Rohini RTOS Project Generator – Zig Dynamic Library (v2.1.0)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](./LICENSE)

A **Zig-based cross-platform dynamic library** for generating ready-to-use **RTOS project scaffolds**.
Designed for embedded developers who want to quickly bootstrap structured RTOS-based applications.

<p align="center">
  <img src="./RTOS.png" alt="Rohini RTOS Project Generator" width="400"/>
</p>

---

## ✨ Features

* **Cross-platform dynamic library** – build for Linux and Windows as `.so` or `.dll`.
* **RTOS project generator** – creates consistent directory trees and boilerplate source files.
* **Configurable templates** – choose project name, RTOS kernel, and optional modules.
* **C-compatible API** – all exported functions use `callconv(.C)` for smooth FFI.
* **Structured error handling** – simple enum-based codes for robust integration.
* **Lightweight and fast** – minimal dependencies, ideal for build tools and scripting.

---

## 🚀 Build Instructions

Requires **Zig ≥ 0.13.0**

### Default build (Linux x86_64)

```bash
zig build
```

### Cross-compiling for other targets

```bash
zig build -Dtarget=x86_64-linux    # Linux x86_64
zig build -Dtarget=aarch64-linux   # Linux aarch64
zig build -Dtarget=x86_64-windows  # Windows x86_64
zig build -Dtarget=aarch64-windows # Windows aarch64
```

**Artifacts Produced:**

| Target          | Output Library                        |
| --------------- | ------------------------------------- |
| Linux x86_64    | `librohini_rtos_gen_linux_x86_64.so`  |
| Linux aarch64   | `librohini_rtos_gen_linux_aarch64.so` |
| Windows x86_64  | `rohini_rtos_gen_windows_x86_64.dll`  |
| Windows aarch64 | `rohini_rtos_gen_windows_aarch64.dll` |

---

## 📦 Example Usage in C

```c
#include "rohini_rtos_gen.h"
#include <stdio.h>

int main() {
    // Create a new RTOS project scaffold
    int res = CreateRTOSProject("MyProject", "FreeRTOS");
    if (res != 0) {
        printf("Project creation failed with code %d\n", res);
        return -1;
    }

    printf("RTOS project created successfully!\n");
    return 0;
}
```

---

## 📦 Example Usage in Python (via `ctypes`)

```python
import ctypes

# Load the library
lib = ctypes.CDLL("./librohini_rtos_gen_linux_x86_64.so")

# Define the function signature
lib.CreateRTOSProject.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
lib.CreateRTOSProject.restype = ctypes.c_int

# Create a project
res = lib.CreateRTOSProject(b"MyProject", b"FreeRTOS")
if res == 0:
    print("RTOS project created successfully!")
else:
    print(f"Failed with error code {res}")
```

---

## 🧩 Versioning

* Current version: **2.1.0**
* Semantic versioning: `MAJOR.MINOR.PATCH`

### Changelog (v2.1.0)

* Added support for multiple RTOS kernels.
* Improved project scaffolding with cleaner directory layout.
* Added robust enum-based error handling.
* Optimized for use in CI/CD pipelines and build tools.

---

## 📜 License

GPL 3.0 [LICENSE](./LICENSE)
