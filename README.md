# Rohini RTOS Project Generator – Python ABI (Pre-release)

This repository provides a **Python ABI (ctypes wrapper)** around the **Zig-based shared library** for the Rohini RTOS Project Generator.
It enables Python applications to interact with the Zig backend via a clean, object-oriented API.

---

## 📌 Features

* Python wrapper around `libproj_gen_linux_x86_64.so`
* High-level abstraction class `ZigProjectGenerator`
* Encapsulates all ctypes details for:

  * **Project initialization** with Git repository and clone path
  * **Log server initialization** on a given port
  * **Network connection checks**
  * **Repository URL validation**
  * **Starting a TCP server** (returns socket file descriptor)

---

## 📂 Project Structure

```
RPG_ABI.py             # Python ABI wrapper (ctypes + OOP class)
lib/libproj_gen_linux_x86_64.so   # Zig compiled shared library (Linux x86_64)
```

---

## ⚡ Installation

1. Clone this repository and ensure you have the Zig shared library compiled:

   ```bash
   zig build
   ```

2. Install Python dependencies (if packaging):

   ```bash
   pip install wheel setuptools
   ```

---

## 🛠 Usage

```python
from RPG_ABI import client

# 1. Initialize with a Git repo URL and destination path
res = client.init(
    git_repo_url="https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git",
    clone_destination_path="/tmp/rohini_project"
)
print("Init result:", res)

# 2. Start log server on port 8080
log_port = client.init_log_server(8080)
print("Log server started on port:", log_port)

# 3. Check network connection
print("Check connection:", client.check_connection())

# 4. Validate Git repository URL
print("Validate URL:", client.validate_url())

# 5. Start TCP server and get socket fd
sock_fd = client.start_server(9090)
print("Server socket FD:", sock_fd)
```

---

## 📜 API Reference

### `init(git_repo_url: str, clone_destination_path: str) -> int`

Initializes the project generator with repository URL and clone path.

### `init_log_server(port: int) -> int`

Starts the log server on the given port.

### `check_connection() -> int`

Checks the system’s network connection status.

### `validate_url() -> int`

Validates the repository URL passed to `init`.

### `start_server(port: int) -> int`

Starts a TCP server on the given port. Returns the **socket file descriptor**.

---

## ⚠️ Notes

* This is a **pre-release** version intended for Linux (x86\_64).
* The `.so` must be present at `./lib/libproj_gen_linux_x86_64.so`.
* Closing sockets should be done with `socket.close(fd)` instead of `os.close(fd)` to avoid descriptor issues.

---

## 📌 License

GPL 3.0 License – © 2025 \[K M Yadukrishnan]