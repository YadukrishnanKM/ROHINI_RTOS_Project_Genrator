import ctypes
import os

# Path to the compiled Zig shared library
LIB_PATH = "./lib/libproj_gen_linux_x86_64.so" 

# Define the structure equivalent to Zig's UserInputStruct_t
class UserInputStruct_t(ctypes.Structure):
    _fields_ = [
        ("GitRepoUrl", ctypes.c_char_p),
        ("GitRepoUrlLen", ctypes.c_uint32),
        ("CloneDestinationPath", ctypes.c_char_p),
        ("CloneDestinationPathLen", ctypes.c_uint8),
    ]

# The high-level abstraction class
class ZigProjectGenerator:
    """
    A high-level abstraction for the Zig shared library.
    Encapsulates all ctypes interactions.
    """
    def __init__(self):
        # Check if the library file exists before loading
        if not os.path.exists(LIB_PATH):
            raise FileNotFoundError(f"Shared library not found at: {LIB_PATH}")

        # Load the shared library
        self._lib = ctypes.CDLL(LIB_PATH)
        self._define_function_prototypes()

    def _define_function_prototypes(self):
        """
        Defines the argument and return types for the C functions.
        This provides better type safety.
        """
        self._lib.init.argtypes = [UserInputStruct_t]
        self._lib.init.restype = ctypes.c_uint32

        self._lib.InitLogServer.argtypes = [ctypes.c_uint32]
        self._lib.InitLogServer.restype = ctypes.c_uint32

        # FIX: Correctly specify a function with no arguments using an empty list
        self._lib.CheckConnection.argtypes = []
        self._lib.CheckConnection.restype = ctypes.c_uint32

        self._lib.ValidateURL.argtypes = []
        self._lib.ValidateURL.restype = ctypes.c_uint32

        self._lib.startServer.argtypes = [ctypes.c_uint32]
        self._lib.startServer.restype = ctypes.c_uint32
    
    def init(self, git_repo_url: str, clone_destination_path: str) -> int:
        """Initializes the project generator with URL and path."""
        git_url_bytes = git_repo_url.encode('utf-8')
        clone_path_bytes = clone_destination_path.encode('utf-8')
        
        user_input = UserInputStruct_t(
            GitRepoUrl=git_url_bytes,
            GitRepoUrlLen=len(git_url_bytes),
            CloneDestinationPath=clone_path_bytes,
            CloneDestinationPathLen=len(clone_path_bytes)
        )
        return self._lib.init(user_input)

    def init_log_server(self, port: int) -> int:
        """Initializes the log server on the specified port."""
        return self._lib.InitLogServer(port)

    def check_connection(self) -> int:
        """Checks the network connection."""
        return self._lib.CheckConnection()

    def validate_url(self) -> int:
        """Validates the Git repository URL."""
        return self._lib.ValidateURL()

    def start_server(self, port: int) -> int:
        """Starts a TCP server and returns its socket file descriptor."""
        return self._lib.startServer(port)

# Create a single instance of the class for other modules to import
client = ZigProjectGenerator()