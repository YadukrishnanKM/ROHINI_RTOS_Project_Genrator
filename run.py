import os
from utils.RPG_ABI import client

# -----------------------------
# 1. Test init function
# -----------------------------
git_url = "https://github.com/YadukrishnanKM/Rohini_RTOS-RP2040.git"
clone_path = "/tmp/clone_test"

print("--- Testing init ---")
res = client.init(git_url, clone_path)
print("init result:", res)
print("-" * 20)

# -----------------------------
# 2. Test InitLogServer
# -----------------------------
print("--- Testing InitLogServer ---")
port = 8080
res_port = client.init_log_server(port)
print("InitLogServer returned port:", res_port)
print("-" * 20)

# -----------------------------
# 3. Test CheckConnection
# -----------------------------
print("--- Testing CheckConnection ---")
res_conn = client.check_connection()
print("CheckConnection result:", res_conn)
print("-" * 20)

# -----------------------------
# 4. Test ValidateURL
# -----------------------------
print("--- Testing ValidateURL ---")
res_url = client.validate_url()
print("ValidateURL result:", res_url)
print("-" * 20)

# -----------------------------
# 5. Test startServer
# -----------------------------
print("--- Testing startServer ---")
sock_fd = client.start_server(9090)
print("startServer returned sock fd:", sock_fd)

# If the function returned a valid socket file descriptor, close it
if sock_fd > 0:
    print("Attempting to close test server socket...")
    try:
        os.close(sock_fd)
        print("Closed test server socket successfully.")
    except OSError as e:
        print(f"Error closing socket: {e}")

print("-" * 20)