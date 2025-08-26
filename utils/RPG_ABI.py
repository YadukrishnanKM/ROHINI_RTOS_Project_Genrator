import ctypes
import os
import socket


#"./lib/libproj_gen_linux_x86_64.so"

if os.name == "nt":
    libname = "./lib/libproj_gen_linux_x86_64.so"
else:
    libname = "./lib/libproj_gen_linux_x86_64.so"

rpg_lib = ctypes.CDLL(libname)

# ------------------------------
# Structures
# ------------------------------
class UserInputStruct(ctypes.Structure):
    _fields_ = [
        ("GitRepoUrl", ctypes.c_char_p),
        ("GitRepoUrlLen", ctypes.c_uint32),
        ("CloneDestinationPath", ctypes.c_char_p),
        ("CloneDestinationPathLen", ctypes.c_uint8),
    ]

class RepoUrlCheckStruct(ctypes.Structure):
    _fields_ = [
        ("Url", ctypes.c_char_p),
        ("length", ctypes.c_uint32),
    ]

class PathDirStruct(ctypes.Structure):
    _fields_ = [
        ("Path", ctypes.c_char_p),
        ("length", ctypes.c_uint32),
    ]

class ServerStruct(ctypes.Structure):
    _fields_ = [
        ("server", ctypes.c_void_p),
        ("port", ctypes.c_uint32),
        ("err_val", ctypes.c_uint32),
    ]

# ------------------------------
# Function bindings
# ------------------------------
init = rpg_lib.init
init.argtypes = [UserInputStruct]
init.restype = ctypes.c_uint32

CheckConnection = rpg_lib.CheckConnection
CheckConnection.argtypes = []
CheckConnection.restype = ctypes.c_uint32

ValidateURL = rpg_lib.ValidateURL
ValidateURL.argtypes = [RepoUrlCheckStruct]
ValidateURL.restype = ctypes.c_uint32

DirExists = rpg_lib.DirExists
DirExists.argtypes = [PathDirStruct]
DirExists.restype = ctypes.c_uint32

MakeDir = rpg_lib.MakeDir
MakeDir.argtypes = [PathDirStruct]
MakeDir.restype = ctypes.c_uint32

InitLogServer = rpg_lib.InitLogServer
InitLogServer.argtypes = [ctypes.c_uint16]
InitLogServer.restype = ServerStruct

# ------------------------------
# Additional Python helpers
# ------------------------------

def check_server(host="127.0.0.1", port=8080, timeout=2):
    """Attempt TCP connection to check if server is running."""
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except (ConnectionRefusedError, socket.timeout):
        return False

def stream_log_example(server_struct, message: str):
    """Send log message to the server (example, requires StreamLog support)."""
    # Currently a placeholder, since StreamLog is not exposed via FFI.
    print(f"[LOG] Would send to server port {server_struct.port}: {message}")
